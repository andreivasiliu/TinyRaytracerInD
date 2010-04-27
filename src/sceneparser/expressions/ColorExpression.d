module sceneparser.expressions.ColorExpression;

import tango.io.Stdout;
import sceneparser.general.Value;
import raytracer.Colors;
import sceneparser.general.Context;
import sceneparser.general.Expression;

private struct NamedColor
{
    string name;
    Colors value;
}

const NamedColor colors[] =
    [ { "red", Colors(1, 0, 0) },
      { "orange", Colors(1, 0.5, 0) },
      { "yellow", Colors(1, 1, 0) },
      { "green", Colors(0, 1, 0) },
      { "blue", Colors(0, 0, 1) },
      { "purple", Colors(1, 0, 1) },
      { "black", Colors(0, 0, 0) },
      { "white", Colors(1, 1, 1) } ];


class ColorExpression: Expression
{
    Expression redExpr, greenExpr, blueExpr;
    Colors color;
    bool namedColor = false;
    
    public this(Context context, string colorName)
    {
        super(context);
        
        namedColor = true;
        
        foreach (NamedColor c; colors)
        {
            if (c.name == colorName)
            {
                this.color = c.value;
                return;
            }
        }
        
        Stdout("Unknown color name: ")(colorName).newline;
    }
    
    public this(Context context, Expression red, Expression green, 
            Expression blue, Expression alpha = null)
    {
        super(context);
        
        this.redExpr = red;
        this.greenExpr = green;
        this.blueExpr = blue;
        
        namedColor = false;
    }
    
    override ColorValue getValue()
    {
        if (namedColor)
        {
            return new ColorValue(color);
        }
        else
        {
            double r = redExpr.getValue.toNumber();
            double g = greenExpr.getValue.toNumber();
            double b = blueExpr.getValue.toNumber();
            
            return new ColorValue(Colors(r, g, b));
        }
    }
}
