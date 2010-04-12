module raydebugger.AntiAliaser;

import raydebugger.EasyPixbuf;
import raytracer.Math;

alias void delegate (int x, int y, out ubyte red, out ubyte green, out ubyte blue) GetColorDelegate;
alias void delegate (int x, int y) MarkerDelegate;

class AntiAliaser
{
    static void markEdgePixels(double threshold, EasyPixbuf pixbuf,
            MarkerDelegate mark)
    {
        for (int x = 0; x < pixbuf.width - 1; x++)
            for (int y = 0; y < pixbuf.height - 1; y++)
            {
                ubyte red1, green1, blue1;
                ubyte red2, green2, blue2;
                
                // Probably not the best color distance formula... but it's
                // better than nothing.
                bool pixelIsDifferent(int x, int y)
                {
                    pixbuf.getPixelColor(x, y, red2, green2, blue2);
                    
                    double redDiff = (cast(double)red1 - cast(double)red2);
                    double greenDiff = (cast(double)green1 - cast(double)green2);
                    double blueDiff = (cast(double)blue1 - cast(double)blue2);
                    
                    double diff = (abs(redDiff) + abs(greenDiff) + abs(blueDiff)) / (255*3);
                    
                    if (diff > threshold)
                        return true;
                    else
                        return false;
                }
                
                pixbuf.getPixelColor(x, y, red1, green1, blue1);
                
                if (pixelIsDifferent(x, y+1) ||
                    pixelIsDifferent(x+1, y) ||
                    pixelIsDifferent(x+1, y+1))
                    mark(x, y);
            }
    }
}
