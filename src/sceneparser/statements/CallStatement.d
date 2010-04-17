module sceneparser.statements.CallStatement;

import sceneparser.expressions.IdentifierExpression;
import sceneparser.general.Expression;
import sceneparser.general.Function;
import sceneparser.general.ParameterList;
import sceneparser.general.SceneLoaderException;
import sceneparser.general.Statement;
import sceneparser.general.Context;

class CallStatement: Statement
{
    string functionName;
    ParameterList parameters;
    
    public this(Context context, Expression functionName, Expression parameters)
    {
        super(context);
        
        this.functionName = (cast(IdentifierExpression)functionName).Name;
        this.parameters = cast(ParameterList)parameters;
    }
    
    public override void Execute()
    {
        if (!(functionName in context.functions))
        {
            throw new SceneLoaderException("Attempting to call unknown function: "
                    ~ functionName);
        }
        
        Function func = context.functions[functionName];
        func.call(parameters);
    }
}
