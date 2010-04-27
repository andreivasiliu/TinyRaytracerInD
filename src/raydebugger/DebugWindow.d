module raydebugger.DebugWindow;

import gtk.MessageDialog;
import TangoThreadPool = tango.core.ThreadPool;
import tango.core.tools.StackTrace;
import tango.text.Util;
import tango.util.log.Config;
import tango.io.device.File;
import tango.core.Thread;
import pango.PgLayout;
import raydebugger.RayDebugger;
import raydebugger.Util;
import raydebugger.EasyPixbuf;
import raydebugger.OrthoView;
import raytracer.AntiAliaser;
import raytracer.Colors;
import raytracer.RayTracer;
import sceneparser.SceneLoader;
import gdk.Bitmap;
import gdk.Color;
import gdk.Event;
import gdk.GC;
import gdk.Pixbuf;
import gdk.Pixmap;
import gdk.Threads;
import gdk.Window;
import glib.ThreadPool;
import gtk.Range;
import gtk.Table;
import gtk.VBox;
import gtk.Widget;
import gtk.MainWindow;
import gtk.Button;
import gtk.CheckButton;
import gtk.Dialog;
import gtk.DrawingArea;
import gtk.HBox;
import gtk.HScale;
import gtk.Main;

version(Win32)
    import tango.core.tools.Cpuid: coresPerCPU;
else
{
    uint coresPerCPU()
    {
        return 4;
    }
}

int threads;

static this()
{
    threads = coresPerCPU();
}

RayTracer rayTracer;
RayDebugger rayDebugger;

OrthoView topView;
OrthoView frontView;
OrthoView sideView;

private Pixmap scenePixmap;
private Pixmap antiAliasedPixels;

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
bool showAntiAliasEdges = false;
bool buttonDown = false;

Thread raytracerThread;
bool shutdownRenderer = false;

private double antiAliasThreshold = 0.1;
private int progressLine = -1;


void initializeRayDebugger()
{
    rayTracer = new RayTracer(width, height);
    const frame = 43;
    
    scope SceneLoader sceneLoader = new SceneLoader();
    sceneLoader.setRaytracer(rayTracer);
    sceneLoader.setFrame(frame);
    scope File sceneScript = new File("scene.cad");
    sceneLoader.execute(sceneScript);
    
    rayDebugger = new RayDebugger(rayTracer);
}


void threadedRun(void delegate() dg)
{
    Thread[] t = new Thread[](threads);

    for (int i = 0; i < threads; i++)
        t[i] = new Thread(dg);

    for (int i = 0; i < threads; i++)
        t[i].start();

    for (int i = 0; i < threads; i++)
        t[i].join();
}

void renderFrame()
{
    Log("Rendering scene...");
    
    auto renderer = &rayTracer.getPixel;
    scope Object mutex = new Object();
    
    gdkThreadsEnter();
    EasyPixbuf scenePixbuf = new EasyPixbuf(scenePixmap, 0, 0, width, height);
    scope GC gc = new GC(scenePixmap);
    gdkThreadsLeave();
    
    int line = -1;

    int getLineNumber()
    {
        synchronized(mutex)
        {
            line++;

            if (line >= height)
                return -1;
            else
                return line;
        }
    }
    
    void renderLines()
    {
        int y;

        while ((y = getLineNumber()) >= 0)
        {
            for (int x = 0; x < width; x++)
                scenePixbuf.setPixelColor(x, y, renderer(x, y));
            
            gdkThreadsEnter();
            if (shutdownRenderer)
            {
                gdkThreadsLeave();
                return;
            }
            scenePixmap.drawPixbuf(gc, scenePixbuf, 0, y, 0, y, width, 1,
                    GdkRgbDither.NONE, 0, 0);
            topLeftSection.queueDrawArea(0, y, width, 1);
            gdkThreadsLeave();
        }
    }

    threadedRun(&renderLines);
    
    gdkThreadsEnter();
    gc.unref();
    scenePixbuf.unref();
    gdkThreadsLeave();
    
    Log("Rendering finished.");
}


void checkAntiAliasThreshold()
{
    EasyPixbuf scenePixbuf = new EasyPixbuf(scenePixmap, 0, 0, width, height);
    EasyPixbuf edgePixelsPixbuf = new EasyPixbuf(width, height, 1);
    
    edgePixelsPixbuf.fill(0);
    
    if (showAntiAliasEdges)
    {
        void marker(int x, int y) 
        {
            edgePixelsPixbuf.setPixelAlpha(x, y, 255);
        }
        
        AntiAliaser.markEdgePixels(antiAliasThreshold, scenePixbuf, &marker);
    }
    
    edgePixelsPixbuf.renderThresholdAlpha(castPixmapToBitmap(antiAliasedPixels),
            0, 0, 0, 0, -1, -1, 127);
    //antiAliasedPixels.drawPixbuf(null, edgePixelsPixbuf, 0, 0, 0, 0, -1, -1,
    //        GdkRgbDither.NONE, 0, 0);
    //edgePixelsBitbuf.drawOntoDrawable(antiAliasedPixels);
    
    topLeftSection.queueDraw();
    
    unref(scenePixbuf);
    unref(edgePixelsPixbuf);
}


