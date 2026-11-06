python3 - <<'PY'
import re, sys
def patch(path, pairs):
    s = open(path, encoding='utf-8').read()
    for old, new in pairs:
        if s.count(old) != 1:
            sys.exit('ERRO: trecho nao encontrado (ou repetido) em %s: %s' % (path, old))
        s = s.replace(old, new)
    open(path, 'w', encoding='utf-8').write(s)
A = 'app/src/main/assets/'
patch(A + 'index.html', [
  ('const M=mul(Dm,mul(tr(Rf),Cm));', 'const M=mul(Dm,mul(tr(Rf),Cm));window.__M=M;')
])
patch(A + 'hand.js', [
  ('var g = grab, WS = UI.WS;', 'var g = grab, WS = g.t.ws || UI.WS;'),
  ('R0: UI.WS.R }', 'R0: (pt.ws || UI.WS).R }')
])
PY
sed -i "s/versionCode 10/versionCode 11/; s/versionName '2.0'/versionName '3.0'/" app/build.gradle
cat > app/src/main/java/com/vr/launcher/AppWin.java <<'EOF'
package com.vr.launcher;
import android.graphics.SurfaceTexture;
import android.hardware.display.VirtualDisplay;
import android.view.Surface;
import java.util.concurrent.atomic.AtomicBoolean;
public class AppWin {
  public final int id, idx;
  public volatile int w, h, dpi;
  public String pkg, comp;
  public volatile int dispId = -1;
  public VirtualDisplay vd;
  public volatile Surface surf;
  public boolean paused = false;
  public long hiddenSince = 0L;
  // parametros vindos do JS (graus / px de cena)
  public volatile float az = 0f, el = 0f, r = 900f, ww = 860f, hh = 272f, kappa = 1f / 900f;
  public volatile boolean placed = false;
  public volatile float focus = 0f;
  public volatile boolean inView = true;
  // so a thread do renderizador mexe aqui
  SurfaceTexture st;
  int texId = 0;
  final float[] stm = new float[16];
  final AtomicBoolean newFrame = new AtomicBoolean(false);
  boolean hasFrame = false;
  public AppWin(int id, int idx, int w, int h, int dpi) {
    this.id = id; this.idx = idx; this.w = w; this.h = h; this.dpi = dpi;
  }
}
EOF
cat > app/src/main/java/com/vr/launcher/WinRenderer.java <<'EOF'
package com.vr.launcher;
import android.graphics.SurfaceTexture;
import android.opengl.EGL14;
import android.opengl.EGLConfig;
import android.opengl.EGLContext;
import android.opengl.EGLDisplay;
import android.opengl.EGLSurface;
import android.opengl.GLES11Ext;
import android.opengl.GLES20;
import android.os.Handler;
import android.os.Looper;
import android.view.Surface;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.util.List;
import java.util.concurrent.ConcurrentLinkedQueue;

/** Desenha cada janela de app como uma faixa de cilindro (curva) com cantos arredondados. */
public class WinRenderer extends Thread {
  public interface Host { void onSurfaceReady(AppWin w); void onError(String m); }
  public static class ViewState { public volatile float[] M; }

  static final String VS =
    "attribute vec2 aUv;\n" +
    "uniform mat4 uMV; uniform mat4 uProj;\n" +
    "uniform vec4 uWin; uniform vec2 uCurve;\n" +
    "varying vec2 vUv;\n" +
    "void main(){\n" +
    "  float az=uWin.x, r=uWin.y, w=uWin.z, h=uWin.w;\n" +
    "  float k=uCurve.x, yc=uCurve.y;\n" +
    "  float s=(aUv.x-0.5)*w;\n" +
    "  vec3 f=vec3(sin(az),0.0,-cos(az));\n" +
    "  vec3 rt=vec3(cos(az),0.0,sin(az));\n" +
    "  vec3 pos;\n" +
    "  if(abs(k)<1e-6){ pos=r*f+s*rt; }\n" +
    "  else { float ph=s*k; pos=r*f+(sin(ph)/k)*rt+((cos(ph)-1.0)/k)*f; }\n" +
    "  pos.y=yc+(aUv.y-0.5)*h;\n" +
    "  gl_Position=uProj*uMV*vec4(pos,1.0);\n" +
    "  vUv=aUv;\n" +
    "}\n";
  static final String FS =
    "#extension GL_OES_EGL_image_external : require\n" +
    "#ifdef GL_FRAGMENT_PRECISION_HIGH\nprecision highp float;\n#else\nprecision mediump float;\n#endif\n" +
    "varying vec2 vUv;\n" +
    "uniform samplerExternalOES uTex; uniform mat4 uSt;\n" +
    "uniform vec2 uSize; uniform float uRad; uniform float uFocus;\n" +
    "void main(){\n" +
    "  vec2 p=(vUv-0.5)*uSize;\n" +
    "  vec2 q=abs(p)-(uSize*0.5-vec2(uRad));\n" +
    "  float d=length(max(q,0.0))+min(max(q.x,q.y),0.0)-uRad;\n" +
    "  float mask=1.0-smoothstep(-1.5,0.0,d);\n" +
    "  if(mask<=0.0) discard;\n" +
    "  vec2 tc=(uSt*vec4(vUv.x,1.0-vUv.y,0.0,1.0)).xy;\n" +
    "  vec3 c=texture2D(uTex,tc).rgb;\n" +
    "  float edge=smoothstep(-3.5,-1.0,d);\n" +
    "  vec3 bc=mix(vec3(1.0),vec3(0.37,0.92,0.83),uFocus);\n" +
    "  c=mix(c,bc,edge*(0.22+0.5*uFocus));\n" +
    "  gl_FragColor=vec4(c*mask,mask);\n" +
    "}\n";

  static final int COLS = 64;

  final List<AppWin> wins;
  final SurfaceTexture target;
  final Host host;
  final ViewState vs;
  final Handler main = new Handler(Looper.getMainLooper());
  final Object lock = new Object();
  final ConcurrentLinkedQueue<Runnable> tasks = new ConcurrentLinkedQueue<>();
  volatile boolean running = true, dirty = true;
  EGLDisplay dpy = EGL14.EGL_NO_DISPLAY; EGLContext ctx = EGL14.EGL_NO_CONTEXT; EGLSurface srf = EGL14.EGL_NO_SURFACE;
  int prog, aUv, uMV, uProj, uWin, uCurve, uTex, uSt, uSize, uRad, uFocus;
  FloatBuffer mesh;
  final float[] mv = new float[16], proj = new float[16];
  final int[] tmp = new int[1];

