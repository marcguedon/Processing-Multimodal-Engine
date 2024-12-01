/* autogenerated by Processing revision 1293 on 2024-12-01 */
import processing.core.*;
import processing.data.*;
import processing.event.*;
import processing.opengl.*;

import fr.dgac.ivy.*;
import fr.dgac.ivy.tools.*;
import gnu.getopt.*;

import java.util.Timer;
import java.util.TimerTask;
import java.awt.Point;
import fr.dgac.ivy.*;

import java.util.HashMap;
import java.util.ArrayList;
import java.io.File;
import java.io.BufferedReader;
import java.io.PrintWriter;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.IOException;

public class Palette extends PApplet {

/*
 * Palette Graphique - prélude au projet multimodal 3A SRI
 * 4 objets gérés : cercle, rectangle(carré), losange et triangle
 * (c) 05/11/2019
 * Dernière révision : 28/04/2020
 */






Ivy bus;

ArrayList<Forme> formes;
FSM mae;
int indice_forme;

final float seuil = 0.80f;
final int TIMER_DURATION = 5000;

int start_time = 0;
boolean timer_active = false;

String sra5_action = "";
String sra5_pointage = "";
String sra5_form = "";
String sra5_couleur = "";
String sra5_localisation = "";
String sra5_confidence = "";
String reco_form = "";

public void setup()
{
    /* size commented out by preprocessor */;
    surface.setResizable(true);
    surface.setTitle("Palette multimodale");
    surface.setLocation(20, 20);
    PImage sketch_icon = loadImage("Palette.jpg");
    surface.setIcon(sketch_icon);
    
    formes = new ArrayList();
    noStroke();
    mae = FSM.INITIAL;
    indice_forme = -1;
    
    try
    {
        bus = new Ivy("Palette", "Palette is ready", null);
        bus.start("127.255.255.255:2010");
        delay(1000);
        bus.sendMsg("sra5 -p on");

        bus.bindMsg("^sra5 Parsed=action=(.*) where=(.*) form=(.*) color=(.*) localisation=(.*) Confidence=(.*) NP=(.*) Num_A=(.*)", new IvyMessageListener()
        {
            public void receive(IvyClient client, String[] args)
            {
                sra5_action = args[0];
                sra5_pointage = args[1];
                sra5_form = args[2];
                sra5_couleur = args[3];
                sra5_localisation = args[4];
                sra5_confidence = args[5].replace(',', '.');
                
                if(PApplet.parseFloat(sra5_confidence) < seuil)
                    println("Répétez s'il vous plait");
                    
                else
                {
                    switch (sra5_action)
                    {
                        case "CREATE":
                            println("Ajout forme");
                            create_form();
                            mae = FSM.AFFICHER_FORMES;
                            
                            break;
                        
                        case "MOVE":
                            if(formes.isEmpty())
                            {
                                mae = FSM.AFFICHER_FORMES;
                                break;
                            }
                        
                            println("Déplacement forme");
                            mae = FSM.DEPLACER_FORMES_SELECTION;
                            start_timer();
                            
                            break;
                            
                        case "DELETE":
                            if(formes.isEmpty())
                            {
                                mae = FSM.AFFICHER_FORMES;
                                break;
                            }
    
                            if(sra5_pointage.equals("THIS"))
                            {
                                mae = FSM.SUPPRIMER_FORMES;
                            }
                        
                            else
                            {
                                delete_forms();
                            }
                            
                            println("Suppression forme");
                            start_timer();
                            break;
                        
                        case "QUIT":
                            println("Quitter");
                            exit();
                            break;
                    }
                }
        
                try
                {
                    bus.sendMsg("Palette Feedback=ok");
                }
                catch (IvyException ie) {}  
            }        
        });
        
        bus.bindMsg("^sra5 Event=(.*)", new IvyMessageListener()
        {
            public void receive(IvyClient client, String[] args)
            {
                if(args[0].equals("Speech_Rejected"))
                    println("Speech rejected");
                
                try
                {
                    bus.sendMsg("Palette Feedback=ok");
                }
                catch (IvyException ie) {}  
            }        
        });
        
        bus.bindMsg("^OneDollarIvy Template=(.*) Confidence=(.*)", new IvyMessageListener()
        {
            public void receive(IvyClient client, String[] args)
            {
                reco_form = args[0];    
                
                Timer timer = new Timer();
                timer.schedule(new TimerTask()
                {
                    @Override
                    public void run()
                    {
                        reco_form = null;
                    }
                }, TIMER_DURATION);
                
                try
                {
                    bus.sendMsg("OneDollarIvy Feedback=ok");
                }
                catch (IvyException ie) {}  
            }        
        });
    }
    catch (IvyException ie) {}
}

public void draw()
{
    background(0);
    
    if (timer_active && millis() - start_time >= TIMER_DURATION) {
        if(mae == FSM.DEPLACER_FORMES_DESTINATION || mae == FSM.DEPLACER_FORMES_SELECTION || mae == FSM.SUPPRIMER_FORMES)
        {
            mae = FSM.AFFICHER_FORMES;
            println("Action forme annulé");
        }
            
        timer_active = false;
    }
      
    switch (mae)
    {
        case INITIAL:  // Etat INITIAL
            background(255);
            fill(0);
            text("C(ercle), L(osange), R(ectangle) ou T(riangle) pour créer la forme correspondante à la position courante)", 25, 25);
            text("M(ove) puis click pour sélectionner un objet et click pour sa nouvelle position", 25, 45);
            text("D(elete) puis click pour supprimer un objet", 25, 65);
            break;
            
        case AFFICHER_FORMES:
            text("Creation d'une forme", 50, 140);
            
        case DEPLACER_FORMES_SELECTION:

        case DEPLACER_FORMES_DESTINATION: 
            affiche();
            break;
            
        case SUPPRIMER_FORMES:
            affiche();
            break;
            
        default:
            break;
    }  
}

public void affiche()
{
    background(255);
    
    for (int i = 0; i < formes.size(); i++)
        (formes.get(i)).update();
}

public void mousePressed()
{
    Point p = new Point(mouseX, mouseY);
      
    switch (mae)
    {
        case AFFICHER_FORMES:
            break;
            
        case DEPLACER_FORMES_SELECTION:
            for (int i = 0; i < formes.size(); i++)
            {      
                if (formes.get(i).isClicked(p))
                {
                    indice_forme = i;
                    mae = FSM.DEPLACER_FORMES_DESTINATION;
                    println("Forme sélectionnée");
                }         
            }
            
            if (indice_forme == -1)
                mae = FSM.AFFICHER_FORMES;
                
            start_timer();
            break;
            
        case DEPLACER_FORMES_DESTINATION:
            if (indice_forme != -1)
                formes.get(indice_forme).setLocation(new Point(mouseX, mouseY));
                
            indice_forme = -1;
            mae = FSM.AFFICHER_FORMES;
            break;
            
        case SUPPRIMER_FORMES:
            for (int i = 0; i < formes.size(); i++) {
                if ((formes.get(i)).isClicked(p))
                    formes.remove(i);
                    println("Suppresion forme sélectionnée");
            }
            mae = FSM.AFFICHER_FORMES;
            break;
            
        default:
            break;
    }
}

public void keyPressed()
{
    Point p = new Point(mouseX, mouseY);
      
    switch(key)
    {
        case 'r': // Rectangle
            formes.add(new Rectangle(p));
            
            println("Ajout rectangle");
            mae = FSM.AFFICHER_FORMES;
            break;
        case 'c': // Circle
            formes.add(new Cercle(p));
            
            println("Ajout cercle");
            mae = FSM.AFFICHER_FORMES;
            break;
        case 't': // Triangle
            formes.add(new Triangle(p));
            
            println("Ajout triangle");
            mae = FSM.AFFICHER_FORMES;
            break;  
        case 'l': // Diamond
            formes.add(new Losange(p));
            
            println("Ajout losange");
            mae = FSM.AFFICHER_FORMES;
            break;    
        case 'm': // Move
            if(formes.isEmpty())
                break;
        
            println("Déplacement forme");
            mae = FSM.DEPLACER_FORMES_SELECTION;
            
            start_timer();
            break;
        case 'd': // Delete
            if(formes.isEmpty())
                break;
                
            println("Suppression forme");
            mae = FSM.SUPPRIMER_FORMES;
            
            start_timer();
            break;
    }
}

public void start_timer()
{
    start_time = millis();
    timer_active = true;
}

public Point get_point_from_localisation_str(String localisation)
{
    if(localisation.equals("THERE"))
        return new Point(mouseX, mouseY);
        
    return new Point((int)random(0, width), (int)random(0, height));
}

public int get_color_from_color_str(String color_msg)
{
    switch (color_msg)
    {
        case "RED":
            return color(255, 0, 0);
        case "ORANGE":
            return color(255, 127, 0);
        case "YELLOW":
            return color(255, 255, 0);
        case "GREEN":
            return color(0, 255, 0);
        case "BLUE":
            return color(0, 0, 255);
        case "PURPLE":
            return color(127, 0, 255);
        case "DARK":
            return color(0, 0, 0);
        default:
            return color(127, 127, 127);
    }
}

public void create_form()
{
    Point pos = get_point_from_localisation_str(sra5_localisation);
    String form_str = sra5_pointage.equals("THIS") ? reco_form : sra5_form;
    Forme form = create_form_from_form_str(form_str, pos);
    
    if(form != null)
    {
        form.setColor(get_color_from_color_str(sra5_couleur));
        formes.add(form);
    }
}

public Forme create_form_from_form_str(String form, Point pos)
{        
    switch (form)
    {
        case "CIRCLE":
            return new Cercle(pos);
        case "cercle_d":
            return new Cercle(pos);
        case "cercle_g":
            return new Cercle(pos);
        case "circle":
            return new Cercle(pos);
        case "TRIANGLE":
            return new Triangle(pos);
        case "triangle":
            return new Triangle(pos);
        case "triangle_d":
            return new Triangle(pos);
        case "triangle_g":
            return new Triangle(pos);
        case "DIAMOND":
            return new Losange(pos);
        case "losange":
            return new Losange(pos);
        case "losange_d":
            return new Losange(pos);
        case "losange_g":
            return new Losange(pos);
        case "RECTANGLE":
            return new Rectangle(pos);
        case "rectangle":
            return new Rectangle(pos);
        case "rectangle_d":
            return new Rectangle(pos);
        case "rectangle_g":
            return new Rectangle(pos);
        default:
            return null;
    }
}

public void delete_forms()
{
   
    if (!sra5_couleur.equals("undefined") && !sra5_form.equals("undefined"))
    {
        println("Suppression par forme et couleur");
        delete_by_form_color(sra5_form, get_color_from_color_str(sra5_couleur));
    }
    
    else if (!sra5_form.equals("undefined"))
    {
        println("Suppression par forme");
        delete_by_form(sra5_form);
    }
    
    else if (!sra5_couleur.equals("undefined"))
    {
        println("Suppression par couleur");
        delete_by_color(get_color_from_color_str(sra5_couleur));
    }
}

public void delete_by_form_color(String form, int couleur)
{
    for (int i = formes.size() - 1; i >= 0; i--)
    {
        switch (form)
        {
            case "RECTANGLE":
                if (formes.get(i).getClass() == Rectangle.class && (formes.get(i)).getColor() == couleur)
                    formes.remove(i);
                break;
                
            case "CIRCLE":
                if (formes.get(i).getClass() == Cercle.class && (formes.get(i)).getColor() == couleur)
                    formes.remove(i);
                break;
                
            case "TRIANGLE":
                if (formes.get(i).getClass() == Triangle.class && (formes.get(i)).getColor() == couleur)
                    formes.remove(i);
                break;
                
            case "DIAMOND":
                if (formes.get(i).getClass() == Losange.class && (formes.get(i)).getColor() == couleur)
                    formes.remove(i);
                break;
        } 
    } 
}

public void delete_by_form(String form)
{
    for (int i = formes.size() - 1; i >= 0; i--)
    {
        switch (form)
        {
            case "RECTANGLE":
                if (formes.get(i).getClass() == Rectangle.class)
                    formes.remove(i);
                break;
                
            case "CIRCLE":
                if (formes.get(i).getClass() == Cercle.class)
                    formes.remove(i);
                break;
                
            case "TRIANGLE":
                if (formes.get(i).getClass() == Triangle.class)
                    formes.remove(i);
                break;
                
            case "DIAMOND":
                if (formes.get(i).getClass() == Losange.class)
                    formes.remove(i);
                break;
        } 
    } 
}

public void delete_by_color(int couleur)
{    
    for (int i = formes.size() - 1; i >= 0; i--)
    {
        if ((formes.get(i)).getColor() == couleur)
            formes.remove(i);
    }
}
/*
 * Classe Cercle
 */ 
 
public class Cercle extends Forme {
  
