module raydebugger.RayDebugger;

import tango.util.log.Config;
import gdk.Color;
import gdk.Drawable;
import gdk.GC;
import raytracer.Colors;
import raytracer.MathShapes;
import raytracer.RTObject;
import raytracer.RayTracer;
import raytracer.Vector;
import raydebugger.DebugWindow;
import raydebugger.EasyPixbuf;
import raydebugger.Shapes;

// Record the information received through the RayDebuggerCallback.
struct RayInfo
{
    int depth;
    Ray ray;
    double intersectionDistance; 
    RTObject intersectedObject;
    Colors color;
    RayType rayType;
}

class RayDebugger
{
    RayTracer rayTracer;
    Shape[] shapes;
    RayInfo[] rays;
    
    public this(RayTracer rayTracer)
    {
        this.rayTracer = rayTracer;
        
        getObjectsFrom(rayTracer);
    }
    
    private void getObjectsFrom(RayTracer rayTracer)
    {
        foreach (RTObject obj; rayTracer.objects)
        {
            MathShape mathShape = obj.getShape();
            
            if (MathCube mathCube = cast(MathCube) mathShape)
            {
                Cube dbgCube = new Cube(mathCube.center, mathCube.length, 
                        mathCube.transformation);
                shapes ~= dbgCube;
            }
        }
    }
    
    public void recordRays(int x, int y)
    {
        void rayDebuggerCallback(int depth, Ray ray, double intersectionDistance, 
                RTObject intersectedObject, Colors color, RayType rayType)
        {
            RayInfo rayInfo = { depth, ray, intersectionDistance,
                    intersectedObject, color, rayType };
            rays ~= rayInfo;
        }
        
        rays.length = 0;
        rayTracer.getPixel(x, y, &rayDebuggerCallback);
    }
    
    public void drawGrid(Drawable canvas, GC gc, double scale = 2)
    {
        int centerX = width / 2;
        int centerY = height / 2;
        
        for (int x = -width; x <= width; x += 10)
            canvas.drawLine(gc,
                    centerX + cast(int) (x * scale), centerY + -height,
                    centerX + cast(int) (x * scale), centerY + height);
        
        for (int y = -height; y <= height; y += 10)
            canvas.drawLine(gc, 
                    centerX + -width, centerY + cast(int) (y * scale), 
                    centerX + width, centerY + cast(int) (y * scale));
    }
    
    public void drawGrid(EasyPixbuf pixbuf, Colors color, double scale = 2)
    {
        int centerX = width / 2;
        int centerY = height / 2;
        
        for (int x = -width; x <= width; x += 10)
        {
            int cx = centerX + cast(int) (x * scale);
            
            if (cx < 0 || cx >= width)
                continue;
            
            for (int y = 0; y < height; y++)
                pixbuf.setPixelColor(cx, y, color);
        }
        
        for (int y = -height; y <= height; y += 10)
        {
            int cy = centerY + cast(int) (y * scale);
            
            if (cy < 0 || cy >= height)
                continue;
            
            for (int x = 0; x < width; x++)
                pixbuf.setPixelColor(x, cy, color);
        }
    }
    
    public void drawObjects(Drawable canvas, GC gc, int axis1, int axis2,
            int dir1, int dir2, double scale = 2)
    {
        void drawLine(Vector from, Vector to)
        {
            int centerX = width / 2;
            int centerY = height / 2;
            
            canvas.drawLine(gc,
                    centerX + cast(int) (scale * dir1 * from.v[axis1]),
                    centerY + cast(int) (scale * dir2 * from.v[axis2]),
                    centerX + cast(int) (scale * dir1 * to.v[axis1]),
                    centerY + cast(int) (scale * dir2 * to.v[axis2]));
        }
        
        foreach (Shape shape; shapes)
            shape.draw(&drawLine);
        
        foreach (RayInfo rayInfo; rays)
        {
            Vector intersectionPoint;
            bool intersected = rayInfo.intersectionDistance != double.infinity;
            
            if (intersected)
                intersectionPoint = rayInfo.ray.point + 
                        rayInfo.ray.direction * rayInfo.intersectionDistance;
            else
                intersectionPoint = rayInfo.ray.point + 
                        rayInfo.ray.direction * 1000;
            
            void setColor(ubyte red, ubyte green, ubyte blue)
            {
                gc.setRgbFgColor(new Color(red, green, blue));
            }
            
            // Show the normal.
            if (intersected && showNormals)
            {
                Vector normal = rayInfo.intersectedObject.getShape
                        .getNormal(intersectionPoint);
                
                setColor(255, 0, 255);
                Vector temp = intersectionPoint + normal * 10;
                drawLine(intersectionPoint, temp);
            }
            
            // And the ray.
            if (rayInfo.rayType == RayType.NormalRay)
                setColor(255, 0, 0);
            else if (rayInfo.rayType == RayType.ReflectionRay)
                setColor(0, 255, 0);
            else if (rayInfo.rayType == RayType.TransmissionRay)
                setColor(0, 0, 255);
            
            drawLine(rayInfo.ray.point, intersectionPoint);
        }
    }
    
    public void renderOrtho(EasyPixbuf pixbuf, int line,
            int axis1, int axis2, int dir1, int dir2, double scale = 2)
    {
        int centerX = width / 2;
        int centerY = height / 2;
        
        int axis3;
        
        if (axis1 != 0 && axis2 != 0)
            axis3 = 0;
        else if (axis1 != 1 && axis2 != 1)
            axis3 = 1;
        else if (axis1 != 2 && axis2 != 2)
            axis3 = 2;
        
        Vector direction;
        direction.v[axis1] = 0;
        direction.v[axis2] = 0;
        direction.v[axis3] = 1;
        
        Vector getOriginForPixel(int x, int y)
        {
            Vector origin;
            origin.v[axis1] = cast(double) ((x - centerX) * dir1) / scale;
            origin.v[axis2] = cast(double) ((y - centerY) * dir2) / scale;
            origin.v[axis3] = -10000;
            
            return origin;
        }
        
        for (int x = 0; x < width; x++)
        {
            Ray ray = Ray(getOriginForPixel(x, line), direction);
            RTObject foremostObject = null;
            double distance = double.infinity;
            
            foreach (RTObject obj; rayTracer.objects)
            {
                if (cast(MathPlane) obj.getShape)
                    continue;
                
                void addIntersection(double d)
                {
                    if (d < distance)
                    {
                        foremostObject = obj;
                        distance = d;
                    }
                }
                
                obj.intersects(ray, &addIntersection);
            }
            
            if (foremostObject)
                pixbuf.blendPixelColor(x, line, foremostObject.getColor(), 0.4);
        }
    }
}
