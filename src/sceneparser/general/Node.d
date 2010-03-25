module sceneparser.general.Node;

import sceneparser.general.Context;

public class Node
{
    public Context context;

    public this(Context context)
    {
        this.context = context;
    }

    public this()
    { }

    public Context getContext()
    {
        return context;
    }
}
