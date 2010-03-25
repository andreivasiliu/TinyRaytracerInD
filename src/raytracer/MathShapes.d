module raytracer.MathShapes;

import tango.io.Stdout;
import raytracer.Math;
import raytracer.Transformation;
import raytracer.Vector;

// TODO: Finish implementing transformations on isOnSurface/isInside and the like.

public abstract class MathShape
{
    Transformation transformation;
    
    abstract public void intersects(Ray ray, void delegate(double d) addIntersection);
    abstract public Vector getNormal(Vector surfacePoint);
    abstract public bool isInside(Vector point);
    abstract public bool isOnSurface(Vector point);
    
    public void setTransformation(Transformation transformation)
    {
        this.transformation = transformation;
        applyTransformation(transformation);
    }
    
    public void applyTransformation(ref Transformation transformation)
    {
        
    }
    
    public Ray reverseTransformRay(Ray ray)
    {
        if (transformation is null)
            return ray;
        else
            return transformation.reverseTransformRay(ray);
    }
}

public class MathSphere : MathShape
{
    Vector center;
    double radius;

    public this(Vector center, double radius)
    {
        this.center = center;
        this.radius = radius;
    }

    public override void intersects(Ray ray, void delegate(double d) addIntersection)
    {
        Vector v = ray.point - center;
        Vector d = ray.direction;
        double r = radius;

        double sum = (v * d) * (v * d) - (v * v - r * r);
        if (sum < 0)
            return;

        double first = -(v * d) + sqrt(sum);
        double second = -(v * d) - sqrt(sum);
        
        if (first >= 0)
            addIntersection(first);
        
        if (second >= 0)
            addIntersection(second);
    }

    public override Vector getNormal(Vector surfacePoint)
    {
        return (surfacePoint - center).Normalize();
    }

    public override bool isInside(Vector point)
    {
        return (point - center).Length() <= radius + epsilon;
    }

    public override bool isOnSurface(Vector point)
    {
        return abs((point - center).Length() - radius) < epsilon;
    }
}

public class MathPlane : MathShape
{
    double A, B, C, D;
    Vector normal;

    public this(double A, double B, double C, double D)
    {
        this.A = A;
        this.B = B;
        this.C = C;
        this.D = D;
        
        normal = Vector(A, B, C).Normalize();
    }
    
    public override void applyTransformation(ref Transformation transformation)
    {
        super.applyTransformation(transformation);
        
        // This is to guard against translations, which should only affect
        // points, not directions.
        Vector transformedOrigin = transformation.transformVector(Vector(0, 0, 0));
        normal = transformation.transformVector(normal) - transformedOrigin;
    }

    public override void intersects(Ray ray, void delegate(double d) addIntersection)
    {
        Vector Pn = (Vector(A, B, C)).Normalize();
        Vector R0 = ray.point;
        Vector Rd = ray.direction;
        double t = 0;
        double Vd = Pn * Rd;

        if (Vd != 0)
        {
            t = -(Pn * R0 + D) * (1 / Vd);
            if (t >= 0)
                addIntersection(t);
        }
    }

    public override Vector getNormal(Vector surfacePoint)
    {
        return normal;
        //return (Vector(A, B, C)).Normalize();
    }

    public override bool isInside(Vector point)
    {
        return false;
    }

    public override bool isOnSurface(Vector point)
    {
        if (transformation is null)
            return isTransformedPointOnSurface(point);
        else
            return isTransformedPointOnSurface(transformation.reverseTransformVector(point));
    }
    
    protected bool isTransformedPointOnSurface(Vector point)
    {
        return abs(A * point.x + B * point.y + C * point.z + D) < epsilon;
    }
}

public class MathCube : MathShape
{
    MathPlane p1, p2, p3, p4, p5, p6;
    Vector center;
    double length;

    public this(Vector center, double length)
    {
        this.center = center;
        this.length = length / 2;

        p1 = new MathPlane(0, 0, 1, -(center.z + length / 2));
        p6 = new MathPlane(0, 0, -1, center.z + -length / 2);
        p2 = new MathPlane(0, 1, 0, -(center.y + length / 2));
        p5 = new MathPlane(0, -1, 0, center.y + -length / 2);
        p3 = new MathPlane(1, 0, 0, -(center.x + length / 2));
        p4 = new MathPlane(-1, 0, 0, center.x + -length / 2);
    }
    
