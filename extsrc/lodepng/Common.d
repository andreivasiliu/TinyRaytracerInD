// written in the D programming language

/***************************************************************************************************
Types and functions common to both the encode and decoder of lodepng, as well as image format
conversion routines

License:
Copyright (c) 2005-2007 Lode Vandevenne
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  - Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.<br>
  - Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.<br>
  - Neither the name of Lode Vandevenne nor the names of his contributors may be used to endorse or promote products derived from this software without specific prior written permission.<br>

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Authors: Lode Vandevenne (original version in C++), Lutger Blijdestijn (D version) : lutger dot blijdestijn at gmail dot com,
  Stewart Gordon (modifications)

Date: August 7, 2007

References:
$(LINK2 http://members.gamedev.net/lode/projects/LodePNG/, Original lodepng) <br>
$(LINK2 http://www.w3.org/TR/PNG/, PNG Specification) <br>
$(LINK2 http://www.libpng.org/pub/png/pngsuite.html, PNG Suite: set of test images) <br>
$(LINK2 http://optipng.sourceforge.net/, OptiPNG: tool to experimentally optimize png images)
***************************************************************************************************/
module lodepng.Common;
import lodepng.util;
import lodepng.ZlibCodec;

/***************************************************************************************************
	Png specific exception.

		Instead of errors codes, this port of lodepng makes use of exceptions.
		At the moment, the decoder is very strict and will tolerate no errors whatsoever even
		if they could safely be ignored. CRC checking is always done.
		This might be slightly relaxed in a future release to be more in line with the
		recommendations of the specification.

***************************************************************************************************/
class PngException : Exception
{
	this(char[] msg)
	{
		super(msg);
	}
}

package alias _enforce!(PngException) pngEnforce;

/***************************************************************************************************
	An enumeration of the color types supported by the png format.

	see the $(LINK2 http://www.w3.org/TR/PNG/index-noobject.html#6Colour-values, png specification)
	for details.

***************************************************************************************************/
enum ColorType : ubyte
{
	Greyscale = 0, /// allowed bit depths: 1, 2, 4, 8 and 16
	RGB = 2, /// allowed bit depths: 8 and 16
	Palette = 3, /// allowed bit depths: 1, 2, 4 and 8
	GreyscaleAlpha = 4, /// allowed bit depths: 8 and 16
	RGBA = 6, /// allowed bit depths: 8 and 16
	Any = 7, /// one of the above
}

/***************************************************************************************************
Convert source pixels from the color type described by info the color type destColorType.

	Conversion can be from any color type supported by the png specification to
	24 / 32 bit RGB(A). If RGBA is specified and the info has a colorkey, transparency is applied.

	If a buffer is given, it may be used to store the result and a slice from it can be returned.

	Returns: converted image in RGB(A) format, pixels are from left to right, top to bottom
***************************************************************************************************/
ubyte[] convert(in ubyte[] source, /+const+/ ref PngInfo info, ColorType destColorType = ColorType.RGBA)
{
	ubyte[] buffer;
	return convert(source, info, buffer, destColorType);
}

/// ditto
ubyte[] convert(in ubyte[] source, /+const+/in PngInfo info, ref ubyte[] buffer, ColorType destColorType = ColorType.RGBA)
{
	if (!(destColorType == ColorType.RGBA || destColorType == ColorType.RGB))
	{
		destColorType = ColorType.RGBA;
		assert(false, "destColorType should be one of: RGB, RGBA");
	}
	return _convert(source, info, buffer, destColorType);
}

/***************************************************************************************************
	Description of the image.

***************************************************************************************************/
struct PngImage
{
	/// constructor
	static PngImage opCall(uint w, uint h, ubyte bd, ColorType ct, ubyte ilace =0)
	{
		PngImage result;
		with (result)
		{
			width = w;
			height = h;
			bitDepth = bd;
			colorType = ct;
			bpp = bitDepth * numChannels(colorType);
			interlaced = ilace; 
		}
		return result;
	}
	uint    width; /// in pixels
	uint    height; /// in pixels
	ubyte   bitDepth; /// bits per color channel, see also: ColorType
	ubyte   bpp; /// bits per pixel
	ColorType colorType; /// the color format, see also: ColorType
	ubyte interlaced = 0;
}

