module raytracer.RayTracer;

import tango.io.Stdout;
import raytracer.CSG;
import raytracer.Colors;
import raytracer.Materials;
import raytracer.Math;
import raytracer.MathShapes;
import raytracer.PointLight;
import raytracer.RTObject;
import raytracer.Transformation;
import raytracer.Vector;

public alias Colors delegate(int x, int y) PixelRenderer;

public final class RayTracer
{
    TransformationStack transformationStack;
    Vector camera;
    double top, bottom, left, right;
    int width, height;
    const int MaxDepth = 10;

    RTObject[] objects;
    PointLight[] pointLights;

    
    public this(int Width, int Height)
    {
        this(Vector(0, 0, -100), 60, -60, -80, 80, Width, Height);
    }

    public this(Vector cam, double Top, double Bottom, double Left, double Right, int Width, int Height)
    {
        camera = cam;
        top = Top;
        bottom = Bottom;
        left = Left;
        right = Right;
        width = Width;
        height = Height;
        
        transformationStack.pushTransformation(MatrixTransformation.createIdentityMatrix());

        objects = new RTObject[](0);
        pointLights = new PointLight[](0);

//        objects.add(new RTObject(new CSG(new CSG(
//            new MathSphere(Vector(10, 0, -105), 20),
//            new MathSphere(Vector(-10, 0, -100), 20), Operator.Union),
//            new MathSphere(Vector(0, 0, -90), 20),
//            Operator.Intersection), new SolidColorMaterial(0, 1, 0)));
//
//
//        objects.add(new RTObject(new CSG(
//            new MathCube(Vector(20, 0, -70), 20),
//            new MathSphere(Vector(20, 0, -70), 12),
//            Operator.Difference),
//            new SolidColorMaterial(1, 0, 0, 0.7)));
//
//        
//        for (int i = 0; i < 10; i++)
//        {
//            double x = 20 * sin((i / 10.0) * 2 * PI);
//            double y = 15;
//            double z = -50 + 20 * cos((i / 10.0) * (2 * PI));
//
//            objects.add(new RTObject(new MathSphere(Vector(x, y, z), 5), new SolidColorMaterial(1, 0, 0)));
//        }
//        objects ~= new RTObject(new MathSphere(Vector(10, 0, -30), 20), new SolidColorMaterial(1,0,0));
//        objects.add(new RTObject(new MathSphere(Vector(-10, 0, -90), 20), new SolidColorMaterial(0, 1, 0)));
//        objects ~= new RTObject(new MathPlane(0, 1, 0, 20), new SolidColorMaterial(0, 0, 1, 0));
//        objects.add(new RTObject(new MathPlane(0, 0, 1, 10), new SolidColorMaterial(0, 0, 0.5)));

//        pointLights ~= new PointLight(Vector(-10, 50, 20), Colors.inRange(0.5, 0.5, 0.5), 100);
        //pointLights.add(new PointLight(Vector(10, 150, -50), new Colors(0.5, 0.5, 0.5), 100));
    }

    private Colors GetRayColor(Ray ray, int depth)
    {
        version(veryverbose)
        if (depth > 3)
        Stdout.formatln("Intersection at depth {}, ray p[{}, {}, {}], d[{}, {}, {}].",
                depth, ray.point.x, ray.point.y, ray.point.z,
                ray.direction.x, ray.direction.y, ray.direction.z);
        
        // TODO: This was a class with opCmp, but we no longer need it... it
        // should probably be removed entirely.
        struct Intersection
        {
            public double distance;
            public RTObject obj;
        }

        Intersection nearestIntersection = Intersection(double.infinity, null);
        
        foreach (RTObject obj; objects)
        {
            void addIntersection(double d)
            {
                if (d > epsilon && d < nearestIntersection.distance)
                {
                    nearestIntersection.distance = d;
                    nearestIntersection.obj = obj;
                }
            }
            
            obj.intersects(ray, &addIntersection);
        }

        if (nearestIntersection.obj is null)
            return Colors.Black;

        RTObject rTobj = nearestIntersection.obj;
        Vector point = ray.point + ray.direction * nearestIntersection.distance;
        Vector normal = rTobj.getShape.getNormal(point);
        
        debug(verbose)
        Stdout.formatln("Intersection (depth {}) at point [{}, {}, {}].",
                depth, point.x, point.y, point.z);

        Colors c = (cast(SolidColorMaterial)rTobj.material).getColor;

        Colors ambient = c.Multiply((Colors.inRange(1, 1, 1)).intensify(0.6));
        Colors finalLight = ambient;

        // TODO: Fix this in the C# raytracer too
        foreach (PointLight light; pointLights)
        {
            Ray shadowRay = Ray(point, (light.point - point).Normalize());
            double distanceToLight = (light.point - point).Length();
            double nearestDistance = double.infinity;
            double transparency = 1;
            RTObject cachedObj;
            
            void addShadowIntersection(double d)
            {
                if (d > epsilon && d < distanceToLight)
                    transparency *= cachedObj.getMaterial().getTransparency();
            }

            foreach (RTObject obj; objects)
            {
                cachedObj = obj;
                obj.intersects(shadowRay, &addShadowIntersection);
                
            }

            // Ignore this light, because there is an opaque object in the way.
            if (transparency == 0)
                continue;

            double angle = Vector.Angle(shadowRay.direction, normal);
            double intensity = 0;

            if (angle < 0)
                Stdout.formatln("Holy crap, negative angle!");
            
            if (angle >= PI / 2)
                angle = PI - angle;
            
            if (angle < (PI / 2) && angle >= 0)
                intensity = 1.0 - (angle / (PI / 2.0));

            Colors lightColor = light.getColor.intensify(intensity).intensify(transparency);

            finalLight = finalLight + lightColor;
        }
        
        double angle = Vector.Angle(-1 * ray.direction, normal);
        double r1 = 1;
        double r2 = 1.45;
        
        if (angle >= PI / 2)
        {
            normal = -1 * normal; r1 = 1.45; r2 = 1;
        }
        
        double transparency = rTobj.getMaterial.getTransparency();
        double reflectivity = rTobj.getMaterial.getReflectivity();
        
        bool totalInternalReflection;
        
        if (depth < MaxDepth && transparency != 0)
        {
            Ray refractedRay;
            
            refractedRay.point = ray.point + ray.direction * 
                    (nearestIntersection.distance);
            refractedRay.direction = getRefractedRayDirection(ray.direction, 
                    normal, r1, r2, totalInternalReflection);
            
            if (!totalInternalReflection)
            {
                Colors refractedRayColor = GetRayColor(refractedRay, depth+1);
                
                finalLight = finalLight.intensify(1 - transparency) + 
                        refractedRayColor.intensify(transparency);
            }
        }
        
        if (totalInternalReflection)
            reflectivity += (1 - reflectivity) * transparency;
        
        if (depth < MaxDepth && reflectivity != 0)
        {
            Ray reflectedRay;
            
            reflectedRay.point = ray.point + ray.direction * 
                    (nearestIntersection.distance);
            reflectedRay.direction = getReflectedRayDirection(ray.direction, 
                    normal);
            
            Colors reflectedRayColor = GetRayColor(reflectedRay, depth+1);
            
            finalLight = finalLight.intensify(1 - reflectivity) + 
                    reflectedRayColor.intensify(reflectivity);
        }
        
        return finalLight;
    }
    
