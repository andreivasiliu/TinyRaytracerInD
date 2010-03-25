module sceneparser.expressions.ComparisonExpression;

import sceneparser.expressions.BooleanExpression;
import sceneparser.general.Context;
import sceneparser.general.Expression;
import sceneparser.general.Value;
import Float = tango.text.convert.Float;

class ComparisonExpression: BooleanExpression
{
    Expression m1, m2;
    string op;
    
    public this(Context con, Expression math1, string sign, Expression math2)
    {
        super(con, false);
        m1 = math1;
        m2 = math2;
        op = sign;
    }

    public override BooleanValue getValue()
    {
        bool result;
        
        try
        {
            double m1 = this.m1.getValue.toNumber;
            double m2 = this.m2.getValue.toNumber;

            switch (op)
            {
                case "<": result = (m1 < m2); break;
                case ">": result = (m1 > m2); break;
                case "<=": result = (m1 <= m2); break;
                case ">=": result = (m1 >= m2); break;
                case "!=": result = (m1 != m2); break;
                case "==": result = (m1 == m2); break;
                default: result = false;
            }
        }
        catch (Exception)
        {
            // FIXME: Print a proper error
            result = false;
        }
        
        return new BooleanValue(result);
    }
}
