module raydebugger.Shapes;

import tango.io.Stdout;
import gdk.Drawable;
import gdk.GC;
import raytracer.Transformation;
import raytracer.Vector;

abstract class Shape
{
    public abstract void draw(void delegate(Vector from, Vector to) drawLine);
}

class Cube: Shape
{
    private Vector center;
    private double length;
    
    private Vector[8] point;
    
    public this(Vector center, double length, Transformation transformation)
    {
        this.center = center;
        this.length = length;
        
        // Make points on the cube's corners.
        for (int i = 0; i < 8; i++)
        {
            point[i] = center;
            
            for (int axis = 0; axis < 3; axis++)
            {
                if (i & (1 << axis))
                    point[i].v[axis] += length;
                else
                    point[i].v[axis] -= length;
            }
        }
        
        // And apply the object's current transformation on them.
        for (int i = 0; i < 8; i++)
            point[i] = transformation.transformVector(point[i]);
    }
    
    public override void draw(void delegate(Vector from, Vector to) drawLine)
    {
        const int[] corners = [0, 3, 5, 6];
        
        foreach (int corner; corners)
            for (int axis = 0; axis < 3; axis++)
                drawLine(point[corner], point[corner ^ (1 << axis)]);
    }
}

class Sphere: Shape
{
    private Vector center;
    private double radius;
    
    public this(Vector center, double radius, Transformation transformation)
    {
        this.center = center;
        this.radius = radius;
        
        center = transformation.transformVector(center);
    }
    
    public override void draw(void delegate(Vector from, Vector to) drawLine)
    {
        
    }
}
