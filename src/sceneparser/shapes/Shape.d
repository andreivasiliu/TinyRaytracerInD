module sceneparser.shapes.Shape;

import sceneparser.general.Value;
import sceneparser.general.Context;
import sceneparser.general.Expression;

public class Shape: Expression
{
    public this(Context con)
    {
        super(con);
    }

    public this()
    { }

    public void Draw()
    {   
    }

    public string Display()
    {
        return " \n";
    }

    public override Value getValue()
    {
        return null;
    }
}
