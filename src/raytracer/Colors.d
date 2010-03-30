module raytracer.Colors;

public struct Colors
{
    double R, G, B, A;

    private static double inLimit(double x, double min, double max)
    {
        if ( x < min )
            return min;
        else if ( x > max )
            return max;
        else 
            return x;
    }

    public static Colors inRange(double R, double G, double B)
    {
        return Colors(inLimit(R, 0, 1), inLimit(G, 0, 1), inLimit(B, 0, 1), 1);
    }

    /+
    public Color getColor()
    {
            return Color.FromArgb(cast(int)round(R * 255), cast(int)round(G * 255), cast(int)round(B * 255));
    } +/

    public Colors Multiply(Colors color)
    {
        // TODO max is 1.0
        return Colors.inRange(R * color.R, G * color.G, B * color.B);
    }

    public Colors intensify(double intensity)
    {
        return Colors.inRange(R * intensity, G * intensity, B * intensity);
    }

    public Colors opAdd(Colors b)
    {
        return Colors.inRange(R + b.R, G + b.G, B + b.B);
    }

    public static Colors Black()
    {
        return Colors(0, 0, 0, 1);
    }
}
