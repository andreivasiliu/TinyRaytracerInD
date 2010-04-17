module raytracer.CSG;

import raytracer.RTObject;
import raytracer.Vector;
import raytracer.MathShapes;

import tango.io.Stdout;

public enum Operator { Union, Intersection, Difference, };

class CSG: MathShape
{
    MathShape A, B;
    RTObject Aobj, Bobj;
    Operator oper;

    public this(RTObject s1, RTObject s2, Operator o)
    {
        A = s1.getShape();
        B = s2.getShape();
        Aobj = s1;
        Bobj = s2;
        oper = o;
    }
    
    public Operator getOperator()
    {
        return oper;
    }
    
    public override Ray reverseTransformRay(Ray ray)
    {
        // CSG objects themselves do not have transformations.
        return ray;
    }

    public override void intersects(Ray ray, void delegate(double d) addIntersection)
    {
        if (oper == Operator.Union)
        {
            void checkIntersection1A(double d)
            {
                if (!B.isInside(ray.point + ray.direction * d))
                    addIntersection(d);
            }
            
            Aobj.intersects(ray, &checkIntersection1A);
            
            void checkIntersection1B(double d)
            {
                if (!A.isInside(ray.point + ray.direction * d))
                    addIntersection(d);
            }
            
            Bobj.intersects(ray, &checkIntersection1B);
        }
        else if (oper == Operator.Intersection)
        {
            void checkIntersection2A(double d)
            {
                if (B.isInside(ray.point + ray.direction * d))
                    addIntersection(d);
            }
            
            Aobj.intersects(ray, &checkIntersection2A);
            
            void checkIntersection2B(double d)
            {
                if (A.isInside(ray.point + ray.direction * d))
                    addIntersection(d);
            }
            
            Bobj.intersects(ray, &checkIntersection2B);
        }
        else if (oper == Operator.Difference)
        {
            void checkIntersection3A(double d)
            {
                if (!B.isInside(ray.point + ray.direction * d))
                    addIntersection(d);
            }
            
            Aobj.intersects(ray, &checkIntersection3A);
            
            void checkIntersection3B(double d)
            {
                if (A.isInside(ray.point + ray.direction * d))
                    addIntersection(d);
            }
            
            Bobj.intersects(ray, &checkIntersection3B);
        }
        else
            throw new Exception("Unknown CSG operator.");
    }

    public override Vector getNormal(Vector surfacePoint)
    {
        Vector normal;
        
        if (oper == Operator.Union ||
            oper == Operator.Intersection)
        {
            if (A.isOnSurface(surfacePoint))
                normal = A.getNormal(surfacePoint);
            else if (B.isOnSurface(surfacePoint))
                normal = B.getNormal(surfacePoint);
            else
                throw new Exception("Get CSG normal failed.");
        }
        else if (oper == Operator.Difference)
        {
            if (A.isOnSurface(surfacePoint))
                normal = A.getNormal(surfacePoint);
            else if (B.isOnSurface(surfacePoint))
                normal = B.getNormal(surfacePoint) * -1;
            else 
                normal = Vector(1, 0, 0);
            //throw new Exception("Get CSG normal failed.");
        }
        else
            throw new Exception("Exception 4.:D");
        
        return normal;
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
