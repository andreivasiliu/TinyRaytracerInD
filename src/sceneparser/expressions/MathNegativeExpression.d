module sceneparser.expressions.MathNegativeExpression;

import sceneparser.general.Context;
import sceneparser.general.Expression;
import sceneparser.general.Value;

import Float = tango.text.convert.Float;

class MathNegativeExpression : Expression
{
    Expression expr1;

    public this(Context con, Expression e1)
    {
        super(con);
        expr1 = e1;
    }

    public override NumberValue getValue()
    {
        try
        {
            double m1 = expr1.getValue.toNumber;
            return new NumberValue(-m1);
        }
        catch (Exception)
        {
            return new NumberValue(0);
        }
    }

    public Expression E1()
    {
        return expr1;
    }
}
