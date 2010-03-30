module sceneparser.statements.DrawStatement;

import raytracer.RTObject;
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
            ParameterList p_list = cast(ParameterList)params;

            foreach (Value v; p_list)
            {
                if (RTObject object = cast(RTObject)v.toObjectReference())
                    context.rt.addObject(object);
                else
                {
                    Stdout.formatln("Object type: {}", v.toObjectReference());
                    throw new Exception("Unknown object type given to draw().");
                }
            }
        }
    }
}