/***************************************************************************************************
Png file and image description.

	A simple data type describing the png file. Usually the image field will contain all the
	required information.

	There is one member that behaves a bit different: parseText(bool). This is used to tell
	the decoder whether to ignore textual metadata (which it does by default).

***************************************************************************************************/
struct PngInfo
{

	PngImage image; /// Information related to the image, see also: PngImage.

	/***********************************************************************************************
	Recommended background color or empty if none is given.

		Interpretation of the array depends on the color type:

		$(DL
			$(DT palette)
				$(DD palette[backgroundColor[0]] is the background color)
			$(DT greyscale (8 bit or less) )
				$(DD backgroundColor[0] is used)
			$(DT RGB(A) (8 bit or less))
				$(DD backgroundColor[0..3] is the rgb triplet used)
			$(DT 16-bit greyscale or RGB(A))
				$(DD  same as above, but the color/greyscale channels are 2 bytes wide))

	***********************************************************************************************/
	ubyte[] backgroundColor;

	/***********************************************************************************************
	Palette colors or empty if this image does not make use of it.

		  Each palette entry is a 32-bit RGBA pixel represented as an ubyte[4].
		  When a colorkey is specified, it is automatically applied to the palette by the decoder.

	***********************************************************************************************/
	ubyte[4][] palette;

	/***********************************************************************************************
		Whether there is a colorkey transparency associated with the png image.

			Note that this is applicable only when the image has no seperate alpha channel, and
			the image format is not ColorType.Palette. In the latter case, transparency is always
			stored in the palette by the decoder.
			The transparent color is stored in keyR, keyG and keyB, for brevity greyscale is in keyR.
	***********************************************************************************************/
	bool   colorKey = false;
	ushort keyR;     ///
	ushort keyG;     ///
	ushort keyB;     ///

	/// By default, lodepng will not parse textual metadata, set to true if this is desired.
	void parseText(bool flag)
	{
		parseTextChunks = flag;
	}

	/// Whether parsing of metadata is enabled.
	bool parseText()
	{
		return parseTextChunks;
	}

	/***********************************************************************************************
		Retrieve the dictionary of textual metadata.

			When no text is read, because it was set to be ignored or there wasn't any,
			this returns null so check the return value.

			In the case that a PngInfo instance is passed more than once to the api,
			an existing dictionary is not reused. Instead a new one will be
			created. It is therefore not necessary to copy anything, the strings they are all yours.

	***********************************************************************************************/
	PngText text()
	{
		return textual;
	}

	/// Returns whether any unicode text has been stored.
	bool hasUnicodeText()
	{
		return textual !is null && textual.unicodeText.length > 0;
	}

	/// Returns whether any latin-1 text has been stored.
	bool hasLatin1Text()
	{
		return textual !is null && textual.latin1Text.length > 0;
	}

	package
	{
		ubyte interlace;
		PngText textual;
    }

    char[][char[]] unicodeText;
    ubyte[][ubyte[]] latin1Text;

	private bool parseTextChunks = true;
}

/// Dictionary of key-value textual metadata in utf-8 and / or latin-1 encoding.
class PngText
{
	///
	this()
	{
	}

	///
	this(char[][char[]] unicodeText)
	{
		this.unicodeText = unicodeText;
	}

	///
	this(ubyte[][ubyte[]] latin1Text)
	{
		this.latin1Text = latin1Text;
	}

	/// Visit utf-8 dictionary
	int opApply(int delegate(ref char[] keyword, ref char[] contents) dg)
	{
		int result = 0;
		foreach(index, value; unicodeText)
		{
			result = dg(index, value);
			if (result)
				return result;
		}
		return 0;
	}

	/// Visit latin-1 dictionary
	int opApply(int delegate(ref ubyte[] keyword, ref ubyte[] contents) dg)
	{
		int result = 0;
		foreach(index, value; latin1Text)
		{
			result = dg(index, value);
			if (result)
				return result;
		}
		return 0;
	}

