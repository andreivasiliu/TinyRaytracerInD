module raytracer.CSG;

import raytracer.Vector;
import raytracer.MathShapes;

public enum Operator { Union, Intersection, Difference, };

class CSG: MathShape
{
    MathShape A, B;
    Operator oper;

    public this(MathShape s1, MathShape s2, Operator o)
    {
        A = s1;
        B = s2;
        oper = o;
    }
    
    public Operator getOperator()
    {
        return oper;
    }

    public override void intersects(Ray ray, void delegate(double d) addIntersection)
    {/+
        if (oper == Operator.Union)
        {
            double[] intersections_a = A.intersects(ray);
            double[] intersections_b = B.intersects(ray);
            double[] finl = new double[](0);

            foreach (double intersection; intersections_a)
                if (!B.isInside(ray.point + ray.direction * intersection))
                    finl ~= intersection;

            foreach (double intersection; intersections_b)
                if (!A.isInside(ray.point + ray.direction * intersection))
                    finl ~= intersection;

            return finl;
        }
        else if (oper == Operator.Intersection)
        {
            double[] intersections_a = A.intersects(ray);
            double[] intersections_b = B.intersects(ray);
            double[] finl = new double[](0);

            foreach (double intersection; intersections_a)
                if (B.isInside(ray.point + ray.direction * intersection))
                    finl ~= intersection;

            foreach (double intersection; intersections_b)
                if (A.isInside(ray.point + ray.direction * intersection))
                    finl ~= intersection;

            return finl;
        }
        else if (oper == Operator.Difference)
        {
            double[] intersections_a = A.intersects(ray);
            double[] intersections_b = B.intersects(ray);
            double[] finl = new double[](0);

            foreach (double intersection; intersections_a)
                if (!B.isInside(ray.point + ray.direction * intersection))
                    finl ~= intersection;

            foreach (double intersection; intersections_b)
                if (A.isInside(ray.point + ray.direction * intersection))
                    finl ~= intersection;

            return finl;
        }
        else
            throw new Exception("Exception 1.:D");+/
    }

    public override Vector getNormal(Vector surfacePoint)
    {
        if (oper == Operator.Union ||
            oper == Operator.Intersection)
        {
            if (A.isOnSurface(surfacePoint))
                return A.getNormal(surfacePoint);
            else if (B.isOnSurface(surfacePoint))
                return B.getNormal(surfacePoint);
            else
                throw new Exception("Get CSG normal failed.");
        }
        else if (oper == Operator.Difference)
        {
            if (A.isOnSurface(surfacePoint))
                return A.getNormal(surfacePoint);
            else if (B.isOnSurface(surfacePoint))
                return B.getNormal(surfacePoint) * -1;
            else
                throw new Exception("Get CSG normal failed.");
        }
        else
            throw new Exception("Exception 4.:D");
    }

    public override bool isInside(Vector point)
    {
        if (oper == Operator.Union)
        {
            return A.isInside(point) || B.isInside(point);
        }
        else if (oper == Operator.Intersection)
        {
            return A.isInside(point) && B.isInside(point);
        }
        else if (oper == Operator.Difference)
        {
            return A.isInside(point) && !B.isInside(point);
        }
        else
            throw new Exception("Exception 2.:D");
    }

    public override bool isOnSurface(Vector point)
    {
        if (oper == Operator.Union)
        {
            return (A.isOnSurface(point) && !B.isInside(point)) ||
                (B.isOnSurface(point) && !A.isInside(point));
        }
        else if (oper == Operator.Intersection)
        {
            return (A.isOnSurface(point) && B.isInside(point)) ||
                (B.isOnSurface(point) && A.isInside(point));
        }
        else if (oper == Operator.Difference)
        {
            return (A.isOnSurface(point) && !B.isInside(point)) ||
                (B.isOnSurface(point) && A.isInside(point));
        }
        else
            throw new Exception("Exception 3.:D");
    }
}
