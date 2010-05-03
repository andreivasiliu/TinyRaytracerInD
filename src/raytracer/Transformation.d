module raytracer.Transformation;

import tango.io.Stdout;
import raytracer.Math;
import raytracer.Vector;

// Just a normal stack, except that it knows how to multiply transformation
// matrices.

struct TransformationStack
{
    private class Element
    {
        Transformation transformation;
        Element next;
    }
    
    private Element stackHead = null;
    
    public void pushTransformation(Transformation transformation)
    {
        if (stackHead is null)
        {
            stackHead = new Element();
            stackHead.transformation = transformation;
            return;
        }
        
        Element newHead = new Element();
        newHead.next = stackHead;
        
        Transformation composedTransformation =
            transformation.composeWith(stackHead.transformation);
        newHead.transformation = composedTransformation;
        stackHead = newHead;
    }
    
    public void popTransformation()
    {
        if (stackHead is null)
            throw new Exception("Trying to pop from an empty TransformationStack!");
        
        stackHead = stackHead.next;
    }
    
    public Transformation getTransformation()
    {
        if (stackHead is null)
            return null;
        
        return stackHead.transformation;
    }
}

abstract class Transformation
{
    abstract public Vector transformVector(Vector vector);
    abstract public Vector reverseTransformVector(Vector vector);
    abstract public Vector transformDirectionVector(Vector vector);
    abstract public Vector reverseTransformDirectionVector(Vector vector);
    abstract public Ray reverseTransformRay(Ray ray);
    abstract public Transformation composeWith(Transformation other);
}

class MatrixTransformation: Transformation
{
    double[4][4] matrix;
    double[4][4] inverseMatrix;
    
    public this(double[4][4] matrix)
    {
        // Apparently 'this.matix = matrix' does not work... I wonder why...
        this.matrix[0..4] = matrix[0..4];
    }
    
    public this(double[4][4] matrix, double[4][4] inverseMatrix)
    {
        this.matrix[0..4] = matrix[0..4];
        this.inverseMatrix[0..4] = inverseMatrix[0..4];
    }
    
    private Vector transformVector(Vector vector, double[4][4] matrix)
    {
        double[3] result;
        
        // In a perfect world, one would use D's array operations... but this
        // is not a perfect world.
        
        result[0] = matrix[0][0] * vector.x +
                    matrix[0][1] * vector.y +
                    matrix[0][2] * vector.z +
                    matrix[0][3];

        result[1] = matrix[1][0] * vector.x +
                    matrix[1][1] * vector.y +
                    matrix[1][2] * vector.z +
                    matrix[1][3];

        result[2] = matrix[2][0] * vector.x +
                    matrix[2][1] * vector.y +
                    matrix[2][2] * vector.z +
                    matrix[2][3];

        return Vector(result[0], result[1], result[2]);
    }
    
    public override Vector transformVector(Vector vector)
    {
        return transformVector(vector, matrix);
    }
    
    public override Vector reverseTransformVector(Vector vector)
    {
        return transformVector(vector, inverseMatrix);
    }
    
    public override Vector transformDirectionVector(Vector vector)
    {
        Vector transformedOrigin = transformVector(Vector(0, 0, 0), matrix);
        
        return transformVector(vector, matrix) - transformedOrigin;
    }
    
    public override Vector reverseTransformDirectionVector(Vector vector)
    {
        Vector transformedOrigin = transformVector(Vector(0, 0, 0), inverseMatrix);
        
        return transformVector(vector, inverseMatrix) - transformedOrigin;
    }
    
    public override Ray reverseTransformRay(Ray ray)
    {
        Ray result;
        
        result.point = reverseTransformVector(ray.point);
        result.direction = reverseTransformDirectionVector(ray.direction);
        
        return result;
    }
    
    public MatrixTransformation composeWith(Transformation other)
    {
        MatrixTransformation otherMatrix = cast(MatrixTransformation)other;
        double[4][4] newMatrix, newInverseMatrix;
        
        // Static matrices can only be passed by reference in D.
        multiplyMatrices(otherMatrix.matrix, matrix, newMatrix);
        multiplyMatrices(inverseMatrix, otherMatrix.inverseMatrix, newInverseMatrix);
        
        return new MatrixTransformation(newMatrix, newInverseMatrix);
    }
    
    public static MatrixTransformation createIdentityMatrix()
    {
        double[4][4] identityMatrix = [ [ 1f, 0, 0, 0 ],
                                        [ 0f, 1, 0, 0 ],
                                        [ 0f, 0, 1, 0 ],
                                        [ 0f, 0, 0, 1 ] ];
        
        return new MatrixTransformation(identityMatrix, identityMatrix);
    }
    
