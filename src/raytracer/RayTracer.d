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

public class RayTracer
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
        this(Vector(0, 0, -100), 40, -40, -60, 60, Width, Height);
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
                if (d < nearestIntersection.distance)
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

        Colors c = (cast(SolidColorMaterial)rTobj.material).getColor;

        Colors ambient = c.Multiply((Colors.inRange(1, 1, 1)).Intensify(0.6));
        Colors finalLight = ambient;

        // TODO: Fix this in the C# raytracer too
        foreach (PointLight light; pointLights)
        {
            Ray shadowRay = Ray(point, (light.point - point).Normalize());
            double distanceToLight = (light.point - point).Length();
            double nearestDistance = double.infinity;
            
            void addShadowIntersection(double d)
            {
                if (d > epsilon && d < nearestDistance)
                    nearestDistance = d;
            }

            foreach (RTObject obj; objects)
                obj.intersects(shadowRay, &addShadowIntersection);

            // Ignore this light, because there is an object in the way.
            if (nearestDistance <= distanceToLight)
                continue;

            double angle = Vector.Angle(shadowRay.direction, rTobj.getShape.getNormal(point));
            double intensity = 0;

            if (angle < (PI / 2) && angle >= 0)
                intensity = 1.0 - (angle / (PI / 2.0));

            Colors lightColor = light.getColor.Intensify(intensity);

            finalLight = finalLight + lightColor;
        }
        
        if (depth > MaxDepth)
            return finalLight;

        Ray reflectionRay = Ray();
        reflectionRay.point = ray.point + ray.direction * (nearestIntersection.distance - epsilon);

        reflectionRay.direction = ray.direction + ( rTobj.getShape.getNormal(point) * 2.0 * (- (rTobj.getShape.getNormal(point) * ray.direction)));
        
        return finalLight.Intensify(1 - rTobj.getMaterial.GetReflectivity()) + GetRayColor(reflectionRay, 
            depth+1).Intensify(rTobj.getMaterial.GetReflectivity());
    }

    public Colors GetPixel(uint x, uint y)
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
        Transformation transformation = transformationStack.getTransformation();
        if (transformation !is null)
            object.shape.setTransformation(transformation);
        
        objects ~= object;
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
