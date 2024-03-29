module raytracer.Colors;

import tango.text.convert.Format;
import tango.util.log.Config;

public struct Colors
{
    public double R, G, B, A;

    private static double inLimit(double x, double min, double max)
    {
        if ( x < min )
            return min;
        else if ( x > max )
            return max;
        else 
            return x;
    }

    public static Colors inRange(double R, double G, double B)
    {
        return Colors(inLimit(R, 0, 1), inLimit(G, 0, 1), inLimit(B, 0, 1), 1);
    }
    
    public static Colors fromUByte(ubyte red, ubyte green, ubyte blue, ubyte alpha = 255)
    {
        return Colors(red / 255.0, green / 255.0, blue / 255.0, alpha / 255.0);
    }

    public void toUByte(out ubyte red, out ubyte green, out ubyte blue)
    {
        red = cast(ubyte) (R * 255);
        green = cast(ubyte) (G * 255);
        blue = cast(ubyte) (B * 255);
    }

    public Colors intensify(double intensity)
    {
        return Colors.inRange(R * intensity, G * intensity, B * intensity);
    }

    public Colors opMul(Colors color)
    {
        return Colors.inRange(R * color.R, G * color.G, B * color.B);
    }

    public Colors opAdd(Colors b)
    {
        return Colors.inRange(R + b.R, G + b.G, B + b.B);
    }

    public static Colors Black()
    {
        return Colors(0, 0, 0, 1);
    }
}

public interface ColorPixmap
{
    int getWidth();
    int getHeight();
    
    // FIXME: Choose between either this or setPixelColor.
    public void setPixelColor(int x, int y, Colors color);
    public Colors getPixelColor(int x, int y);
}

public class RTPixmap: ColorPixmap
{
    private int width;
    private int height;
    private Colors[] colorsPixmap;
    
    public this(int width, int height)
    {
        this.width = width;
        this.height = height;
        
        colorsPixmap = new Colors[width * height];
    }
    
    public void setColorAt(int x, int y, Colors color)
    {
        // Maybe add bounds-checking for releases as well?
        assert(x >= 0 && x < width, Format("x = {} is not within the bounds 0..{}", x, width));
        assert(y >= 0 && y < height, Format("y = {} is not within the bounds 0..{}", y, height));
        
        colorsPixmap[y * width + x] = color;
    }
    
    public Colors getColorAt(int x, int y)
    {
        assert(x >= 0 && x < width, Format("x = {} is not within the bounds 0..{}", x, width));
        assert(y >= 0 && y < height, Format("y = {} is not within the bounds 0..{}", y, height));
        
        return colorsPixmap[y * width + x];
    }
    
    public void setPixelColor(int x, int y, Colors color)
    {
        setColorAt(x, y, color);
    }
    
    public Colors getPixelColor(int x, int y)
    {
        return getColorAt(x, y);
    }
    
    public int getWidth()
    {
        return width;
    }
    
    public int getHeight()
    {
        return height;
    }
}
