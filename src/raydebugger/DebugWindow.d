module raydebugger.DebugWindow;

import pango.PgLayout;
import raydebugger.RayDebugger;
import raydebugger.Util;
import raydebugger.AntiAliaser;
import raydebugger.EasyPixbuf;
import raydebugger.OrthoView;
import raytracer.Colors;
import raytracer.RayTracer;
import sceneparser.SceneLoader;
import tango.util.log.Config;
import tango.io.device.File;
import tango.core.Thread;
import gdk.Bitmap;
import gdk.Color;
import gdk.Event;
import gdk.GC;
import gdk.Pixbuf;
import gdk.Pixmap;
import gdk.Threads;
import gdk.Window;
import gtk.Range;
import gtk.Table;
import gtk.VBox;
import gtk.Widget;
import gtk.MainWindow;
import gtk.CheckButton;
import gtk.DrawingArea;
import gtk.HBox;
import gtk.HScale;
import gtk.Main;

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

void renderFrame()
{
	Log("Rendering scene...");
	
    auto renderer = &rayTracer.getPixel;
    
    gdkThreadsEnter();
    scope GC gc = new GC(scenePixmap);
    scope Colors[width] linePixels;
    gdkThreadsLeave();
    
    for (uint y = 0; y < height; y++)
    {
        for (uint x = 0; x < width; x++)
            linePixels[x] = renderer(x, y);
        
        gdkThreadsEnter();
    	if (shutdownRenderer)
    	{
    		Log("Renderer received shutdown request...");
    		gdkThreadsLeave();
    		break;
    	}
    	
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
    
    gdkThreadsEnter();
    unref(gc);
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
    topView.renderWithRaytracer();
    frontView.renderWithRaytracer();
    sideView.renderWithRaytracer();
}


void main(string[] args)
{
    initializeRayDebugger();
    
    Main.initMultiThread(args);
    gdkThreadsEnter();
    
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
	        gc.setFill(GdkFill.STIPPLED);
	        gc.setStipple(antiAliasedPixels);
	        
	        scope Color cyan = new Color();
	        cyan.set8(0, 255, 255);
	        
	        gc.setRgbFgColor(cyan);
	        wnd.drawRectangle(gc, true, 0, 0, width, height);
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
}

