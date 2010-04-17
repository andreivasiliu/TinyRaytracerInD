module sceneparser.statements.DimensionStatement;

import sceneparser.general.Statement;
import sceneparser.general.Context;

class DimensionStatement: Statement
{
    Statement program;

    public this(Context con, Statement s)
    {
        super(con);
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