  public WinRenderer(SurfaceTexture target, List<AppWin> wins, ViewState vs, Host host) {
    super("winrender");
    this.target = target; this.wins = wins; this.vs = vs; this.host = host;
  }
  public void requestRender() { synchronized (lock) { dirty = true; lock.notifyAll(); } }
  public void post(Runnable r) { tasks.add(r); requestRender(); }
  public void quit() { running = false; requestRender(); }

  @Override public void run() {
    try {
      initEgl(); initGl();
    } catch (Throwable t) {
      final String m = "GL: " + t;
      main.post(new Runnable() { public void run() { host.onError(m); } });
      return;
    }
    while (running) {
      Runnable t;
      while ((t = tasks.poll()) != null) { try { t.run(); } catch (Throwable e) { } }
      ensureTextures();
      draw();
      synchronized (lock) {
        if (!dirty && running) { try { lock.wait(); } catch (InterruptedException e) { } }
        dirty = false;
      }
    }
    teardown();
  }

  void initEgl() {
    dpy = EGL14.eglGetDisplay(EGL14.EGL_DEFAULT_DISPLAY);
    int[] v = new int[2];
    if (!EGL14.eglInitialize(dpy, v, 0, v, 1)) throw new RuntimeException("eglInitialize");
    int[] ca = { EGL14.EGL_RENDERABLE_TYPE, EGL14.EGL_OPENGL_ES2_BIT, EGL14.EGL_RED_SIZE, 8, EGL14.EGL_GREEN_SIZE, 8,
      EGL14.EGL_BLUE_SIZE, 8, EGL14.EGL_ALPHA_SIZE, 8, EGL14.EGL_NONE };
    EGLConfig[] cfg = new EGLConfig[1]; int[] n = new int[1];
    if (!EGL14.eglChooseConfig(dpy, ca, 0, cfg, 0, 1, n, 0) || n[0] < 1) throw new RuntimeException("eglChooseConfig");
    int[] xa = { EGL14.EGL_CONTEXT_CLIENT_VERSION, 2, EGL14.EGL_NONE };
    ctx = EGL14.eglCreateContext(dpy, cfg[0], EGL14.EGL_NO_CONTEXT, xa, 0);
    int[] sa = { EGL14.EGL_NONE };
    srf = EGL14.eglCreateWindowSurface(dpy, cfg[0], target, sa, 0);
    if (srf == null || srf == EGL14.EGL_NO_SURFACE) throw new RuntimeException("eglCreateWindowSurface");
    if (!EGL14.eglMakeCurrent(dpy, srf, srf, ctx)) throw new RuntimeException("eglMakeCurrent");
    EGL14.eglSwapInterval(dpy, 1);
  }

  static int shader(int type, String src) {
    int s = GLES20.glCreateShader(type);
    GLES20.glShaderSource(s, src);
    GLES20.glCompileShader(s);
    int[] ok = new int[1];
    GLES20.glGetShaderiv(s, GLES20.GL_COMPILE_STATUS, ok, 0);
    if (ok[0] == 0) { String log = GLES20.glGetShaderInfoLog(s); GLES20.glDeleteShader(s); throw new RuntimeException("shader: " + log); }
    return s;
  }

  void initGl() {
    int vsh = shader(GLES20.GL_VERTEX_SHADER, VS), fsh = shader(GLES20.GL_FRAGMENT_SHADER, FS);
    prog = GLES20.glCreateProgram();
    GLES20.glAttachShader(prog, vsh); GLES20.glAttachShader(prog, fsh);
    GLES20.glLinkProgram(prog);
    int[] ok = new int[1];
    GLES20.glGetProgramiv(prog, GLES20.GL_LINK_STATUS, ok, 0);
    if (ok[0] == 0) throw new RuntimeException("link: " + GLES20.glGetProgramInfoLog(prog));
    aUv = GLES20.glGetAttribLocation(prog, "aUv");
    uMV = GLES20.glGetUniformLocation(prog, "uMV");
    uProj = GLES20.glGetUniformLocation(prog, "uProj");
    uWin = GLES20.glGetUniformLocation(prog, "uWin");
    uCurve = GLES20.glGetUniformLocation(prog, "uCurve");
    uTex = GLES20.glGetUniformLocation(prog, "uTex");
    uSt = GLES20.glGetUniformLocation(prog, "uSt");
    uSize = GLES20.glGetUniformLocation(prog, "uSize");
    uRad = GLES20.glGetUniformLocation(prog, "uRad");
    uFocus = GLES20.glGetUniformLocation(prog, "uFocus");
    float[] m = new float[(COLS + 1) * 4];
    for (int i = 0; i <= COLS; i++) {
      float u = (float) i / COLS;
      m[i * 4] = u; m[i * 4 + 1] = 0f; m[i * 4 + 2] = u; m[i * 4 + 3] = 1f;
    }
    mesh = ByteBuffer.allocateDirect(m.length * 4).order(ByteOrder.nativeOrder()).asFloatBuffer();
    mesh.put(m); mesh.position(0);
    GLES20.glDisable(GLES20.GL_DEPTH_TEST);
    GLES20.glDisable(GLES20.GL_CULL_FACE);
    GLES20.glEnable(GLES20.GL_BLEND);
    GLES20.glBlendFunc(GLES20.GL_ONE, GLES20.GL_ONE_MINUS_SRC_ALPHA);
  }