void raytraceOrthoViews()
{
    scope auto threadPool = new TangoThreadPool.ThreadPool!()(threads);
    
    threadPool.assign(&topView.renderWithRaytracer);
    threadPool.assign(&frontView.renderWithRaytracer);
    threadPool.assign(&sideView.renderWithRaytracer);
    
    threadPool.finish();
}


void applyAntiAliasing()
{
    gdkThreadsEnter();
    EasyPixbuf scenePixbuf = new EasyPixbuf(scenePixmap, 0, 0, width, height);
    EasyPixbuf antiAliasedDestination = new EasyPixbuf(width, height);
    scope GC gc = new GC(scenePixmap);
    gdkThreadsLeave();
    
    Object mutex = new Object();
    int line = -1;

    int getLineNumber()
    {
        synchronized(mutex)
        {
            line++;

            if (line >= height - 1)
                return -1;
            else
                return line;
        }
    }
    
    int rayCounter;
    
    void antiAliasLines()
    {
        AntiAliaser antiAliaser = new AntiAliaser(rayTracer, scenePixbuf,
                antiAliasedDestination, antiAliasThreshold);
        int y;

        while ((y = getLineNumber()) >= 0)
        {
            try
            {
                antiAliaser.antiAliasLine(y);
            }
            catch(Exception e)
            {
                Log("Caught exception: {}", e.msg);
                return;
            }
            
            gdkThreadsEnter();
            // TODO: check shutdown
            
            int oldProgressLine = progressLine;
            progressLine = y + 1;
            
            scenePixmap.drawPixbuf(gc, antiAliasedDestination, 0, y, 0, y, width, 1,
                    GdkRgbDither.NONE, 0, 0);
            topLeftSection.queueDrawArea(0, oldProgressLine, width, 1);
            topLeftSection.queueDrawArea(0, y, width, 2);
            gdkThreadsLeave();
        }
        
        synchronized (mutex)
        {
            rayCounter += antiAliaser.rayCounter;
        }
        
        delete antiAliaser;
    }
    

    threadedRun(&antiAliasLines);
    
    gdkThreadsEnter();
    int oldProgressLine = progressLine;
    progressLine = -1;
    topLeftSection.queueDrawArea(0, oldProgressLine, width, 1);
    
    Log("Additional rays traced for anti-aliasing: {}.", rayCounter);
    scenePixbuf.unref();
    antiAliasedDestination.unref();
    gc.unref();
    gdkThreadsLeave();
}



