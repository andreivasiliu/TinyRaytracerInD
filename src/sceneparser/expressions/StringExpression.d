module sceneparser.expressions.StringExpression;

import sceneparser.general.Value;
import sceneparser.general.Context;
import sceneparser.general.Expression;

class StringExpression : Expression
{
    StringValue strVal;

    public this(Context con, string value)
    {
        super(con);
        strVal = new StringValue(value);
    }

    public override StringValue getValue()
    {
        return strVal;
    }

    public override string ToString()
    {
        return strVal.toString;
    }
}
