module Bitmap;

import raytracer.Colors;
import raytracer.RayTracer;
import lodepng.Encode;

import tango.io.Stdout;
import tango.io.device.File;
import tango.io.model.IConduit;
import tango.core.Thread;

version(Win32)
    import tango.core.tools.Cpuid: coresPerCPU;
else
{
    uint coresPerCPU()
    {
        return 4;
    }
}

alias ubyte[4] RGBA;

public class Bitmap
{
    ubyte[4][][] pixels;
    uint width, height;
    
    public this(uint width, uint height)
    {
        pixels = new ubyte[4][][](height, width);
        this.width = width;
        this.height = height;
    }
    
    public void setPixel(uint x, uint y, ubyte[4] color)
    {
        pixels[y][x][0..4] = color[0..4];
    }
    
    public void setPixel(uint x, uint y, Colors color)
    {
        pixels[y][x][0] = cast(ubyte) (color.R * 255);
        pixels[y][x][1] = cast(ubyte) (color.G * 255);
        pixels[y][x][2] = cast(ubyte) (color.B * 255);
        pixels[y][x][3] = cast(ubyte) (color.A * 255);
    }
    
    public void fillFrom(Colors delegate(double x, double y, 
            RayDebuggerCallback callback = null) renderer)
    {
        for (uint y = 0; y < height; y++)
            for (uint x = 0; x < width; x++)
                setPixel(x, y, renderer(x, y));
    }
    
    public void threadedFillFrom(Colors delegate(double x, double y, 
            RayDebuggerCallback callback = null) renderer)
    {
        Object mutex = new Object();
        int line = -1;

        int getLine()
        {
            synchronized(mutex)
            {
                line++;

                if (line >= height)
                    return -1;
                else
                    return line;
            }
        }

        void renderLines()
        {
            int y;

            while ((y = getLine()) >= 0)
            {
                for (uint x = 0; x < width; x++)
                    setPixel(x, y, renderer(x, y));
            }
        }

        final int threads = coresPerCPU();
        Thread[] t = new Thread[](threads);

        for (int i = 0; i < threads; i++)
            t[i] = new Thread(&renderLines);

        for (int i = 0; i < threads; i++)
            t[i].start();

        for (int i = 0; i < threads; i++)
            t[i].join();
    }
    
    public ubyte[] toArray()
    {
        ubyte[] byteArray = new ubyte[width*height*4];
        
        for (uint y = 0; y < height; y++)
            byteArray[y*width*4 .. (y+1)*width*4] =
                (cast(ubyte[]) pixels[y])[0..width*4];
        
        return byteArray;
    }
    
    public void savePng(char[] fileName)
    {
        Settings pngSettings;
        pngSettings = Settings(PngImage(width, height, 8, ColorType.RGBA));
        ubyte[] rawInput = this.toArray();
        
        Stdout("Encoding ")(rawInput.length)(" bytes.").newline;
        ubyte[] pngOutput = encode(rawInput, pngSettings);
        
        File file = new File(fileName, File.WriteCreate);
        OutputStream os = file.output();
        os.write(pngOutput);
        os.close();
    }
}