    // Yeah, it's huge... but thankfully, it does not need to be fast.
    public static MatrixTransformation createRotationMatrix(double x, double y,
            double z)
    {
        static void xRotationMatrix(double angle, double[4][4] output)
        {
            double[4][4] matrix = [ [ 1f,            0,              0,   0 ],
                                    [ 0f,  cos (angle),   -sin (angle),   0 ],
                                    [ 0f,  sin (angle),    cos (angle),   0 ],
                                    [ 0f,            0,              0,   1 ] ];
            output[0..4] = matrix[0..4];
        }
        
        static void yRotationMatrix(double angle, double[4][4] output)
        {
            // FIXME: Check if it should be left-handed or right-handed
            double[4][4] matrix = [ [ cos (angle),   0,   -sin (angle),   0 ],
                                    [           0,   1,              0,   0 ],
                                    [ sin (angle),   0,    cos (angle),   0 ],
                                    [           0,   0,              0,   1 ] ];
            output[0..4] = matrix[0..4];
        }
        
        static void zRotationMatrix(double angle, double[4][4] output)
        {
            double[4][4] matrix = [ [ cos (angle),   -sin (angle),   0,   0 ],
                                    [ sin (angle),    cos (angle),   0,   0 ],
                                    [           0,              0,   1,   0 ],
                                    [           0,              0,   0,   1 ] ];
            output[0..4] = matrix[0..4];
        }
        
        double[4][4] matrix1, inverseMatrix1;
        double[4][4] matrix2, inverseMatrix2;
        double[4][4] matrix3, inverseMatrix3;
        
        xRotationMatrix( x, matrix1);
        xRotationMatrix(-x, inverseMatrix1);
        yRotationMatrix( y, matrix2);
        yRotationMatrix(-y, inverseMatrix2);
        zRotationMatrix( z, matrix3);
        zRotationMatrix(-z, inverseMatrix3);
        
        double[4][4] finalMatrix, finalInverseMatrix;
        double[4][4] temp;
        
        multiplyMatrices(matrix1, matrix2, temp);
        multiplyMatrices(temp, matrix3, finalMatrix);
        multiplyMatrices(inverseMatrix1, inverseMatrix2, temp);
        multiplyMatrices(temp, inverseMatrix3, finalInverseMatrix);
        
        return new MatrixTransformation(finalMatrix, finalInverseMatrix);
    }
    
    public static MatrixTransformation createTranslationMatrix(double x,
            double y, double z)
    {
        double[4][4] matrix = [ [ 1f, 0, 0, x ],
                                [ 0f, 1, 0, y ],
                                [ 0f, 0, 1, z ],
                                [ 0f, 0, 0, 1 ] ];
        
        double[4][4] inverseMatrix = [ [ 1f, 0, 0, -x ],
                                       [ 0f, 1, 0, -y ],
                                       [ 0f, 0, 1, -z ],
                                       [ 0f, 0, 0,  1 ] ];
        
        return new MatrixTransformation(matrix, inverseMatrix);
    }
    
    public static MatrixTransformation createScalingMatrix(double x, double y,
            double z)
    {
        double[4][4] matrix = [ [  x, 0, 0, 0 ],
                                [ 0f, y, 0, 0 ],
                                [ 0f, 0, z, 0 ],
                                [ 0f, 0, 0, 1 ] ];
        
        double[4][4] inverseMatrix = [ [ 1/x,  0,  0, 0 ],
                                       [ 0f, 1/y,  0, 0 ],
                                       [ 0f,  0, 1/z, 0 ],
                                       [ 0f,  0,  0, 1 ] ];
        
        return new MatrixTransformation(matrix, inverseMatrix);
    }
}

private void showMatrix(double[4][4] matrix)
{
    Stdout("Matrix:").newline;
    for (int i = 0; i < 4; i++)
    {
        Stdout("[");
        for (int j = 0; j < 4; j++)
        {
            if (j != 0)
                Stdout(", ");
            Stdout(matrix[i][j]);
        }
        Stdout("]").newline;
    }
}

private void showVector(char[] name, Vector v)
{
    Stdout.formatln("Vector '{}': <{}, {}, {}>", name, v.x, v.y, v.z);
}

private void multiplyMatrices(double[4][4] matrix1, double[4][4] matrix2,
        double[4][4] result)
{
    for (int i = 0; i < 4; i++)
        for (int j = 0; j < 4; j++)
        {
            result[i][j]=0;
            for (int k = 0; k < 4; k++)
                result[i][j] += matrix1[i][k] * matrix2[k][j];
        }
}

/// Calculate the inverse matrix.
private void invertMatrix(double[4][4] matrix, double[4][4] result)
{
    const double epsilon = 10e-10;
    const int n = 4;
    alias result A;
    double[4] T = [0f, 1, 2, 3];
    
    for (int i = 0; i < 4; i++)
        for (int j = 0; j < 4; j++)
            A[i][j] = matrix[i][j];

    for (int p = 0; p < n; p++)
    {
        // Find the max
        int i0 = p;
        for (int i = p + 1; i < n; i++)
            if (abs(A[i0][p]) < abs(A[i][p]))
                i0 = i;

        if (abs(A[i0][p]) <= epsilon)
            throw new Exception("Cannot invert singular matrix.");

        swapLines(A, i0, p);
        swapLines(T, i0, p);

        for (int i = 0; i < n; i++)
            if (i != p)
            {
                for (int j = 0; j < n; j++)
                    if (j != p)
                        A[i][j] = A[i][j] - (A[i][p] / A[p][p]) * A[p][j];

                A[i][p] = A[i][p] / A[p][p];
            }

            for (int j = 0; j < n; j++)
                if (j != p)
                    A[p][j] = -A[p][j] / A[p][p];

            A[p][p] = 1 / A[p][p];
    }

    for (int i = 0; i < n; i++)
    {
        // Find column i
        for (int j = 0; j < n; j++)
            if (T[j] == i)
            {
                swapLines(A, i, j);
                swapLines(T, i, j);
                break;
            }
    }
}

private void swapLines(double[4] vector, int line1, int line2)
{
    double temp = vector[line1];
    vector[line1] = vector[line2];
    vector[line2] = temp;
}

private void swapLines(double[4][4] matrix, int line1, int line2)
{
    double temp;
    
    for (int i = 0; i < 4; i++)
    {
        temp = matrix[line1][i];
        matrix[line1][i] = matrix[line2][i];
        matrix[line2][i] = temp;
    }
}
