module sceneparser.general.Value;

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
    
    public Object toObjectReference()
    {
        throw new TypeMismatchException("Cannot convert this Value object to an object reference.");
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

// Currently only for references to shapes.
class ObjectReference: Value
{
    Object obj;
    
    public this(Object obj)
    {
        this.obj = obj;
    }
    
    public Object toObjectReference()
    {
        return obj;
    }
}

class TypeMismatchException: Exception
{
    public this(char[] msg, Exception next = null)
    {
        super(msg, next);
    }
}
