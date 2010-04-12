module raydebugger.EasyPixbuf;

import tango.util.log.Config;
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
    
    public this(int width, int height, bool hasAlpha)
    {
    super(GdkColorspace.RGB, hasAlpha, 8, width, height);
    
    this.width = width;
    this.height = height;
    
    rowstride = super.getRowstride();
        ubyte *pixelsPtr = cast (ubyte*) super.getPixels();
        pixels = pixelsPtr[0 .. height * rowstride];
        nChannels = super.getNChannels();
    
    assert(nChannels == 4);
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
    
    public final void setPixelAlpha(int x, int y, ubyte alpha)
    {
        int pos = y * rowstride + x * nChannels;
        ubyte[] pixel = pixels[pos .. pos+4];
        
        pixel[3] = alpha;
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

class EasyBitbuf: Pixbuf
{
    public int width;
    public int height;
    
    ubyte[] pixels;
    int rowstride;
    
    public this(Drawable src, int srcX, int srcY, int width, int height)
    {
        super(src, srcX, srcY, width, height);
        
        this.width = super.getWidth();
        this.height = super.getHeight();
        
        rowstride = super.getRowstride();
        ubyte *pixelsPtr = cast (ubyte*) super.getPixels();
        
        pixels = pixelsPtr[0 .. height * rowstride];
        
        Log("Bits per sample: {}.", super.getBitsPerSample());
        Log("Channels: {}.", super.getNChannels());
        assert(super.getBitsPerSample() == 1);
        assert(super.getNChannels() == 1);
    }
    
    public void drawOntoDrawable(Drawable drawable)
    {
        drawable.drawPixbuf(null, this, 0, 0, 0, 0, -1, -1,
        GdkRgbDither.NONE, 0, 0);
    }
    
    public void fill(bool bit)
    {
    if (bit)
    pixels[] = ~cast(ubyte)0;
    else
    pixels[] = 0;
    }
    
    public final bool getPixelBit(int x, int y)
    {
    int bitPos = x % 8;
        int pos = y * rowstride + x / 8;
        bool bit = (pixels[pos] & (1 << bitPos)) ? 1 : 0;
        
        return bit;
    }
    
    public final void setPixelBit(int x, int y, bool bit)
    {
    int bitPos = x % 8;
        int pos = y * rowstride + x / 8;
        
        if (bit)
        pixels[pos] |= 1 << bitPos;
        else
        pixels[pos] &= ~(1 << bitPos);
    }
}
