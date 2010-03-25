module sceneparser.general.Expression;

import sceneparser.general.Value;
import sceneparser.general.Context;
import sceneparser.general.Node;

public class Expression : Node
{
    public this(Context context) 
    {
        super(context);
    }

    public this()
    { }

    public Value getValue() 
    {
        return null;
    }

    public string ToString()
    {
        return null;
    }
}
