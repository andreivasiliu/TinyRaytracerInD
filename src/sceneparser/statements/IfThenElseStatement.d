module sceneparser.statements.IfThenElseStatement;

import sceneparser.expressions.BooleanExpression;
import sceneparser.general.Expression;
import sceneparser.general.Statement;
import sceneparser.general.Context;

class IfThenElseStatement:Statement
{
    BooleanExpression condition;
    Statement then, else_;

    public this(Context context, Expression cond, Statement left, Statement right)
    {
        super(context);
        condition = cast(BooleanExpression)cond;
        then = left;
        else_ = right;
    }

    public override void Execute()
    {
        if (condition.getValue.toBoolean == true)
            then.Execute();
        else else_.Execute();
    }
}
