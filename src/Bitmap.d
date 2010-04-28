module Bitmap;

import raytracer.AntiAliaser;
import raytracer.Colors;
import raytracer.RayTracer;
import lodepng.Encode;

import tango.util.log.Config;
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

public int threads = 0;

alias ubyte[4] RGBA;

void threadedRun(void delegate() dg)
{
    Thread[] t = new Thread[](threads);

    for (int i = 0; i < threads; i++)
        t[i] = new Thread(dg);

    for (int i = 0; i < threads; i++)
        t[i].start();

    for (int i = 0; i < threads; i++)
        t[i].join();
}

public class Bitmap: ColorPixmap
{
    ubyte[4][][] pixels;
    int width, height;
    
    public this(int width, int height)
    {
        pixels = new ubyte[4][][](height, width);
        this.width = width;
        this.height = height;
    }
    
    public void setPixelColor(int x, int y, ubyte[4] color)
    {
        pixels[y][x][0..4] = color[0..4];
    }
    
    public void setPixelColor(int x, int y, Colors color)
    {
        pixels[y][x][0] = cast(ubyte) (color.R * 255);
        pixels[y][x][1] = cast(ubyte) (color.G * 255);
        pixels[y][x][2] = cast(ubyte) (color.B * 255);
        pixels[y][x][3] = cast(ubyte) (color.A * 255);
    }
    
    public Colors getPixelColor(int x, int y)
    {
        ubyte[4] pixel = pixels[y][x];
        return Colors.fromUByte(pixel[0], pixel[1], pixel[2], pixel[3]);
    }
    
    public int getWidth()
    {
        return width;
    }
    
    public int getHeight()
    {
        return height;
    }
    
    public void fillFrom(Colors delegate(double x, double y, 
            RayDebuggerCallback callback = null) renderer)
    {
        for (int y = 0; y < height; y++)
            for (int x = 0; x < width; x++)
                setPixelColor(x, y, renderer(x, y));
    }
    
    public void threadedFillFrom(Colors delegate(double x, double y, 
            RayDebuggerCallback callback = null) renderer)
    {
        if (threads == 0)
            threads = coresPerCPU();

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
                for (int x = 0; x < width; x++)
                    setPixelColor(x, y, renderer(x, y));
            }
        }

        threadedRun(&renderLines);
    }
    
    public void applyAntiAliasing(RayTracer raytracer, Bitmap destination, 
            double threshold = 0.1, int level = 3)
    {
        Object mutex = new Object();
        int line = -1;
        
        int getLine()
        {
            synchronized(mutex)
            {
                line++;

                if (line >= height - 1)
                    return -1;
                else
                    return line;
            }
        }

        void antiAliasLines()
        {
            ColorPixmap source = this;
            AntiAliaser antiAliaser = new AntiAliaser(raytracer, source, 
                    destination, threshold, level);
            int y;

            while ((y = getLine()) >= 0)
            {
                antiAliaser.antiAliasLine(y);
            }
        }

        threadedRun(&antiAliasLines);
    }
    
    public ubyte[] toArray()
    {
        ubyte[] byteArray = new ubyte[width*height*4];
        
        for (int y = 0; y < height; y++)
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
