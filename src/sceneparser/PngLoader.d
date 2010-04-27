module sceneparser.PngLoader;

import raytracer.Colors;
import lodepng.Decode;

RTPixmap pngToRTPixmap(ubyte[] pngBytes)
{
    PngInfo pngInfo;
    ubyte[] pixels = decode32(pngBytes, pngInfo);
    
    int width = pngInfo.image.width;
    int height = pngInfo.image.height;
    
    RTPixmap pixmap = new RTPixmap(width, height);
    
    Colors getColorAt(int x, int y)
    {
        ubyte[] line = pixels[y * 4 * width .. (y+1) * 4 * width];
        ubyte[] pixel = line[x * 4 .. (x+1) * 4];
        return Colors.fromUByte(pixel[0], pixel[1], pixel[2], pixel[3]);
    }
    
    for (int x = 0; x < width; x++)
        for (int y = 0; y < height; y++)
            pixmap.setColorAt(x, y, getColorAt(x, y));
    
    delete pixels;
    
    return pixmap;
}

