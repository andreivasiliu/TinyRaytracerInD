module sceneparser.statements.DimensionStatement;

import sceneparser.general.Statement;
import sceneparser.general.Context;

class DimensionStatement: Statement
{

    string type;
    Statement program;

    public this(Context con, string t, Statement s)
    {
        super(con);
        type = t;
        program = s;
    }

    public override void Execute()
    {
        /+if (type == "3D" || type == "3d")
        {
            context.mp.rt = new RayTracer.RayTracer(context.mp.W, context.mp.H);
        }+/
        
        program.Execute();
    }
}
