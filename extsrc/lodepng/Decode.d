// written in the D programming language

/***************************************************************************************************
License:
Copyright (c) 2005-2007 Lode Vandevenne
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  - Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.<br>
  - Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.<br>
  - Neither the name of Lode Vandevenne nor the names of his contributors may be used to endorse or promote products derived from this software without specific prior written permission.<br>

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Authors: Lode Vandevenne (original version in C++), Lutger Blijdestijn (D version) : lutger dot blijdestijn at gmail dot com.

About:
The decoder is small but sufficient for most purposes. It is compliant to the png specification and
has been tested with the png suite. To decode images, only <i>decode</i> is needed. The <i>decode32</i> function is for convenience,
it can decode and convert to the common 32-bit RGBA format in one go.
The rest of the api exposes the low-level functionality of lodepng, which is made available in order to use this library
for png-editing purposes.
<br>
This module publicly imports lodepng.Common, where you'll find the data types used by both the encoder
and decoder, as well as some utility and image format conversion routines.

Date: Januari 16, 2008

Examples:
Here is an example how you could use LodePNG with opengl, see the api documentation for details.
---
uint loadPNG(char[] filename)
{
    uint textureID;

    glEnable(GL_TEXTURE_2D);
    glGenTextures(1, &textureID);
    glBindTexture(GL_TEXTURE_2D, textureID);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);

    PngInfo info;
    ubyte[] image = decode32(cast(ubyte[])std.file.read(filename), info);

    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, info.image.width, info.image.height, 0, GL_RGBA, GL_UNSIGNED_BYTE,
                        image.ptr);
    return textureID;
}
---

Features:
The following features are supported by the decoder:
<ul>
    <li> conformant decoding of PNGs (all color types, bit depth, interlace mode, CRC checking, etc.)</li>
    <li> support for translucent PNG's, including translucent palettes and color key</li>
    <li> textual key-value meta-data</li>
    <li> the following chunks are interpreted by the decoder
        <ul>
            <li>IHDR (image information)</li>
            <li>PLTE (color palette)</li>
            <li>IDAT (pixel data)</li>
            <li>IEND (the final chunk)</li>
            <li>tRNS (transparency for palettized images)</li>
            <li>bKGD (suggested background color)</li>
            <li>tEXt (uncompressed latin-1 key-value strings)</li>
            <li>zTXt (compressed latin-1 key-value strings)</li>
            <li>iTXt (utf8 key-value strings)</li>
        </ul>
   </li>
</UL>

Limitations:
The following features are not supported.
<ul>
    <li> Streaming / progressive display. All data must be available and is processed in one call.</li>
    <li> The following optional chunk types are not interpreted by the decoder
        <ul>
            <li>cHRM (device independent color info)
            <li>gAMA (device independent color info)
            <li>iCCP (device independent color info)
            <li>sBIT (original number of significant bits)
            <li>sRGB (device independent color info)
            <li>pHYs (physical pixel dimensions)
            <li>sPLT (suggested reduced palette)
            <li>tIME (last image modification time)
        </ul>
    </li>
</ul>


References:
$(LINK2 http://members.gamedev.net/lode/projects/LodePNG/, Original lodepng) <br>
$(LINK2 http://www.w3.org/TR/PNG/, PNG Specification) <br>
$(LINK2 http://www.libpng.org/pub/png/pngsuite.html, PNG Suite: set of test images) <br>
$(LINK2 http://optipng.sourceforge.net/, OptiPNG: tool to experimentally optimize png images)
*/

module lodepng.Decode;
import lodepng.ZlibCodec;
import lodepng.util;
import std.intrinsic;


version (Tango)
{
    import czlib = tango.io.compress.c.zlib;
}
else
{
    import czlib = etc.c.zlib;
}

public import lodepng.Common;


/** Decode source png file

    If a buffer is provided, it may be used to store the result. See bufferSize for details.

    Throws: PngException

    Returns: Decoded image pixels. The color format of the resulting image is the
    same as the source image, see lodepng.Common.convert and decode32 if a specific color format
    is desired.

  	Params:
      source = a png file
      info = information about the image will be stored in here
      buffer = optionally provide an array to use as a buffer while decoding
      dg = optionally provide a delegate that will be called for (and only for) unknown chunks
*/
ubyte[] decode(in ubyte[] source, ref PngInfo info, ubyte[] buffer = null, int delegate(inout Chunk) dg = null)
{
    info.image = source.readHeader();
    scope decompressor = new PngDecoder(info.image);

    foreach(chunk; StreamChunkIter(source[HEADER_SIZE - 1 .. $]))
    {
    	if  (chunk.type == IDAT)
    		decompressor(chunk.data);
    	else if (!parseChunk(chunk, info))
    		if (dg !is null)
    			if (dg(chunk) != 0)
    				return null;

    }
    assert(decompressor.ended);

    return decompressor.reconstructImage()[0..info.image.width * bytesPerPixel(info.image) * info.image.height];
}

