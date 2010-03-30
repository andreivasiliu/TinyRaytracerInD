/***************************************************************************************************
    Decode and encode a png image.

    This can be useful to:
    - test lodepng
    - convert png images to RGB(A) format
    - remove redundant information that is not parsed by lodepng
    - possibly reduce png image size

    Usage: recode pngfile1 pngfile2 [options]
   -f=<filter>         filter can be one of: adaptive, none, sub, up, average, paeth
   -c=<compression>    zlib strategy, one of: none, rle, default, filtered


***************************************************************************************************/
module Recode;

version(Tango)
{
    import tango.io.File;
    import tango.io.Stdout;
}
else
{
    import std.stdio;
    import std.file;
    import std.path;
    import std.stdio;
}

import lodepng.Decode;
import lodepng.Encode;

version( Tango )
{
    void println(char[] str)
    {
        Stdout(str).newline;
    }
}
else
{
    alias writefln println;
}
/+
None      (ubyte c, ubyte b, ubyte a, ubyte x) { return x; }
    ubyte Sub       (ubyte c, ubyte b, ubyte a, ubyte x) { return x - a; }
    ubyte Up        (ubyte c, ubyte b, ubyte a, ubyte x) { return x - b; }
    ubyte Average   (ubyte c, ubyte b, ubyte a, ubyte x) { return x - (a + b) / 2; }
    ubyte Paeth     (
+/
void showHelp(char[] errorMessage = "")
{
    if (errorMessage.length)
        println("error: " ~ errorMessage);
    println("  usage: recode pngfile1 pngfile2 [options]");
    println("   -f=<filter>         filter can be one of: adaptive, none, sub, up, average, paeth");
    println("   -c=<compression>    zlib strategy, one of: none, rle, default, filtered");
}

CompressionStrategy cs = CompressionStrategy.RLE;
FilterStrategy fs = FilterStrategy.Dynamic;

void main(char[][] args)
{
 	println("Recode. Decode and encode a png image, will discard unsupported chunks.\n");

	if (args.length < 3)
	{
		showHelp("wrong number of arguments provided");
		return 0;
	}

	char[] pngFile1;
	char[] pngFile2;

	foreach(arg; args[1..$])
	{
	    if (arg[0] == '-')
	    {
	        if (arg.length < 4)
            {
                showHelp("option not recognized");
                return 1;
            }
            if (arg[1..3] == "f=")
            {
                switch(arg[3..$])
                {
                    case "adaptive": fs = FilterStrategy.Dynamic; break;
                    case "none":  fs = FilterStrategy.None; break;
                    case "sub":  fs = FilterStrategy.Sub; break;
                    case "up":  fs = FilterStrategy.Up; break;
                    case "average":  fs = FilterStrategy.Average; break;
                    case "paeth":  fs = FilterStrategy.Paeth; break;
                    default: showHelp("wrong filter type"); return 1; break;
                }
            }
            else if (arg[1..3] == "c=")
            {
                switch (arg[3..$])
                {
                	case "rle":	case "RLE": cs = CompressionStrategy.RLE; break;
                	case "default": cs = CompressionStrategy.Default; break;
                	case "filtered": cs = CompressionStrategy.Filtered; break;
                	case "none": cs = CompressionStrategy.None; break;
                    default: showHelp("wrong compression type"); return 1; break;
                }
            }
            else
            {
                showHelp("unrecognized option");
                return 1;
            }
	    }
	    else
	    {
	        if (pngFile1.length)
	        {
	            if (pngFile2.length)
                {
                    showHelp("too files specified");
                    return 1;
                }
	            pngFile2 = arg;
	        }
	        else
	            pngFile1 = arg;
	    }
	}

 	ubyte[] source;

    version (Tango)
    {
        source = cast(ubyte[])((new File(pngFile1)).read());
    }
    else
    {
        source = cast(ubyte[])read(pngFile1);
    }

	ubyte[] data;
    data.length = source.length * 2;

	PngInfo inf;
    inf.image = readHeader(source);

    assert(source.length > 0);
	data = decode(source, inf, data);
	assert(data.length > 0);

	ubyte[] dataOut = encode(data, Settings(inf, false));
	version(Tango)
	{
	    (new File(pngFile2)).write(dataOut);
	    Stdout("Original file: ")(pngFile1)(" (")(source.length / 1024)(" Kb)").newline;
	    Stdout("Recoded as: ")(pngFile2)(" (")(dataOut.length / 1024)(" Kb)").newline;
	    Stdout("Difference: ")( (cast(int)dataOut.length - cast(int)source.length) / 1024)(" Kb)").newline;
	}
	else
	{
	    std.file.write(pngFile2, dataOut);
	    writefln("Original file: ", pngFile1, " (", source.length / 1024, " Kb)");
	    writefln("Recoded as: ", pngFile2, " (", dataOut.length / 1024, " Kb)");
	    writefln("Difference: ", (cast(int)dataOut.length - cast(int)source.length) / 1024, " Kb");
	}
}
