module raydebugger.OrthoView;

import raydebugger.Util;
import pango.PgLayout;
import gdk.Color;
import gdk.GC;
import gdk.Pixmap;
import gdk.Threads;
import gdk.Window;
import gtk.DrawingArea;
import gtk.Widget;
import raydebugger.EasyPixbuf;
import raydebugger.RayDebugger;
import tango.util.log.Config;


class OrthoView
{
    string title;
    
    RayDebugger rayDebugger;
    
    DrawingArea drawingArea;
    Pixmap view;
    Pixmap background;
    
    int width, height;
    
    int progressLine;
    int axis1, axis2;
    int dir1, dir2;
    
    
    public this(DrawingArea drawingArea, RayDebugger rayDebugger, string title, 
            int width, int height, int axis1, int axis2, int dir1, int dir2)
    {
        this.drawingArea = drawingArea;
        this.rayDebugger = rayDebugger;
        this.title = title;
        this.width = width;
        this.height = height;
        this.axis1 = axis1;
        this.axis2 = axis2;
        this.dir1 = dir1;
        this.dir2 = dir2;
        
        view = new Pixmap(drawingArea.getWindow(), width, height, -1);
        background = new Pixmap(drawingArea.getWindow(), width, height, -1);
        
        scope GC gc = new GC(background);
        
        gc.setRgbFgColor(Color.white);
        background.drawRectangle(gc, true, 0, 0, width, height);
        
        gc.setRgbFgColor(new Color(cast(ubyte) 240, cast(ubyte) 240, cast(ubyte) 240));
        rayDebugger.drawGrid(background, gc);

        redraw();

        unref(gc);
    }
    
    public bool expose(GdkEventExpose *event, Widget widget)
    {
        Window wnd = widget.getWindow();
        scope GC gc = new GC(wnd);
        
        wnd.drawDrawable(gc, view,
                event.area.x, event.area.y,
                event.area.x, event.area.y,
                event.area.width, event.area.height);
        
        unref(gc);
        
        return false;
    }
    
    void redraw()
    {
        scope GC gc = new GC(view);
        
        //gc.setRgbFgColor(Color.white);
        //view.drawRectangle(gc, true, 0, 0, width, height);
        
        view.drawDrawable(gc, background, 0, 0, 0, 0, -1, -1);
        
        //gc.setRgbFgColor(new Color(cast(ubyte) 240, cast(ubyte) 240, cast(ubyte) 240));
        //rayDebugger.drawGrid(view, gc, axis1, axis2);
        
        gc.setRgbFgColor(Color.black);
        rayDebugger.drawObjects(view, gc, axis1, axis2, dir1, dir2);
        
        gc.setRgbFgColor(new Color(cast(ubyte) 140, cast(ubyte) 140, cast(ubyte) 180));
        scope PgLayout layout = drawingArea.createPangoLayout(title);
        view.drawLayout(gc, 10, 5, layout);
        
        if (progressLine >= 0 && progressLine < height)
        {
            gc.setRgbFgColor(Color.black);
            view.drawLine(gc, 0, progressLine, width, progressLine);
        }
        
        unref(layout);
        unref(gc);
    }

    // This is called from a different thread.
    void renderWithRaytracer()
    {
        gdkThreadsEnter();
        scope EasyPixbuf pixbuf = new EasyPixbuf(background, 0, 0, width, height);
        
        for (int y = 0; y < height; y++)
        {
            gdkThreadsLeave();
            
            rayDebugger.renderOrtho(pixbuf, y, axis1, axis2, dir1, dir2);
            
            gdkThreadsEnter();
            // Draw the newly-rendered line of the pixbuf.
            background.drawPixbuf(null, pixbuf, 0, y, 0, y, width, 1,
                    GdkRgbDither.NONE, 0, 0);
            progressLine = y + 1;
            redraw();
            drawingArea.queueDrawArea(0, y, width, 2);
        }
        
        unref(pixbuf);
        gdkThreadsLeave();
    }
}