  int rayon;
  
  public Cercle(Point p) {
    super(p, FormType.CIRCLE);
    this.rayon=80;
  }
   
  public void update() {
    fill(this.c);
    circle((int) this.origin.getX(),(int) this.origin.getY(),this.rayon);
  }  
   
  public boolean isClicked(Point p) {
    // vérifier que le cercle est cliqué
   PVector OM= new PVector( (int) (p.getX() - this.origin.getX()),(int) (p.getY() - this.origin.getY())); 
   if (OM.mag() <= this.rayon/2)
     return(true);
   else 
     return(false);
  }
  
  protected double perimetre() {
    return(2*PI*this.rayon);
  }
  
  protected double aire(){
    return(PI*this.rayon*this.rayon);
  }
}
/*
 * Enumération de a Machine à Etats (Finite State Machine)
 *
 *
 */
 
public enum FSM {
  INITIAL, 
  AFFICHER_FORMES, 
  DEPLACER_FORMES_SELECTION,
  DEPLACER_FORMES_DESTINATION,
  SUPPRIMER_FORMES
}
/*****
 * Création d'un nouvelle classe objet : Forme (Cercle, Rectangle, Triangle
 * 
 * Date dernière modification : 28/10/2019
 */

enum FormType {
    CIRCLE,
    RECTANGLE,
    TRIANGLE,
    DIAMOND
}

abstract class Forme {
    Point origin;
    int c;
    private final FormType type;
 
