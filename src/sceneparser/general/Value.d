module sceneparser.general.Value;

import raytracer.Vector;
import raytracer.Colors;

class TypeMismatchException: Exception
{
    public this(char[] msg, Exception next = null)
    {
        super(msg, next);
    }
}

abstract class Value
{
    public char[] toString()
    {
        throw new TypeMismatchException("Cannot convert this Value object to a string.");
    }
    
    public double toNumber()
    {
        throw new TypeMismatchException("Cannot convert this Value object to a number.");
    }
    
    public bool toBoolean()
    {
        throw new TypeMismatchException("Cannot convert this Value object to a boolean.");
    }
    
    public Vector toVector()
    {
        throw new TypeMismatchException("Cannot convert this Value object to a vector.");
    }
    
    public Colors toColor()
    {
        throw new TypeMismatchException("Cannot convert this Value object to a color.");
    }
    
    public Object toObjectReference()
    {
        throw new TypeMismatchException("Cannot convert this Value object to an object reference.");
    }
    
    final public T toReference(T : Object)()
    {
        T obj = cast(T) toObjectReference();
        
        if (obj is null)
            throw new TypeMismatchException("Cannot convert this Value object "
                    "to an object reference of type: " ~ T.stringof);
        
        return obj;
    }
    
    public bool isVector()
    {
        return false;
    }
    
    public bool isColor()
    {
        return false;
    }
}

class StringValue: Value
{
    char[] value;
    
    public this(char[] value)
    {
        this.value = value;
    }
    
    public char[] toString()
    {
        return value;
    }
}

class NumberValue: Value
{
    double value;
    
    public this(double value)
    {
        this.value = value;
    }
    
    public double toNumber()
    {
        return value;
    }
}

class BooleanValue: Value
{
    bool value;
    
    public this(bool value)
    {
        this.value = value;
    }
    
    public bool toBoolean()
    {
        return value;
    }
}

class VectorValue: Value
{
    Vector value;
    
    public this(Vector value)
    {
        this.value = value;
    }
    
    public Vector toVector()
    {
        return value;
    }
    
    override bool isVector()
    {
        return true;
    }
}

class ColorValue: Value
{
    Colors value;
    
    public this(Colors value)
    {
        this.value = value;
    }
    
    public Colors toColor()
    {
        return value;
    }
    
    override bool isColor()
    {
        return true;
    }
}

// Currently only for references to shapes and textures.
class ObjectReference: Value
{
    Object obj;
    
    public this(Object obj)
    {
        this.obj = obj;
        
        // FIXME: Guard against null objects.
    }
    
    public override Object toObjectReference()
    {
        return obj;
    }
}
