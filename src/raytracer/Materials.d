module raytracer.Materials;

import raytracer.Colors;

public abstract class Material
{
    public abstract Colors getColorAt(double x, double y);
    public abstract double getReflectivity();
    public abstract double getTransparency();
}

public class SolidColorMaterial : Material
{
    Colors color;
    double reflectivity;
    double transparency;

    public this(double red, double green, double blue,
            double reflectivity = 0, double transparency = 0)
    {
        color = Colors.inRange(red, green, blue);
        this.reflectivity = reflectivity;
        this.transparency = transparency;
    }

    public override Colors getColorAt(double x, double y)
    {
        return color;
    }

    public override double getReflectivity()
    {
        return reflectivity;
    }

    public override double getTransparency()
    {
        return transparency;
    }

    public Colors getColor()
    {
        return color;
    }
}
