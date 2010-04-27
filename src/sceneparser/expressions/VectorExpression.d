module sceneparser.expressions.VectorExpression;

import raytracer.Vector;
import sceneparser.general.Value;
import sceneparser.general.Context;
import sceneparser.general.Expression;

class VectorExpression: Expression
{
    Expression xExpr, yExpr, zExpr;
    
    this(Context context, Expression x, Expression y, Expression z)
    {
        super(context);
        
        this.xExpr = x;
        this.yExpr = y;
        this.zExpr = z;
    }
    
    override VectorValue getValue()
    {
        double x = xExpr.getValue.toNumber();
        double y = yExpr.getValue.toNumber();
        double z = zExpr.getValue.toNumber();
        
        return new VectorValue(Vector(x, y, z));
    }
}
