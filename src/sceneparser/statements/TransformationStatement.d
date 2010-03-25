module sceneparser.statements.TransformationStatement;

import raytracer.Transformation;
import raytracer.Vector;
import sceneparser.general.Expression;
import sceneparser.general.ParameterList;
import sceneparser.general.Statement;
import sceneparser.general.Value;
import sceneparser.general.Context;

import tango.io.Stdout;

class TransformationStatement : Statement
{
    Expression parameters;
    Statement statements;
    string transformationType;
    
    public this(Context context, Expression transformationType,
            Expression parameters, Statement statements)
    {
        super(context);
        this.parameters = parameters;
        this.statements = statements;
        this.transformationType = transformationType.getValue.toString;
    }

    public override void Execute()
    {
        ParameterList params = cast(ParameterList) parameters;
        
        double x = params[0].toNumber;
        double y = params[1].toNumber;
        double z = params[2].toNumber;
        
        Transformation transformation;
        
        if (transformationType == "rotate")
            transformation = MatrixTransformation.createRotationMatrix(x, y, z);
        else if (transformationType == "translate")
            transformation = MatrixTransformation.createTranslationMatrix(x, y, z);
        else if (transformationType == "scale")
            transformation = MatrixTransformation.createScalingMatrix(x, y, z);
        else
            throw new Exception("Unknown transformation type '" ~
                    transformationType ~ "'!");
        
        context.rt.transformationStack.pushTransformation(transformation);
        statements.Execute();
        context.rt.transformationStack.popTransformation();
    }
}
