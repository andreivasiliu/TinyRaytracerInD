module sceneparser.statements.DisplayStatement;

import sceneparser.general.Context;
import sceneparser.general.Expression;
import sceneparser.general.ParameterList;
import sceneparser.general.Statement;
import sceneparser.general.Value;
import sceneparser.shapes.Shape;

import tango.io.Stdout;

class DisplayStatement : Statement
{
    Expression params;

    public this(Context context, Expression parameters)
    {
        super(context);
        params = parameters;
    }

    public override void Execute()
    {
        /+
        if (params is null)
            Stdout("Nothing to display...").newline;
        else
        {
            try
            {
                ParameterList p_list = cast(ParameterList)params;

                Display(p_list);
            }
            catch (Exception)
            {
                try { Stdout((cast(Shape)params.getValue.toObjectReference()).Display()).newline; }
                catch (Exception) { Stdout(params.getValue.toString()).newline; }
            }
        }
        +/
    }

    public void Display(ParameterList list)
    {
        /+
        foreach (Value v; list)
        {
            try {
                Stdout((cast(Shape)v.toObjectReference()).Display()).newline;
            } catch (Exception) {
                Stdout(v.toString()).newline;
            }
        }+/
    }
}
