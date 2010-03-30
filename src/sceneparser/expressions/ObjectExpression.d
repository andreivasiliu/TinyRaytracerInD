module sceneparser.expressions.ObjectExpression;

import sceneparser.general.Value;
import sceneparser.shapes.Csg;
import sceneparser.shapes.Cube;
import sceneparser.shapes.Plane;
import sceneparser.shapes.Shape;
import sceneparser.shapes.Sphere;
import sceneparser.general.Context;
import sceneparser.general.Expression;

class ObjectExpression : Expression
{
    Shape shape;
    
    public this(Context con, string name, Expression parameters)
    {
        super(con);
        
        shape = createObject(name, parameters);
    }

    public Shape createObject(string objName, Expression parameters)
    {
        switch (objName)
        {
            case "cube": return new Cube(context, parameters);
            case "sphere": return new Sphere(context, parameters);
            case "plane": return new Plane(context, parameters);
            case "csg": return new Csg(context, parameters);
            default:
                return null;
        }
    }

    public override Value getValue()
    {
        return shape.getValue;
    }
}
