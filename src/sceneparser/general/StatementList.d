module sceneparser.general.StatementList;

import sceneparser.general.Context;
import sceneparser.general.Statement;

class StatementList: Statement
{
    public Statement currentS, nextS;

    public this(Context context, Statement stat1, Statement stat2)
    {
        super(context);
        currentS = stat1;
        nextS = stat2;
    }

    public override void Execute()
    {
        currentS.Execute();
        if (nextS !is null)
            nextS.Execute();
    }

}