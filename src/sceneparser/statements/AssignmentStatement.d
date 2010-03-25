module sceneparser.statements.AssignmentStatement;

import sceneparser.expressions.IdentifierExpression;
import sceneparser.general.Expression;
import sceneparser.general.Statement;
import sceneparser.general.Context;

class AssignmentStatement : Statement
{
    string identifier;
    Expression toAssignExpr;

    public this(Context con, Expression id, Expression expr)
    {
        super(con);
        identifier = (cast(IdentifierExpression)id).Name;
        toAssignExpr = expr;
    }

    public override void Execute()
    {
        if (identifier != "")
        {
            context.variables[identifier] = toAssignExpr.getValue;
        }
    }

    public string IDENTIFIER()
    {
        return identifier;
    }

    public Expression EXPRESSION()
    {
        return toAssignExpr;
    }
}
