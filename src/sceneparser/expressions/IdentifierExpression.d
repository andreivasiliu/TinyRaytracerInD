module sceneparser.expressions.IdentifierExpression;

import sceneparser.general.SceneLoaderException;
import sceneparser.general.Value;
import sceneparser.general.Context;
import sceneparser.general.Expression;

class IdentifierExpression : Expression
{
    string name;

    public this(Context con, string name)
    {
        super(con);
        this.name = name;
    }

    public override Value getValue()
    {
        if (name in context.stack.localVariables)
            return context.stack.localVariables[name];
        else if (name in context.variables)
            return context.variables[name];
        else
        {
            throw new SceneLoaderException("Unknown variable: " ~ name);
            //return null;
        }
    }

    public string Name()
    {
        return name;
    }
}
