#!/bin/bash

set -e

DSSS_PATH='C:\Programs\Dsss-0.78'

GDKD_EXCLUDE='+xgtkc +xgtk +xglib +xgobject +xgdk +xatk +xgthread +xpango'
GDKD_EXCLUDE+=' +xgio +xgdkpixbuf +xcairo'

EXCLUDE="$GDKD_EXCLUDE +xtango +xstd"

LINUX_LDC_LIB_FLAGS=-L-lz
WIN32_LDC_LIB_FLAGS=-Lzlib1.dll

LDC_LIB_FLAGS=$LINUX_LDC_LIB_FLAGS

#xfbuild +cldc +C.o +Oobj +xtango \
#-Lzlib1.dll
#-O5 -release

build_with_dmd()
{
    rm -rf obj/*
    
    GDKD_LIBS='-L+DD-gtkc.lib'
    GDKD_LIBS+=' -L+DD-gtk.lib'
    GDKD_LIBS+=' -L+DD-glib.lib'
    GDKD_LIBS+=' -L+DD-gobject.lib'
    GDKD_LIBS+=' -L+DD-gdk.lib'
    GDKD_LIBS+=' -L+DD-atk.lib'
    GDKD_LIBS+=' -L+DD-gthread.lib'
    GDKD_LIBS+=' -L+DD-pango.lib'
    GDKD_LIBS+=' -L+DD-gio.lib'
    GDKD_LIBS+=' -L+DD-gdkpixbuf.lib'
    GDKD_LIBS+=' -L+DD-cairo.lib'
    
    xfbuild +Oobj/obj-rd +Dobj/.deps-rd $EXCLUDE \
    -I../src -I../extsrc -J../src \
    "../src/raydebugger/DebugWindow.d" +oRayDebugger \
    -I"${DSSS_PATH}/include/d" -L+"${DSSS_PATH}\\lib\\" "${GDKD_LIBS}" \
    -g
    
    xfbuild +Oobj/obj-rt +Dobj/.deps-rt $EXCLUDE +xraydebugger \
    -I../src -I../extsrc -J../src \
    "../src/Main.d" +oRayTracer \
    -g
    
    rm RayTracer.map
    rm RayDebugger.map
}

build_with_ldc()
{
    mkdir -p obj
    rm -rf obj/*
    
    xfbuild +Oobj/obj-ldc-rt +Dobj/.deps-ldc-rt $EXCLUDE +xraydebugger \
    +cldc +C.o \
    -I../src -I../extsrc -J../src \
    "../src/Main.d" +oRayTracer \
    -O5 $LDC_LIB_FLAGS
}

build_with_ldc
