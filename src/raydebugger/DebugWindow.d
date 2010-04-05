module raydebugger.DebugWindow;

import pango.PgLayout;
import raydebugger.RayDebugger;
import raytracer.Colors;
import raytracer.RayTracer;
import sceneparser.SceneLoader;
import tango.io.device.File;
import tango.stdc.stdio;
import tango.core.Thread;
import gdk.Color;
import gdk.GC;
import gdk.Pixmap;
import gdk.Threads;
import gdk.Window;
import gtk.Table;
import gtk.VBox;
import gtk.Widget;
import gtk.MainWindow;
import gtk.CheckButton;
import gtk.DrawingArea;
import gtk.Main;
import glib.Str;
static import gthread.Thread;

RayTracer rayTracer;
RayDebugger rayDebugger;

private Pixmap scenePixmap;
private Pixmap topView;
private Pixmap frontView;
private Pixmap leftView;

private DrawingArea topLeftSection;
private DrawingArea topRightSection;
private DrawingArea bottomLeftSection;
private DrawingArea bottomRightSection;

public const width = 480;
public const height = 360;

const axisX = 0;
const axisY = 1;
const axisZ = 2;

bool showNormals = false;
bool buttonDown = false;

void initializeRayDebugger()
{
    rayTracer = new RayTracer(width, height);
    const frame = 43;
    
    scope SceneLoader sceneLoader = new SceneLoader();
    sceneLoader.setRaytracer(rayTracer);
    sceneLoader.setFrame(frame);
    scope File sceneScript = new File("cod.cad");
    sceneLoader.execute(sceneScript);
    
    rayDebugger = new RayDebugger();
    rayDebugger.getObjectsFrom(rayTracer);
}

void renderFrame()
{
    vprintf("Thread started.\n", null);
    
    auto renderer = &rayTracer.getPixel;
    
    scope GC gc = new GC(scenePixmap);
    scope Colors[width] linePixels;
    
    for (uint y = 0; y < height; y++)
    {
        for (uint x = 0; x < width; x++)
            linePixels[x] = renderer(x, y);
        
        gdkThreadsEnter();
        scope Color color = new Color();
        
        for (uint x = 0; x < width; x++)
        {
            color.set8(cast(ubyte)(linePixels[x].R * 255),
                       cast(ubyte)(linePixels[x].G * 255),
                       cast(ubyte)(linePixels[x].B * 255));
            
            gc.setRgbFgColor(color);
            scenePixmap.drawPoint(gc, x, y);
        }
        
        topLeftSection.queueDrawArea(0, y, width, 1);
        gdkThreadsLeave();
    }
    return;
}

