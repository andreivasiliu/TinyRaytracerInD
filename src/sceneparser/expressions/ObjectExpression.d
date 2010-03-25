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
    string objName;
    Expression parameters;
    Shape shape;
    
    public this(Context con, string name, Expression expr)
    {
        super(con);
        this.objName = name;
        parameters = expr;
        shape = null;
    }

    public Shape createObject(string objName, Expression parameters)
    {
        switch (objName)
        {
            case "cube": { return new Cube(context, parameters); }
            case "sphere": { return new Sphere(context, parameters); }
            case "plane": { return new Plane(context, parameters); }
            case "csg": { return new Csg(context, parameters); }
            default:
                return null;
        }
    }

    public override Value getValue()
    {
        if (shape is null)
            shape = createObject(objName, parameters);

        return shape.getValue;
    }

    public string NAME()
    {
        return objName;
    }

    public Expression PARAMETERS()
    {
        return parameters;
    }

    public Shape SHAPE()
    {
        return shape;
    }
    
    public Shape SHAPE(Shape value)
    {
        shape = value;
        return value;
    }
}
