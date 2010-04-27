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
    Expression parameters;

    public this(Context context, Expression expr)
    {
        super(context);
        parameters = expr;
    }

    public override void Execute()
    {
        Vector position;
        
        try
        {
            ParameterList p_list = cast(ParameterList)parameters;

            position = p_list[0].toVector();
        }
        catch (TypeMismatchException)
        {
            Stdout("Error handling parameters to SetCamera.").newline;
            return;
        }

        context.rt.setCamera(position);
    }
}