void main(string[] args)
{
    Main.initMultiThread(args);
    gdkThreadsEnter();
    
    MainWindow win = new MainWindow("Drawing test");
    
    VBox vbox1 = new VBox(false, 0);
    win.add(vbox1);
    
    CheckButton showNormalsButton = new CheckButton("Show normals", 
            (CheckButton button) { showNormals = cast(bool) button.getActive(); },
            false);
    vbox1.packStart(showNormalsButton, false, true, 0);
    
    Table table = new Table(2, 2, false);
    vbox1.packStartDefaults(table);
    
    table.setRowSpacings(1);
    table.setColSpacings(1);
    
    topLeftSection = new DrawingArea(width, height);
    topRightSection = new DrawingArea(width, height);
    bottomLeftSection = new DrawingArea(width, height);
    bottomRightSection = new DrawingArea(width, height);
    
    initializeRayDebugger();
    
    //Thread thrd = Thread.create(&renderFrame, null, false);
    
    bool drwOnExpose(GdkEventExpose *event, Widget widget)
    {
        Window wnd = widget.getWindow();
        scope GC gc = new GC(wnd);
        Pixmap pixmap = null;
        
        if (widget is topLeftSection)
            pixmap = scenePixmap;
        else if (widget is topRightSection)
            pixmap = topView;
        else if (widget is bottomLeftSection)
            pixmap = leftView;
        else if (widget is bottomRightSection)
            pixmap = frontView;
        
        wnd.drawDrawable(gc, pixmap,
                event.area.x, event.area.y,
                event.area.x, event.area.y,
                event.area.width, event.area.height);
        
//        wnd.drawLine(gc, width, 0, width, height * 2 + 1);
//        wnd.drawLine(gc, 0, height, width * 2 + 1, height);
        
        return false;
    }

    void drawOnView(Pixmap view, Widget widget, string title, 
            int axis1, int axis2, int dir1, int dir2)
    {
        scope GC gc = new GC(view);
        
        gc.setRgbFgColor(Color.white);
        view.drawRectangle(gc, true, 0, 0, width, height);
        
        gc.setRgbFgColor(new Color(cast(ubyte) 240, cast(ubyte) 240, cast(ubyte) 240));
        rayDebugger.drawGrid(view, gc, axis1, axis2);
        
        gc.setRgbFgColor(new Color(cast(ubyte) 140, cast(ubyte) 140, cast(ubyte) 180));
        PgLayout layout = widget.createPangoLayout(title);
        view.drawLayout(gc, 10, 5, layout);
        
        gc.setRgbFgColor(Color.black);
        rayDebugger.drawObjects(view, gc, axis1, axis2, dir1, dir2);
    }
    
    bool drwOnConfigure(GdkEventConfigure *event, Widget widget)
    {
        if (scenePixmap)
            return true;
        
        scenePixmap = new Pixmap(widget.getWindow(), width, height, -1);
        topView = new Pixmap(widget.getWindow(), width, height, -1);
        frontView = new Pixmap(widget.getWindow(), width, height, -1);
        leftView = new Pixmap(widget.getWindow(), width, height, -1);
        
        scope GC gc = new GC(scenePixmap);
        gc.setRgbFgColor(Color.white);
        scenePixmap.drawRectangle(gc, true, 0, 0, width, height);
        
        drawOnView(topView, widget, "Top View", axisX, axisZ, 1, -1);
        drawOnView(frontView, widget, "Front View", axisX, axisY, 1, -1);
        drawOnView(leftView, widget, "Side View", axisZ, axisY, -1, -1);
        
        Thread thrd = new Thread(&renderFrame);
        thrd.start();
        
        return false;
    }
    
    void drawRays(Widget widget, int x, int y)
    {
        static bool renderingSingleRay = false;
        
        if (renderingSingleRay)
            return;
        
        renderingSingleRay = true;
        rayDebugger.recordRays(rayTracer, x, y);
        
        drawOnView(topView, widget, "Top View", axisX, axisZ, 1, -1);
        drawOnView(frontView, widget, "Front View", axisX, axisY, 1, -1);
        drawOnView(leftView, widget, "Side View", axisZ, axisY, -1, -1);
        
        topRightSection.queueDraw();
        bottomLeftSection.queueDraw();
        bottomRightSection.queueDraw();
        renderingSingleRay = false;
    }
    
    bool drwOnButtonPress(GdkEventButton *event, Widget widget)
    {
        buttonDown = true;
        drawRays(widget, cast(int) event.x, cast(int) event.y);
        
        return false;
    }

    bool drwOnButtonRelease(GdkEventButton *event, Widget widget)
    {
        buttonDown = false;
        
        return false;
    }
    
    bool drwOnMotionNotify(GdkEventMotion *event, Widget widget)
    {
        if (buttonDown)
            drawRays(widget, cast(int) event.x, cast(int) event.y);
        
        return false;
    }

    table.attach(topLeftSection);
    table.attach(topRightSection);
    table.attach(bottomLeftSection);
    table.attach(bottomRightSection);
    
    topLeftSection.addOnConfigure(&drwOnConfigure);
    topLeftSection.addOnExpose(&drwOnExpose);
    topLeftSection.addOnButtonPress(&drwOnButtonPress);
    topLeftSection.addOnButtonRelease(&drwOnButtonRelease);
    topLeftSection.addOnMotionNotify(&drwOnMotionNotify);
    
    topRightSection.addOnExpose(&drwOnExpose);
    bottomLeftSection.addOnExpose(&drwOnExpose);
    bottomRightSection.addOnExpose(&drwOnExpose);
    
    win.showAll();

    Main.run();
    
    gdkThreadsLeave();
}

