module sceneparser.statements.FunctionStatement;

import sceneparser.expressions.IdentifierExpression;
import sceneparser.general.Context;
import sceneparser.general.Expression;
import sceneparser.general.Function;
import sceneparser.general.IdentifierList;
import sceneparser.general.Statement;

class FunctionStatement: Statement
{
    string functionName;
    IdentifierList parameters;
    Statement statements;
    
    public this(Context context, Expression functionName, Expression idList,
            Statement statements)
    {
        super(context);
        
        this.functionName = (cast(IdentifierExpression)functionName).Name;
        this.parameters = cast(IdentifierList)idList;
        this.statements = statements;
        
        assert(parameters !is null);
    }
    
    public override void Execute()
    {
        context.functions[functionName] = new Function(context, functionName,
                parameters, statements);
    }
}
