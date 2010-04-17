module sceneparser.expressions.MathExpressionId;

import sceneparser.expressions.IdentifierExpression;
import sceneparser.general.Expression;
import sceneparser.general.Value;
import sceneparser.general.Context;

class ObjectMathExpressionID : Expression
{
    public IdentifierExpression val;

    public this(Context context, Expression expr)
    {
        super(context);
        val = cast(IdentifierExpression)expr;
    }

    public override Value getValue()
    {   
//        Console.WriteLine("Called value: " + val.Name + "\n Varibles contains: " + context.variables.Count);
//        Console.WriteLine("In identifier value = " + context.variables[val.Name]);
        if (val.Name in context.stack.localVariables)
            return context.stack.localVariables[val.Name];
        else if (val.Name in context.variables)
            return context.variables[val.Name];
        else return new NumberValue(0);
    }
}