    Forme(Point p, FormType type) {
        this.origin=p;
        this.c = color(127);
        this.type = type;
    }
 
    public void setColor(int c) {
        this.c=c;
    }
 
    public int getColor(){
        return(this.c);
    }
 
    public abstract void update();
 
    public Point getLocation() {
        return(this.origin);
    }
 
    public boolean matchesType(FormType type) {
        return this.type == type;   
    }
 
    public void setLocation(Point p) {
        this.origin = p;
    }
 
    public abstract boolean isClicked(Point p);
 
    // Calcul de la distance entre 2 points
    protected double distance(Point A, Point B) {
        PVector AB = new PVector( (int) (B.getX() - A.getX()),(int) (B.getY() - A.getY())); 
        return(AB.mag());
    }
 
    protected abstract double perimetre();
    protected abstract double aire();
}
/*
 * Classe Losange
 */ 
 
public class Losange extends Forme {
  Point A, B,C,D;
  
  public Losange(Point p) {
    super(p, FormType.DIAMOND);
    // placement des points
    A = new Point();    
    A.setLocation(p);
    B = new Point();    
    B.setLocation(A);
    C = new Point();  
    C.setLocation(A);
    D = new Point();
    D.setLocation(A);
    B.translate(40,60);
    D.translate(-40,60);
    C.translate(0,120);
  }
  
