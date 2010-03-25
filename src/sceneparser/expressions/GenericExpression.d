module sceneparser.expressions.GenericExpression;

import sceneparser.general.Value;
import sceneparser.general.Context;
import sceneparser.general.Expression;

class GenericExpression : Expression
{
    StringValue strVal;

    public this(Context con, string value)
    {
        super(con);
        strVal = new StringValue(value);
    }

    public override Value getValue()
    {
        return strVal;
    }

    public override string ToString()
    {
        return strVal.toString;
    }
}
