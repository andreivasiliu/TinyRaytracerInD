module sceneparser.statements.AppendLightStatement;

import raytracer.Colors;
import raytracer.Vector;
import sceneparser.general.Expression;
import sceneparser.general.ParameterList;
import sceneparser.general.Statement;
import sceneparser.general.Context;

class AppendLightStatement: Statement
{
    double x, y, z, r, g, b, fade;

    Expression parameters;

    public this(Context context, Expression expr)
    {
        super(context);
        parameters = expr;
    }

    private void CheckParameters()
    {
        ParameterList p_list = cast(ParameterList)parameters;

        x = p_list[0].toNumber();
        y = p_list[1].toNumber();
        z = p_list[2].toNumber();
        r = p_list[3].toNumber();
        g = p_list[4].toNumber();
        b = p_list[5].toNumber();
        fade = p_list[6].toNumber();
    }

    public override void Execute()
    {
        CheckParameters();

        context.rt.addLight(Vector(x, y, z), Colors.inRange(r, g, b), fade);
    }
}
