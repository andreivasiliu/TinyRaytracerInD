module raydebugger.AntiAliaser;

import raytracer.RayTracer;
import raytracer.Colors;
import raytracer.Math;

alias void delegate (int x, int y) MarkerDelegate;

class AntiAliaser
{
    RayTracer rayTracer;
    ColorPixmap source;
    ColorPixmap antiAliasedDestination;
    double threshold;
    int rayCounter;
    
    // Note: this makes it not thread-safe; multiple instances of this class
    // must be used for multi-threading support.
    private Colors[][] subPixels;
    private bool[][] subPixelIsRendered;
    
    private int level;
    private int size;
    
    public this(RayTracer rayTracer, ColorPixmap source, ColorPixmap destination,
            double threshold = 0.1, int level = 3)
    {
        this.rayTracer = rayTracer;
        this.source = source;
        this.threshold = threshold;
        
        antiAliasedDestination = destination;
        
        this.level = level;
        this.size = (1 << level) + 1;
        
        subPixels = new Colors[][](size, size);
        subPixelIsRendered = new bool[][](size, size);
    }
    
    public void setThreshold(double threshold)
    {
        this.threshold = threshold;
    }
    
    // TODO: Find a proper name for these methods.
    public void antiAliasAll()
    {
        for (int y = 0; y < source.getHeight - 1; y++)
            antiAliasLine(y);
    }
    
    public void antiAliasLine(int y)
    {
        for (int x = 0; x < source.getWidth - 1; x++)
            antiAliasedDestination.setPixelColor(x, y, getAntiAliasedPixel(x, y));
        
        // Copy the last pixel.
        antiAliasedDestination.setPixelColor(source.getWidth - 1, y, 
                source.getPixelColor(source.getWidth - 1, y));
    }
    
    private void clearMatrices()
    {
        for (int y = 0; y < size; y++)
            for (int x = 0; x < size; x++)
                subPixelIsRendered[x][y] = false;
    }
    
    public Colors getAntiAliasedPixel(int x, int y)
    {
        clearMatrices();
        
        // Set up this pixel's subpixel matrix.
        // Note that which dimension is Y and which is X does not actually
        // matter; the result is the same.
        subPixels[0][0] = source.getPixelColor(x, y);
        subPixels[0][size-1] = source.getPixelColor(x, y+1);
        subPixels[size-1][0] = source.getPixelColor(x+1, y);
        subPixels[size-1][size-1] = source.getPixelColor(x+1, y+1);
        subPixelIsRendered[0][0] = true;
        subPixelIsRendered[0][size-1] = true;
        subPixelIsRendered[size-1][0] = true;
        subPixelIsRendered[size-1][size-1] = true;
        
        Colors subRenderer(int subX, int subY)
        {
            if (subPixelIsRendered[subX][subY])
                return subPixels[subX][subY];
            
            rayCounter++;
            
            subPixels[subX][subY] = 
                rayTracer.getPixel(x + subX / cast(double)size, 
                        y + subY / cast(double)size);
            subPixelIsRendered[subX][subY] = true;
            return subPixels[subX][subY];
        }
        
        Colors finalColor = getSubpixelColor(0, 0, size-1, size-1,
                level, &subRenderer);
        
        return finalColor;
    }
    
    private alias Colors delegate(int subX, int subY) SubRenderer;
    
    private Colors getSubpixelColor(int x1, int y1, int x2, int y2, 
            int level, SubRenderer render)
    {
        // Render the corners that are not already rendered.
        Colors color1 = render(x1, y1); // upper left
        Colors color2 = render(x2, y1); // upper right
        Colors color3 = render(x1, y2); // lower left
        Colors color4 = render(x2, y2); // lower right
        
        // Check how different they are.
        bool different = pixelsAreDifferent(color1, color2, threshold) ||
                         pixelsAreDifferent(color1, color3, threshold) ||
                         pixelsAreDifferent(color1, color4, threshold);
        
        // If they are not too different, just return the average of the four.
        if (!different || level <= 0)
            return colorAverage(color1, color2, color3, color4);
        
        // Otherwise, divide the subpixel in four smaller subpixels.
        int midX = x1 + (x2-x1) / 2;
        int midY = y1 + (y2-y1) / 2;
        assert(x2-x1 >= 2 && y2-y1 >= 2);
        
        color1 = getSubpixelColor(x1, y1, midX, midY, level-1, render);
        color2 = getSubpixelColor(midX, y1, x2, midY, level-1, render);
        color3 = getSubpixelColor(x1, midY, midX, y2, level-1, render);
        color4 = getSubpixelColor(midX, midY, x2, y2, level-1, render);
        
        return colorAverage(color1, color2, color3, color4);
    }
    
    private static bool pixelsAreDifferent(Colors color1, Colors color2, 
            double threshold)
    {
        // Probably not the best color distance formula...
        if ((abs(color1.R - color2.R) +
             abs(color1.G - color2.G) +
             abs(color1.B - color2.B) +
             abs(color1.A - color2.A)) / 4 > threshold)
            return true;
        else
            return false;
    }
    
    private static Colors colorAverage(Colors color1, Colors color2, 
            Colors color3, Colors color4)
    {
        double red = (color1.R + color2.R + color3.R + color4.R) / 4;
        double green = (color1.G + color2.G + color3.G + color4.G) / 4;
        double blue = (color1.B + color2.B + color3.B + color4.B) / 4;
        double alpha = (color1.A + color2.A + color3.A + color4.A) / 4;
        
        return Colors(red, green, blue, alpha);
    }
    
    public static void markEdgePixels(double threshold, ColorPixmap pixmap,
            MarkerDelegate mark)
    {
        for (int x = 0; x < pixmap.getWidth - 1; x++)
            for (int y = 0; y < pixmap.getHeight - 1; y++)
            {
                Colors color1 = pixmap.getPixelColor(x, y);
                
                bool pixelIsDifferent(Colors color2)
                {
                    return pixelsAreDifferent(color1, color2, threshold);
                }
                
                if (pixelIsDifferent(pixmap.getPixelColor(x, y+1)) ||
                    pixelIsDifferent(pixmap.getPixelColor(x+1, y)) ||
                    pixelIsDifferent(pixmap.getPixelColor(x+1, y+1)))
                    mark(x, y);
            }
    }
}
