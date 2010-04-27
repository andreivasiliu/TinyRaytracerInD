module raytracer.Textures;

import raytracer.Vector;
import raytracer.Colors;

public abstract class Texture
{
    public abstract Colors getColorAt(UV uvCoordinates);
}

public class PixmapTexture: Texture
{
    RTPixmap pixmap;
    
    public this(RTPixmap pixmap)
    {
        assert(pixmap !is null);
        
        this.pixmap = pixmap;
    }
    
    public override Colors getColorAt(UV uvCoordinates)
    {
        int width = pixmap.getWidth;
        int height = pixmap.getHeight;
        int x = cast(int) (uvCoordinates.u * (width - 1));
        int y = height - cast(int) (uvCoordinates.v * (height - 1)) - 1;
        
        return pixmap.getColorAt(x, y);
    }
}
