module sceneparser.expressions.NumberExpression;

import sceneparser.general.Context;
import sceneparser.general.Expression;
import sceneparser.general.Value;

import Float = tango.text.convert.Float;
import tango.core.Exception;

class NumberExpression : Expression
{
    NumberValue val;

    public this(Context con, char[] strVal)
    {
        super(con);
        
        try
        {
            this.val = new NumberValue(Float.toFloat(strVal));
        }
        catch (IllegalArgumentException)
        {
            this.val = new NumberValue(0);
        }
    }

    public this(double val)
    {
        this.val = new NumberValue(val);
    }

    public override Value getValue()
    {
        return val;
    }
}
