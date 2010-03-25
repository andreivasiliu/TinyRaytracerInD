module sceneparser.expressions.BooleanExpression;

import sceneparser.general.Value;
import sceneparser.general.Context;
import sceneparser.general.Expression;

class BooleanExpression : Expression
{
    BooleanValue val;

    public this(Context con, bool value)
    {
        super(con);
        val = new BooleanValue(value);
    }

    public override BooleanValue getValue()
    {
        return val;
    }
}
