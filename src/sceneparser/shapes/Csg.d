module sceneparser.shapes.Csg;

import raytracer.CSG;
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
    double r, g, b, reflectivity = 0, transparency = 0;

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

            MS1 = cast(RTObject) p_list[0].toObjectReference();
            MS2 = cast(RTObject) p_list[1].toObjectReference();
            string oper = p_list[2].toString;

            switch (oper)
            {
                case "'difference'": { op = Operator.Difference; break; }
                case "'union'": { op = Operator.Union; break; }
                case "'intersection'": { op = Operator.Intersection; break; }
                default: { op = Operator.Union; break; }
            }

            r = p_list[3].toNumber;
            g = p_list[4].toNumber;
            b = p_list[5].toNumber;
            
            if (p_list.length() >= 7)
                reflectivity = p_list[6].toNumber;
            if (p_list.length() >= 8)
                transparency = p_list[7].toNumber;
        }
        catch (TypeMismatchException)
        {
            Stdout("Error handling parameters to plane.").newline;
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
                new SolidColorMaterial(r, g, b, reflectivity, transparency));
        context.rt.applyCurrentTransformation(object);
        
        return object;
    }
    
    public override ObjectReference getValue()
    {
        return new ObjectReference(createRTObject());
    }
}