    public override void applyTransformation(ref Transformation transformation)
    {
        super.applyTransformation(transformation);
        
        p1.setTransformation(transformation);
        p2.setTransformation(transformation);
        p3.setTransformation(transformation);
        p4.setTransformation(transformation);
        p5.setTransformation(transformation);
        p6.setTransformation(transformation);
    }

    public override bool isInside(Vector point)
    {
        if (point.x <= (center.x + length) &&
            point.x >= (center.x - length) &&
            point.y <= (center.y + length) &&
            point.y >= (center.y - length) &&
            point.z <= (center.z + length) &&
            point.z >= (center.z - length))
            return true;

        return false;
    }

    public override void intersects(Ray ray, void delegate(double d) addIntersection)
    {
        // TODO: The checkIntersection delegates look like they could be
        // somehow merged into one... find out how.
        
        void checkIntersection1(double d)
        {
            Vector point = ray.point + ray.direction * d;

            if (isBetween(point.y, center.y - length, center.y + length) &&
                isBetween(point.x, center.x - length, center.x + length))
                addIntersection(d);
        }
        
        p1.intersects(ray, &checkIntersection1);
        p6.intersects(ray, &checkIntersection1);
        
        void checkIntersection2(double d)
        {
            Vector point = ray.point + ray.direction * d;

            if (isBetween(point.z, center.z - length, center.z + length) &&
                isBetween(point.x, center.x - length, center.x + length))
                addIntersection(d);
        }
        
        p2.intersects(ray, &checkIntersection2);
        p5.intersects(ray, &checkIntersection2);
        
        void checkIntersection3(double d)
        {
            Vector point = ray.point + ray.direction * d;

            if (isBetween(point.y, center.y - length, center.y + length) &&
                isBetween(point.z, center.z - length, center.z + length))
                addIntersection(d);
        }
        
        p3.intersects(ray, &checkIntersection3);
        p4.intersects(ray, &checkIntersection3);
    }

    private bool isBetween(double p, double p_2, double p_3)
    {
        return (p >= p_2) && (p <= p_3); 
    }

    public override Vector getNormal(Vector surfacePoint)
    {
        // TODO: This could be greatly improved, since we should already know
        // which surface was intersected.
        
        if (transformation !is null)
            surfacePoint = transformation.reverseTransformVector(surfacePoint);
        
        Vector normal;
        
        if (p1.isTransformedPointOnSurface(surfacePoint))
            normal = p1.getNormal(surfacePoint);
        else if (p2.isTransformedPointOnSurface(surfacePoint))
            normal = p2.getNormal(surfacePoint);
        else if (p3.isTransformedPointOnSurface(surfacePoint))
            normal = p3.getNormal(surfacePoint);
        else if (p4.isTransformedPointOnSurface(surfacePoint))
            normal = p4.getNormal(surfacePoint);
        else if (p5.isTransformedPointOnSurface(surfacePoint))
            normal = p5.getNormal(surfacePoint);
        else if (p6.isTransformedPointOnSurface(surfacePoint))
            normal = p6.getNormal(surfacePoint);
        else
            //throw new Exception("Exception: get normal for cube failed.");
        {
            static bool erroredOnceAlready = false;
            if (erroredOnceAlready)
                return Vector(1, 0, 0);
            Stdout("Get normal for cube failed!").newline;
            //erroredOnceAlready = true;
            return Vector(1, 0, 0);
        }
        
        return normal;
    }

    public override bool isOnSurface(Vector point)
    {
        if (transformation is null)
            return isTransformedPointOnSurface(point);
        else
            return isTransformedPointOnSurface(transformation.reverseTransformVector(point));
    }
    
    protected bool isTransformedPointOnSurface(Vector point)
    {
        if (isBetween(point.y, center.y - length - epsilon, center.y + length + epsilon) &&
            isBetween(point.x, center.x - length - epsilon, center.x + length + epsilon) &&
            (p1.isOnSurface(point) || p6.isOnSurface(point)))
            return true;
        else if (isBetween(point.z, center.z - length - epsilon, center.z + length + epsilon) &&
                 isBetween(point.x, center.x - length - epsilon, center.x + length + epsilon) &&
                 (p2.isOnSurface(point) || p5.isOnSurface(point)))
            return true;
        else if (isBetween(point.y, center.y - length - epsilon, center.y + length + epsilon) &&
                 isBetween(point.z, center.z - length - epsilon, center.z + length + epsilon) &&
                 (p3.isOnSurface(point) || p4.isOnSurface(point)))
            return true;
        else
            return false;
    }
}
