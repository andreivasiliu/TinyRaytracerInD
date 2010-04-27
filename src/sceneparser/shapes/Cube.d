module sceneparser.shapes.Cube;

import raytracer.Colors;
import raytracer.Materials;
import raytracer.Math;
import raytracer.MathShapes;
import raytracer.RTObject;
import raytracer.Vector;
import sceneparser.general.Context;
import sceneparser.general.Expression;
import sceneparser.general.ParameterList;
import sceneparser.general.Value;
import sceneparser.shapes.Shape;

import tango.io.Stdout;
import tango.text.convert.Format;
import Float = tango.text.convert.Float;

class Cube: Shape
{
    private Vector center = {0, 0, 0};
    private double length;
    private Colors color = {0, 0, 0};
    private double reflectivity = 0, transparency = 0;
    Expression parameters;

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
            length = p_list[i++].toNumber;
            
            if (p_list.length >= i + 1)
                color = p_list[i++].toColor();
            if (p_list.length >= i + 1)
                reflectivity = p_list[i++].toNumber;
            if (p_list.length >= i + 1)
                transparency = p_list[i++].toNumber;
        }
        catch (TypeMismatchException)
        {
            Stdout("Error handling parameters to cube.").newline;
        }
    }
    
    private RTObject createRTObject()
    {
        checkParameters();
        RTObject object = new RTObject(new MathCube(center, length),
                new SolidColorMaterial(color, reflectivity, transparency));
        context.rt.applyCurrentTransformation(object);
        
        return object;
    }

    public override ObjectReference getValue()
    {
        return new ObjectReference(createRTObject());
    }
}