	/// Assign key-value pair
	PngText opIndexAssign(ubyte[] value, ubyte[] keyword)
	{
		latin1Text[value] = keyword;
		return this;
	}

	/// ditto
	PngText opIndexAssign(char[] value, char[] keyword)
	{
		unicodeText[value] = keyword;
		return this;
	}

	package
	{
		char[][char[]] unicodeText;
		ubyte[][ubyte[]] latin1Text;
	}
}

/// Number of color or alpha channels associated with this color type.
uint numChannels(ColorType colorType)
in
{
	assert(colorType != ColorType.Any, "cannot determine number of channels with ColorType.Any");
}
body
{
	return [ 0 : 1, 2 : 3, 3 : 1, 4 : 2, 6 : 4, 7 : 0] [colorType];
}

uint bytesPerPixel(ref PngImage image)
{
    return image.bpp / 8;
}

///
bool isGreyscale(ColorType colorType)
{
	return colorType == ColorType.Greyscale || colorType == ColorType.GreyscaleAlpha;
}

///
bool hasAlphaChannel(ColorType colorType)
{
	return colorType == ColorType.RGBA || colorType == ColorType.GreyscaleAlpha;
}

/// Whether the image contains any alpha information (channel / colorkey / palette)
bool hasAlpha(/+const+/ ref PngInfo info)
{
	if (hasAlphaChannel(info.image.colorType) || info.colorKey)
		return true;
	else if (info.image.colorType == ColorType.Palette)
		foreach(color; info.palette)
			if (color[3] != 255)
				return true;
	return false;
}

bool checkCRC(uint crc, ubyte[] data)
{
    return crc == czlib.crc32(0, cast(ubyte *)data, data.length);
}

bool checkCRC(ubyte[] crc, ubyte[] data)
{
    return toUint(crc) == czlib.crc32(0, cast(ubyte *)data, data.length);
}

uint createCRC(ubyte[] data)
{
    return czlib.crc32(0, cast(ubyte *)data, data.length);
}
/**
 * Abstracts a png chunk
 * 
 * */
struct Chunk
{
    /**
     * Construct a Chunk from a stream of bytes
     * 
     * Params:
     *     byteStream = the whole chunk needs to be available in this array
     * Returns: a crc-checked chunk from byteStream, the data is sliced, not copied
     */
    static Chunk fromStream(ubyte[] byteStream)
    in
    {
        assert(byteStream.length >= 12);
    }
    body
    {
        Chunk result;
        uint dataLength = toUint(byteStream);
        result.type = toUint(byteStream[4 .. 8]);
        if (dataLength)
            result.data = byteStream[8 .. 8 + dataLength];
        mixin(pngEnforce("checkCRC(byteStream[8 + dataLength..12 + dataLength], byteStream[4..8 + dataLength])",
                         "CRC check failed"));
        return result;
    }
    
    int opCmp(Chunk other)
    {
        int result = chunkOrder(type, other.type);

        /* Setting of the afterIDAT member is not yet implemented.  It would
         * be used to prevent unknown ancillary chunks from being moved from
         * before the IDAT chunk to after it, or vice versa.

        if (result == 0) {
            result = cast(int) afterIDAT - cast(int) other.afterIDAT;
        }
        if (result == 0) {
            // if one of them is IDAT, the other is before IDAT
            if (type == IDAT) return 1;
            if (other.type == IDAT) return -1;
        }
         */
        return result;
    }

    /**
     * 
     * Returns: total length of this chunk (not only data)
     */
    uint length() { return data.length + 12; }
    
    /**
     * 
     * Returns: chunk containing a copy of the data
     */
    Chunk dup()
    {
    	return Chunk(type, data.dup);
    	
    }
    
    /**
     * type of the chunk packed into a uint, see the png specification for details
     */
    uint type;
    
    /**
     * (slice of) the data of this chunk
     */
    ubyte[] data;
    //bool afterIDAT;
}

/**
 * 
 * Params:
 *     a = 
 *     b = 
 *     c = 
 *     d = 
 * Returns:
 */
uint toUint(ubyte a, ubyte b, ubyte c, ubyte d) { return a << 24 | b << 16 | c << 8 | d; }

