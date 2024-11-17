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
PImage sketch_icon;
float seuil = 0.80;

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
    sketch_icon = loadImage("Palette.jpg");
    surface.setIcon(sketch_icon);
    
    formes = new ArrayList();
    noStroke();
    mae = FSM.INITIAL;
    indice_forme = -1;
    
    try
    {
        bus = new Ivy("Palette", "Palette is ready", null);
        bus.start("127.255.255.255:2010");
        
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
                
                Point p = get_point_from_localisation_str(sra5_localisation);
                
                if(float(sra5_confidence) < seuil)
                    println("Répétez s'il vous plait");
                    
                else
                {
                    switch (sra5_action)
                    {
                        case "CREATE":
                            create_form(p);
                            
                            mae = FSM.AFFICHER_FORMES;
                            break;
                        
                        case "MOVE":
                            //move_form();
                            
                            println("Déplacement forme");
                            mae = FSM.DEPLACER_FORMES_SELECTION;
                            
                            // mae = FSM.AFFICHER_FORMES;
                            break;
                            
                        case "DELETE":               
                            delete_form(p);
                            
                            mae = FSM.AFFICHER_FORMES;
                            break;
                        
                        case "QUIT":
                            //exit();
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
                }, 5000);
                
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
    Point p = new Point(mouseX, mouseY);
      
    switch (mae)
    {
        case INITIAL:  // Etat INITIAL
            background(255);
            fill(0);
            text("Etat initial (c(ercle)/l(osange)/r(ectangle)/t(riangle) pour créer la forme à la position courante)", 50, 50);
            text("m(ove)+ click pour sélectionner un objet et click pour sa nouvelle position", 50, 80);
            text("d(elete)+ click pour supprimer un objet", 50, 110);
            text("click sur un objet pour changer sa couleur de manière aléatoire", 50, 140);
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
            for (int i = 0; i < formes.size(); i++)
            {
                if ((formes.get(i)).isClicked(p))
                    (formes.get(i)).setColor(color(random(0, 255), random(0, 255), random(0, 255)));
            } 
            break;
            
        case DEPLACER_FORMES_SELECTION:
            for (int i=0;i<formes.size();i++)
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
            Forme f = new Rectangle(p);
            formes.add(f);
            mae = FSM.AFFICHER_FORMES;
            break;
        case 'c': // Circle
            Forme f2 = new Cercle(p);
            formes.add(f2);
            mae = FSM.AFFICHER_FORMES;
            break;
        case 't': // Triangle
            Forme f3 = new Triangle(p);
            formes.add(f3);
            mae = FSM.AFFICHER_FORMES;
            break;  
        case 'l': // Diamond
            Forme f4 = new Losange(p);
            formes.add(f4);
            mae = FSM.AFFICHER_FORMES;
            break;    
        case 'm': // Move
            mae = FSM.DEPLACER_FORMES_SELECTION;
            break;
        case 'd': // Delete
            mae = FSM.SUPPRIMER_FORMES;
            break;
    }
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

void create_form(Point pos)
{
    Forme form;
                            
    if(sra5_pointage.equals("THIS"))
    {
        println("Creation forme par reco");
        form = create_form_from_form_str(reco_form, pos);
    }
    
    else
    {
        println("Creation forme par parole");
        form = create_form_from_form_str(sra5_form, pos);
    }

    form.setColor(get_color_from_color_str(sra5_couleur));
    formes.add(form);
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
            return new Cercle(pos);
    }
}

void delete_form(Point p)
{
    if(sra5_pointage.equals("THIS"))
    {
        for (int i = 0; i < formes.size(); i++)
        {
            if ((formes.get(i)).isClicked(p))
            {
                println("Suppression forme cliquée");
                formes.remove(i);
            }
        }
    }
    
    else if (!sra5_couleur.equals("undefined") && !sra5_form.equals("undefined"))
    {
        println("Suppression par forme et couleur");
        delete_object_by_form_color(sra5_form, get_color_from_color_str(sra5_couleur));
    }
    
    else if (!sra5_form.equals("undefined"))
    {
        println("Suppression par forme");
        delete_object_by_form(sra5_form);
    }
    
    else if (!sra5_couleur.equals("undefined"))
    {
        println("Suppression par couleur");
        delete_object_by_color(get_color_from_color_str(sra5_couleur));
    }
}

void delete_object_by_form_color(String form, color couleur)
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
                
            case "TRIANLGE":
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

void delete_object_by_form(String form)
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
                
            case "TRIANLGE":
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

void delete_object_by_color(color couleur)
{    
    for (int i = formes.size() - 1; i >= 0; i--)
    {
        if ((formes.get(i)).getColor() == couleur)
            formes.remove(i);
    }
}
