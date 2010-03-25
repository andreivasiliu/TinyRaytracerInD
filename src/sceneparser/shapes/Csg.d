module sceneparser.shapes.Csg;

import raytracer.CSG;
import raytracer.Materials;
import raytracer.MathShapes;
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
    MathShape MS1, MS2;
    Operator op;
    double r, g, b, reflectivity;

    Expression parameters;
    bool init = false;

    public this(Context con, Expression expr)
    {
        super(con);
        parameters = expr;
    }

    private void CheckParameters()
    {
        try
        {
            ParameterList p_list = cast(ParameterList)parameters;

            MS1 = Set(cast(Shape)p_list[0].toObjectReference());
            MS2 = Set(cast(Shape)p_list[1].toObjectReference());
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
        }
        catch (TypeMismatchException)
        {
            Stdout("Error handling parameters to plane.").newline;
        }
    }


    private MathShape Set(Shape MS1)
    {
        if (is(MS1 : Cube))
        {
            Cube c = cast(Cube) MS1;
            return new MathCube(Vector(c.x, c.y, c.z), c.length);
        }
        if (is(MS1 : Sphere))
        {
            Sphere s = cast(Sphere) MS1;
            return new MathSphere(Vector(s.x, s.y, s.z), s.radius);
        }
        if (is(MS1 : Csg))
        {
            Csg s = cast(Csg) MS1;
            return new CSG(s.MS1, s.MS2, s.op);
        }

        return null;
    }

    public override string Display()
    {
        if (!init)
            CheckParameters();
        init = true;

        return Format("Csg: rgb = ({}; {}; {}); reflectivity = {}",
                r, g, b, reflectivity);
    }

    public override ObjectReference getValue()
    {
        if (!init)
            CheckParameters();
        return new ObjectReference(this);
    }

    public override void Draw()
    {
        if (MS1 !is null && MS2 !is null)
        {
            if (!init)
                CheckParameters();
            if (reflectivity == -1)
                context.rt.addObject(new CSG(MS1, MS2, op),
                        new SolidColorMaterial(r, g, b));
            else
                context.rt.addObject(new CSG(MS1, MS2, op),
                        new SolidColorMaterial(r, g, b, reflectivity));
        }
    }
}
