module sceneparser.general.Function;

import tango.text.convert.Format;
import sceneparser.general.IdentifierList;
import sceneparser.general.ParameterList;
import sceneparser.general.SceneLoaderException;
import sceneparser.general.Statement;
import sceneparser.general.Value;
import sceneparser.general.Context;

class Function
{
    Context context;
    string name;
    IdentifierList parameterNames;
    Statement statements;
    
    public this(Context context, string name, IdentifierList parameterNames,
            Statement statements)
    {
        this.context = context;
        this.name = name;
        this.parameterNames = parameterNames;
        this.statements = statements;
    }
    
    public void call(ParameterList parameters)
    {
        if (parameters.length != parameterNames.length)
            throw new SceneLoaderException(Format("Called function {} with {} "
                    "arguments, expected {} instead.", name, parameters.length, 
                    parameterNames.length));
        
        Value[] values = new Value[parameters.length];
        
        for (int i = 0; i < values.length; i++)
        {
            // The ParameterList's opIndex actually evaluates values as well.
            values[i] = parameters[i];
        }
        
        context.enterFunction();
        scope(exit) context.leaveFunction();
        
        for (int i = 0; i < values.length; i++)
            context.stack.localVariables[parameterNames[i]] = values[i];
        
        statements.Execute();
    }
}
