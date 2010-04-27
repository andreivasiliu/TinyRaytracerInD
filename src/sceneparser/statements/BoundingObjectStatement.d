module sceneparser.statements.BoundingObjectStatement;

import sceneparser.general.Context;
import sceneparser.general.Statement;

class BoundingObjectStatement: Statement
{
    string type;
    Statement statement;
    
    public this(Context context, string type, Statement statement)
    {
        super(context);
        
        this.type = type;
        this.statement = statement;
    }
    
    public override void Execute()
    {
        statement.Execute();
    }
}