  public void setLocation(Point p) {
      super.setLocation(p);
      // redéfinition de l'emplacement des points
      A.setLocation(p);   
      B.setLocation(A);  
      C.setLocation(A);
      D.setLocation(A);
      B.translate(40,60);
      D.translate(-40,60);
      C.translate(0,120);   
  }
  
  public void update() {
    fill(this.c);
    quad((float) A.getX(), (float) A.getY(), (float) B.getX(), (float) B.getY(), (float) C.getX(), (float) C.getY(),  (float) D.getX(),  (float) D.getY());
  }  
  
  public boolean isClicked(Point M) {
    // vérifier que le losange est cliqué
    // aire du rectangle AMD + AMB + BMC + CMD = aire losange  
    if (round( (float) (aire_triangle(A,M,D) + aire_triangle(A,M,B) + aire_triangle(B,M,C) + aire_triangle(C,M,D))) == round((float) aire()))
      return(true);
    else 
      return(false);  
  }
  
  protected double perimetre() {
    //
    PVector AB= new PVector( (int) (B.getX() - A.getX()),(int) (B.getY() - A.getY())); 
    PVector BC= new PVector( (int) (C.getX() - B.getX()),(int) (C.getY() - B.getY())); 
    PVector CD= new PVector( (int) (D.getX() - C.getX()),(int) (D.getY() - C.getY())); 
    PVector DA= new PVector( (int) (A.getX() - D.getX()),(int) (A.getY() - D.getY())); 
    return( AB.mag()+BC.mag()+CD.mag()+DA.mag()); 
  }
  
  protected double aire(){
    PVector AC= new PVector( (int) (C.getX() - A.getX()),(int) (C.getY() - A.getY())); 
    PVector BD= new PVector( (int) (D.getX() - B.getX()),(int) (D.getY() - B.getY())); 
    return((AC.mag()*BD.mag())/2);
  } 
  
  private double perimetre_triangle(Point I, Point J, Point K) {
    //
    PVector IJ= new PVector( (int) (J.getX() - I.getX()),(int) (J.getY() - I.getY())); 
    PVector JK= new PVector( (int) (K.getX() - J.getX()),(int) (K.getY() - J.getY())); 
    PVector KI= new PVector( (int) (I.getX() - K.getX()),(int) (I.getY() - K.getY())); 
    
    return( IJ.mag()+JK.mag()+KI.mag()); 
  }
   
