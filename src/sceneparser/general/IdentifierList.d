module sceneparser.general.IdentifierList;

import sceneparser.general.Value;
import sceneparser.expressions.IdentifierExpression;
import sceneparser.general.Context;
import sceneparser.general.Expression;

class IdentifierList: Expression
{
    string[] identifiers;

    public this(Context context, Expression identifier)
    {
        super(context);
        string idString = (cast(IdentifierExpression)identifier).Name;
        identifiers = [idString];
    }
    
    public this(Context context)
    {
        super(context);
        identifiers = [];
    }
    
    public void appendToFront(Expression identifier)
    {
        string idString = (cast(IdentifierExpression)identifier).Name;
        identifiers = idString ~ identifiers;
    }
    
    public size_t length()
    {
        return identifiers.length;
    }
    
    public string opIndex(size_t i) {
        return identifiers[i];
    }
    
    int opApply(int delegate(ref string) dg)
    {
        int result = 0;
        
        for (int i = 0; i < identifiers.length; i++)
        {
            result = dg(identifiers[i]);
            if (result)
                break;
        }
        return result;
    }
    
    public override Value getValue()
    {
        throw new Exception("Oh noes! Someone called getValue on an IdentifierList!");
    }
}
