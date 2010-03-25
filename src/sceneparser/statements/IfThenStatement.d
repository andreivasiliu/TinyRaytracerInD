module sceneparser.statements.IfThenStatement;

import sceneparser.expressions.BooleanExpression;
import sceneparser.general.Expression;
import sceneparser.general.Statement;
import sceneparser.general.Context;

class IfThenStatement:Statement
{
    BooleanExpression condition;
    Statement then;

    public this(Context context, Expression cond, Statement expr)
    {
        super(context);
        condition = cast(BooleanExpression)cond;
        then = expr;
    }

    public override void Execute()
    {
        if (condition.getValue.toBoolean() == true)
            then.Execute();
    }
}
