module raytracer.Materials;

import raytracer.Textures;
import raytracer.Vector;
import raytracer.Colors;

public abstract class Material
{
    public abstract Colors getColorAt(double u, double v);
    public abstract double getReflectivityAt(double u, double v);
    public abstract double getTransparencyAt(double u, double v);
    
    final public Colors getColorAt(UV uvCoordinates)
    {
        return getColorAt(uvCoordinates.u, uvCoordinates.v);
    }
    
    final public double getReflectivityAt(UV uvCoordinates)
    {
        return getReflectivityAt(uvCoordinates.u, uvCoordinates.v);
    }
    
    final public double getTransparencyAt(UV uvCoordinates)
    {
        return getTransparencyAt(uvCoordinates.u, uvCoordinates.v);
    }
}

public class SolidColorMaterial: Material
{
    private Colors color;
    private double reflectivity;
    private double transparency;

    public this(double red, double green, double blue,
            double reflectivity = 0, double transparency = 0)
    {
        this(Colors(red, green, blue), reflectivity, transparency);
    }

    public this(Colors color, double reflectivity = 0, double transparency = 0)
    {
        this.color = color;
        this.reflectivity = reflectivity;
        this.transparency = transparency;
    }

    public override Colors getColorAt(double u, double v)
    {
        return color;
    }

    public override double getReflectivityAt(double u, double v)
    {
        return reflectivity;
    }

    public override double getTransparencyAt(double u, double v)
    {
        return transparency;
    }
}

public class TexturedMaterial: Material
{
    private Texture texture;
    private double reflectivity;
    private double transparency;
    
    public this(Texture texture, double reflectivity = 0, 
            double transparency = 0)
    {
        this.texture = texture;
        this.reflectivity = reflectivity;
        this.transparency = transparency;
    }
    
    public override Colors getColorAt(double u, double v)
    {
        return texture.getColorAt(UV(u, v));
    }
    
    public override double getReflectivityAt(double u, double v)
    {
        return reflectivity;
    }
    
    public override double getTransparencyAt(double u, double v)
    {
        return transparency;
    }
}