  void ensureTextures() {
    for (final AppWin w : wins) {
      if (w.st != null) continue;
      int[] t = new int[1];
      GLES20.glGenTextures(1, t, 0);
      w.texId = t[0];
      GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, w.texId);
      GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR);
      GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR);
      GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE);
      GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE);
      w.st = new SurfaceTexture(w.texId);
      w.st.setDefaultBufferSize(w.w, w.h);
      w.hasFrame = false;
      w.newFrame.set(false);
      w.st.setOnFrameAvailableListener(new SurfaceTexture.OnFrameAvailableListener() {
        @Override public void onFrameAvailable(SurfaceTexture s) { w.newFrame.set(true); requestRender(); }
      }, main);
      w.surf = new Surface(w.st);
      main.post(new Runnable() { public void run() { host.onSurfaceReady(w); } });
    }
  }

  /** Libera os recursos GL de uma janela (chamar via post). */
  public void releaseWin(AppWin w) {
    if (w.surf != null) { w.surf.release(); w.surf = null; }
    if (w.st != null) { w.st.setOnFrameAvailableListener(null); w.st.release(); w.st = null; }
    if (w.texId != 0) { tmp[0] = w.texId; GLES20.glDeleteTextures(1, tmp, 0); w.texId = 0; }
  }

  void projection(int W, int H) {
    float sx = 1.2f, sy = 1.2f * W / (float) H, n = 10f, f = 6000f;
    for (int i = 0; i < 16; i++) proj[i] = 0f;
    proj[0] = sx; proj[5] = sy;
    proj[10] = -(f + n) / (f - n); proj[11] = -1f; proj[14] = -2f * f * n / (f - n);
  }

  static float yc(AppWin w) { return (float) (-w.r * Math.tan(Math.toRadians(w.el))); }

  boolean sees(AppWin w, float sx, float sy) {
    float az = (float) Math.toRadians(w.az), r = w.r, k = w.kappa, ww = w.ww, hh = w.hh, y0 = yc(w);
    for (int i = -2; i <= 2; i++) {
      float s = ww * i / 4f;
      float px, pz;
      if (k < 1e-6f) { px = r * (float) Math.sin(az) + s * (float) Math.cos(az); pz = -r * (float) Math.cos(az) + s * (float) Math.sin(az); }
      else {
        float ph = s * k, a = (float) Math.sin(ph) / k, b = ((float) Math.cos(ph) - 1f) / k;
        px = (r + b) * (float) Math.sin(az) + a * (float) Math.cos(az);
        pz = -(r + b) * (float) Math.cos(az) + a * (float) Math.sin(az);
      }
      for (int j = -1; j <= 1; j++) {
        float py = y0 + j * hh / 2f;
        float qx = mv[0] * px + mv[4] * py + mv[8] * pz;
        float qy = mv[1] * px + mv[5] * py + mv[9] * pz;
        float qz = mv[2] * px + mv[6] * py + mv[10] * pz;
        if (qz < -1f) {
          float nx = sx * qx / -qz, ny = sy * qy / -qz;
          if (Math.abs(nx) < 1.15f && Math.abs(ny) < 1.15f) return true;
        }
      }
    }
    return false;
  }

  void draw() {
    EGL14.eglQuerySurface(dpy, srf, EGL14.EGL_WIDTH, tmp, 0); int W = tmp[0];
    EGL14.eglQuerySurface(dpy, srf, EGL14.EGL_HEIGHT, tmp, 0); int H = tmp[0];
    if (W < 2 || H < 2) return;
    for (AppWin w : wins) {
      if (w.st != null && w.newFrame.getAndSet(false)) {
        try { w.st.updateTexImage(); w.st.getTransformMatrix(w.stm); w.hasFrame = true; } catch (Throwable t) { }
      }
    }
    GLES20.glViewport(0, 0, W, H);
    GLES20.glClearColor(0f, 0f, 0f, 0f);
    GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT);
    float[] M = vs.M;
    if (M != null) {
      // q' = diag(1,-1,1) * A * p, A_ij = M[3i+j]  (matriz coluna-major)
      for (int i = 0; i < 16; i++) mv[i] = 0f;
      mv[0] = M[0]; mv[1] = -M[3]; mv[2] = M[6];
      mv[4] = M[1]; mv[5] = -M[4]; mv[6] = M[7];
      mv[8] = M[2]; mv[9] = -M[5]; mv[10] = M[8];
      mv[15] = 1f;
      projection(W, H);
      GLES20.glUseProgram(prog);
      GLES20.glUniformMatrix4fv(uProj, 1, false, proj, 0);
      GLES20.glUniformMatrix4fv(uMV, 1, false, mv, 0);
      GLES20.glUniform1i(uTex, 0);
      GLES20.glActiveTexture(GLES20.GL_TEXTURE0);
      GLES20.glEnableVertexAttribArray(aUv);
      mesh.position(0);
      GLES20.glVertexAttribPointer(aUv, 2, GLES20.GL_FLOAT, false, 0, mesh);
      for (AppWin w : wins) {
        if (w.st == null || !w.placed) continue;
        boolean vis = sees(w, proj[0], proj[5]);
        w.inView = vis;
        if (!vis || !w.hasFrame) continue;
        GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, w.texId);
        GLES20.glUniformMatrix4fv(uSt, 1, false, w.stm, 0);
        GLES20.glUniform4f(uWin, (float) Math.toRadians(w.az), w.r, w.ww, w.hh);
        GLES20.glUniform2f(uCurve, w.kappa, yc(w));
        GLES20.glUniform2f(uSize, w.ww, w.hh);
        GLES20.glUniform1f(uRad, 28f);
        GLES20.glUniform1f(uFocus, w.focus);
        GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, (COLS + 1) * 2);
      }
      GLES20.glDisableVertexAttribArray(aUv);
    }
    EGL14.eglSwapBuffers(dpy, srf);
  }

  void teardown() {
    try {
      for (AppWin w : wins) { try { releaseWin(w); } catch (Throwable t) { } }
      if (prog != 0) GLES20.glDeleteProgram(prog);
    } catch (Throwable t) { }
    try {
      EGL14.eglMakeCurrent(dpy, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_CONTEXT);
      if (srf != EGL14.EGL_NO_SURFACE) EGL14.eglDestroySurface(dpy, srf);
      if (ctx != EGL14.EGL_NO_CONTEXT) EGL14.eglDestroyContext(dpy, ctx);
      EGL14.eglTerminate(dpy);
    } catch (Throwable t) { }
  }
}
EOF
cat > app/src/main/java/com/vr/launcher/MainActivity.java <<'EOF'
package com.vr.launcher;
import android.Manifest;
import android.app.Activity;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.content.pm.PackageManager;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.SurfaceTexture;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.hardware.display.DisplayManager;
import android.hardware.display.VirtualDisplay;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.IBinder;
import android.os.Looper;
import android.view.TextureView;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.webkit.JavascriptInterface;
import android.webkit.PermissionRequest;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.FrameLayout;
import android.widget.Toast;
import java.io.InputStream;
import java.util.concurrent.CopyOnWriteArrayList;
import org.json.JSONObject;
import rikka.shizuku.Shizuku;
public class MainActivity extends Activity implements SensorEventListener, WinRenderer.Host {
  static final String HOST = "appassets.androidplatform.net";
  static final String HOOK = "window.__r=function(a,x,y,z){Rdev=a;if(!haveSensor){haveSensor=true;haveGyro=true;mode='gyro';setTimeout(recenter,200)}if(st.textContent!=='Sensor nativo OK')st.textContent='Sensor nativo OK';if(window.__a)window.__a(x,y,z)};";
  static final int MAX_WINS = 3;
  // {largura, altura, dpi} em pixels do buffer. 19:6 = 1140x360. Mesmo layout (dp) que 1520x480@220 com 44% menos pixels.
  static final int[] WIDE = {1140, 360, 165};
  static final int[] TALL = {540, 960, 220};
  static final int[][] SIZE = {WIDE, TALL, WIDE, WIDE, TALL, WIDE, WIDE, TALL};
  static final String[] APPN = {"YouTube", "WhatsApp", "Chrome", "Camera", "Galeria", "Musica", "Mapas", "Config."};
  static final String[][] CAND = {
    {"com.google.android.youtube"},
    {"com.whatsapp", "com.whatsapp.w4b"},
    {"com.android.chrome", "org.mozilla.firefox", "com.brave.browser"},
    {"com.motorola.camera3", "com.motorola.camera", "com.android.camera2"},
    {"com.google.android.apps.photos", "com.motorola.gallery"},
    {"com.google.android.apps.youtube.music", "com.spotify.music"},
    {"com.google.android.apps.maps"},
    {"com.android.settings"}
  };
  static class CursorView extends View {
    Paint p = new Paint(Paint.ANTI_ALIAS_FLAG);
    volatile float x, y; volatile boolean show, pinch;
    CursorView(Context c) { super(c); p.setStrokeWidth(5f); }
    @Override protected void onDraw(Canvas c) {
      if (!show) return;
      p.setColor(pinch ? 0xFF5EEAD4 : 0xFFFFFFFF);
      p.setStyle(Paint.Style.STROKE);
      c.drawCircle(x, y, pinch ? 16f : 26f, p);
      p.setStyle(Paint.Style.FILL);
      c.drawCircle(x, y, 6f, p);
    }
  }
  class Bridge {
    @JavascriptInterface public void openApp(final int i) { ui.post(new Runnable() { public void run() { openIdx(i); } }); }
    @JavascriptInterface public void closeWin(final int id) { ui.post(new Runnable() { public void run() { AppWin w = byId(id); if (w != null) closeWindow(w); } }); }
    @JavascriptInterface public void resizeWin(final int id) { ui.post(new Runnable() { public void run() { AppWin w = byId(id); if (w != null) toggleRatio(w); } }); }
    @JavascriptInterface public void frame(String rf, String ws, float cx, float cy, boolean pinch, boolean has) { onFrame(rf, ws, cx, cy, pinch, has); }
  }
  FrameLayout root; WebView web; CursorView curv; TextureView glv;
  SensorManager sm; Sensor rot, lin; boolean ready = false;
  PermissionRequest pending = null;
  float[] m = new float[9]; float[] grav = new float[3]; float lx = 0, ly = 0, lz = 0;
  float density = 1f;
  Handler ui = new Handler(Looper.getMainLooper());
  HandlerThread ht; Handler th;
  IShell shell; boolean binding = false;
  final CopyOnWriteArrayList<AppWin> wins = new CopyOnWriteArrayList<>();
  final WinRenderer.ViewState vs = new WinRenderer.ViewState();
  WinRenderer rend;
  int nextId = 1, pendingIdx = -1;
  // toque
  volatile AppWin touchWin; volatile boolean down = false, armed = false, prevPinch = false; volatile float lastX, lastY;
  Shizuku.OnRequestPermissionResultListener permL = new Shizuku.OnRequestPermissionResultListener() {
    @Override public void onRequestPermissionResult(int req, int res) {
      if (res == PackageManager.PERMISSION_GRANTED) ui.post(new Runnable() { public void run() {
        if (pendingIdx >= 0) { int i = pendingIdx; pendingIdx = -1; openIdx(i); }
      } });
    }
  };
  Runnable visTick = new Runnable() { public void run() {
    long now = System.currentTimeMillis();
    for (AppWin w : wins) {
      if (w.vd == null || w.surf == null) continue;
      if (w.inView) {
        w.hiddenSince = 0L;
        if (w.paused) { try { w.vd.setSurface(w.surf); } catch (Throwable t) { } w.paused = false; }
      } else {
        if (w.hiddenSince == 0L) w.hiddenSince = now;
        else if (!w.paused && now - w.hiddenSince > 700L) { try { w.vd.setSurface(null); } catch (Throwable t) { } w.paused = true; }
      }
    }
    ui.postDelayed(this, 250L);
  } };
  boolean hasCam() { return checkSelfPermission(Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED; }
  void say(final String s) {
    ui.post(new Runnable() { public void run() {
      Toast.makeText(MainActivity.this, s, Toast.LENGTH_LONG).show();
      if (ready) web.evaluateJavascript("window.__msg&&window.__msg(" + JSONObject.quote(s) + ")", null);
    } });
  }
  void js(final String code) {
    ui.post(new Runnable() { public void run() { if (ready) web.evaluateJavascript(code, null); } });
  }
  AppWin byId(int id) { for (AppWin w : wins) if (w.id == id) return w; return null; }
  @Override public void onError(String msg) { say(msg); }
  @Override protected void onCreate(Bundle b) {
    super.onCreate(b);
    getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
    density = getResources().getDisplayMetrics().density;
    ht = new HandlerThread("touch"); ht.start(); th = new Handler(ht.getLooper());
    root = new FrameLayout(this);
    web = new WebView(this);
    web.setBackgroundColor(Color.TRANSPARENT);
    WebSettings s = web.getSettings();
    s.setJavaScriptEnabled(true);
    s.setDomStorageEnabled(true);
    s.setMediaPlaybackRequiresUserGesture(false);
    web.addJavascriptInterface(new Bridge(), "Android");
    web.setWebChromeClient(new WebChromeClient() {
      @Override public void onPermissionRequest(final PermissionRequest r) {
        runOnUiThread(new Runnable() { public void run() {
          if (hasCam()) { r.grant(r.getResources()); }
          else { pending = r; requestPermissions(new String[]{Manifest.permission.CAMERA}, 1); }
        } });
      }
    });
    web.setWebViewClient(new WebViewClient() {
      @Override public WebResourceResponse shouldInterceptRequest(WebView v, WebResourceRequest r) {
        Uri u = r.getUrl();
        if (!HOST.equals(u.getHost())) return null;
        String p = u.getPath();
        if (p == null || p.equals("/")) p = "/index.html";
        try {
          InputStream in = getAssets().open(p.substring(1));
          String mime = "text/html"; String enc = "UTF-8";
          if (p.endsWith(".js") || p.endsWith(".mjs") || p.endsWith(".cjs")) mime = "application/javascript";
          else if (p.endsWith(".wasm")) { mime = "application/wasm"; enc = null; }
          else if (p.endsWith(".task")) { mime = "application/octet-stream"; enc = null; }
          return new WebResourceResponse(mime, enc, in);
        } catch (Exception e) { return null; }
      }
      @Override public void onPageFinished(WebView v, String u) {
        v.evaluateJavascript(HOOK, null);
        ready = true;
      }
    });
    glv = new TextureView(this);
    glv.setOpaque(false);
    glv.setSurfaceTextureListener(new TextureView.SurfaceTextureListener() {
      @Override public void onSurfaceTextureAvailable(SurfaceTexture st, int w, int h) {
        WinRenderer r = new WinRenderer(st, wins, vs, MainActivity.this);
        rend = r; r.start();
      }
      @Override public void onSurfaceTextureSizeChanged(SurfaceTexture st, int w, int h) { if (rend != null) rend.requestRender(); }
      @Override public boolean onSurfaceTextureDestroyed(SurfaceTexture st) {
        for (AppWin w : wins) { if (w.vd != null) { try { w.vd.setSurface(null); } catch (Throwable t) { } } }
        WinRenderer r = rend; rend = null;
        if (r != null) { r.quit(); try { r.join(1500); } catch (InterruptedException e) { } }
        return true;
      }
      @Override public void onSurfaceTextureUpdated(SurfaceTexture st) { }
    });
    curv = new CursorView(this);
    root.addView(web, new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
    root.addView(glv, new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
    root.addView(curv, new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
    setContentView(root);
    if (!hasCam()) requestPermissions(new String[]{Manifest.permission.CAMERA}, 1);
    web.loadUrl("https://" + HOST + "/index.html");
    try { Shizuku.addRequestPermissionResultListener(permL); } catch (Throwable t) { }
    sm = (SensorManager) getSystemService(SENSOR_SERVICE);
    rot = sm.getDefaultSensor(Sensor.TYPE_GAME_ROTATION_VECTOR);
    if (rot == null) rot = sm.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR);
    lin = sm.getDefaultSensor(Sensor.TYPE_LINEAR_ACCELERATION);
    if (lin == null) lin = sm.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
  }
  boolean shizukuReady() {
    try {
      if (!Shizuku.pingBinder()) { say("Shizuku não está ativo. Abra o app Shizuku e inicie o serviço."); return false; }
      if (Shizuku.checkSelfPermission() != PackageManager.PERMISSION_GRANTED) {
        if (Shizuku.shouldShowRequestPermissionRationale()) { say("Permissão negada. Libere o VR Launcher dentro do app Shizuku."); return false; }
        Shizuku.requestPermission(100);
        say("Autorize o VR Launcher no Shizuku.");
        return false;
      }
      return true;
    } catch (Throwable t) { say("Shizuku: " + t); return false; }
  }
  void bind() {
    if (binding) return;
    binding = true;
    ServiceConnection sc = new ServiceConnection() {
      @Override public void onServiceConnected(ComponentName n, IBinder b) {
        shell = IShell.Stub.asInterface(b); binding = false;
        try { String inf = shell.info(); if (!"ok".equals(inf)) say("Toque indisponível: " + inf); } catch (Throwable t) { }
        if (pendingIdx >= 0) { int i = pendingIdx; pendingIdx = -1; openIdx(i); }
      }
      @Override public void onServiceDisconnected(ComponentName n) { shell = null; binding = false; }
    };
    try {
      Shizuku.bindUserService(new Shizuku.UserServiceArgs(new ComponentName(getPackageName(), ShellService.class.getName()))
        .daemon(false).processNameSuffix("sh").debuggable(false).version(1), sc);
    } catch (Throwable t) { binding = false; say("Shizuku: " + t); }
  }
  void toFront(AppWin w) {
    wins.remove(w); wins.add(w);
    for (AppWin o : wins) o.focus = (o == w) ? 1f : 0f;
    if (rend != null) rend.requestRender();
  }
  void openIdx(int idx) {
    if (idx < 0 || idx >= CAND.length) return;
    for (AppWin o : wins) if (o.idx == idx) { toFront(o); say(APPN[idx] + " já está aberto"); return; }
    if (wins.size() >= MAX_WINS) { say("Máximo de " + MAX_WINS + " janelas. Feche uma primeiro."); return; }
    PackageManager pm = getPackageManager();
    Intent li = null; String pkg = null;
    for (String c : CAND[idx]) { li = pm.getLaunchIntentForPackage(c); if (li != null) { pkg = c; break; } }
    if (li == null || li.getComponent() == null) { say(APPN[idx] + " não está instalado"); return; }
    pendingIdx = idx;
    if (!shizukuReady()) return;
    if (shell == null) { say("Conectando ao Shizuku…"); bind(); return; }
    pendingIdx = -1;
    if (rend == null) { say("Renderizador iniciando, tente de novo"); return; }
    int[] sz = SIZE[idx];
    AppWin w = new AppWin(nextId++, idx, sz[0], sz[1], sz[2]);
    w.pkg = pkg; w.comp = li.getComponent().flattenToShortString();
    wins.add(w);
    toFront(w);
    js("window.__winAdd&&window.__winAdd(" + w.id + "," + idx + "," + w.w + "," + w.h + ")");
    rend.requestRender();
  }
  /** Chamado na UI quando o renderizador criou a Surface da janela (ou recriou depois de pausa). */
  @Override public void onSurfaceReady(AppWin w) {
    if (!wins.contains(w)) return;
    if (w.vd != null) { try { w.vd.setSurface(w.surf); } catch (Throwable t) { } w.paused = false; return; }
    makeDisplay(w);
  }
  void makeDisplay(final AppWin w) {
    DisplayManager dm = (DisplayManager) getSystemService(Context.DISPLAY_SERVICE);
    int[] fl = {1 | 8 | 64 | 256, 1 | 8, 1};
    String err = "";
    VirtualDisplay vd = null;
    for (int f : fl) {
      try {
        vd = dm.createVirtualDisplay("vrapp" + w.id, w.w, w.h, w.dpi, w.surf, f);
        if (vd != null && vd.getDisplay() != null) break;
      } catch (Throwable t) { err = String.valueOf(t); }
    }
    if (vd == null || vd.getDisplay() == null) { say("Tela virtual falhou: " + err); closeWindow(w); js("window.__winDel&&window.__winDel(" + w.id + ")"); return; }
    w.vd = vd;
    w.dispId = vd.getDisplay().getDisplayId();
    final String cmd = "am start --display " + w.dispId + " -n " + w.comp;
    final IShell s = shell;
    new Thread(new Runnable() { public void run() {
      try {
        String out = s.run(cmd);
        if (out.contains("Error") || out.contains("Exception") || out.contains("Warning")) say("am start: " + out.trim());
      } catch (Throwable t) { say("Falha ao abrir: " + t); }
    } }).start();
  }
  void closeWindow(final AppWin w) {
    wins.remove(w);
    if (touchWin == w) { touchWin = null; down = false; }
    if (w.vd != null) { try { w.vd.release(); } catch (Throwable t) { } w.vd = null; }
    final WinRenderer r = rend;
    if (r != null) r.post(new Runnable() { public void run() { r.releaseWin(w); } });
    if (wins.isEmpty()) { curv.show = false; curv.postInvalidate(); }
    boolean shared = false;
    for (AppWin o : wins) if (w.pkg != null && w.pkg.equals(o.pkg)) shared = true;
    final IShell s = shell; final String p = w.pkg;
    if (s != null && p != null && !shared) new Thread(new Runnable() { public void run() {
      try { s.run("am force-stop " + p); } catch (Throwable t) { }
    } }).start();
    if (!wins.isEmpty()) toFront(wins.get(wins.size() - 1));
  }
  /** Alterna 19:6 <-> retrato na janela (experimental: depende do app reagir ao resize). */
  void toggleRatio(AppWin w) {
    int[] n = (w.w >= w.h) ? TALL : WIDE;
    w.w = n[0]; w.h = n[1]; w.dpi = n[2];
    if (w.st != null) w.st.setDefaultBufferSize(w.w, w.h);
    if (w.vd != null) {
      try { w.vd.resize(w.w, w.h, w.dpi); w.vd.setSurface(w.surf); } catch (Throwable t) { say("Resize: " + t); }
    }
    js("window.__winSize&&window.__winSize(" + w.id + "," + w.w + "," + w.h + ")");
  }
  // ---- ponte JS -> nativo, uma chamada por quadro ----
  void onFrame(String rf, String ws, float x, float y, boolean pinch, boolean has) {
    if (rf != null && rf.length() > 10) {
      String[] p = rf.split(",");
      if (p.length >= 9) {
        float[] M = new float[9];
        try { for (int i = 0; i < 9; i++) M[i] = Float.parseFloat(p[i]); vs.M = M; } catch (Throwable t) { }
      }
    }
    if (ws != null && !ws.equals("-")) {
      for (String part : ws.split(";")) {
        if (part.length() < 3) continue;
        String[] q = part.split(",");
        if (q.length < 7) continue;
        try {
          AppWin w = byId(Integer.parseInt(q[0]));
          if (w == null) continue;
          w.az = Float.parseFloat(q[1]); w.el = Float.parseFloat(q[2]); w.r = Float.parseFloat(q[3]);
          w.ww = Float.parseFloat(q[4]); w.hh = Float.parseFloat(q[5]); w.kappa = Float.parseFloat(q[6]);
          w.placed = true;
        } catch (Throwable t) { }
      }
    }
    if (rend != null && !wins.isEmpty()) rend.requestRender();
    onCursor(x, y, pinch, has);
  }
  static float clamp(float v, float a, float b) { return Math.max(a, Math.min(b, v)); }
  /** Raio do cursor (px CSS) contra a faixa de cilindro da janela. Retorna {u,v} (v=0 no topo) ou null. */
  float[] project(AppWin w, float x, float y, boolean clampOut) {
    float[] M = vs.M;
    if (M == null || !w.placed) return null;
    float W = web.getWidth() / density, H = web.getHeight() / density, P = 0.6f * W;
    double qx = x - W / 2f, qy = y - H / 2f, qz = -P;
    // d = A^T q, A_ij = M[3i+j]
    double dx = M[0] * qx + M[3] * qy + M[6] * qz;
    double dy = M[1] * qx + M[4] * qy + M[7] * qz;
    double dz = M[2] * qx + M[5] * qy + M[8] * qz;
    double az = Math.toRadians(w.az), r = w.r, k = w.kappa;
    double fx = Math.sin(az), fz = -Math.cos(az), rx = Math.cos(az), rz = Math.sin(az);
    double s, t;
    if (k < 1e-6) {
      double den = dx * fx + dz * fz;
      if (den <= 1e-6) return null;
      t = r / den; s = (t * dx) * rx + (t * dz) * rz;
    } else {
      double rho = 1.0 / k, cx = (r - rho) * fx, cz = (r - rho) * fz;
      double a = dx * dx + dz * dz;
      if (a < 1e-9) return null;
      double b = dx * cx + dz * cz, c = cx * cx + cz * cz - rho * rho;
      double disc = b * b - a * c;
      if (disc < 0) return null;
      t = (b + Math.sqrt(disc)) / a;
      double hx = t * dx - cx, hz = t * dz - cz;
      double cosp = (hx * fx + hz * fz) / rho, sinp = (hx * rx + hz * rz) / rho;
      if (cosp <= 0) return null;
      s = Math.atan2(sinp, cosp) * rho;
    }
    if (t <= 0) return null;
    double yc = -r * Math.tan(Math.toRadians(w.el));
    double u = s / w.ww + 0.5, v = (t * dy - (yc - w.hh / 2.0)) / w.hh;
    if (!clampOut && (u < 0 || u > 1 || v < 0 || v > 1)) return null;
    return new float[]{ clamp((float) u, 0f, 1f), clamp((float) v, 0f, 1f) };
  }
  AppWin hit(float x, float y) {
    for (int i = wins.size() - 1; i >= 0; i--) {
      AppWin w = wins.get(i);
      if (project(w, x, y, false) != null) return w;
    }
    return null;
  }
  void send(final int a, final float px, final float py, final AppWin w) {
    final IShell s = shell; final int d = w.dispId;
    if (s == null || d < 0) return;
    th.post(new Runnable() { public void run() { try { s.touch(a, px, py, d); } catch (Throwable t) { } } });
  }
  void onCursor(float x, float y, boolean pinch, boolean has) {
    curv.x = x * density; curv.y = y * density; curv.pinch = pinch; curv.show = has && !wins.isEmpty();
    curv.postInvalidate();
    if (wins.isEmpty() || shell == null) { prevPinch = false; down = false; return; }
    if (!has) {
      if (down && touchWin != null) { send(1, lastX, lastY, touchWin); }
      down = false; armed = false; prevPinch = false; return;
    }
    if (pinch && !prevPinch) {
      AppWin h = hit(x, y);
      armed = h != null;
      if (h != null) { touchWin = h; if (wins.get(wins.size() - 1) != h) ui.post(new Runnable() { public void run() { AppWin t = touchWin; if (t != null && wins.contains(t)) toFront(t); } }); }
    }
    prevPinch = pinch;
    AppWin w = touchWin;
    if (!pinch) {
      if (down && w != null) { send(1, lastX, lastY, w); }
      down = false; armed = false; return;
    }
    if (!armed || w == null) return;
    float[] uv = project(w, x, y, true);
    if (uv == null) return;
    float px = clamp(uv[0] * w.w, 0f, w.w - 1f), py = clamp(uv[1] * w.h, 0f, w.h - 1f);
    if (!down) { down = true; lastX = px; lastY = py; send(0, px, py, w); }
    else { lastX = px; lastY = py; send(2, px, py, w); }
  }
  @Override public void onRequestPermissionsResult(int c, String[] p, int[] res) {
    if (pending != null) {
      if (res.length > 0 && res[0] == PackageManager.PERMISSION_GRANTED) pending.grant(pending.getResources());
      else pending.deny();
      pending = null;
    }
  }
  @Override public void onWindowFocusChanged(boolean f) {
    super.onWindowFocusChanged(f);
    if (f) web.setSystemUiVisibility(View.SYSTEM_UI_FLAG_FULLSCREEN | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
      | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY | View.SYSTEM_UI_FLAG_LAYOUT_STABLE);
  }
  @Override protected void onResume() {
    super.onResume();
    if (rot != null) sm.registerListener(this, rot, SensorManager.SENSOR_DELAY_GAME);
    if (lin != null) sm.registerListener(this, lin, SensorManager.SENSOR_DELAY_GAME);
    ui.postDelayed(visTick, 250L);
  }
  @Override protected void onPause() { super.onPause(); sm.unregisterListener(this); ui.removeCallbacks(visTick); }
  @Override protected void onDestroy() {
    for (AppWin w : wins) closeWindow(w);
    try { Shizuku.removeRequestPermissionResultListener(permL); } catch (Throwable t) { }
    ht.quit();
    super.onDestroy();
  }
  @Override public void onSensorChanged(SensorEvent e) {
    int ty = e.sensor.getType();
    if (ty == Sensor.TYPE_LINEAR_ACCELERATION || ty == Sensor.TYPE_ACCELEROMETER) {
      float x = e.values[0], y = e.values[1], z = e.values[2];
      if (ty == Sensor.TYPE_ACCELEROMETER) {
        grav[0] = 0.95f * grav[0] + 0.05f * x;
        grav[1] = 0.95f * grav[1] + 0.05f * y;
        grav[2] = 0.95f * grav[2] + 0.05f * z;
        x -= grav[0]; y -= grav[1]; z -= grav[2];
      }
      lx = x; ly = y; lz = z;
      return;
    }
    if (!ready) return;
    SensorManager.getRotationMatrixFromVector(m, e.values);
    StringBuilder sb = new StringBuilder("__r([");
    for (int i = 0; i < 9; i++) { sb.append(m[i]); if (i < 8) sb.append(','); }
    sb.append("],").append(lx).append(',').append(ly).append(',').append(lz).append(')');
    web.evaluateJavascript(sb.toString(), null);
  }
  @Override public void onAccuracyChanged(Sensor s, int a) { }
}
EOF
cat > app/src/main/assets/apps.js <<'EOF'
(function () {
  var B = window.Android, UI = window.UI, WS = UI.WS;
  if (!B || !B.openApp) return;
  var W = [], winItems = [], lastWs = '', dockSaved = null;
  function clamp(v, a, b) { return Math.max(a, Math.min(b, v)); }
  function norm(a) { a = ((a + 180) % 360 + 360) % 360 - 180; return a; }
  function angDiff(a, b) { return Math.abs(norm(a - b)); }

  var css = document.createElement('style');
  css.textContent = [
    '.wh{position:absolute;left:0;top:0;backface-visibility:hidden;display:flex;align-items:center;justify-content:space-between;padding:0 10px 0 18px;border-radius:999px;background:rgba(18,26,48,.66);border:1px solid rgba(255,255,255,.32);box-shadow:0 8px 28px rgba(0,0,0,.35);color:#fff;font-family:system-ui,sans-serif}',
    '.wh.hand{border-color:rgba(255,255,255,.75)}',
    '.wt{display:flex;align-items:center;gap:10px;font-size:24px;font-weight:500;white-space:nowrap}',
    '.wi{font-size:30px}',
    '.wbs{display:flex;gap:8px}',
    '.wb{width:52px;height:52px;border-radius:50%;display:flex;align-items:center;justify-content:center;background:rgba(255,255,255,.16);border:1px solid rgba(255,255,255,.3);font-size:28px;font-weight:500;transition:transform .12s,background .12s}',
    '.wb svg{width:28px;height:28px;stroke:#fff;fill:none;stroke-width:2.2;stroke-linecap:round;stroke-linejoin:round}',
    '.wb.hand{background:rgba(255,255,255,.5)!important;transform:scale(1.12)}',
    '.wb.x{background:rgba(220,60,60,.35)}'
  ].join('');
  document.head.appendChild(css);

  function msg(t) {
    var d = document.createElement('div');
    d.style.cssText = 'position:fixed;top:44px;left:50%;transform:translateX(-50%);z-index:20;background:rgba(0,0,0,.8);color:#fff;font:13px sans-serif;padding:6px 12px;border-radius:999px;max-width:90%';
    d.textContent = t; document.body.appendChild(d);
    d.onclick = function () { d.remove(); };
    setTimeout(function () { d.remove(); }, 4500);
  }
  window.__msg = msg;

  var HW = 540, HH = 68;
  function dims(w) {
    if (w.pw >= w.ph) { w.ww0 = 860; w.hh0 = 860 * w.ph / w.pw; }
    else { w.hh0 = 500; w.ww0 = 500 * w.pw / w.ph; }
  }
  function Rn(w) { return clamp(w.R - (WS.L || 0), 240, 2400); }
  function hs(w) { return clamp(w.s, 0.8, 1.25); }

  var ICON_CURVE = '<svg viewBox="0 0 24 24"><path d="M3 15 Q12 5 21 15"/></svg>';
  var ICON_RATIO = '<svg viewBox="0 0 24 24"><rect x="3" y="7" width="18" height="10" rx="2"/><path d="M9 4v3M15 4v3" opacity=".0"/></svg>';

  function act(w, a) {
    if (a === 'x') { B.closeWin(w.id); removeW(w); return; }
    if (a === 'sm') w.s = Math.max(0.5, w.s / 1.1);
    else if (a === 'bg') w.s = Math.min(2.4, w.s * 1.1);
    else if (a === 'curve') w.curve = w.curve === 1 ? 0.5 : (w.curve === 0.5 ? 0 : 1);
    else if (a === 'ratio') B.resizeWin(w.id);
    lastWs = '';
  }
  function buildHandle(w) {
    var app = APPS[w.idx];
    w.hEl = mk('wh', '<div class="wt"><span class="wi">' + app[0] + '</span><span>' + app[1] + '</span></div><div class="wbs">' +
      '<div class="wb" data-a="curve">' + ICON_CURVE + '</div><div class="wb" data-a="sm">&#8722;</div><div class="wb" data-a="bg">+</div>' +
      '<div class="wb" data-a="ratio">' + ICON_RATIO + '</div><div class="wb x" data-a="x">&#10005;</div></div>');
    w.hEl.style.width = HW + 'px'; w.hEl.style.height = HH + 'px';
    w.hEl.style.marginLeft = -HW / 2 + 'px'; w.hEl.style.marginTop = -HH / 2 + 'px';
    var arr = [{ k: 'win', ws: w, el: w.hEl, az: 0, e: 0, hw: 0, hh: 0 }];
    w.hEl.querySelectorAll('.wb').forEach(function (b) {
      var a = b.getAttribute('data-a');
      arr.push({ k: 'btn', el: b, fn: function () { act(w, a); }, rep: a === 'sm' || a === 'bg', az: 0, e: 0, hw: 0, hh: 0 });
    });
    w.items = arr;
  }
  function rebuildItems() {
    winItems = [];
    W.forEach(function (w) { winItems = winItems.concat(w.items); });
    setItems();
  }
  function removeW(w) {
    var i = W.indexOf(w); if (i < 0) return;
    W.splice(i, 1);
    if (w.hEl) w.hEl.remove();
    rebuildItems(); adjustDock(); lastWs = '';
  }
  function spawnAz() {
    var base = gaze.az, step = 58, order = [0, 1, -1, 2, -2];
    for (var i = 0; i < order.length; i++) {
      var c = norm(base + order[i] * step), free = true;
      for (var j = 0; j < W.length; j++) if (angDiff(W[j].az, c) < 45) free = false;
      if (free) return c;
    }
    return norm(base + (W.length * 20));
  }
  // empurra o dock (barra de apps) para baixo das janelas, estilo Quest; devolve ao fechar a ultima
  function adjustDock() {
    if (!W.length) {
      if (dockSaved !== null) { WS.el = dockSaved; dockSaved = null; UI.layout(); }
      return;
    }
    if (dockSaved === null) dockSaved = WS.el;
    var low = 1e9;
    W.forEach(function (w) {
      var bot = w.el - Math.atan((w.hh0 * w.s / 2 + 14 + HH * hs(w)) / Rn(w)) / D;
      if (bot < low) low = bot;
    });
    var need = low - 3 - 10 * WS.s;
    if (WS.el > need) { WS.el = Math.max(-60, need); UI.layout(); }
  }

  window.__winAdd = function (id, idx, pw, ph) {
    var w = { id: id, idx: idx, pw: pw, ph: ph, s: 1, R: 900, curve: 1, az: 0, el: 0, key: '' };
    dims(w);
    w.az = spawnAz(); w.el = clamp(gaze.el, -10, 10);
    buildHandle(w); W.push(w);
    rebuildItems(); adjustDock(); lastWs = '';
  };
  window.__winDel = function (id) { W.slice().forEach(function (w) { if (w.id === id) removeW(w); }); };
  window.__winSize = function (id, pw, ph) { W.forEach(function (w) { if (w.id === id) { w.pw = pw; w.ph = ph; dims(w); lastWs = ''; adjustDock(); } }); };

  // a barra de apps passa a abrir janelas (sem esconder o launcher)
  openApp = function (a) { B.openApp(APPS.indexOf(a)); };
  closeApp = function () { };
  setItems = function () { items = (UI.WS.min ? [UI.bubItem] : ring).concat(winItems); };
  setItems();

  // centralizar: leva as janelas junto com o dock, mantendo o arranjo
  var rcb = document.getElementById('rc'), prevRc = rcb.onclick;
  rcb.onclick = function () {
    var base = WS.az;
    if (prevRc) prevRc();
    W.forEach(function (w) { w.az = norm(w.az - base); });
    if (dockSaved !== null) dockSaved = 0;
    adjustDock(); lastWs = '';
  };

  function place2(w) {
    var R = Rn(w), s = hs(w), yc = -R * Math.tan(w.el * D);
    var y = yc + w.hh0 * w.s / 2 + 14 + HH * s / 2;
    var x = R * Math.sin(w.az * D), z = -R * Math.cos(w.az * D);
    w.hEl.style.transform = 'translate3d(' + x.toFixed(1) + 'px,' + y.toFixed(1) + 'px,' + z.toFixed(1) + 'px) rotateY(' + (-w.az).toFixed(2) + 'deg) scale(' + s.toFixed(3) + ')';
    var ea = -Math.atan(y / R) / D, hw = Math.atan(HW * s / 2 / R) / D, hh = Math.atan(HH * s / 2 / R) / D;
    w.items.forEach(function (it) { it.az = w.az; it.e = ea; it.hw = hw; it.hh = hh; });
  }

  (function loop() {
    requestAnimationFrame(loop);
    if (!W.length) { if (lastWs !== '') { B.frame('', '', 0, 0, false, false); lastWs = ''; } return; }
    var parts = [];
    for (var i = 0; i < W.length; i++) {
      var w = W[i], R = Rn(w);
      var key = w.az.toFixed(2) + '|' + w.el.toFixed(2) + '|' + R.toFixed(0) + '|' + w.s.toFixed(3) + '|' + w.curve + '|' + w.pw + 'x' + w.ph;
      if (key !== w.key) { w.key = key; place2(w); }
      parts.push([w.id, w.az.toFixed(3), w.el.toFixed(3), R.toFixed(1), (w.ww0 * w.s).toFixed(1), (w.hh0 * w.s).toFixed(1), (w.curve / R).toFixed(6)].join(','));
    }
    var s = parts.join(';');
    var M = window.__M, h = window.handCursor || {};
    B.frame(M ? M.join(',') : '', s === lastWs ? '-' : s, h.x || 0, h.y || 0, !!h.pinch, !!h.has);
    lastWs = s;
  })();
})();
EOF