/**
 * 
 * Params:
 *     source = 
 * Returns:
 */
uint toUint(ubyte[] source)
    in { assert(source.length >= 4); }
    body { return source[0] << 24 | source[1] << 16 | source[2] << 8 | source[3]; }

template toConstUint(char[] source, Dummy = void)
{
    const uint toConstUint = source[0] << 24 | source[1] << 16 | source[2] << 8 | source[3];
}

    const IHDR = toConstUint!("IHDR");///
	//const IHDR = toUint('I', 'H', 'D', 'R');
	const IDAT = toUint('I', 'D', 'A', 'T');///
	const PLTE = toUint('P', 'L', 'T', 'E');///
	const tRNS = toUint('t', 'R', 'N', 'S');///
	const bKGD = toUint('b', 'K', 'G', 'D');///
	const IEND = toUint('I', 'E', 'N', 'D');///
	const tEXt = toUint('t', 'E', 'X', 't');///
	const iTXt = toUint('i', 'T', 'X', 't');///
	const zTXt = toUint('z', 'T', 'X', 't');///
	const cHRM = toUint('c', 'H', 'R', 'M');///
	const gAMA = toUint('g', 'A', 'M', 'A');///
	const hIST = toUint('h', 'I', 'S', 'T');///
	const iCCP = toUint('i', 'C', 'C', 'P');///
	const oFFs = toUint('o', 'F', 'F', 's');///
	const pCAL = toUint('p', 'C', 'A', 'L');///
	const pHYs = toUint('p', 'H', 'Y', 's');///
	const sBIT = toUint('s', 'B', 'I', 'T');///
	const sCAL = toUint('s', 'C', 'A', 'L');///
	const sPLT = toUint('s', 'P', 'L', 'T');///
	const sRGB = toUint('s', 'R', 'G', 'B');///

package
{
	//return type is a LodePNG error code
	bool checkColorValidity(uint colorType, uint bitDepth)
	{
		alias bitDepth bd;
		switch(colorType)
		{
			case 0: if(!(bd == 1 || bd == 2 || bd == 4 || bd == 8 || bd == 16)) //grey
						return false;
				break;
			case 2: if(!(bd == 8 || bd == 16)) //RGB
						return false;
				break;
			case 3: if(!(bd == 1 || bd == 2 || bd == 4 || bd == 8 )) //palette
						return false;
				break;
			case 4: if(!(bd == 8 || bd == 16)) //greyalpha
						return false;
				break;
			case 6: if(!(bd == 8 || bd == 16)) //RGBA
						return false;
				break;
			default:
				mixin(pngEnforce(`false`, "invalid png color format"));
		}
		return true;
	}

	// Paeth predicter, used by one of the PNG filter types
	int paethPredictor(int a, int b, int c)
	{
		int p = a + b - c;
		int pa = p > a ? p - a : a - p;
		int pb = p > b ? p - b : b - p;
		int pc = p > c ? p - c : c - p;

		if(pa <= pb && pa <= pc) return a;
		else if(pb <= pc) return b;
		return c;
	}

	uint readBitFromStreamReversed(ref size_t bitpointer, ubyte[] bitstream)
	{
		return (bitstream[bitpointer / 8] >> (7 - bitpointer++ & 0x7)) & 1;
	}
}

private int chunkOrder(uint type1, uint type2) {
	if (type1 == type2) return 0;

	// sort out IHDR and IEND first
	if (type1 == IHDR) return -1;
	if (type1 == IEND) return 1;
	if (type2 == IHDR) return 1;
	if (type2 == IEND) return -1;

	// now sort out PLTE and IDAT
	switch (type1) {
		case PLTE:
			switch (type2) {
				case gAMA: case cHRM: case sRGB: case iCCP: case sBIT:
					return 1;

				case tRNS: case bKGD: case hIST: case IDAT:
					return -1;

				default:
					return 0;
			}

		case IDAT:
			switch (type2) {
				case gAMA: case cHRM: case sRGB: case iCCP: case sBIT:
				case PLTE: case tRNS: case bKGD: case hIST: case pHYs:
				case sPLT: case oFFs: case pCAL: case sCAL:
					return 1;

				default:
					return 0;
			}

		default:
			if (type2 == PLTE || type2 == IDAT) {
				return -chunkOrder(type2, type1);
			}
	}

	// if we reach this point, they're both ancillary chunks
	switch (type1) {
		case gAMA: case cHRM: case sRGB: case iCCP: case sBIT:
			switch (type2) {
				case tRNS: case bKGD: case hIST: case IDAT:
					return -1;

				default:
					return 0;
			}

		case tRNS: case bKGD: case hIST: case IDAT:
			switch (type2) {
				case gAMA: case cHRM: case sRGB: case iCCP: case sBIT:
					return 1;

				default:
					return 0;
			}

		default:
			return 0;
	}
}




