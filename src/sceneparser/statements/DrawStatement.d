module sceneparser.statements.DrawStatement;

import sceneparser.general.ParameterList;
import sceneparser.general.Statement;
import sceneparser.general.Value;
import sceneparser.general.Context;
import sceneparser.general.Expression;
import sceneparser.shapes.Shape;

import tango.io.Stdout;

class DrawStatement: Statement
{
    Expression params;

    public this(Context context, Expression parameters)
    {
        super(context);
        params = parameters;
    }

    public override void Execute()
    {
        //Console.WriteLine("Draw apelat.. In rand culoarea: " + context.mp.rand.COLOR);
        if (params !is null)
        {
            try
            {
                ParameterList p_list = cast(ParameterList)params;

                Draw(p_list);
            }
            catch (Exception)
            {
                try
                {
                    Shape s = cast(Shape)(params.getValue.toObjectReference);
                    s.Draw();
                }
                catch (Exception e) { Stdout("Exception: " ~ e.msg).newline; }
            }
        }
    }

    public void Draw(ParameterList list)
    {
        foreach (Value v; list)
        {
            try {
                (cast(Shape)v.toObjectReference).Draw();
            } catch (Exception e) {
                Stdout("Exception: " ~ e.msg).newline;
            }
        }
    }
}