/***************************************************************************************************
    Decode source png file to 32-bit RGBA format

    Throws: PngException

    Returns: decoded image pixels in 32-bit RGBA format

    Params:
          source = a png file
          info = information about the image will be stored in here
          buffer = optionally provide an array to use as a buffer while decoding
***************************************************************************************************/
ubyte[] decode32(/+const+/ in ubyte[] source, ref PngInfo info, ubyte[] buffer = null)
{
	buffer = decode(source, info, buffer);
	buffer = convert(buffer, info, ColorType.RGBA);
	info.image.colorType = ColorType.RGBA;
	info.image.bpp = 32;
	info.image.bitDepth = 8;
	info.palette.length = 0;
	return buffer[0..info.image.width * bytesPerPixel(info.image) * info.image.height];
}


/***************************************************************************************************
    Parse png image header from memory.

    throws: PngException

    returns: header information

    Params: source=must contain the first 33 bytes of a png file
***************************************************************************************************/
PngImage readHeader(/+const+/ in ubyte[] source)
in
{
	assert(source.length >= HEADER_SIZE, "array is too small to contain png header");
}
body // see spec: http://www.w3.org/TR/PNG/#11IHDR
{
	mixin(pngEnforce(`source.length >= HEADER_SIZE`, "png header data is too small"));
	mixin(pngEnforce(`source[0..8] == [cast(ubyte)137, 80, 78, 71, 13, 10, 26, 10]`, "invalid png header "));
	mixin(pngEnforce((toUint(source[12..16]) == IHDR).stringof, "invalid png header"));
	mixin(pngEnforce(`checkCRC(source[29 .. 33], source[12 .. 29])`, "invalid CRC"));

	PngImage result;


	with (result)
	{
	    width = toUint(source[16..20]);
	    height = toUint(source[20..24]);
	    bitDepth = source[24];
	    colorType = cast(ColorType)source[25];
	    mixin(pngEnforce( `source[26] == 0`, "unsupported compression method in png header" ));
	    mixin(pngEnforce( `source[27] == 0`, "unsupported filter method in png header" ));
	    mixin(pngEnforce( `checkColorValidity(colorType, bitDepth)`, "invalid header: wrong color format" ));
	    interlaced = source[28];
        mixin(pngEnforce( `interlaced < 2`, "invalid  interlace method in png header" ));
	    bpp = numChannels(colorType) * bitDepth;
	}

	return result;
}

/***************************************************************************************************
    Iterates through chunks in source, parses only the header

    Throws: PngException
    Params: source = a png file
        image = the parsed header
        dg = will be called for each chunk, return anything other than 0 to stop iterating

***************************************************************************************************/
void iterateChunks(/+const+/ in ubyte[] source, out PngImage image, int delegate(inout Chunk) dg)
{
    image = source.readHeader();

    foreach(chunk; StreamChunkIter(source[HEADER_SIZE - 1 .. $]))
    	if (dg(chunk) != 0)
    		return;
}

/***************************************************************************************************
    decode IDAT data

***************************************************************************************************/
scope class PngDecoder
{
	/** constructor */
	this(PngImage image)
	{
		this(image, buf);
	}

	/** ditto */
	this(PngImage image, ref ubyte[] buffer)
	{
		img = image;
		buf = buffer;
		if (img.interlaced == 1)
	        buf.length = ((img.width * img.bpp + 7) / 8) * img.height + (img.height * 2); // guess
	    else
	        buf.length = ((img.width * img.bpp + 7) / 8) * img.height + img.height;
		if (img.interlaced == 1)
	        ilaceBuffer.length = buf.length - img.height;
		decoder = DecodeStream.create(buf);
	}

    /***************************************************************************************************
        inflate, call multiple times if there are more than 1 IDAT chunks to be decompressed

        Throws: ZlibException
        params: data of an IDAT chunk
    ***************************************************************************************************/
	void opCall(ref ubyte[] data)
	{
		decoder(data);
		return true;
	}

    /***************************************************************************************************
        Whether inflation has completed

    ***************************************************************************************************/
	bool ended()
	{
		return decoder.hasEnded;
	}

    /***************************************************************************************************
        Apply reconstruction filters and deinterlace if required

        note that ended() must return true before this function can be called if no data is provided

        params:
            filtered=optionally provide uncompressed filtered pixels yourself
    **************************************************************************************************/
	ubyte[] reconstructImage(ubyte[] filtered = null)
    in
    {
        assert(filtered !is null || ended);
        
    }
    body
	{
        buf = filtered is null ? decoder() : filtered;
        return (img.interlaced == 0) ? reconstruct(buf, img) : deinterlace(buf, ilaceBuffer, img);
	}

	private
	{
		DecodeStream decoder;
		PngImage img;

		ubyte[] buf;
		ubyte[] ilaceBuffer;
	}
}


