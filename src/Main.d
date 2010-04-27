module Main;

import tango.io.Stdout;
import tango.io.device.File;
import tango.core.Exception;
import tango.core.Memory;
import tango.core.Thread;
import tango.text.Arguments;
import tango.text.convert.Integer;
import tango.time.StopWatch;
import raytracer.Colors;
import raytracer.RayTracer;
import Bitmap;
import sceneparser.SceneLoader;
import sceneparser.general.Context;

version(Win32) version(DigitalMars)
    import tango.core.tools.TraceExceptions;

version = normal;

version(huge)
    const width = 2560, height = 1920;
else version(big)
    const width = 1280, height = 960;
else version(normal)
    const width = 640, height = 480;
else
    static assert(0, "Please set the size of the output");


int main(char[][] args)
{
    Arguments arguments = new Arguments();
    arguments("frames").defaults("1").params(0, 1);
    arguments("start").defaults("0").params(0, 1);
    arguments("threads").defaults("0").params(0, 1);
    
    if (!arguments.parse(args))
    {
        stderr(arguments.errors(&stderr.layout.sprint));
        return 1;
    }
    
    int frames = parse(arguments("frames").assigned()[0]);
    int start = parse(arguments("start").assigned()[0]);
    threads = parse(arguments("threads").assigned()[0]);
    
    Stdout.formatln("Rendering {} frames, starting from frame {}.", frames, start);
    
    /+
    rayTracer.addObject(new MathSphere(Vector(10, 0, -30), 20), new SolidColorMaterial(1,0,0));
    rayTracer.addObject(new MathPlane(0, 1, 0, 20), new SolidColorMaterial(0, 0, 1, 0));
    rayTracer.addLight(new PointLight(Vector(-10, 50, 20), Colors.inRange(0.5, 0.5, 0.5), 100));
    +/

    for (int frame = start; frame < frames; frame++)
    {
        if(!renderFrame(frame))
            return 1;
        
        GC.collect();
        GC.minimize();
    }
    
    Stdout("Done!").newline();
    
    return 0;
}

bool renderFrame(int frame)
{
    RayTracer rayTracer = new RayTracer(width, height);
    Bitmap bitmap = new Bitmap(width, height);
    
    Stdout("Parsing code for frame ")(frame)("...").newline();
    
    try
    {
        scope SceneLoader sceneLoader = new SceneLoader();
        sceneLoader.setRaytracer(rayTracer);
        sceneLoader.setFrame(frame);
        scope File sceneScript = new File("scene.cad");
        sceneLoader.execute(sceneScript);
    }
    catch (IOException e)
    {
        Stdout("Cannot read cod.cad: " ~ e.msg).newline;
        return false;
    }
    
    Stdout("Rendering...").newline();
    try
    {
        StopWatch renderTime;
        
        renderTime.start();
        bitmap.threadedFillFrom(&rayTracer.getPixel);
        bitmap.applyAntiAliasing(rayTracer);
        double time = renderTime.stop();
        
        Stdout.formatln("Done. Render time: {}.", time);
    }
    catch (Exception e)
    {
        e.writeOut((char[] msg) { Stdout(msg); });
        return false;
    }
    
    Stdout("Saving...");
    bitmap.savePng("output" ~ toString(frame) ~ ".png");
    return true;
}
