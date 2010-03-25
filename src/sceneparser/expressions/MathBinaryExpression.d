module sceneparser.expressions.MathBinaryExpression;

import sceneparser.general.Context;
import sceneparser.general.Expression;
import sceneparser.general.Value;

import Float = tango.text.convert.Float;

class MathBinaryExpression : Expression
{
    Expression expr1, expr2;
    string sign;

    public this(Context con, Expression e1, string s, Expression e2)
    {
        super(con);
        
        expr1 = e1;
        expr2 = e2;
        sign = s;
    }

    public override Value getValue()
    {
        double result;
        
        try
        {
            double m1 = expr1.getValue.toNumber;
            double m2 = expr2.getValue.toNumber;
            switch (sign)
            {
                case "/": result = (m1 / m2); break;
                case "*": result = (m1 * m2); break;
                case "+": result = (m1 + m2); break;
                case "-": result = (m1 - m2); break;
                case "%": result = (m1 % m2); break;
                default: result = 0;
            }
        }
        catch (Exception)
        {
            result = 0;
        }
        
        return new NumberValue(result);
    }

    public Expression E1()
    {
        return expr1;
    }

    public Expression E2()
    {
        return expr2;
    }

    public string SIGN()
    {
        return sign;
    }
}
