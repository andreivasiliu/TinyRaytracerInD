module sceneparser.shapes.Shape;

import raytracer.RTObject;
import sceneparser.general.Value;
import sceneparser.general.Context;
import sceneparser.general.Expression;

public abstract class Shape: Expression
{
    public this(Context con)
    {
        super(con);
    }
}
