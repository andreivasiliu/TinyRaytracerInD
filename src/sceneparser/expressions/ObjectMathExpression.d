module sceneparser.expressions.ObjectMathExpression;

import sceneparser.general.Value;
import sceneparser.general.Context;
import sceneparser.general.Expression;

class ObjectMathExpression : Expression
{
    Expression val;

    public this(Context context, Expression expr)
    {
        super(context);
        val = expr;
    }

    public override Value getValue()
    {
        return val.getValue;
    }
}
