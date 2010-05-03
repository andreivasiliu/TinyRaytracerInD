module sceneparser.general.Context;

import raytracer.Math;
import raytracer.RayTracer;
import sceneparser.SceneLoader;
import sceneparser.general.Function;
import sceneparser.general.Value;

public alias char[] string;

public class Context
{
    class VariableStack
    {
        public Value[string] localVariables;
        private VariableStack next;
    }

    public Value[string] variables;
    public Function[string] functions;
    public SceneLoader mp;
    public RayTracer rt;
    public VariableStack stack;

    public this(SceneLoader loader, RayTracer rayTracer)
    {
        stack = new VariableStack();
        mp = loader;
        rt = rayTracer;
        variables["pi"] = new NumberValue(PI);
    }
    
    public void enterFunction()
    {
        VariableStack newLocalVariables = new VariableStack();
        newLocalVariables.next = stack;
        stack = newLocalVariables;
    }
    
    public void leaveFunction()
    {
        assert(stack !is null);
        stack = stack.next;
    }
}
