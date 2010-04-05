module raydebugger.RayDebugger;

import tango.io.Stdout;
import gdk.Color;
import gdk.Drawable;
import gdk.GC;
import raytracer.Colors;
import raytracer.MathShapes;
import raytracer.RTObject;
import raytracer.RayTracer;
import raytracer.Vector;
import raydebugger.DebugWindow;
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
    Shape[] shapes;
    RayInfo[] rays;
    
    public void getObjectsFrom(RayTracer rayTracer)
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
    
    public void recordRays(RayTracer rayTracer, int x, int y)
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
    
    public void drawGrid(Drawable canvas, GC gc, int axis1, int axis2,
            double scale = 2)
    {
        const centerX = width / 2;
        const centerY = height / 2;
        
        for (int x = -width; x <= width; x += 10)
            canvas.drawLine(gc,
                    centerX + cast(int) (x * scale), centerY + -height,
                    centerX + cast(int) (x * scale), centerY + height);
        
        for (int y = -height; y <= height; y += 10)
            canvas.drawLine(gc, 
                    centerX + -width, centerY + cast(int) (y * scale), 
                    centerX + width, centerY + cast(int) (y * scale));
    }
    
    public void drawObjects(Drawable canvas, GC gc, int axis1, int axis2,
            int dir1, int dir2, double scale = 2)
    {
        void drawLine(Vector from, Vector to)
        {
            const centerX = width / 2;
            const centerY = height / 2;
            
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
                        rayInfo.ray.direction * 10000;
            
            // Show the normal.
            if (intersected && showNormals)
            {
                Vector normal = rayInfo.intersectedObject.getShape
                        .getNormal(intersectionPoint);
                
                gc.setRgbFgColor(new Color(cast(ubyte) 255, cast(ubyte) 0, cast(ubyte) 255));
                Vector temp = intersectionPoint + normal * 2;
                drawLine(intersectionPoint, temp);
            }
            
            // And the ray.
            if (rayInfo.rayType == RayType.NormalRay)
                gc.setRgbFgColor(new Color(cast(ubyte) 255, cast(ubyte) 0, cast(ubyte) 0));
            else if (rayInfo.rayType == RayType.ReflectionRay)
                gc.setRgbFgColor(new Color(cast(ubyte) 0, cast(ubyte) 255, cast(ubyte) 0));
            else if (rayInfo.rayType == RayType.TransmissionRay)
                gc.setRgbFgColor(new Color(cast(ubyte) 0, cast(ubyte) 0, cast(ubyte) 255));
            
            drawLine(rayInfo.ray.point, intersectionPoint);
        }
    }
}
