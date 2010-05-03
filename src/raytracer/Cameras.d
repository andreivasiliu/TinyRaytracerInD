module raytracer.Cameras;

import raytracer.Colors;
import raytracer.RayTracer;
import raytracer.Vector;

abstract class Camera
{
    abstract Colors getPixelColor(double x, double y, RayTracer rayTracer,
            RayDebuggerCallback callback = null);
    abstract Ray createRay(double x, double y);
}

class PerspectiveCamera: Camera
{
    private int width, height;
    private Vector center, lookAt, up, right;
    private Vector direction;
    private double aspectRatio;
    
    this(int width, int height, Vector center, Vector lookAt = Vector(0, 0, 0),
            Vector up = Vector(0, 1, 0), Vector right = Vector(0, 0, 0))
    {
        this.width = width;
        this.height = height;
        this.center = center;
        this.lookAt = lookAt;
        this.up = up;
        this.right = right;
        direction = (lookAt - center).normalized();
        aspectRatio = cast(double)width / cast(double)height;
        
        if (right.length() == 0)
        {
            // FIXME: Remove the negation after switching to a proper coordinate system
            this.right = -Vector.crossProduct(direction, up);
        }
    }
    
    override Ray createRay(double x, double y)
    {
        // Get coordinates in the range -0.5 .. 0.5
        double sx = ((x / width) - 0.5) * aspectRatio;
        double sy = ((height - 1 - y) / height - 0.5);
        
        Ray ray;
        ray.direction = direction + sx * right + sy * up;
        ray.point = center;
        return ray;
    }
    
    override Colors getPixelColor(double x, double y, RayTracer rayTracer,
            RayDebuggerCallback callback = null)
    {
        Ray ray = createRay(x, y);
        return rayTracer.getRayColor(ray, 0, RayType.NormalRay, callback);
    }
}

//TODO: A way to specify cross/parallel viewing
class StereoscopicCamera: Camera
{
    private PerspectiveCamera leftCamera;
    private PerspectiveCamera rightCamera;
    private int width;
   
    this(int width, int height, Vector center, double eyeDistance, 
            Vector lookAt = Vector(0, 0, 0), Vector up = Vector(0, 1, 0),
            Vector right = Vector(0, 0, 0))
    {
        width /= 2;
        this.width = width;
        
        if (right.length() == 0)
        {
            Vector direction = (lookAt - center).normalized();
            
            // FIXME: Remove the negation after switching to a proper coordinate system
            right = -Vector.crossProduct(direction, up);
        }
        
        Vector leftEye = center - right * (eyeDistance / 2);
        Vector rightEye = center + right * (eyeDistance / 2);
        
        leftCamera = new PerspectiveCamera(width, height, leftEye, lookAt, up);
        rightCamera = new PerspectiveCamera(width, height, rightEye, lookAt, up);
    }
    
    override Ray createRay(double x, double y)
    {
        return leftCamera.createRay(x, y);
    }
    
    override Colors getPixelColor(double x, double y, RayTracer rayTracer,
             RayDebuggerCallback callback = null)
    {
        Camera camera = rightCamera;
        
        if (x >= width)
        {
            x -= width;
            camera = leftCamera;
        }
        
        Ray ray = camera.createRay(x, y);
        return rayTracer.getRayColor(ray, 0, RayType.NormalRay, callback);
    }
}

// TODO: Color masks for each eye
class AnaglyphCamera: Camera
{
    private PerspectiveCamera leftCamera;
    private PerspectiveCamera rightCamera;
    private int width;
   
    this(int width, int height, Vector center, double eyeDistance,
            Vector lookAt = Vector(0, 0, 0), Vector up = Vector(0, 1, 0),
            Vector right = Vector(0, 0, 0))
    {
        this.width = width;
        
        if (right.length() == 0)
        {
            Vector direction = (lookAt - center).normalized();
            
            // FIXME: Remove the negation after switching to a proper coordinate system
            right = -Vector.crossProduct(direction, up);
        }
        
        Vector leftEye = center - right * (eyeDistance / 2);
        Vector rightEye = center + right * (eyeDistance / 2);
        
        leftCamera = new PerspectiveCamera(width, height, leftEye, lookAt, up);
        rightCamera = new PerspectiveCamera(width, height, rightEye, lookAt, up);
    }
    
    override Ray createRay(double x, double y)
    {
        return leftCamera.createRay(x, y);
    }
    
    override Colors getPixelColor(double x, double y, RayTracer rayTracer,
             RayDebuggerCallback callback = null)
    {
        Colors color1 = rayTracer.getRayColor(leftCamera.createRay(x, y),
                0, RayType.NormalRay, callback);
        Colors color2 = rayTracer.getRayColor(rightCamera.createRay(x, y),
                0, RayType.NormalRay, callback);
        
        return Colors(color1.R, color2.G, color2.B);
    }
}


// TODO:
// - PanoramicCamera
// - OrthogonalCamera