/***************************************************************************************************
    parse any known chunk except IDAT

    params:
            chunk=chunk to be parsed
            info=parsed information will be written to info
    returns: true if a chunk is parsed, false otherwise

***************************************************************************************************/
bool parseChunk(/+const+/ ref Chunk chunk, ref PngInfo info)
{
	switch(chunk.type)
    {
        case PLTE: parsePLTE(chunk, info);
        	break;
        case tRNS: parsetRNS(chunk, info);
            break;
        case bKGD: parsebKGD(chunk, info);
            break;
        case zTXt: parsezTXt(chunk, info);
            break;
        case tEXt: parsetTXt(chunk, info);
            break;
        case iTXt: parseiTXt(chunk, info);
            break;
        default:
        	return false;
    }
	return true;
}

/** parse palette chunk */
void parsePLTE(/+const+/ ref Chunk chunk, ref PngInfo info)
{
	mixin(pngEnforce(`chunk.data.length <= 256 * 3`, "palette size is too large"));
    info.palette.length = chunk.data.length / 3;
    foreach(index, ref ubyte[4] color; info.palette)
    {
        color[0..3] = chunk.data[index * 3 .. index * 3 + 3];
        color[3] = 255;
    }
}

/** parse transparency chunk */
void parsetRNS(/+const+/ ref Chunk chunk, ref PngInfo info)
{
	if (chunk.data.length == 0)
        return;
    info.colorKey = true;
    if (info.image.colorType == ColorType.Palette) // index-values
    {
        mixin(pngEnforce(`chunk.data.length <= info.palette.length`, "palette size is too large"));
        foreach(index, alpha; chunk.data)
            info.palette[index][3] = alpha;
    }
    else if (info.image.colorType == ColorType.RGB)
    {
        info.keyR = 256U * chunk.data[0] + chunk.data[1];
        info.keyG = 256U * chunk.data[2] + chunk.data[3];
        info.keyB = 256U * chunk.data[4] + chunk.data[5];
    }
    else if (info.image.colorType == ColorType.Greyscale)
    {
        info.keyR = 256U * chunk.data[0] + chunk.data[1];
    }
    else
    {
        assert(false);
    }
}

/** parse background color chunk */
void parsebKGD(/+const+/ ref Chunk chunk, ref PngInfo info)
{
	if (info.image.colorType == ColorType.Palette || info.image.bitDepth == 16)
	    info.backgroundColor = chunk.data.dup;
	else
	{
	    info.backgroundColor.length = chunk.data.length / 2;
	        foreach(index, ref value; info.backgroundColor)
	            value = chunk.data[index * 2];
	}
}

/** parse latin1 text chunk */
void parsetTXt(/+const+/ ref Chunk chunk, ref PngInfo info)
{
	if (info.parseText)
    {
        auto sep = strFind(cast(char[])chunk.data, 0);
        if (sep > 0)
            info.latin1Text[chunk.data[0..sep]] = chunk.data[sep + 1 .. $];
    }
}

/** parse latin1 compressed text chunk */
void parsezTXt(/+const+/ ref Chunk chunk, ref PngInfo info)
{
	if (info.parseText)
	{
	    auto sep = strFind(cast(char[])chunk.data, 0);
	    if (sep > 0)
	    {
	        if (chunk.data[sep + 1] == 0)
	            info.latin1Text[chunk.data[0..sep]] = chunk.data[sep + 2 .. $];
	        else
	        {
	            ubyte[] value;
	            auto decoder = DecodeStream.create(value);
	            decoder(chunk.data[sep + 2 .. $]);
	            info.latin1Text[chunk.data[0..sep]] = value;
	        }
	    }
	}
}