    private Vector getReflectedRayDirection(Vector incident, Vector normal)
    {
        return incident - (normal * 2.0 * (normal * incident));
    }
    
    // According to Snell's law
    private Vector getRefractedRayDirection1(Vector incident, Vector normal,
            double rIndex1, double rIndex2, out bool totalInternalReflection)
    {
        double r = rIndex1 / rIndex2;
        
        //if (r == 1)
        //    return incident;
        
        double cos_i = incident * normal;
        double sin2_t = r * r * (1 - cos_i * cos_i);
        
        totalInternalReflection = (sin2_t > 1.0);
        if (totalInternalReflection)
            return Vector(0, 0, 0);
        
        return (r * incident - (r * cos_i + sqrt(1 - sin2_t)) * normal).Normalize();
    }

    private Vector getRefractedRayDirection(Vector incident, Vector normal,
            double rIndex1, double rIndex2, out bool totalInternalReflection)
    {
        double r = rIndex1 / rIndex2;
        
        //if (r == 1)
        //    return incident;
        
        double cos_1 = (-1 * incident) * normal;
        double v = 1 - r * r * (1 - cos_1 * cos_1);
        
        totalInternalReflection = (v < 0);
        if (totalInternalReflection)
            return Vector(0, 0, 0);
        
        double cos_2 = sqrt(v);
        
        if (cos_1 < 0)
        {
            cos_2 = -cos_2;
            Stdout("minus").newline;
        }
        //else
            //Stdout("plus").newline;
        
        Vector result = r * incident + (r * cos_1 - cos_2) * normal;
        //if (result.Length() < 0.98 || result.Length() > 1.02)
        //    Stdout("Result's length: ")(result.Length()).newline;
        return result.Normalize();
    }

    public Colors getPixel(uint x, uint y)
    {
        double X = left + x * ((right - left) / width);
        double Y = top - y * ((top - bottom) / height);

        Ray ray = Ray();
        ray.point = camera;
        ray.direction = (Vector(X, Y, 0) - camera).Normalize();

        return GetRayColor(ray, 0);
    }

    public void SetCamera(Vector newCamera)
    {
        camera = newCamera;
    }

    public void addLight(Vector position, Colors color, double fade_distance)
    {
        pointLights ~= new PointLight(position, color, fade_distance);
    }

    public void addLight(PointLight light)
    {
        pointLights ~= light;
    }

    public void addObject(MathShape shape, Material material)
    {
        addObject(new RTObject(shape, material));
    }

    public void addObject(MathShape shape)
    {
        addObject(new RTObject(shape));
    }
    
    public void addObject(RTObject object)
    {
        
        objects ~= object;
    }
    
    public void applyCurrentTransformation(RTObject object)
    {
        object.shape.setTransformation(transformationStack.getTransformation());
    }
}

class Utils
{
    public static void Write(char[] line)
    {
//        fs = new StreamWriter("console_out.txt", true);
//
//        fs.WriteLine(line);
//
//        fs.Close();
        return;
    }
}
