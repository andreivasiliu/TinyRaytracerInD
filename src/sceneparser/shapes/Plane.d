module sceneparser.shapes.Plane;

import raytracer.Materials;
import raytracer.MathShapes;
import raytracer.RTObject;
import raytracer.Transformation;
import sceneparser.general.Context;
import sceneparser.general.Expression;
import sceneparser.general.ParameterList;
import sceneparser.general.Value;
import sceneparser.shapes.Shape;

import tango.io.Stdout;
import tango.text.convert.Format;

class Plane: Shape
{
    double A, B, C, D, r, g, b, reflectivity = 0, transparency = 0;

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

            A = p_list[0].toNumber;
            B = p_list[1].toNumber;
            C = p_list[2].toNumber;
            D = p_list[3].toNumber;
            r = p_list[4].toNumber;
            g = p_list[5].toNumber;
            b = p_list[6].toNumber;
            
            if (p_list.length >= 8)
                reflectivity = p_list[7].toNumber;
            if (p_list.length >= 9)
                reflectivity = p_list[8].toNumber;
        }
        catch (TypeMismatchException)
        {
            Stdout("Error handling parameters to cube.");
        }
    }

    private RTObject createRTObject()
    {
        checkParameters();
        RTObject object = new RTObject(new MathPlane(A, B, C, D),
                new SolidColorMaterial(r, g, b, reflectivity, transparency));
        context.rt.applyCurrentTransformation(object);
        
        return object;
    }
    
    public override ObjectReference getValue()
    {
        return new ObjectReference(createRTObject());
    }
}
