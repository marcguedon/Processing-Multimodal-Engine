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
    color c;
    private final FormType type;
 
    Forme(Point p, FormType type) {
        this.origin=p;
        this.c = color(127);
        this.type = type;
    }
 
    void setColor(color c) {
        this.c=c;
    }
 
    color getColor(){
        return(this.c);
    }
 
    abstract void update();
 
    Point getLocation() {
        return(this.origin);
    }
 
    boolean matchesType(FormType type) {
        return this.type == type;   
    }
 
    void setLocation(Point p) {
        this.origin = p;
    }
 
    abstract boolean isClicked(Point p);
 
    // Calcul de la distance entre 2 points
    protected double distance(Point A, Point B) {
        PVector AB = new PVector( (int) (B.getX() - A.getX()),(int) (B.getY() - A.getY())); 
        return(AB.mag());
    }
 
    protected abstract double perimetre();
    protected abstract double aire();
}
