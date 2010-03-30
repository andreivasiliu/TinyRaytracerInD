module raytracer.RTObject;

import raytracer.Transformation;
import raytracer.Vector;
import raytracer.Colors;
import raytracer.Materials;
import raytracer.MathShapes;

class RTObject
{
    MathShape shape;
    Material material;

    public this(MathShape Shape, Material Material)
    {
        shape = Shape;
        material = Material;
    }

    public this(MathShape Shape)
    {
        this(Shape, new SolidColorMaterial(0, 0, 1));
    }
    
    public void intersects(Ray ray, void delegate(double d) addIntersection)
    {
        Ray transformedRay = shape.reverseTransformRay(ray);
        shape.intersects(transformedRay, addIntersection);
    }
    
    public Material getMaterial()
    {
        return material;
    }

    public MathShape getShape()
    {
        return shape;
    }

    public Colors getColor()
    {
        return material.getColorAt(0, 0);
    }
}
