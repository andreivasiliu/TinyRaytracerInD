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

    public Vector Normalize()
    {
        return *this * (1 / this.Length());
    }

    public double Length()
    {
        return sqrt(x * x + y * y + z * z);
    }

    public static double Distance(Vector a, Vector b)
    {
        return (a - b).Length();
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

    public static double Angle(Vector a, Vector b)
    {
        return acos((a * b)/(a.Length() * b.Length()));
    }
}