private ubyte[] _convert(in ubyte[] source, /+const+/ ref PngInfo info, ref ubyte[] buffer, ColorType destColorType)
{
	bool alpha = hasAlphaChannel(destColorType);

	if (destColorType == info.image.colorType)
	{
		if ((destColorType == ColorType.RGBA || destColorType == ColorType.RGB) && info.image.bitDepth == 8)
		{
			buffer = source;
			return buffer;
		}
	}


	uint w = info.image.width;
	uint h = info.image.height;
	ubyte[] res = buffer;
	ubyte colors = alpha ? 4 : 3;

	res.length = w * h * colors;

	assert(source.length >=  (w * (info.image.bpp / 8  ) * h));

	 if (!info.colorKey && alpha)
		for(size_t i = 0; i < w * h; i++)
			res[4 * i + 3] = 255;

	switch(info.image.colorType)
	{
		case 0: //greyscale color
		{
			if(info.image.bitDepth == 8)
			{
				foreach(i, pixel; source[0 .. w * h])
					res[colors * i + 0] = res[colors * i + 1] = res[colors * i + 2] = pixel;
				if (info.colorKey && alpha)
					foreach(i, pixel; source[0 .. w * h])
						res[colors * i + 3] = (pixel == info.keyR) ? 0 : 255;
			}
			else if (info.image.bitDepth == 8)
			{
				for(size_t i = 0; i < w * h; i++)
					res[colors * i + 0] = res[colors * i + 1] = res[colors * i + 2] = source[i * 2];
				if (info.colorKey && alpha)
					for(size_t i = 0; i < w * h; i++)
						res[colors * i + 3] = (256U * source[i] + source[i + 1] == info.keyR) ? 0 : 255;
			}
			else
			{
				if (!info.colorKey)
				{
					for(size_t i = 0; i < w * h; i++)
					{
						size_t bp = info.image.bitDepth * i;
						uint value = 0;
						uint pot = 1 << info.image.bitDepth; //power of two
						for(size_t j = 0; j < info.image.bitDepth; j++)
						{
							pot /= 2;
							uint _bit = readBitFromStreamReversed(bp, source);
							value += pot * _bit;
						}
						//scale value from 0 to 255
						value = (value * 255) / ((1 << info.image.bitDepth) - 1);
						res[colors * i + 0] = res[colors * i + 1] = res[colors * i + 2] = cast(ubyte)(value);
					}
				}
				else if (alpha)
				{
					for(size_t i = 0; i < w * h; i++)
					{
						size_t bp = info.image.bitDepth * i;
						uint value = 0;
						uint pot = 1 << info.image.bitDepth; //power of two
						for(size_t j = 0; j < info.image.bitDepth; j++)
						{
							pot /= 2;
							uint _bit = readBitFromStreamReversed(bp, source);
							value += pot * _bit;
						}
						res[colors * i + 3] = ( value && ((1U << info.image.bitDepth) - 1U) ==
							info.keyR && ((1U << info.image.bitDepth) - 1U)) ? 0 : 255;
						value = (value * 255) / ((1 << info.image.bitDepth) - 1);
						res[colors * i + 0] = res[colors * i + 1] = res[colors * i + 2] = cast(ubyte)(value);
					}
				}
			}
		}
		break;
		case 2: //RGB color
		{
			if(info.image.bitDepth == 8)
			{
				for(size_t i = 0; i < w * h; i++)
					for(size_t c = 0; c < 3; c++)
						res[colors * i + c] =
								source[3 * i + c];
				if (info.colorKey && alpha)
					for(size_t i = 0; i < w * h; i++)
						res[colors * i + 3] = (source[3 * i + 0] == info.keyR && source[3 * i + 1] ==
							info.keyG && source[3 * i + 2] == info.keyB) ? 0 : 255;
			}
			else // 16 bit
			{
				for(size_t i = 0; i < w * h; i++)
					for(size_t c = 0; c < 3; c++)
						res[colors * i + c] = source[6 * i + 2 * c];
				if (info.colorKey && alpha)
					for(size_t i = 0; i < w * h; i++)
						res[colors * i + 3] = (256U * source[6 * i + 0] + source[6 * i + 1] ==
							 info.keyR && 256U * source[6 * i + 2] + source[6 * i + 3] ==
							 info.keyG && 256U * source[6 * i + 4] + source[6 * i + 5] ==
							 info.keyB) ? 0 : 255;
			}
			break;
		}
		case 3: //indexed color (palette)
		{
			if(info.image.bitDepth == 8)
				for(size_t i = 0; i < w * h; i++)
					res[colors * i..colors * i + colors] = info.palette[source[i]][0..colors];
			else if(info.image.bitDepth < 8)
			{
				for(size_t i = 0; i < w * h; i++)
				{
					size_t bp = info.image.bitDepth * i;
					uint value = 0;
					uint pot = 1 << info.image.bitDepth; //power of two
					for(size_t j = 0; j < info.image.bitDepth; j++)
					{
						pot /= 2;
						uint _bit = readBitFromStreamReversed(bp, source);
						value += pot * _bit;
					}
					res[colors * i.. colors * i + colors] = info.palette[value][0..colors];
				}
			}
			break;
		}
		case 4: //greyscale with alpha
		{
			if(info.image.bitDepth == 8)
			{
				for(size_t i = 0; i < w * h; i++)
				{
					res[colors * i + 0] = res[colors * i + 1] = res[colors * i + 2] = source[i * 2 + 0];
					if (alpha)
						res[colors * i + 3] = source[i * 2 + 1];
				}
			}
			else if(info.image.bitDepth == 16)
			{
				for(size_t i = 0; i < w * h; i++)
				{
					//most significant byte
					res[colors * i + 0] = res[colors * i + 1] = res[colors * i + 2] = source[4 * i];
					if (alpha)
						res[colors * i + 3] = source[4 * i + 2];
				}
			}
			break;
		}
		case 6: //RGB with alpha
		{
			if (alpha && info.image.bitDepth == 16)
			{
				for(size_t i = 0; i < w * h; i++)
					res[colors * i .. colors * i + colors] =
						[ source[8 * i], source[8 * i + 2], source[8 * i + 4], source[8 * i + 6] ];
			}
			else if (info.image.bitDepth == 16)
			{
				for(size_t i = 0; i < w * h; i++)
					res[colors * i .. colors * i + 3] =
						[ source[8 * i], source[8 * i + 2], source[8 * i + 4] ];
			}
			else // must be RGB
				for(size_t i = 0; i < w * h; i++)
					res[colors * i .. colors * i + 3] = source[4 * i .. 4 * i + 3];
			break;
		}
		default:
			mixin(pngEnforce("false", "invalid conversion"));
			break;

	}
	return res;
}

/**
 * 
 * Params:
 *     chunkType = 
 * Returns:
 */
public char[] chunkTypeToString(uint chunkType)
{
    char[] result = new char[4];
    result[0] = chunkType >> 24 ;
    result[1] = chunkType >> 16;
    result[2] = chunkType >> 8;
    result[3] = chunkType;
    return result;
}

public char[] colorTypeToString(ColorType ct)
{
    switch (ct)
    {
        with (ColorType)
        {
            case Greyscale: return "Greyscale";
            case RGB: return "RGB";
            case Palette: return "Palette";
            case GreyscaleAlpha: return "GreyscaleAlpha";
            case RGBA: return "RGBA";
        }
        default: return null;
    }
}