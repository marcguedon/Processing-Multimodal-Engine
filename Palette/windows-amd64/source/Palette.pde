/*
 * Palette Graphique - prélude au projet multimodal 3A SRI
 * 4 objets gérés : cercle, rectangle(carré), losange et triangle
 * (c) 05/11/2019
 * Dernière révision : 28/04/2020
 */

import java.util.Timer;
import java.util.TimerTask;
import java.awt.Point;
import fr.dgac.ivy.*;

Ivy bus;

ArrayList<Forme> formes;
FSM mae;
int indice_forme;

final float seuil = 0.80;
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

void setup()
{
    size(800, 600);
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
                
                if(float(sra5_confidence) < seuil)
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

void draw()
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

void affiche()
{
    background(255);
    
    for (int i = 0; i < formes.size(); i++)
        (formes.get(i)).update();
}

void mousePressed()
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

void keyPressed()
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

void start_timer()
{
    start_time = millis();
    timer_active = true;
}

Point get_point_from_localisation_str(String localisation)
{
    if(localisation.equals("THERE"))
        return new Point(mouseX, mouseY);
        
    return new Point((int)random(0, width), (int)random(0, height));
}

color get_color_from_color_str(String color_msg)
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

void create_form()
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

Forme create_form_from_form_str(String form, Point pos)
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

void delete_forms()
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

void delete_by_form_color(String form, color couleur)
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

void delete_by_form(String form)
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

void delete_by_color(color couleur)
{    
    for (int i = formes.size() - 1; i >= 0; i--)
    {
        if ((formes.get(i)).getColor() == couleur)
            formes.remove(i);
    }
}