  // Calcul de l'aire d'un triangle par la méthode de Héron 
  private double aire_triangle(Point I, Point J, Point K){
    double s = perimetre_triangle(I,J,K)/2;
    double aire = s*(s-distance(I,J))*(s-distance(J,K))*(s-distance(K,I));
    return(sqrt((float) aire));
  }
}
/*
 * Classe Rectangle
 */ 
 
public class Rectangle extends Forme {
  
  int longueur;
  
  public Rectangle(Point p) {
    super(p, FormType.RECTANGLE);
    this.longueur=60;
  }
   
  public void update() {
    fill(this.c);
    square((int) this.origin.getX(),(int) this.origin.getY(),this.longueur);
  }  
  
  public boolean isClicked(Point p) {
    int x= (int) p.getX();
    int y= (int) p.getY();
    int x0 = (int) this.origin.getX();
    int y0 = (int) this.origin.getY();
    
    // vérifier que le rectangle est cliqué
    if ((x>x0) && (x<x0+this.longueur) && (y>y0) && (y<y0+this.longueur))
      return(true);
    else  
      return(false);
  }
  
  // Calcul du périmètre du carré
  protected double perimetre() {
    return(this.longueur*4);
  }
  
  protected double aire(){
    return(this.longueur*this.longueur);
  }
}
/*
 * Classe Triangle
 */ 
 
public class Triangle extends Forme {
  Point A, B,C;
  public Triangle(Point p) {
    super(p, FormType.TRIANGLE);
    // placement des points
    A = new Point();    
    A.setLocation(p);
    B = new Point();    
    B.setLocation(A);
    C = new Point();    
    C.setLocation(A);
    B.translate(40,60);
    C.translate(-40,60);
  }
  
    public void setLocation(Point p) {
      super.setLocation(p);
      // redéfinition de l'emplacement des points
      A.setLocation(p);   
      B.setLocation(A);  
      C.setLocation(A);
      B.translate(40,60);
      C.translate(-40,60);   
  }
  
  public void update() {
    fill(this.c);
    triangle((float) A.getX(), (float) A.getY(), (float) B.getX(), (float) B.getY(), (float) C.getX(), (float) C.getY());
  }  
  
  public boolean isClicked(Point M) {
    // vérifier que le triangle est cliqué
    
    PVector AB= new PVector( (int) (B.getX() - A.getX()),(int) (B.getY() - A.getY())); 
    PVector AC= new PVector( (int) (C.getX() - A.getX()),(int) (C.getY() - A.getY())); 
    PVector AM= new PVector( (int) (M.getX() - A.getX()),(int) (M.getY() - A.getY())); 
    
    PVector BA= new PVector( (int) (A.getX() - B.getX()),(int) (A.getY() - B.getY())); 
    PVector BC= new PVector( (int) (C.getX() - B.getX()),(int) (C.getY() - B.getY())); 
    PVector BM= new PVector( (int) (M.getX() - B.getX()),(int) (M.getY() - B.getY())); 
    
    PVector CA= new PVector( (int) (A.getX() - C.getX()),(int) (A.getY() - C.getY())); 
    PVector CB= new PVector( (int) (B.getX() - C.getX()),(int) (B.getY() - C.getY())); 
    PVector CM= new PVector( (int) (M.getX() - C.getX()),(int) (M.getY() - C.getY())); 
    
    if ( ((AB.cross(AM)).dot(AM.cross(AC)) >=0) && ((BA.cross(BM)).dot(BM.cross(BC)) >=0) && ((CA.cross(CM)).dot(CM.cross(CB)) >=0) ) { 
      return(true);
    }
    else
      return(false);
  }
  
  protected double perimetre() {
    //
    PVector AB= new PVector( (int) (B.getX() - A.getX()),(int) (B.getY() - A.getY())); 
    PVector AC= new PVector( (int) (C.getX() - A.getX()),(int) (C.getY() - A.getY())); 
    PVector BC= new PVector( (int) (C.getX() - B.getX()),(int) (C.getY() - B.getY())); 
    
    return( AB.mag()+AC.mag()+BC.mag()); 
  }
   
  // Calcul de l'aire du triangle par la méthode de Héron 
  protected double aire(){
    double s = perimetre()/2;
    double aire = s*(s-distance(B,C))*(s-distance(A,C))*(s-distance(A,B));
    return(sqrt((float) aire));
  }
}


    public void settings() { size(800, 600); }

    static public void main(String[] passedArgs) {
        String[] appletArgs = new String[] { "Palette" };
        if (passedArgs != null) {
            PApplet.main(concat(appletArgs, passedArgs));
        } else {
            PApplet.main(appletArgs);
        }
    }
}
