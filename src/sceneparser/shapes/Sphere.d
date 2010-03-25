module sceneparser.shapes.Sphere;

import sceneparser.shapes.Shape;
import raytracer.Materials;
import raytracer.MathShapes;
import raytracer.Vector;
import sceneparser.general.Context;
import sceneparser.general.Expression;
import sceneparser.general.ParameterList;
import sceneparser.general.Value;

import tango.io.Stdout;
import tango.text.convert.Format;

class Sphere: Shape
{
    public double x, y, z, radius, r, g, b, reflectivity = -1;

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

            x = p_list[0].toNumber;
            y = p_list[1].toNumber;
            z = p_list[2].toNumber;
            radius = p_list[3].toNumber;
            r = p_list[4].toNumber;
            g = p_list[5].toNumber;
            b = p_list[6].toNumber;
            
            if (p_list.length >= 8)
                reflectivity = p_list[7].toNumber;
        }
        catch (TypeMismatchException)
        {
            Stdout("Error handling parameters to cube.").newline;
        }
    }

    public override string Display()
    {
        if (!init)
            CheckParameters();
        init = true;

        return Format("Sphere: center({}, {}, {}); radius = {}; "
                "rgb = ({}; {}; {}); reflectivity = {}",
                x, y, z, radius, r, g, b, reflectivity);
    }

    public override ObjectReference getValue()
    {
        if (!init)
            CheckParameters();
        return new ObjectReference(this);
    }

    public override void Draw()
    {
        if (!init)
            CheckParameters();
        if (reflectivity == -1)
            context.rt.addObject(new MathSphere(Vector(x, y, z), radius),
                    new SolidColorMaterial(r, g, b));
        else
            context.rt.addObject(new MathSphere(Vector(x, y, z), radius),
                    new SolidColorMaterial(r, g, b, reflectivity));
    }
}
