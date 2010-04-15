module raydebugger.Util;

import gdk.Bitmap;
import gdk.Pixmap;
import gobject.ObjectG;


void unref(ObjectG object)
{
    ObjectG.unref(object.getObjectGStruct());
}

Bitmap castPixmapToBitmap(Pixmap pixmap)
{
    return new Bitmap(cast(GdkBitmap*) pixmap.getObjectGStruct());
}