int main(string[] args)
{
    Main.initMultiThread(args);
    gdkThreadsEnter();
    
    try
    {
        initializeRayDebugger();
    }
    catch(Exception e)
    {
        string errMsg = "Exception: " ~ e.msg;
        MessageDialog dialog = new MessageDialog(null, 
                GtkDialogFlags.DESTROY_WITH_PARENT, GtkMessageType.ERROR, 
                GtkButtonsType.OK, errMsg, null);
        
        dialog.setTitle("RayDebugger Error");
        dialog.setResizable(true);
        dialog.run();
        
        gdkThreadsLeave();
        return 1;
    }
    
    MainWindow win = new MainWindow("Ray Debugger");
    
    VBox vbox1 = new VBox(false, 0);
    win.add(vbox1);
    
    HBox hbox1 = new HBox(false, 0);
    vbox1.packStart(hbox1, false, false, 0);
    
    HScale thresholdScale = new HScale(0, 1, 0.01);
    thresholdScale.setDigits(2);
    thresholdScale.setDrawValue(true);
    thresholdScale.setValue(0.1);
    thresholdScale.setValuePos(GtkPositionType.LEFT);
    thresholdScale.addOnValueChanged((Range range) {
        antiAliasThreshold = range.getValue();
        checkAntiAliasThreshold();
    });
    hbox1.packEnd(thresholdScale, true, true, 10);
    
    CheckButton showNormalsButton = new CheckButton("Show normals", 
            (CheckButton button) { showNormals = cast(bool) button.getActive(); },
            false);
    hbox1.packStart(showNormalsButton, false, true, 0);
    
    CheckButton showAntiAliasEdgesButton = new CheckButton("Show edges", 
            (CheckButton button) { 
        showAntiAliasEdges = cast(bool) button.getActive();
        if (showAntiAliasEdges)
            thresholdScale.show();
        else
            thresholdScale.hide();
        checkAntiAliasThreshold();
    }, false);
    hbox1.packStart(showAntiAliasEdgesButton, false, true, 0);
    
    CheckButton antiAliasButton = new CheckButton("Enable anti-aliasing",
            (CheckButton button) {
        button.setSensitive(false);
        Thread thrd = new Thread(&applyAntiAliasing);
        thrd.start();
    });
    hbox1.packStart(antiAliasButton, false, false, 0);
    
    CheckButton raytraceOrthoViewsButton = new CheckButton(
            "Raytrace orthogonal views", (CheckButton button) {
        if (button.getActive())
        {
            button.setSensitive(false);
            Thread thrd = new Thread(&raytraceOrthoViews);
            thrd.start();
        }
    }, false);
    hbox1.packStart(raytraceOrthoViewsButton, false, true, 0);
    
    
    // ------ The four views ------
    
    Table table = new Table(2, 2, false);
    vbox1.packStartDefaults(table);
    
    table.setRowSpacings(1);
    table.setColSpacings(1);
    
    topLeftSection = new DrawingArea(width, height);
    topRightSection = new DrawingArea(width, height);
    bottomLeftSection = new DrawingArea(width, height);
    bottomRightSection = new DrawingArea(width, height);
    
    table.attach(topLeftSection);
    table.attach(topRightSection);
    table.attach(bottomLeftSection);
    table.attach(bottomRightSection);
    
    bool onExpose(GdkEventExpose *event, Widget widget)
    {
        Window wnd = widget.getWindow();
        scope GC gc = new GC(wnd);
        
        wnd.drawDrawable(gc, scenePixmap,
                event.area.x, event.area.y,
                event.area.x, event.area.y,
                event.area.width, event.area.height);
        
        if (showAntiAliasEdges)
        {
            scope Color cyan = new Color();
            cyan.set8(0, 255, 255);
            
            gc.setFill(GdkFill.STIPPLED);
            gc.setStipple(antiAliasedPixels);
            
            gc.setRgbFgColor(cyan);
            wnd.drawRectangle(gc, true, 0, 0, width, height);
        }
        
        if (progressLine >= 0 && progressLine < height)
        {
            gc.setRgbFgColor(Color.black);
            wnd.drawLine(gc, 0, progressLine, width, progressLine);
        }
        
        unref(gc);
        
        return false;
    }
    
    bool onConfigure(GdkEventConfigure *event, Widget widget)
    {
        if (scenePixmap)
            return true;
        
        Log("Configuring...");
        
        scenePixmap = new Pixmap(widget.getWindow(), width, height, -1);
        antiAliasedPixels = new Pixmap(null, width, height, 1);
        
        scope GC gc = new GC(scenePixmap);
        gc.setRgbFgColor(Color.white);
        scenePixmap.drawRectangle(gc, true, 0, 0, width, height);
        unref(gc);
        
        topView = new OrthoView(topRightSection, rayDebugger, "Top View",
                width, height, axisX, axisZ, 1, -1);
        frontView = new OrthoView(bottomRightSection, rayDebugger, "Front View",
                width, height, axisX, axisY, 1, -1);
        sideView = new OrthoView(bottomLeftSection, rayDebugger, "Side View",
                width, height, axisZ, axisY, -1, -1);
        
        topRightSection.addOnExpose(&topView.expose);
        bottomRightSection.addOnExpose(&frontView.expose);
        bottomLeftSection.addOnExpose(&sideView.expose);
        
        Log("Done.");
        
        raytracerThread = new Thread(&renderFrame);
        raytracerThread.start();
        
        Log("Rendering thread started.");
        
        return false;
    }
    
    void drawRays(Widget widget, int x, int y)
    {
        rayDebugger.recordRays(x, y);
        
        topView.redraw();
        frontView.redraw();
        sideView.redraw();
        
        topRightSection.queueDraw();
        bottomLeftSection.queueDraw();
        bottomRightSection.queueDraw();
    }
    
    bool onButtonPress(GdkEventButton *event, Widget widget)
    {
        buttonDown = true;
        drawRays(widget, cast(int) event.x, cast(int) event.y);
        
        return false;
    }

    bool onButtonRelease(GdkEventButton *event, Widget widget)
    {
        buttonDown = false;
        
        return false;
    }
    
    bool onMotionNotify(GdkEventMotion *event, Widget widget)
    {
        if (buttonDown)
            drawRays(widget, cast(int) event.x, cast(int) event.y);
        
        return false;
    }

    topLeftSection.addOnConfigure(&onConfigure);
    topLeftSection.addOnExpose(&onExpose);
    topLeftSection.addOnButtonPress(&onButtonPress);
    topLeftSection.addOnButtonRelease(&onButtonRelease);
    topLeftSection.addOnMotionNotify(&onMotionNotify);
    
    topLeftSection.addOnUnrealize((Widget widget) {
        Log("Unrealizing...");
        shutdownRenderer = true;
        if (raytracerThread)
        {
            gdkThreadsLeave();
            raytracerThread.join();
            Log("Thread joined.");
            gdkThreadsEnter();
        }
    });
    
    win.showAll();
    thresholdScale.hide();

    Main.run();
    
    gdkThreadsLeave();
    
    return 0;
}

