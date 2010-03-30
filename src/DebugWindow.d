module DebugWindow;

import gdk.GC;
import gdk.Pixmap;
import gdk.Window;
import gtk.Widget;
import gtk.MainWindow;
import gtk.DrawingArea;
import gtk.Main;

void main(string[] args)
{
    Main.init(args);
    MainWindow win = new MainWindow("Drawing test");
    DrawingArea drwArea = new DrawingArea(640, 480);
    Pixmap pixmap = new Pixmap(null, 640, 480, 32);
    bool drwOnExpose(GdkEventExpose *event, Widget widget)
    {
        Window wnd = widget.getWindow();
        scope GC gc = new GC(wnd);
        
        wnd.drawDrawable(gc, pixmap,
                event.area.x, event.area.y,
                event.area.x, event.area.y,
                event.area.width, event.area.height);
        
        return false;
    }

    win.add(drwArea);
    drwArea.addOnExpose(&drwOnExpose);
    
    scope GC gc = new GC(drwArea.getWindow());
    for (int i = 0; i < 400; i++)
        pixmap.drawPoint(gc, i*2, i);
    
    win.showAll();

    Main.run();
}
