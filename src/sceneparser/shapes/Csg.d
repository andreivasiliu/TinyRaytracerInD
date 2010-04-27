module sceneparser.shapes.Csg;

import raytracer.CSG;
import raytracer.Colors;
import raytracer.Materials;
import raytracer.MathShapes;
import raytracer.RTObject;
import raytracer.Vector;
import sceneparser.general.Context;
import sceneparser.general.Expression;
import sceneparser.general.ParameterList;
import sceneparser.general.Value;
import sceneparser.shapes.Cube;
import sceneparser.shapes.Shape;
import sceneparser.shapes.Sphere;

import tango.io.Stdout;
import tango.text.convert.Format;

class Csg : Shape
{
    RTObject MS1, MS2;
    Operator op;
    Colors color = {0, 0, 0};
    double reflectivity = 0, transparency = 0;

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
            
            MS1 = cast(RTObject) p_list[i++].toObjectReference();
            MS2 = cast(RTObject) p_list[i++].toObjectReference();
            string oper = p_list[i++].toString;

            switch (oper)
            {
                case "difference": op = Operator.Difference; break;
                case "union": op = Operator.Union; break;
                case "intersection": op = Operator.Intersection; break;
                default: op = Operator.Union; break;
            }

            if (p_list.length >= i + 1)
                color = p_list[i++].toColor();
            if (p_list.length >= i + 1)
                reflectivity = p_list[i++].toNumber;
            if (p_list.length >= i + 1)
                transparency = p_list[i++].toNumber;
        }
        catch (TypeMismatchException)
        {
            Stdout("Error handling parameters to CSG.").newline;
        }
    }
    
    private RTObject createRTObject()
    {
        checkParameters();
        
        if (MS1 is null || MS2 is null)
        {
            Stdout("A null parameter was given to csg!").newline;
            return null;
        }
        
        RTObject object = new RTObject(new CSG(MS1, MS2, op),
                new SolidColorMaterial(color, reflectivity, transparency));
        context.rt.applyCurrentTransformation(object);
        
        return object;
    }
    
    public override ObjectReference getValue()
    {
        return new ObjectReference(createRTObject());
    }
}
