/*******************************************************************************

        copyright:      Copyright (c) 2004 Kris Bell. All rights reserved

        license:        BSD style: $(LICENSE)

        version:        Initial release: December 2005

        author:         Kris

*******************************************************************************/

module goldengine.unicodebom;

version(Tango) {
    public import tango.text.convert.UnicodeBom;
} else {

private import Utf = std.utf;
private import std.intrinsic;

/*******************************************************************************

        see http://icu.sourceforge.net/docs/papers/forms_of_unicode/#t2

*******************************************************************************/

enum Encoding {
              Unknown,
              UTF_8,
              UTF_8N,
              UTF_16,
              UTF_16BE,
              UTF_16LE,
              UTF_32,
              UTF_32BE,
              UTF_32LE,
              };

struct ByteSwap
{
        /***********************************************************************

        ***********************************************************************/

        final static void swap16 (void *dst, uint bytes)
        {
                ubyte* p = cast(ubyte*) dst;
                while (bytes)
                      {
                      ubyte b = p[0];
                      p[0] = p[1];
                      p[1] = b;

                      p += short.sizeof;
                      bytes -= short.sizeof;
                      }
        }

        /***********************************************************************

        ***********************************************************************/

        final static void swap32 (void *dst, uint bytes)
        {
                uint* p = cast(uint*) dst;
                while (bytes)
                      {
                      *p = bswap(*p);
                      p ++;
                      bytes -= int.sizeof;
                      }
        }
}


class UnicodeBom(T)
{
        static if (!is (T == char) && !is (T == wchar) && !is (T == dchar))
                    pragma (msg, "Template type must be char, wchar, or dchar");


        private Encoding encoding;      // the current encoding
        private Info*    settings;      // pointer to encoding configuration

        private struct  Info
                {
                int      type;          // type of element (char/wchar/dchar)
                Encoding encoding;      // Encoding.xx encoding
                char[]   bom;           // pattern to match for signature
                bool     test,          // should we test for this encoding?
                         endian,        // this encoding have endian concerns?
                         bigEndian;     // is this a big-endian encoding?
                Encoding fallback;      // can this encoding be defaulted?
                };

        enum {Utf8, Utf16, Utf32};

        private const Info[] lookup =
        [
        {Utf8,  Encoding.Unknown,  null,        true,  false, false, Encoding.UTF_8N},
        {Utf8,  Encoding.UTF_8,    null,        true,  false, false, Encoding.UTF_8N},
        {Utf8,  Encoding.UTF_8N,   x"efbbbf",   false},
        {Utf16, Encoding.UTF_16,   null,        true,  false, false, Encoding.UTF_16BE},
        {Utf16, Encoding.UTF_16BE, x"feff",     false, true, true},
        {Utf16, Encoding.UTF_16LE, x"fffe",     false, true},
        {Utf32, Encoding.UTF_32,   null,        true,  false, false, Encoding.UTF_32BE},
        {Utf32, Encoding.UTF_32BE, x"0000feff", false, true, true},
        {Utf32, Encoding.UTF_32LE, x"fffe0000", false, true},
        ];


        /***********************************************************************

                Construct a instance using the given external encoding ~ one
                of the Encoding.xx types

        ***********************************************************************/

        this (Encoding encoding)
        {
                setup (encoding);
        }

        /***********************************************************************

                Return the current encoding. This is either the originally
                specified encoding, or a derived one obtained by inspecting
                the content for a BOM. The latter is performed as part of
                the decode() method

        ***********************************************************************/

        final Encoding getEncoding ()
        {
                return encoding;
        }

        /***********************************************************************

                Return the signature (BOM) of the current encoding

        ***********************************************************************/

        final void[] getSignature ()
        {
                return settings.bom;
        }

        /***********************************************************************

                Convert the provided content. The content is inspected
                for a BOM signature, which is stripped. An exception is
                thrown if a signature is present when, according to the
                encoding type, it should not be. Conversely, An exception
                is thrown if there is no known signature where the current
                encoding expects one to be present

        ***********************************************************************/

        final T[] decode (void[] content)
        {
                // look for a BOM
                auto info = test (content);

                // are we expecting a BOM?
                if (lookup[encoding].test)
                    if (info)
                       {
                       // yep ~ and we got one
                       setup (info.encoding);

                       // strip BOM from content
                       content = content [info.bom.length .. length];
                       }
                    else
                       // can this encoding be defaulted?
                       if (settings.fallback)
                           setup (settings.fallback);
                       else
                          throw new Exception ("UnicodeBom.decode :: unknown or missing BOM");
                else
                   if (info)
                       // found a BOM when using an explicit encoding
                       throw new Exception ("UnicodeBom.decode :: explicit encoding does not permit BOM");

                // convert it to internal representation
                return into (swapBytes(content), settings.type);
        }

        /***********************************************************************

                Scan the BOM signatures looking for a match. We scan in
                reverse order to get the longest match first

        ***********************************************************************/

        private final Info* test (void[] content)
        {
                for (Info* info=lookup.ptr+lookup.length; --info >= lookup.ptr;)
                     if (info.bom)
                        {
                        int len = info.bom.length;
                        if (len <= content.length)
                            if (content[0..len] == info.bom[0..len])
                                return info;
                        }
                return null;
        }

        /***********************************************************************

                Swap bytes around, as required by the encoding

        ***********************************************************************/

        private final void[] swapBytes (void[] content)
        {
                bool endian = settings.endian;
                bool swap   = settings.bigEndian;

                version (BigEndian)
                         swap = !swap;

                if (endian && swap)
                   {
                   if (settings.type == Utf16)
                       ByteSwap.swap16 (content.ptr, content.length);
                   else
                       ByteSwap.swap32 (content.ptr, content.length);
                   }
                return content;
        }

        /***********************************************************************

                Configure this instance with unicode converters

        ***********************************************************************/

        public final void setup (Encoding encoding)
        {
                this.settings = &lookup[encoding];
                this.encoding = encoding;
        }

        /***********************************************************************


        ***********************************************************************/

        static T[] into (void[] x, uint type)
        {
                T[] ret;

                static if (is (T == char))
                          {
                          if (type == Utf8)
                              return cast(T[]) x;

                          if (type == Utf16)
			      ret = Utf.toUTF8 (cast(wchar[]) x);
                          else
                          if (type == Utf32)
                              ret = Utf.toUTF8 (cast(dchar[]) x);
                          }

                static if (is (T == wchar))
                          {
                          if (type == Utf16)
                              return cast(T[]) x;

                          if (type == Utf8)
                              ret = Utf.toUTF16 (cast(char[]) x);
                          else
                          if (type == Utf32)
                              ret = Utf.toUTF16 (cast(dchar[]) x);
                          }

                static if (is (T == dchar))
                          {
                          if (type == Utf32)
                              return cast(T[]) x;

                          if (type == Utf8)
                              ret = Utf.toUTF32 (cast(char[]) x);
                          else
                          if (type == Utf16)
                              ret = Utf.toUTF32 (cast(wchar[]) x);
                          }

                return ret;
        }
}

} //version(Tango)