/** parse unicode text chunk */
void parseiTXt(/+const+/ ref Chunk chunk, ref PngInfo info)
{
	if (info.parseText)
    {

        auto sep = strFind(cast(char[])chunk.data, 0);
        char[] keyword = cast(char[])chunk.data[0..sep];
        bool compressed = chunk.data[sep + 1] == 0 ? false : true;
        sep += strFind(cast(char[])chunk.data[sep + 3 .. $], 0) + 3;
        sep += strFind(cast(char[])chunk.data[sep + 1 .. $], 0) + 1;
        if (!compressed)
            info.unicodeText[keyword] = cast(char[])chunk.data[sep + 1..$];
        else
        {
            ubyte[] value;
            auto decoder = DecodeStream.create(value);
            decoder(chunk.data[sep + 1..$]);
            info.unicodeText[keyword] = cast(char[])value;
        }
    }
}






/***************************************************************************************************
    Predict size of buffer needed for decoding

        Estimate of the amount of heap memory needed to decode an image. Interlaced images, images
        with a color format of less than 8 bits per pixel and the parsing of certain information
        such as text will allocate more heap memory.
***************************************************************************************************/
uint bufferSize( /+const+/ ref PngImage image)
{
    return ((image.width * image.bpp + 7) / 8) * image.height + image.height;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                //
//                          PRIVATE SECTION                                                       //
//                                                                                                //
////////////////////////////////////////////////////////////////////////////////////////////////////

private:

const uint HEADER_SIZE = 34;

struct StreamChunkIter
{
	int opApply(int delegate(ref Chunk chunk) visitor)
	{
		int result = 0;
		uint pos = 0;
		Chunk chunk;
		while(pos + 12 <= stream.length)
		{
			chunk = Chunk.fromStream(stream[pos..$]);
			if (chunk.type == IEND)
				break;
			result = visitor(chunk);
			if (result)
				return result;
			pos += chunk.length;
		}
		return result;
	}
	ubyte[] stream;
}

//filter a PNG image scanline by scanline. when the pixels are smaller than 1 byte, the filter works
//byte per byte (bytewidth = 1)precon is the previous filtered scanline, recon the result, scanline
//the current one
void unFilterFirstScanline(ubyte[] result, ubyte[] scanline, uint bytewidth, uint filterType)
in
{
    assert(filterType >= 0 && filterType <= 4);
}
body
{
    mixin(pngEnforce(`filterType >= 0 && filterType <= 4`, "wrong filter byte: image corrupt?"));
    switch(filterType)
	{
		case 0:
			for(uint i = 0; i < scanline.length; i++)
                result[i] = scanline[i];
			break;
		case 1:
            for(uint i = 0; i < bytewidth; i++)
                result[i] = scanline[i];
            for(uint i = bytewidth; i < scanline.length; i++)
                result[i] = scanline[i] + result[i - bytewidth];
        break;
		case 2:
			for(size_t i = 0; i < scanline.length; i++)
                result[i] = scanline[i];
			break;
		case 3:
            for(size_t i = 0; i < bytewidth; i++)
                result[i] = scanline[i];
			for(size_t i = bytewidth; i < scanline.length; i++)
                result[i] = (scanline[i] + result[i - bytewidth]) / 2;
			break;
		case 4:
            for(size_t i = 0; i < bytewidth; i++)
                result[i] = scanline[i];
            for(size_t i = bytewidth; i < scanline.length; i++)
                result[i] = cast(ubyte)(scanline[i] + paethPredictor(result[i - bytewidth], 0, 0));
            break;
		default:
            mixin(pngEnforce("false", "wrong type of filter"));
            break;

	}
}

//filter a PNG image scanline by scanline. when the pixels are smaller than 1 byte, the filter works
//byte per byte (bytewidth = 1) precon is the previous filtered scanline, recon the result,
//scanline the current one
void unFilterScanline(ubyte[] result, ubyte[] scanline, ubyte[] previous, uint bytewidth,
                     uint filterType)
in
{
    assert(filterType >= 0 && filterType <= 4);
}
body
{
	switch(filterType)
	{
		case 4:
			for(size_t i = 0; i < bytewidth; i++)
                result[i] = cast(ubyte)(scanline[i] + previous[i] );
			for(size_t i = bytewidth; i < scanline.length; i++)
                result[i] = cast(ubyte)(scanline[i] +
                            paethPredictor(result[i - bytewidth],
                                           previous[i],
                                           previous[i - bytewidth]));
            break;
		case 3:
			for(size_t i = 0; i < bytewidth; i++)
                result[i] = scanline[i] + previous[i] / 2;
			for(size_t i = bytewidth; i < scanline.length; i++)
                result[i] = scanline[i] + ((result[i - bytewidth] + previous[i]) / 2);
			break;
		case 2:
            for(size_t i = 0; i < scanline.length; i++)
                result[i] = scanline[i] + previous[i];
			break;
		case 1:
            for(size_t i = 0; i < bytewidth; i++)
                result[i] = scanline[i];
            for(size_t i = bytewidth; i < scanline.length; i++)
                result[i] = scanline[i] + result[i - bytewidth];
        break;
        case 0:
            for(uint i = 0; i < scanline.length; i++) result[i] = scanline[i];
            break;
		default:
            mixin(pngEnforce("false", "wrong type of filter"));
            break;
	}
}

ubyte[] deinterlace(in ubyte[] scanlines, ref ubyte[] result, ref PngImage image)
{
    const x = 0;
    const y = 1;
    uint bytewidth = (image.bpp + 7) / 8; // bytewidth is used for filtering
    ubyte[] source;
    ubyte[] scanlineo = new ubyte[image.width * bytewidth]; //"old" scanline
    ubyte[] scanlinen = new ubyte[image.width * bytewidth]; //"new" scanline

    uint[7][2] passDim;
    passDim[x][0] = (image.width + 7) / 8; passDim[y][0] = (image.height + 7) / 8;
    passDim[x][1] = (image.width + 3) / 8; passDim[y][1] = (image.height + 7) / 8;
    passDim[x][2] = (image.width + 3) / 4; passDim[y][2] = (image.height + 3) / 8;
    passDim[x][3] = (image.width + 1) / 4; passDim[y][3] = (image.height + 3) / 4;
    passDim[x][4] = (image.width + 1) / 2; passDim[y][4] = (image.height + 1) / 4;
    passDim[x][5] = (image.width + 0) / 2; passDim[y][5] = (image.height + 1) / 2;
    passDim[x][6] = (image.width + 0) / 1; passDim[y][6] = (image.height + 0) / 2;

    // locate start in source of each pass, note:
    // (HACK) pass can be empty, sets both x and y axis to zero to recognize this in processPass

    size_t[7] passstart;
    passstart[0] = 0;
    for(int i = 0; i < 6; i++)
    {
        if (passDim[y][i] * passDim[x][i] == 0)
            passDim[y][i] = passDim[x][i] = 0;

        passstart[i + 1] = passstart[i] + (passDim[y][i] * (1 + (passDim[x][i] * image.bpp + 7) / 8));
    }

    void adam7Pass( size_t passleft, size_t passtop, size_t spacex, size_t spacey,
                    size_t passw, size_t passh)
    {
        size_t linelength = 1 + ((image.bpp * passw + 7) / 8);
        size_t linestart = 0;
        uint filterType = source[0];

        void placePixels(uint s)
        {
            if(image.bpp >= 8)
                for(size_t i = 0; i < passw; i++)
                    for(size_t b = 0; b < bytewidth; b++) //b = current byte of this pixel
                        result[bytewidth * image.width * (passtop + spacey * s) + bytewidth *
                               (passleft + spacex * i) + b] = scanlinen[bytewidth * i + b];
            else
            {
                for(size_t i = 0; i < passw; i++)
                {
                    size_t outbitp = image.bpp * image.width * (passtop + spacey * s) +
                                     image.bpp * (passleft + spacex * i);
                    for(size_t b = 0; b < image.bpp; b++) //b = current bit of this pixel
                    {
                        size_t obp = outbitp + b;
                        //where bitpos 0 refers to the LSB, bitpot 7 to the MSB of a byte
                        size_t obitpos = 7 - (obp & 0x7);
                        size_t bp = i * image.bpp + b;
                        //where bitpos 0 refers to the LSB, bitpot 7 to the MSB of a byte
                        size_t bitpos = 7 - (bp & 0x7);
                        uint _bit = (scanlinen[bp / 8] >> bitpos) & 1;
                        result[obp / 8] = cast(ubyte)((result[obp / 8] & ~(1 << obitpos)) |
                                            (_bit << obitpos));
                    }
                }
            }
        }

        void swapScanlines()
        {
            ubyte[] temp = scanlinen;
            scanlinen = scanlineo;
            scanlineo = temp;
        }

        unFilterFirstScanline(scanlinen, source[linestart + 1 .. linestart + linelength],
                                      bytewidth, filterType);
        placePixels(0);
        swapScanlines();

        for(uint s = 1; s < passh; s++)
        {
            linestart = s * linelength;
            filterType = source[linestart];

            unFilterScanline(scanlinen, source[linestart + 1 .. linestart + linelength],
                             scanlineo, bytewidth, filterType);
            placePixels(s);
            swapScanlines();
        }
    }

    void processPass(size_t pass, size_t left, size_t top, size_t sx, size_t sy)
    {
        // check if pass is empty
        if (pass > 0 && (passDim[x][pass] * passDim[y][pass] == 0))
            return;
        source = scanlines[passstart[pass]..$];
        adam7Pass( left, top, sx, sy, passDim[x][pass], passDim[y][pass]);
    }


    processPass(0, 0, 0, 8, 8);
    processPass(1, 4, 0, 8, 8);
    processPass(2, 0, 4, 4, 8);
    processPass(3, 2, 0, 4, 4);
    processPass(4, 0, 2, 2, 4);
    processPass(5, 1, 0, 2, 2);
    processPass(6, 0, 1, 1, 2);

    return result;
}

ubyte[] reconstruct(ref ubyte[] buffer, /+const+/ ref PngImage image)
in
{
    assert(buffer.length >= image.width * (image.bpp / 8) * image.height);
}
body
{
    //filter and interlace
	uint bytewidth = (image.bpp + 7) / 8; // bytewidth is used for filtering
	uint outlength = image.height * image.width * bytewidth;


    size_t linestart = 0; //start of current scanline

    // bits are tightly packed, but scanlines are always padded to 1 byte bounderies:
    uint scanlength = ((image.width * image.bpp) + 7) / 8;
    
    mixin(pngEnforce( `buffer.length >= (scanlength + 1) * image.height && buffer.length > 0`, "invalid size of source data: "));

    uint filterType = buffer[linestart];


    if(image.bpp >= 8) //byte per byte
    {
        filterType = buffer[linestart];
        unFilterFirstScanline(buffer, buffer[1..1 + scanlength], bytewidth, filterType);

        //go to start of next scanline
        linestart += 1 + scanlength;

        for(size_t s = 1; s < image.height; ++s)
        {
            filterType = buffer[linestart];
            unFilterScanline(buffer[linestart - s..$],
                    buffer[linestart + 1 .. linestart + 1 + scanlength],
                    buffer[(s - 1) * image.width * bytewidth..$],
                    bytewidth, filterType);


            //go to start of next scanline
            linestart += 1 + scanlength;
        }
    }
    else //less than 8 bits per pixel, so fill it up bit per bit
    {
        size_t obp = 0; //out bit pointer

        ubyte[] templine = new ubyte[scanlength];
        filterType = buffer[linestart];
        unFilterFirstScanline(templine, buffer[1 .. 1 + scanlength], bytewidth, filterType);

        linestart += 1 + scanlength;

        //bp is here bit pointer in templine
        for(size_t bp = 0; bp < image.width * image.bpp; bp++)
        {
            size_t obitpos = 7 - (obp & 0x7);
            size_t bitpos = 7 - (bp & 0x7);
            uint _bit = (templine[bp / 8] >> bitpos) & 1;
            buffer[obp / 8] = cast(ubyte)((buffer[obp / 8] & ~(1 << obitpos)) |
                                            (_bit << obitpos)); //set current bit
            obp++;
        }

        for(size_t s = 1; s < image.height; ++s)
        {
            filterType = buffer[linestart];
            unFilterScanline(   templine,
                                buffer[linestart + 1 .. linestart + 1 + scanlength],
                                buffer[(s - 1) * scanlength..$],
                                bytewidth,
                                filterType);

            //bp is here bit pointer in templine
            for(size_t bp = 0; bp < image.width * image.bpp; bp++)
            {
                size_t obitpos = 7 - (obp & 0x7);
                size_t bitpos = 7 - (bp & 0x7);
                uint _bit = (templine[bp / 8] >> bitpos) & 1;
                buffer[obp / 8] = cast(ubyte)((buffer[obp / 8] & ~(1 << obitpos)) |
                                                (_bit << obitpos)); //set current bit
                obp++;
            }

            //go to start of next scanline
            linestart += 1 + ((image.width * image.bpp + 7) / 8);
        }
    }
	return buffer;
}

