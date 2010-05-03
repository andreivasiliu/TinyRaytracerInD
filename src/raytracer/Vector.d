module raytracer.Vector;

import raytracer.Math;

public struct Ray
{
    public Vector point;
    public Vector direction;
}

public struct Vector
{
    public union
    {
        public struct 
        {
            double x, y, z;
        }
        double[3] v;
    }

    public Vector normalized()
    {
        return *this * (1 / this.length());
    }

    public double length()
    {
        return sqrt(x * x + y * y + z * z);
    }

    public static double distance(Vector a, Vector b)
    {
        return (a - b).length();
    }

    public Vector opSub(Vector b)
    {
        return Vector(x - b.x, y - b.y, z - b.z);
    }

    public Vector opAdd(Vector b)
    {
        return Vector(x + b.x, y + b.y, z + b.z);
    }

    public Vector opMul(double b)
    {
        return Vector(x * b, y * b, z * b);
    }

    public double opMul(Vector b)
    {
        return x * b.x + y * b.y + z * b.z;
    }

    public Vector opNeg()
    {
        return Vector(-x, -y, -z);
    }
    
    public static double angle(Vector a, Vector b)
    {
        return acos((a * b)/(a.length() * b.length()));
    }
    
    public static Vector crossProduct(Vector a, Vector b)
    {
        return Vector(a.y * b.z - a.z * b.y, 
                      a.x * b.z - a.z * b.x,
                      a.x * b.y - a.y * b.x);
    }
}

public struct UV
{
    double u;
    double v;
}
