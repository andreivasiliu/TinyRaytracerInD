module sceneparser.general.ParameterList;

import sceneparser.general.Value;
import sceneparser.general.Context;
import sceneparser.general.Expression;

class ParameterList: Expression
{
    Expression[] params;

    public this(Context context, Expression param)
    {
        super(context);
        params = [param];
    }
    
    public this(Context context)
    {
        super(context);
        params = [];
    }
    
    public void appendToFront(Expression param)
    {
        params = param ~ params;
    }
    
    public size_t length()
    {
        return params.length;
    }
    
    public Value opIndex(size_t i) {
        return params[i].getValue;
    }
    
    int opApply(int delegate(ref Value) dg)
    {
        int result = 0;

        for (int i = 0; i < params.length; i++)
        {
            Value v = params[i].getValue;
            result = dg(v);
            if (result)
                break;
        }
        return result;
    }
    
    public override Value getValue()
    {
        throw new Exception("Oh noes! Someone called getValue on a ParmeterList!");
    }
}
