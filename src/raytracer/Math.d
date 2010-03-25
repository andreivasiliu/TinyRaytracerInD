module raytracer.Math;

import tmath = tango.math.Math;
import cmath = tango.stdc.math;

public const double PI = tmath.PI;
public const double epsilon = 10e-7;

version(LLVM)
    pragma(intrinsic, "llvm.sqrt.f64")
      double sqrt(double);
else
    public alias cmath.sqrt sqrt;

public alias cmath.acos acos;
public alias cmath.fabs abs;
public alias cmath.sin sin;
public alias cmath.cos cos;

version(none)
{
    // Dummy functions
    public double acos(double x)
    {
        return x;
    }
    
    public double sqrt(double x)
    {
        return x;
    }
    
    public double abs(double x)
    {
        return x;
    }
}
