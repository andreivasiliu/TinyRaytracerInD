module raydebugger.Util;

import gdk.Pixbuf;
import gobject.ObjectG;


void unref(ObjectG object)
{
    ObjectG.unref(object.getObjectGStruct());
}

void unref(Pixbuf pixbuf)
{
    ObjectG.unref(pixbuf.getPixbufStruct());
}

