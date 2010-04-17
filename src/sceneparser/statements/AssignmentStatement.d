module sceneparser.statements.AssignmentStatement;

import sceneparser.expressions.IdentifierExpression;
import sceneparser.general.Expression;
import sceneparser.general.Statement;
import sceneparser.general.Context;

class AssignmentStatement : Statement
{
    string identifier;
    Expression toAssignExpr;
    bool local;

    public this(Context con, Expression id, Expression expr, bool local)
    {
        super(con);
        
        identifier = (cast(IdentifierExpression)id).Name;
        toAssignExpr = expr;
        this.local = local;
    }

    public override void Execute()
    {
        if (identifier != "")
        {
            if (local)
                context.stack.localVariables[identifier] = toAssignExpr.getValue;
            else
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
