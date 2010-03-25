module raytracer.PointLight;

import raytracer.Colors;
import raytracer.Vector;

class PointLight
{
    Vector point;
    Colors color;
    double fade_distance;

    public this(Vector point)
    {
        this.point = point;
    }

    public this(Vector point, Colors c)
    {
        color = c;
        this(point);
    }

    public this(Vector point, Colors c, double fade)
    {
        fade_distance = fade;
        this(point, c);
    }

    public Vector getPoint()
    {
        return point;
    }

    //public Color COLOR
    //{
    //    get { return color.getColor(); }
    //}

    public Colors getColor()
    {
        return color;
    }

    public double fadeDistance()
    {
        return fade_distance;
    }

    //fade power
    public double intensity(double distance)
    {
        if (distance >= fade_distance)
            return 0;

        return distance / fade_distance;
    }
}
