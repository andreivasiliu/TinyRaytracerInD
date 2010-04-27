module sceneparser.shapes.Plane;

import raytracer.Colors;
import raytracer.Materials;
import raytracer.MathShapes;
import raytracer.RTObject;
import raytracer.Transformation;
import raytracer.Vector;
import sceneparser.general.Context;
import sceneparser.general.Expression;
import sceneparser.general.ParameterList;
import sceneparser.general.Value;
import sceneparser.shapes.Shape;

import tango.io.Stdout;
import tango.text.convert.Format;

class Plane: Shape
{
    Vector normal;
    double distance;
    Colors color = {0, 0, 0};
    double reflectivity = 0, transparency = 0;

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
            
            normal = p_list[i++].toVector;
            distance = p_list[i++].toNumber;
            
            if (p_list.length >= i + 1)
                color = p_list[i++].toColor();
            if (p_list.length >= i + 1)
                reflectivity = p_list[i++].toNumber;
            if (p_list.length >= i + 1)
                transparency = p_list[i++].toNumber;
        }
        catch (TypeMismatchException)
        {
            Stdout("Error handling parameters to plane.").newline;
        }
    }

    private RTObject createRTObject()
    {
        checkParameters();
        RTObject object = new RTObject(new MathPlane(normal, distance),
                new SolidColorMaterial(color, reflectivity, transparency));
        context.rt.applyCurrentTransformation(object);
        
        return object;
    }
    
    public override ObjectReference getValue()
    {
        return new ObjectReference(createRTObject());
    }
}
