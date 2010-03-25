module raytracer.Materials;

import raytracer.Colors;

public abstract class Material
{
    public abstract Colors GetColorAt(double x, double y);
    public abstract double GetReflectivity();
}

public class SolidColorMaterial : Material
{
    Colors color;
    double reflectivity;

    public this(double R, double G, double B)
    {
        this(R, G, B, 0.3);
    }

    public this(double R, double G, double B, double r)
    {
        color = Colors.inRange(R, G, B);
        reflectivity = r;
    }

    public override Colors GetColorAt(double x, double y)
    {
        return color;
    }

    public override double GetReflectivity()
    {
        return reflectivity;
    }

    public Colors getColor()
    {
        return color;
    }
}
