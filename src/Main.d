module Main;

import tango.io.Stdout;
import tango.io.device.File;
import tango.core.Exception;
import tango.core.tools.TraceExceptions;
import raytracer.Colors;
import raytracer.Materials;
import raytracer.MathShapes;
import raytracer.PointLight;
import raytracer.RayTracer;
import raytracer.Vector;
import Bitmap;
import sceneparser.SceneLoader;
import sceneparser.general.Context;

int main()
{
    
    RayTracer rayTracer = new RayTracer(640, 480);
    Bitmap bitmap = new Bitmap(640, 480);
    /+
    rayTracer.addObject(new MathSphere(Vector(10, 0, -30), 20), new SolidColorMaterial(1,0,0));
    rayTracer.addObject(new MathPlane(0, 1, 0, 20), new SolidColorMaterial(0, 0, 1, 0));
    rayTracer.addLight(new PointLight(Vector(-10, 50, 20), Colors.inRange(0.5, 0.5, 0.5), 100));
    +/

    Stdout("Parsing...").newline();
    
    try
    {
        scope SceneLoader sceneLoader = new SceneLoader();
        sceneLoader.setRaytracer(rayTracer);
        scope File sceneScript = new File("cod.cad");
        sceneLoader.execute(sceneScript);
    }
    catch (IOException e)
    {
        Stdout("Cannot read cod.cad: " ~ e.msg).newline;
        return 1;
    }
    
    Stdout("Rendering...").newline();
    try
    {
        bitmap.fillFrom(&rayTracer.GetPixel);
    }
    catch (Exception e)
    {
        e.writeOut((char[] msg) { Stdout(msg); });
        return 1;
    }
    
    Stdout("Saving...");
    bitmap.savePng("output.png");
    
    Stdout("Done!").newline();
    
    return 0;
}
