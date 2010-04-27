module sceneparser.shapes.Sphere;

import sceneparser.shapes.Shape;
import raytracer.Colors;
import raytracer.Materials;
import raytracer.MathShapes;
import raytracer.RTObject;
import raytracer.Textures;
import raytracer.Vector;
import sceneparser.general.Context;
import sceneparser.general.Expression;
import sceneparser.general.ParameterList;
import sceneparser.general.Value;

import tango.io.Stdout;
import tango.text.convert.Format;

class Sphere: Shape
{
    private Vector center = {0, 0, 0};
    private double radius;
    private Colors color = {0, 0, 0};
    double reflectivity = 0, transparency = 0;
    Texture texture;

    Expression parameters;
    bool init = false;

    public this(Context con, Expression expr)
    {
        super(con);
        parameters = expr;
    }

    private void checkParameters()
    {
        try
        {
            ParameterList p_list = cast(ParameterList)parameters;
            int i = 0;
            
            if (p_list[i].isVector)
                center = p_list[i++].toVector;
            radius = p_list[i++].toNumber;
            
            if (p_list.length >= i + 1)
                color = p_list[i++].toColor();
            if (p_list.length >= i + 1)
                reflectivity = p_list[i++].toNumber;
            if (p_list.length >= i + 1)
                transparency = p_list[i++].toNumber;
            if (p_list.length >= i + 1)
                texture = p_list[i++].toReference!(Texture)();
        }
        catch (TypeMismatchException)
        {
            Stdout("Error handling parameters to sphere.").newline;
        }
    }

    private RTObject createRTObject()
    {
        checkParameters();
        Material material;
        
        if (texture)
            material = new TexturedMaterial(texture, reflectivity, transparency);
        else
            material = new SolidColorMaterial(color, reflectivity, transparency);
        
        RTObject object = new RTObject(new MathSphere(center, radius), material);
        context.rt.applyCurrentTransformation(object);
        
        return object;
    }

    public override ObjectReference getValue()
    {
        return new ObjectReference(createRTObject());
    }
}
