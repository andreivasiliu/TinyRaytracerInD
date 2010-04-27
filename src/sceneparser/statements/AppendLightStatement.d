module sceneparser.statements.AppendLightStatement;

import tango.io.Stdout;
import raytracer.Colors;
import raytracer.Vector;
import sceneparser.general.Expression;
import sceneparser.general.ParameterList;
import sceneparser.general.Statement;
import sceneparser.general.Value;
import sceneparser.general.Context;

class AppendLightStatement: Statement
{
    Expression parameters;

    public this(Context context, Expression expr)
    {
        super(context);
        parameters = expr;
    }

    public override void Execute()
    {
        Vector center;
        Colors color = { 0.5, 0.5, 0.5 };
        double fade = 100;

        try
        {
            ParameterList p_list = cast(ParameterList)parameters;
            int i = 0;
            
            center = p_list[i++].toVector;
            
            if (p_list.length >= i + 1)
                color = p_list[i++].toColor();
            if (p_list.length >= i + 1)
                fade = p_list[i++].toNumber();
        }
        catch (TypeMismatchException)
        {
            Stdout("Error handling parameters to AppendLight.").newline;
            return;
        }
        
        context.rt.addLight(center, color, fade);
    }
}
