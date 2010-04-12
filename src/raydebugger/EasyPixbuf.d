module raydebugger.EasyPixbuf;

import raytracer.Colors;
import gdk.Drawable;
import gdk.Pixbuf;

class EasyPixbuf: Pixbuf
{
    public int width;
    public int height;
    
    ubyte[] pixels;
    int rowstride;
    int nChannels;
    
    public this(Drawable src, int srcX, int srcY, int width, int height)
    {
        super(src, srcX, srcY, width, height);
        
        this.width = super.getWidth();
        this.height = super.getHeight();
        
        rowstride = super.getRowstride();
        ubyte *pixelsPtr = cast (ubyte*) super.getPixels();
        pixels = pixelsPtr[0 .. height * rowstride];
        nChannels = super.getNChannels();
        
        assert(super.getBitsPerSample() == 8);
        assert(nChannels == 3);
    }
    
    public final void getPixelColor(int x, int y, 
            out ubyte red, out ubyte green, out ubyte blue)
    {
        int pos = y * rowstride + x * nChannels;
        ubyte[] pixel = pixels[pos .. pos+3];
        
        red = pixel[0];
        green = pixel[1];
        blue = pixel[2];
    }
    
    public final void setPixelColor(int x, int y, Colors color)
    {
        setPixelColor(x, y, 
                cast (ubyte) (color.R * 255),
                cast (ubyte) (color.G * 255),
                cast (ubyte) (color.B * 255));
    }
    
    public final void setPixelColor(int x, int y, 
            ubyte red, ubyte green, ubyte blue)
    {
        int pos = y * rowstride + x * nChannels;
        ubyte[] pixel = pixels[pos .. pos+3];
        
        pixel[0] = red;
        pixel[1] = green;
        pixel[2] = blue;
    }
    
    public final void blendPixelColor(int x, int y, Colors color, double alpha)
    {
        blendPixelColor(x, y, 
                cast (ubyte) (color.R * 255),
                cast (ubyte) (color.G * 255),
                cast (ubyte) (color.B * 255),
                cast (ubyte) (alpha * 255));
    }
    
    public final void blendPixelColor(int x, int y,
            ubyte red, ubyte green, ubyte blue, ubyte alpha)
    {
        ubyte dstRed, dstGreen, dstBlue;
        double fAlpha = cast(double) alpha / 255;
        
        getPixelColor(x, y, dstRed, dstGreen, dstBlue);
        
        ubyte finalRed = cast(ubyte) (red * fAlpha + dstRed * (1 - fAlpha));
        ubyte finalGreen = cast(ubyte) (green * fAlpha + dstGreen * (1 - fAlpha));
        ubyte finalBlue = cast(ubyte) (blue * fAlpha + dstBlue * (1 - fAlpha));
        
        setPixelColor(x, y, finalRed, finalGreen, finalBlue);
    }
}