module sceneparser.general.Context;

import raytracer.RayTracer;
import sceneparser.GrammarConstants;
import sceneparser.SceneLoader;
import sceneparser.expressions.BooleanExpression;
import sceneparser.expressions.ComparisonExpression;
import sceneparser.expressions.GenericExpression;
import sceneparser.expressions.IdentifierExpression;
import sceneparser.expressions.MathBinaryExpression;
import sceneparser.expressions.MathExpressionId;
import sceneparser.expressions.MathNegativeExpression;
import sceneparser.expressions.NumberExpression;
import sceneparser.expressions.ObjectExpression;
import sceneparser.expressions.ObjectMathExpression;
import sceneparser.expressions.StringExpression;
import sceneparser.general.Expression;
import sceneparser.general.Node;
import sceneparser.general.ParameterList;
import sceneparser.general.Statement;
import sceneparser.general.StatementList;
import sceneparser.general.Value;
import sceneparser.statements.AppendLightStatement;
import sceneparser.statements.AssignmentStatement;
import sceneparser.statements.DimensionStatement;
import sceneparser.statements.DisplayStatement;
import sceneparser.statements.DrawStatement;
import sceneparser.statements.IfThenElseStatement;
import sceneparser.statements.IfThenStatement;
import sceneparser.statements.SetCameraStatement;
import sceneparser.statements.WhileStatement;
import goldengine.goldparser;

public alias char[] string; 

public class Context
{
    public Value[string] variables;
    public SceneLoader mp;
    public RayTracer rt;

    public this(SceneLoader loader, RayTracer rayTracer)
    {
        mp = loader;
        rt = rayTracer;
    }
}
