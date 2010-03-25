module sceneparser.statements.WhileStatement;

import sceneparser.expressions.BooleanExpression;
import sceneparser.general.Context;
import sceneparser.general.Expression;
import sceneparser.general.Statement;

class WhileStatement: Statement
{
    BooleanExpression condition;
    Statement stat;

    public this(Context context, Expression cond, Statement s)
    {
        super(context);
        condition = cast(BooleanExpression)cond;
        stat = s;
    }

    public override void Execute()
    {
        while (condition.getValue.toBoolean() == true)
            stat.Execute();
    }
}
