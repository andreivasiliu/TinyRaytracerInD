module sceneparser.statements.SetCameraStatement;

import raytracer.Vector;
import sceneparser.general.Expression;
import sceneparser.general.ParameterList;
import sceneparser.general.Statement;
import sceneparser.general.Value;
import sceneparser.general.Context;

import tango.io.Stdout;

class SetCameraStatement : Statement
{
    double x, y, z;

    Expression parameters;

    public this(Context context, Expression expr)
    {
        super(context);
        parameters = expr;
    }

    private void CheckParameters()
    {
        try
        {
            ParameterList p_list = cast(ParameterList)parameters;

            x = p_list[0].toNumber();
            y = p_list[1].toNumber();
            z = p_list[2].toNumber();
        }
        catch (TypeMismatchException)
        {
            Stdout("Error handling parameters to Camera.").newline;
        }
    }

    public override void Execute()
    {
        CheckParameters();

        context.rt.SetCamera(Vector(x, y, z));
    }
}
