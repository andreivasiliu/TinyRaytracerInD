module sceneparser.expressions.TextureFileExpression;

import tango.io.device.File;
import raytracer.Colors;
import raytracer.Textures;
import sceneparser.PngLoader;
import sceneparser.general.Value;
import sceneparser.general.Context;
import sceneparser.general.Expression;

class TextureFileExpression: Expression
{
    Context context;
    Expression fileName;
    
    this(Context context, Expression fileName)
    {
        this.context = context;
        this.fileName = fileName;
    }
    
    override ObjectReference getValue()
    {
        string fileName = this.fileName.getValue.toString();
        
        ubyte[] fileContents = cast(ubyte[]) File.get(fileName);
        RTPixmap pixmap = pngToRTPixmap(fileContents);
        delete fileContents;
        Texture texture = new PixmapTexture(pixmap);

        return new ObjectReference(texture);
    }
}
