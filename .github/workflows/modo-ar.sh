#!/usr/bin/env bash
# Modo AR (6DoF) do VR Launcher: tudo do 6DoF fica neste arquivo.
# Para atualizar: envie um modo-ar.sh novo para o repositorio, substituindo este.
set -e
echo "modo-ar.sh: Fase 7 - estereo VR Box nos dois modos (2026-11-16)"
mkdir -p app/src/main/java/com/vr/launcher
python3 - <<'PY'
def patch(path, old, new, skip=None):
    s = open(path, encoding='utf-8').read()
    if skip and skip in s:
        print('ja aplicado em', path)
        return
    assert old in s, 'nao achei em ' + path + ': ' + old
    open(path, 'w', encoding='utf-8').write(s.replace(old, new, 1))
def soft(path, old, new, skip=None):
    import os
    if not os.path.exists(path):
        print('AVISO: nao achei', path)
        return
    s = open(path, encoding='utf-8').read()
    if (skip and skip in s) or (not skip and new in s):
        print('ja aplicado em', path)
        return
    if old not in s:
        print('AVISO: trecho nao encontrado em', path, '->', old)
        return
    open(path, 'w', encoding='utf-8').write(s.replace(old, new, 1))
patch('app/build.gradle', "implementation 'com.google.guava:guava:32.1.3-android'", "implementation 'com.google.guava:guava:32.1.3-android'\n  implementation 'com.google.ar:core:1.44.0'", 'com.google.ar:core')
patch('app/src/main/AndroidManifest.xml', '</application>', """<meta-data android:name="com.google.ar.core" android:value="optional"/>
    <activity android:name=".ArActivity" android:exported="true" android:label="VR Launcher AR"
      android:theme="@android:style/Theme.Black.NoTitleBar.Fullscreen"
      android:screenOrientation="sensorLandscape"
      android:configChanges="orientation|screenSize|keyboardHidden|screenLayout|smallestScreenSize">
      <intent-filter>
        <action android:name="android.intent.action.MAIN"/>
        <category android:name="android.intent.category.LAUNCHER"/>
      </intent-filter>
    </activity>
  </application>""", '.ArActivity')
UI = 'app/src/main/assets/ui.js'
SK = None
soft(UI, "miSpace = null;", "miSpace = null, T_cfg = [], miCfg = null;", SK)
soft(UI, "['cfg', 'Configurações', soon]", "['cfg', 'Configurações', function () { setTab('cfg'); }]", SK)
soft(UI, "if (m[0] === 'space') miSpace = d;", "if (m[0] === 'space') miSpace = d; if (m[0] === 'cfg') miCfg = d;", SK)
soft(UI, "tabApps.style.zIndex = 200; tabHelp.style.zIndex = 200; tabSpace.style.zIndex = 200;",
 "var tabCfg = mk2('tab', '<div class=\"tt\">CONFIGURAÇÕES</div><div class=\"cfl\"></div>'); tabCfg.style.zIndex = 200; " +
 "(function () { var l = tabCfg.querySelector('.cfl'), r = document.createElement('div'); r.className = 'cfr'; " +
 "r.innerHTML = '<div class=\"cft\"><b>Modo 6DoF (AR)</b><span>Janelas e menu fixos no espaço, usando o ARCore. Para voltar ao modo original: Configurações dentro do modo 6DoF.</span></div><div class=\"cfs\"><i></i></div>'; l.appendChild(r); " +
 "T_cfg.push({ k: 'btn', el: r, fn: function () { if (window.Android && Android.openAr) { r.classList.add('on'); toast('Entrando no modo 6DoF...'); setTimeout(function () { Android.openAr(); r.classList.remove('on'); }, 350); } else toast('Modo 6DoF indisponível'); } }); })(); " +
 "(function () { var l = tabCfg.querySelector('.cfl'), r = document.createElement('div'); r.className = 'cfr'; " +
 "r.innerHTML = '<div class=\"cft\"><b>Estéreo (VR Box)</b><span>Divide a tela em duas, uma imagem para cada olho. Desligado: tela inteira.</span></div><div class=\"cfs\"><i></i></div>'; l.appendChild(r); " +
 "try { if (window.Android && Android.getStereo && Android.getStereo()) r.classList.add('on'); } catch (e) { } " +
 "T_cfg.push({ k: 'btn', el: r, fn: function () { if (window.Android && Android.setStereo) { var on = !r.classList.contains('on'); r.classList.toggle('on', on); Android.setStereo(on); toast(on ? 'Estéreo ligado' : 'Estéreo desligado'); } else toast('Estéreo indisponível'); } }); })(); " +
 "tabApps.style.zIndex = 200; tabHelp.style.zIndex = 200; tabSpace.style.zIndex = 200;", SK)
soft(UI, "['space', tabSpace]]", "['space', tabSpace], ['cfg', tabCfg]]", SK)
soft(UI, "tabSpace.style.display = TAB === 'space' ? 'flex' : 'none';", "tabSpace.style.display = TAB === 'space' ? 'flex' : 'none'; tabCfg.style.display = TAB === 'cfg' ? 'flex' : 'none';", SK)
soft(UI, "miSpace.classList.toggle('on', TAB === 'space');", "miSpace.classList.toggle('on', TAB === 'space'); miCfg.classList.toggle('on', TAB === 'cfg');", SK)
soft(UI, "(TAB === 'space' ? tabSpace : null)", "(TAB === 'space' ? tabSpace : (TAB === 'cfg' ? tabCfg : null))", SK)
soft(UI, "else if (TAB === 'space') t = t.concat(T_space);", "else if (TAB === 'space') t = t.concat(T_space); else if (TAB === 'cfg') t = t.concat(T_cfg);", SK)
soft(UI, "RHS.space].forEach", "RHS.space, RHS.cfg].forEach", SK)
soft(UI, "'.mi.hand,.ai.hand{background:#fff;color:#000}',",
 "'.mi.hand,.ai.hand{background:#fff;color:#000}', '.cfl{flex:1;display:flex;flex-direction:column;gap:14px}', " +
 "'.cfr{display:flex;align-items:center;gap:22px;padding:22px 26px;border-radius:30px;background:rgba(255,255,255,.08);border:1px solid rgba(255,255,255,.12)}', " +
 "'.cfr.hand{background:#fff;color:#000}', '.cft{flex:1;display:flex;flex-direction:column;gap:6px}', '.cft b{font-size:28px;font-weight:600}', '.cft span{font-size:19px;font-weight:300;opacity:.8;line-height:1.3}', " +
 "'.cfs{width:92px;height:50px;border-radius:25px;background:rgba(255,255,255,.25);position:relative;flex:none}', '.cfs i{position:absolute;left:5px;top:5px;width:40px;height:40px;border-radius:50%;background:#fff;transition:left .2s}', " +
 "'.cfr.hand .cfs{background:rgba(0,0,0,.3)}', '.cfr.hand .cfs i{background:#000}', '.cfr.on .cfs{background:#3ddc84}', '.cfr.on .cfs i{left:47px}',", SK)
soft('app/src/main/java/com/vr/launcher/MainActivity.java', 'class Bridge {',
 'class Bridge {\n'
 '              @JavascriptInterface public void openAr() { ui.post(() -> { try {\n'
 '                java.util.ArrayList<String> arL = new java.util.ArrayList<>();\n'
 '                for (Win aw : wins) {\n'
 '                  StringBuilder asb = new StringBuilder(); int acur = 0, an = 0;\n'
 '                  for (WebView at : aw.tabs) { String au = at.getUrl(); if (au == null || !au.startsWith("http")) continue; if (at == aw.v) acur = an; asb.append((char) 10).append(au); an++; }\n'
 '                  if (an > 0) arL.add(acur + asb.toString());\n'
 '                }\n'
 '                android.content.Intent ait = new android.content.Intent(MainActivity.this, ArActivity.class);\n'
 '                ait.putStringArrayListExtra("wins", arL);\n'
 '                startActivity(ait); finish();\n'
 '              } catch (Throwable t) { } }); }', 'putStringArrayListExtra')

MA = 'app/src/main/java/com/vr/launcher/MainActivity.java'
soft(MA, 'class Bridge {',
 'class Bridge {\n'
 '    @JavascriptInterface public boolean getStereo() { return stereoOn; }\n'
 '    @JavascriptInterface public void setStereo(final boolean v) { ui.post(() -> applyStereo(v, true)); }', 'public boolean getStereo')
soft(MA, '  static class CursorView extends View {',
 """  /* ---- estereo (VR Box): a mesma tela desenhada duas vezes, uma em cada metade; cada metade tem o layout de "meia tela" ---- */
  boolean stereoOn = false;
  void applyStereo(boolean v, boolean save) {
    stereoOn = v;
    if (save) { try { getSharedPreferences("ar", MODE_PRIVATE).edit().putBoolean("stereo", v).apply(); } catch (Throwable t) { } }
    try {
      previewView.setImplementationMode(v ? PreviewView.ImplementationMode.COMPATIBLE : PreviewView.ImplementationMode.PERFORMANCE);
      if (preview != null) preview.setSurfaceProvider(previewView.getSurfaceProvider());
    } catch (Throwable t) { }
    if (root instanceof StereoFrame) ((StereoFrame) root).setStereo(v);
  }
  static class StereoFrame extends FrameLayout {
    boolean on = false; int pass = 0;
    StereoFrame(Context c) { super(c); }
    void setStereo(boolean v) {
      on = v;
      for (int i = 0; i < getChildCount(); i++) layerOf(getChildAt(i));
      requestLayout(); invalidate();
    }
    void layerOf(View c) { if (c instanceof WebView) c.setLayerType(on ? View.LAYER_TYPE_HARDWARE : View.LAYER_TYPE_NONE, null); }
    @Override public void onViewAdded(View c) { super.onViewAdded(c); layerOf(c); }
    @Override protected void onMeasure(int ws, int hs) {
      if (!on) { super.onMeasure(ws, hs); return; }
      int w = MeasureSpec.getSize(ws), h = MeasureSpec.getSize(hs);
      super.onMeasure(MeasureSpec.makeMeasureSpec(w / 2, MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(h, MeasureSpec.EXACTLY));
      for (int i = 0; i < getChildCount(); i++) {
        View c = getChildAt(i);
        if (c instanceof GLSurfaceView) c.measure(MeasureSpec.makeMeasureSpec(w, MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(h, MeasureSpec.EXACTLY));
      }
      setMeasuredDimension(w, h);
    }
    @Override protected void dispatchDraw(Canvas cv) {
      pass = 0;
      super.dispatchDraw(cv);
      if (on) { pass = 1; super.dispatchDraw(cv); pass = 0; }
    }
    @Override protected boolean drawChild(Canvas cv, View c, long t) {
      if (!on) return super.drawChild(cv, c, t);
      if (c instanceof GLSurfaceView) return pass == 0 && super.drawChild(cv, c, t);   // superficie de video: uma so, ocupa a tela toda e desenha os dois olhos
      int cw = getWidth() / 2, sv = cv.save();
      cv.clipRect(pass == 0 ? 0 : cw, 0, pass == 0 ? cw : getWidth(), getHeight());
      if (pass == 1) cv.translate(cw, 0);
      boolean r = super.drawChild(cv, c, t);
      cv.restoreToCount(sv);
      return r;
    }
    @Override public boolean dispatchTouchEvent(MotionEvent e) {
      if (on && e.getX() >= getWidth() / 2f) e.offsetLocation(-getWidth() / 2f, 0f);
      return super.dispatchTouchEvent(e);
    }
  }
  static class CursorView extends View {""", 'class StereoFrame')
soft(MA, 'root = new FrameLayout(this);', 'root = new StereoFrame(this);', 'new StereoFrame(this)')
soft(MA, '    setContentView(root);\n', '    setContentView(root);\n    try { if (getSharedPreferences("ar", MODE_PRIVATE).getBoolean("stereo", false)) applyStereo(true, false); } catch (Throwable t) { }\n', 'applyStereo(true, false)')
soft(MA, 'volatile float sw = 1f, sh = 1f, fl = 500f;', 'volatile float sw = 1f, sh = 1f, fl = 500f; int surfW = 0, surfH = 0;', 'int surfW')
soft(MA, 'public void onSurfaceChanged(GL10 g, int w, int h) { GLES20.glViewport(0, 0, w, h); }', 'public void onSurfaceChanged(GL10 g, int w, int h) { surfW = w; surfH = h; GLES20.glViewport(0, 0, w, h); }', 'surfW = w')
soft(MA, '      GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4);\n    }\n    @Override public void onFrameAvailable',
 """      if (root instanceof StereoFrame && ((StereoFrame) root).on && surfW > 1) {
        GLES20.glViewport(0, 0, surfW / 2, surfH);
        GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4);
        GLES20.glViewport(surfW / 2, 0, surfW - surfW / 2, surfH);
        GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4);
        GLES20.glViewport(0, 0, surfW, surfH);
      } else {
        GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4);
      }
    }
    @Override public void onFrameAvailable""", 'surfW / 2, surfH')
PY
cat > app/src/main/java/com/vr/launcher/ArHand.java <<'EOF'
package com.vr.launcher;

import android.content.Context;
import android.graphics.Bitmap;
import android.media.Image;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.SystemClock;
import com.google.mediapipe.framework.image.BitmapImageBuilder;
import com.google.mediapipe.tasks.components.containers.NormalizedLandmark;
import com.google.mediapipe.tasks.core.BaseOptions;
import com.google.mediapipe.tasks.core.Delegate;
import com.google.mediapipe.tasks.vision.core.RunningMode;
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarker;
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarkerResult;
import java.nio.ByteBuffer;
import java.util.List;
import java.util.concurrent.atomic.AtomicBoolean;

/** IA da mao rodando em thread propria, alimentada pela imagem de CPU do ARCore. */
final class ArHand {

  /** pts: 21 pontos (x,y) no sistema IMAGE_NORMALIZED do ARCore. */
  static final class Result {
    final float[] pts;
    final float size;   // tamanho da mao (cresce quando chega perto da camera)
    final float ratio;  // distancia polegar-indicador / distancia pulso-base do dedo medio
    final boolean fist; // mao fechada (dedos dobrados): nao conta como pinca
    Result(float[] pts, float size, float ratio, boolean fist) { this.pts = pts; this.size = size; this.ratio = ratio; this.fist = fist; }
  }

  /** 1 = imagem inteira (640x480). 2 = metade (320x240), bem mais leve e suficiente para a IA. */
  private static final int STEP = 2;
  /** Sem mao por 1,5 s: so processa um quadro a cada IDLE_GAP ms para poupar bateria. */
  private static final long IDLE_GAP = 250;

  volatile Result latest = null;   // null = sem mao
  volatile long detSeq = 0;        // aumenta a cada deteccao concluida (com ou sem mao)
  volatile long latestSubmit = 0;  // hora (uptime) em que a imagem que gerou "latest" foi entregue a IA
  volatile String delegateName = "cpu";
  volatile String note = "";
  private volatile boolean gpu = false;
  private final AtomicBoolean fellBack = new AtomicBoolean(false);
  volatile String status = "carregando modelo...";
  volatile float detFps = 0f;
  volatile float detMs = 0f;

  private final Context context;
  private final AtomicBoolean busy = new AtomicBoolean(true);
  private final HandlerThread thread = new HandlerThread("ar-hand");
  private final Handler handler;
  private volatile HandLandmarker landmarker;
  private volatile long lastHandMs = 0;
  private long lastSubmitMs = 0;
  private long lastTs = 0, fpsStart = 0;
  private int fpsCount = 0;

  private Bitmap bmp;
  private int[] pixels = new int[0];
  private byte[] yb = new byte[0], ub = new byte[0], vb = new byte[0];

  ArHand(Context ctx, boolean useGpu) {
    context = ctx.getApplicationContext();
    gpu = useGpu;
    thread.start();
    handler = new Handler(thread.getLooper());
    handler.post(new Runnable() { @Override public void run() { loadModel(); } });
  }

  private HandLandmarker build(boolean useGpu) {
    BaseOptions base = BaseOptions.builder()
      .setModelAssetPath("mediapipe/hand_landmarker.task")
      .setDelegate(useGpu ? Delegate.GPU : Delegate.CPU)
      .build();
    HandLandmarker.HandLandmarkerOptions o = HandLandmarker.HandLandmarkerOptions.builder()
      .setBaseOptions(base)
      .setRunningMode(RunningMode.VIDEO)
      .setNumHands(1)
      .build();
    return HandLandmarker.createFromOptions(context, o);
  }

  private void loadModel() {
    HandLandmarker lm = null;
    note = "";
    if (gpu) {
      try {
        lm = build(true);
        delegateName = "gpu";
      } catch (Throwable t) {
        note = " (gpu falhou: " + t.getClass().getSimpleName() + ")";
        gpu = false;
      }
    }
    if (lm == null) {
      try {
        lm = build(false);
        delegateName = "cpu";
      } catch (Throwable t) {
        status = "erro no modelo: " + t;
      }
    }
    landmarker = lm;
    if (lm != null) status = "ok";
    busy.set(lm == null);
  }

  boolean wantsGpu() { return gpu; }

  /** Alterna a IA da mao entre CPU e GPU (teste de desempenho). Recarrega o modelo na thread da IA. */
  void toggleDelegate() {
    reload(!gpu);
  }

  private void reload(final boolean useGpu) {
    gpu = useGpu;
    handler.post(new Runnable() {
      @Override public void run() {
        busy.set(true);
        HandLandmarker old = landmarker;
        landmarker = null;
        if (old != null) { try { old.close(); } catch (Throwable t) { } }
        gpu = useGpu;
        latest = null;
        detMs = 0f;
        detFps = 0f;
        fpsStart = 0;
        fpsCount = 0;
        loadModel();
      }
    });
  }

  /** O renderer pergunta antes de buscar a imagem, para nao gastar a toa. */
  boolean wants() {
    if (busy.get()) return false;
    long now = SystemClock.uptimeMillis();
    boolean idle = now - lastHandMs > 1500;
    return !(idle && now - lastSubmitMs < IDLE_GAP);
  }

  /** Chamado na thread do GL. Copia os bytes e processa em outra thread. rot = 0, 90, 180 ou 270. */
  boolean submit(Image img, int rot) {
    if (!busy.compareAndSet(false, true)) return false;
    lastSubmitMs = SystemClock.uptimeMillis();
    final long sub = lastSubmitMs;
    try {
      final int w = img.getWidth(), h = img.getHeight();
      Image.Plane[] pl = img.getPlanes();
      yb = copy(pl[0].getBuffer(), yb);
      ub = copy(pl[1].getBuffer(), ub);
      vb = copy(pl[2].getBuffer(), vb);
      final int yRow = pl[0].getRowStride(), uvRow = pl[1].getRowStride(), uvPix = pl[1].getPixelStride();
      final int r = rot;
      handler.post(new Runnable() {
        @Override public void run() {
          try {
            process(w, h, r, yRow, uvRow, uvPix, sub);
          } catch (Throwable t) {
            if (gpu && fellBack.compareAndSet(false, true)) {
              // a GPU falhou durante o uso: volta sozinha para a CPU
              note = " (gpu falhou: " + t.getClass().getSimpleName() + ")";
              reload(false);
            } else {
              status = "erro: " + t;
            }
          } finally {
            busy.set(false);
          }
        }
      });
      return true;
    } catch (Throwable t) {
      busy.set(false);
      return false;
    }
  }

  private static byte[] copy(ByteBuffer b, byte[] dst) {
    int n = b.remaining();
    if (dst.length < n) dst = new byte[n];
    b.get(dst, 0, n);
    return dst;
  }

  private void process(int w, int h, int rot, int yRow, int uvRow, int uvPix, long sub) {
    HandLandmarker lm = landmarker;
    if (lm == null) return;

    // imagem "em pe" em relacao a tela: uW x uH (a do sensor, girada por rot)
    final boolean swap = (rot == 90 || rot == 270);
    final int uW = swap ? h : w, uH = swap ? w : h;
    final int oW = uW / STEP, oH = uH / STEP;
    Bitmap b = bmp;
    if (b == null || b.getWidth() != oW || b.getHeight() != oH) {
      b = Bitmap.createBitmap(oW, oH, Bitmap.Config.ARGB_8888);
      bmp = b;
      pixels = new int[oW * oH];
    }
    // posicao no sensor = origem + coef * (u, v) da imagem em pe
    int sx0, sxu, sxv, sy0, syu, syv;
    switch (rot) {
      case 90:  sx0 = 0;     sxu = 0;  sxv = 1;  sy0 = h - 1; syu = -1; syv = 0;  break;
      case 180: sx0 = w - 1; sxu = -1; sxv = 0;  sy0 = h - 1; syu = 0;  syv = -1; break;
      case 270: sx0 = w - 1; sxu = 0;  sxv = -1; sy0 = 0;     syu = 1;  syv = 0;  break;
      default:  sx0 = 0;     sxu = 1;  sxv = 0;  sy0 = 0;     syu = 0;  syv = 1;  break;
    }
    final byte[] y = yb, u = ub, v = vb;
    final int[] px = pixels;
    for (int oy = 0; oy < oH; oy++) {
      final int vv0 = oy * STEP;
      final int row = oy * oW;
      for (int ox = 0; ox < oW; ox++) {
        final int uu0 = ox * STEP;
        final int sx = sx0 + sxu * uu0 + sxv * vv0;
        final int sy = sy0 + syu * uu0 + syv * vv0;
        final int yy = y[sy * yRow + sx] & 0xFF;
        final int ci = (sy >> 1) * uvRow + (sx >> 1) * uvPix;
        final int cu = (u[ci] & 0xFF) - 128;
        final int cv = (v[ci] & 0xFF) - 128;
        int r = yy + ((359 * cv) >> 8);
        int g = yy - ((88 * cu + 183 * cv) >> 8);
        int bl = yy + ((454 * cu) >> 8);
        if (r < 0) r = 0; else if (r > 255) r = 255;
        if (g < 0) g = 0; else if (g > 255) g = 255;
        if (bl < 0) bl = 0; else if (bl > 255) bl = 255;
        px[row + ox] = 0xFF000000 | (r << 16) | (g << 8) | bl;
      }
    }
    b.setPixels(px, 0, oW, 0, 0, oW, oH);

    long t0 = SystemClock.uptimeMillis();
    long ts = Math.max(t0, lastTs + 1);
    lastTs = ts;
    HandLandmarkerResult res = lm.detectForVideo(new BitmapImageBuilder(b).build(), ts);
    long t1 = SystemClock.uptimeMillis();
    detMs = detMs == 0f ? (t1 - t0) : detMs * 0.85f + (t1 - t0) * 0.15f;

    List<List<NormalizedLandmark>> hands = res.landmarks();
    Result out = null;
    if (hands != null && !hands.isEmpty()) {
      List<NormalizedLandmark> l = hands.get(0);
      final float fw = oW, fh = oH;
      float palmH = dist(l, 0, 9, fw, fh);
      float palm = palmH + dist(l, 5, 17, fw, fh);
      float ratio = dist(l, 4, 8, fw, fh) / Math.max(palmH, 1f);
      float[] pts = new float[42];
      for (int i = 0; i < 21; i++) {
        float lx = l.get(i).x(), ly = l.get(i).y();
        float nx, ny;   // de volta ao sistema da imagem do sensor
        switch (rot) {
          case 90:  nx = ly;        ny = 1f - lx; break;
          case 180: nx = 1f - lx;   ny = 1f - ly; break;
          case 270: nx = 1f - ly;   ny = lx;      break;
          default:  nx = lx;        ny = ly;      break;
        }
        pts[2 * i] = nx;
        pts[2 * i + 1] = ny;
      }
      boolean fist = curled(l, 8, 5, fw, fh, 1.3f) && curled(l, 12, 9, fw, fh, 1.2f)
        && curled(l, 16, 13, fw, fh, 1.2f) && curled(l, 20, 17, fw, fh, 1.2f);
      out = new Result(pts, palm / fh, ratio, fist);
      lastHandMs = t1;
    }
    latestSubmit = sub;
    latest = out;
    detSeq++;

    fpsCount++;
    if (fpsStart == 0) fpsStart = t1;
    if (t1 - fpsStart >= 1000) {
      detFps = fpsCount * 1000f / (t1 - fpsStart);
      fpsCount = 0;
      fpsStart = t1;
    }
  }

  /** Dedo dobrado: a ponta fica perto do pulso, quase na altura da base do dedo. */
  private static boolean curled(List<NormalizedLandmark> l, int tip, int mcp, float w, float h, float k) {
    return dist(l, tip, 0, w, h) < dist(l, mcp, 0, w, h) * k;
  }

  private static float dist(List<NormalizedLandmark> l, int a, int c, float w, float h) {
    float dx = (l.get(a).x() - l.get(c).x()) * w;
    float dy = (l.get(a).y() - l.get(c).y()) * h;
    return (float) Math.sqrt(dx * dx + dy * dy);
  }

  void close() {
    handler.post(new Runnable() {
      @Override public void run() {
        HandLandmarker l = landmarker;
        landmarker = null;
        if (l != null) { try { l.close(); } catch (Throwable t) { } }
        thread.quitSafely();
      }
    });
  }

  /** Filtro 1 euro: suave quando a mao esta parada, rapido quando se mexe. */
  static final class OneEuro {
    private final float minC, beta, dC;
    private boolean init = false;
    private float xp, dxp;
    private long tp;
    float x = 0f, v = 0f;
    OneEuro(float minC, float beta, float dC) { this.minC = minC; this.beta = beta; this.dC = dC; }
    private static float alpha(float c, float dt) { return 1f / (1f + (1f / (float) (2 * Math.PI * c)) / dt); }
    float f(float val, long tMs) {
      if (!init) { init = true; xp = val; dxp = 0f; tp = tMs; x = val; v = 0f; return val; }
      float dt = Math.max(0.005f, (tMs - tp) / 1000f);
      tp = tMs;
      dxp += alpha(dC, dt) * ((val - xp) / dt - dxp);
      xp += alpha(minC + beta * Math.abs(dxp), dt) * (val - xp);
      x = xp; v = dxp;
      return xp;
    }
    void reset() { init = false; v = 0f; }
  }
}
EOF
cat > app/src/main/java/com/vr/launcher/ArImu.java <<'EOF'
package com.vr.launcher;

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Handler;
import android.os.HandlerThread;

/** Orientacao do celular pelo giroscopio (vetor de rotacao "game": sem bussola, so giroscopio + gravidade). */
final class ArImu implements SensorEventListener {

  final boolean available;
  private final SensorManager sm;
  private final Sensor sensor;
  private final HandlerThread thread = new HandlerThread("ar-imu");
  private Handler handler;
  private boolean started = false;

  private final Object lock = new Object();
  private final float[] r = new float[9];
  private final float[] tmp = new float[9];
  private final float[] q4 = new float[4];
  private boolean has = false;

  ArImu(Context c) {
    sm = (SensorManager) c.getSystemService(Context.SENSOR_SERVICE);
    Sensor s = sm == null ? null : sm.getDefaultSensor(Sensor.TYPE_GAME_ROTATION_VECTOR);
    if (s == null && sm != null) s = sm.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR);
    sensor = s;
    available = s != null;
  }

  void start() {
    if (!available) return;
    if (handler == null) {
      thread.start();
      handler = new Handler(thread.getLooper());
    }
    if (!started) {
      sm.registerListener(this, sensor, 10000, handler);   // 100 Hz
      started = true;
    }
  }

  void stop() {
    if (sm != null && started) {
      sm.unregisterListener(this);
      started = false;
    }
  }

  void close() {
    stop();
    if (handler != null) thread.quitSafely();
  }

  /** Copia a rotacao atual (3x3 por linhas, aparelho -> mundo ENU). Falso se ainda nao ha leitura. */
  boolean get(float[] out9) {
    synchronized (lock) {
      if (!has) return false;
      System.arraycopy(r, 0, out9, 0, 9);
      return true;
    }
  }

  @Override public void onSensorChanged(SensorEvent e) {
    float[] v = e.values;
    if (v == null || v.length < 3) return;
    float x = v[0], y = v[1], z = v[2];
    float w = v.length > 3 ? v[3] : (float) Math.sqrt(Math.max(0f, 1f - x * x - y * y - z * z));
    q4[0] = x; q4[1] = y; q4[2] = z; q4[3] = w;
    SensorManager.getRotationMatrixFromVector(tmp, q4);
    synchronized (lock) {
      System.arraycopy(tmp, 0, r, 0, 9);
      has = true;
    }
  }

  @Override public void onAccuracyChanged(Sensor s, int accuracy) { }
}
EOF
cat > app/src/main/java/com/vr/launcher/ArFuse.java <<'EOF'
package com.vr.launcher;

/**
 * Fusao ARCore + giroscopio. Enquanto o ARCore rastreia, aprende como os eixos do giroscopio se
 * relacionam com os da camera (testa as 24 orientacoes possiveis e fica com a que bate com o ARCore)
 * e o desvio de direcao (yaw) entre os dois. Quando o ARCore perde o rastreio, a orientacao continua
 * pelo giroscopio (3DoF) em vez de congelar. Todas as matrizes 3x3 sao por linhas: m[3*linha + coluna].
 */
final class ArFuse {

  // ENU (z para cima) -> mundo do ARCore (y para cima)
  private static final float[] E = {1f, 0f, 0f, 0f, 0f, 1f, 0f, -1f, 0f};
  private static final float[][] CAND = candidates();

  private final double[] err = new double[CAND.length];
  private double wsum = 0.0;
  private final float[] refAr = new float[9], refG = new float[9], prevG = new float[9];
  private boolean hasRef = false, hasPrev = false;
  private int best = -1;
  private float bestErr = 99f, secondErr = 99f;
  private boolean ready = false;
  private float yc = 1f, ys = 0f;
  private boolean yawInit = false;

  private final float[] a = new float[9], b = new float[9], c = new float[9], d = new float[9];

  /** Calibrado e com direcao conhecida: pode assumir quando o ARCore perder o rastreio. */
  boolean usable() { return ready && yawInit && best >= 0; }

  String status() {
    if (usable()) return "calibrado (erro " + Math.round(bestErr * 10f) / 10f + " graus)";
    return "calibrando " + Math.min(3, (int) wsum) + "/3: vire a cabeca em varias direcoes";
  }

  /** Chamar a cada quadro em que o ARCore rastreia. rAr: camera->mundo do ARCore. rG: aparelho->ENU do giroscopio. */
  void feed(float[] rAr, float[] rG) {
    float spd = hasPrev ? angle(prevG, rG) : 0f;
    System.arraycopy(rG, 0, prevG, 0, 9);
    hasPrev = true;

    if (!hasRef) {
      System.arraycopy(rAr, 0, refAr, 0, 9);
      System.arraycopy(rG, 0, refG, 0, 9);
      hasRef = true;
    } else if (angle(refAr, rAr) > 20f) {
      // rotacao relativa no referencial da camera: o ARCore e o giroscopio medem a mesma coisa, so em eixos diferentes
      mulTN(refAr, rAr, a);   // relAr
      mulTN(refG, rG, b);     // relG
      for (int k = 0; k < CAND.length; k++) {
        float[] m = CAND[k];
        mul(b, m, c);
        mulTN(m, c, d);       // M^T * relG * M
        err[k] = err[k] * 0.92 + angle(a, d);
      }
      wsum = wsum * 0.92 + 1.0;
      double b1 = 1e18, b2 = 1e18;
      int bi = -1;
      for (int k = 0; k < CAND.length; k++) {
        double v = err[k] / wsum;
        if (v < b1) { b2 = b1; b1 = v; bi = k; } else if (v < b2) { b2 = v; }
      }
      best = bi;
      bestErr = (float) b1;
      secondErr = (float) b2;
      ready = wsum >= 2.5 && bestErr < 10f && secondErr - bestErr > 10f;
      System.arraycopy(rAr, 0, refAr, 0, 9);
      System.arraycopy(rG, 0, refG, 0, 9);
    }
    if (best >= 0 && ready && spd < 1.5f) yawUpdate(rAr, rG);
  }

  private void base(float[] rG, float[] out) {
    mul(rG, CAND[best], c);   // aparelho -> eixos da tela
    mul(E, c, out);           // ENU -> mundo do ARCore
  }

  private void yawUpdate(float[] rAr, float[] rG) {
    float[] ref = new float[9], q = new float[9];
    base(rG, ref);
    mulNT(rAr, ref, q);       // deve ser uma rotacao so em torno do eixo vertical
    if (q[4] < 0.97f) return;
    float th = (float) Math.atan2(q[2], q[0]);
    float cc = (float) Math.cos(th), ss = (float) Math.sin(th);
    if (!yawInit) {
      yc = cc; ys = ss; yawInit = true;
    } else {
      yc += (cc - yc) * 0.03f;
      ys += (ss - ys) * 0.03f;
      float n = (float) Math.sqrt(yc * yc + ys * ys);
      if (n > 1e-4f) { yc /= n; ys /= n; }
    }
  }

  /** Orientacao da camera (camera->mundo do ARCore) a partir so do giroscopio. */
  boolean fused(float[] rG, float[] out) {
    if (!usable()) return false;
    float[] ref = new float[9];
    base(rG, ref);
    float[] ry = {yc, 0f, ys, 0f, 1f, 0f, -ys, 0f, yc};
    mul(ry, ref, out);
    return true;
  }

  // =============================================================
  // Matematica pequena
  // =============================================================

  static void mul(float[] x, float[] y, float[] o) {
    float[] t = new float[9];
    for (int i = 0; i < 3; i++)
      for (int j = 0; j < 3; j++)
        t[3 * i + j] = x[3 * i] * y[j] + x[3 * i + 1] * y[3 + j] + x[3 * i + 2] * y[6 + j];
    System.arraycopy(t, 0, o, 0, 9);
  }

  /** x^T * y */
  static void mulTN(float[] x, float[] y, float[] o) {
    float[] t = new float[9];
    for (int i = 0; i < 3; i++)
      for (int j = 0; j < 3; j++)
        t[3 * i + j] = x[i] * y[j] + x[3 + i] * y[3 + j] + x[6 + i] * y[6 + j];
    System.arraycopy(t, 0, o, 0, 9);
  }

  /** x * y^T */
  static void mulNT(float[] x, float[] y, float[] o) {
    float[] t = new float[9];
    for (int i = 0; i < 3; i++)
      for (int j = 0; j < 3; j++)
        t[3 * i + j] = x[3 * i] * y[3 * j] + x[3 * i + 1] * y[3 * j + 1] + x[3 * i + 2] * y[3 * j + 2];
    System.arraycopy(t, 0, o, 0, 9);
  }

  /** Angulo (graus) da rotacao que leva x em y. */
  static float angle(float[] x, float[] y) {
    float t = 0f;
    for (int k = 0; k < 9; k++) t += x[k] * y[k];
    float cs = Math.max(-1f, Math.min(1f, (t - 1f) * 0.5f));
    return (float) Math.toDegrees(Math.acos(cs));
  }

  /** As 24 matrizes de permutacao com sinais e determinante +1. */
  private static float[][] candidates() {
    int[][] perms = {{0, 1, 2}, {0, 2, 1}, {1, 0, 2}, {1, 2, 0}, {2, 0, 1}, {2, 1, 0}};
    int[] parity = {1, -1, -1, 1, 1, -1};
    float[][] out = new float[24][];
    int n = 0;
    for (int p = 0; p < 6; p++) {
      for (int sg = 0; sg < 8; sg++) {
        int s0 = (sg & 1) == 0 ? 1 : -1, s1 = (sg & 2) == 0 ? 1 : -1, s2 = (sg & 4) == 0 ? 1 : -1;
        if (parity[p] * s0 * s1 * s2 != 1) continue;
        float[] m = new float[9];
        m[3 * perms[p][0] + 0] = s0;
        m[3 * perms[p][1] + 1] = s1;
        m[3 * perms[p][2] + 2] = s2;
        out[n++] = m;
      }
    }
    return out;
  }

  static void quatFromMat(float[] m, float[] q) {
    float t = m[0] + m[4] + m[8];
    float x, y, z, w;
    if (t > 0f) {
      float s = (float) Math.sqrt(t + 1f) * 2f;
      w = 0.25f * s; x = (m[7] - m[5]) / s; y = (m[2] - m[6]) / s; z = (m[3] - m[1]) / s;
    } else if (m[0] > m[4] && m[0] > m[8]) {
      float s = (float) Math.sqrt(1f + m[0] - m[4] - m[8]) * 2f;
      w = (m[7] - m[5]) / s; x = 0.25f * s; y = (m[1] + m[3]) / s; z = (m[2] + m[6]) / s;
    } else if (m[4] > m[8]) {
      float s = (float) Math.sqrt(1f + m[4] - m[0] - m[8]) * 2f;
      w = (m[2] - m[6]) / s; x = (m[1] + m[3]) / s; y = 0.25f * s; z = (m[5] + m[7]) / s;
    } else {
      float s = (float) Math.sqrt(1f + m[8] - m[0] - m[4]) * 2f;
      w = (m[3] - m[1]) / s; x = (m[2] + m[6]) / s; y = (m[5] + m[7]) / s; z = 0.25f * s;
    }
    q[0] = x; q[1] = y; q[2] = z; q[3] = w;
  }

  static void matFromQuat(float[] q, float[] m) {
    float x = q[0], y = q[1], z = q[2], w = q[3];
    m[0] = 1f - 2f * (y * y + z * z); m[1] = 2f * (x * y - z * w);     m[2] = 2f * (x * z + y * w);
    m[3] = 2f * (x * y + z * w);     m[4] = 1f - 2f * (x * x + z * z); m[5] = 2f * (y * z - x * w);
    m[6] = 2f * (x * z - y * w);     m[7] = 2f * (y * z + x * w);     m[8] = 1f - 2f * (x * x + y * y);
  }

  static void nlerp(float[] p, float[] q, float t, float[] out) {
    float dot = p[0] * q[0] + p[1] * q[1] + p[2] * q[2] + p[3] * q[3];
    float sg = dot < 0f ? -1f : 1f;
    float n = 0f;
    for (int i = 0; i < 4; i++) { out[i] = p[i] * (1f - t) + q[i] * sg * t; n += out[i] * out[i]; }
    n = (float) Math.sqrt(n);
    if (n > 1e-6f) for (int i = 0; i < 4; i++) out[i] /= n;
  }
}
EOF
cat > app/src/main/java/com/vr/launcher/ArChrome.java <<'EOF'
package com.vr.launcher;

import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.RectF;

/**
 * Barra do navegador acima de cada janela, minimalista: uma fileira com voltar, avancar, endereco,
 * botao de abas e fechar janela. O botao de abas mostra/oculta, acima da fileira, as abas da janela com o "+".
 * Desenhada num bitmap 960x167 que vira textura; o desenho usa unidades de 576x100.
 */
final class ArChrome {

  static final int DW = 576, DH = 100;
  static final int BW = 960, BH = 167;
  static final float K = BW / (float) DW;

  static final int NONE = 0, TAB = 1, TABX = 2, NEW = 3, WINX = 4, BACK = 5, FWD = 6, URL = 7, TABS = 8;

  // fileira das abas (so quando aberta, em cima) e fileira de navegacao (embaixo)
  private static final float R1_T = 0f, R1_B = 44f, R2_T = 50f, R2_B = 100f;
  private static final float PADX = 8f, GAP = 4f, TAB_MAX = 150f, PLUSW = 44f;
  private static final float BACK_X0 = 8f, BACK_X1 = 58f, FWD_X0 = 62f, FWD_X1 = 112f;
  private static final float URL_X0 = 118f, URL_X1 = 458f, TABS_X0 = 462f, TABS_X1 = 512f, WINX_X0 = 518f, WINX_X1 = 568f;
  private static final float PAD = 4f;
  private static final int WHITE = Color.WHITE, DIM = Color.argb(80, 255, 255, 255);

  private static final Paint P = new Paint(Paint.ANTI_ALIAS_FLAG);
  private static final RectF R = new RectF(0f, 0f, 0f, 0f);
  private static final Path PATH = new Path();

  private ArChrome() { }

  static float tabW(int n) {
    float w = (DW - 2f * PADX - PLUSW - GAP - (n - 1) * GAP) / Math.max(1, n);
    return Math.min(TAB_MAX, w);
  }

  static float tabX0(int i, int n) { return PADX + i * (tabW(n) + GAP); }

  /** Retangulo (x0,y0,x1,y1) em unidades de projeto de um elemento. */
  static void rect(int elem, int idx, int n, float[] out) {
    float x0 = 0f, x1 = 0f, y0 = R2_T, y1 = R2_B;
    switch (elem) {
      case TAB: x0 = tabX0(idx, n); x1 = x0 + tabW(n); y0 = R1_T; y1 = R1_B; break;
      case TABX: x1 = tabX0(idx, n) + tabW(n) - 4f; x0 = x1 - 36f; y0 = R1_T + 4f; y1 = R1_B - 4f; break;
      case NEW: x0 = tabX0(n, n); x1 = x0 + PLUSW; y0 = R1_T; y1 = R1_B; break;
      case BACK: x0 = BACK_X0; x1 = BACK_X1; break;
      case FWD: x0 = FWD_X0; x1 = FWD_X1; break;
      case URL: x0 = URL_X0; x1 = URL_X1; break;
      case TABS: x0 = TABS_X0; x1 = TABS_X1; break;
      case WINX: x0 = WINX_X0; x1 = WINX_X1; break;
      default: break;
    }
    out[0] = x0; out[1] = y0; out[2] = x1; out[3] = y1;
  }

  /** dx, dy em unidades de projeto (0,0 = canto superior esquerdo). Devolve elem | (indice << 8). */
  static int hit(float dx, float dy, int n, int cur, boolean tabsOpen) {
    if (dx < 0f || dx > DW || dy < 0f || dy > DH) return NONE;
    float[] r = new float[4];
    if (dy <= (R1_B + R2_T) / 2f) {
      if (!tabsOpen) return NONE;
      if (n < ArPanel.MAXT) {
        rect(NEW, 0, n, r);
        if (in(dx, dy, r)) return NEW;
      }
      if (n > 1 && cur >= 0 && cur < n) {
        rect(TABX, cur, n, r);
        if (in(dx, dy, r)) return TABX | (cur << 8);
      }
      for (int i = 0; i < n; i++) {
        rect(TAB, i, n, r);
        if (in(dx, dy, r)) return TAB | (i << 8);
      }
      return NONE;
    }
    int[] order = {BACK, FWD, TABS, WINX, URL};
    for (int e : order) {
      rect(e, 0, n, r);
      if (in(dx, dy, r)) return e;
    }
    return NONE;
  }

  private static boolean in(float x, float y, float[] r) {
    return x >= r[0] - PAD && x <= r[2] + PAD && y >= r[1] - PAD && y <= r[3] + PAD;
  }

  // =============================================================
  // Desenho
  // =============================================================

  static void draw(Bitmap bmp, ArPanel.Snap s, boolean tabsOpen) {
    draw(bmp, s, tabsOpen, null, false, false);
  }

  /** edit != null: o endereco esta sendo editado (texto, cursor piscando e, se sel, tudo selecionado). */
  static void draw(Bitmap bmp, ArPanel.Snap s, boolean tabsOpen, String edit, boolean caret, boolean selAll) {
    Canvas c = new Canvas(bmp);
    bmp.eraseColor(0);
    c.scale(K, K);
    float[] r = new float[4];
    int n = s.n;
    int bg = Color.argb(135, 10, 12, 18);

    if (tabsOpen) {
      fill(c, 0f, R1_T, DW, R1_B, 22f, bg);
      for (int i = 0; i < n; i++) {
        rect(TAB, i, n, r);
        boolean sel = i == s.cur;
        if (sel) fill(c, r[0], r[1] + 4f, r[2], r[3] - 4f, 18f, Color.argb(60, 255, 255, 255));
        float textR = r[2] - (sel && n > 1 ? 44f : 12f);
        text(c, s.titles[i], r[0] + 14f, 29f, textR - (r[0] + 14f), 20f, sel ? WHITE : Color.argb(170, 255, 255, 255));
        if (sel && n > 1) {
          rect(TABX, i, n, r);
          cross(c, (r[0] + r[2]) / 2f, (r[1] + r[3]) / 2f, 6f, WHITE, 3f);
        }
      }
      if (n < ArPanel.MAXT) {
        rect(NEW, 0, n, r);
        float cx = (r[0] + r[2]) / 2f, cy = (r[1] + r[3]) / 2f;
        line(c, cx - 8f, cy, cx + 8f, cy, WHITE, 3.5f);
        line(c, cx, cy - 8f, cx, cy + 8f, WHITE, 3.5f);
      }
    }

    // fileira unica: voltar, avancar, endereco, abas, fechar
    fill(c, 0f, R2_T, DW, R2_B, 25f, bg);
    rect(BACK, 0, n, r);
    arrow(c, (r[0] + r[2]) / 2f, (r[1] + r[3]) / 2f, -1f, s.back ? WHITE : DIM);
    rect(FWD, 0, n, r);
    arrow(c, (r[0] + r[2]) / 2f, (r[1] + r[3]) / 2f, 1f, s.fwd ? WHITE : DIM);

    rect(URL, 0, n, r);
    if (edit != null) {
      fill(c, r[0], r[1] + 7f, r[2], r[3] - 7f, 18f, Color.argb(80, 255, 255, 255));
      outline(c, r[0] + 1f, r[1] + 8f, r[2] - 1f, r[3] - 8f, 17f, Color.argb(230, 94, 234, 212), 2f);
      editText(c, selAll ? shortUrl(edit) : edit, r[0] + 14f, r[2] - 14f, (r[1] + r[3]) / 2f + 7f, caret, selAll);
    } else {
      fill(c, r[0], r[1] + 7f, r[2], r[3] - 7f, 18f, Color.argb(46, 255, 255, 255));
      textCenter(c, shortUrl(s.url), (r[0] + r[2]) / 2f, (r[1] + r[3]) / 2f + 7f, r[2] - r[0] - 28f, 20f, WHITE);
    }

    rect(TABS, 0, n, r);
    float tx = (r[0] + r[2]) / 2f, ty = (r[1] + r[3]) / 2f;
    if (tabsOpen) fill(c, tx - 21f, ty - 21f, tx + 21f, ty + 21f, 21f, Color.argb(60, 255, 255, 255));
    outline(c, tx - 11f, ty - 6f, tx + 5f, ty + 10f, 4f, WHITE, 3f);
    outline(c, tx - 5f, ty - 11f, tx + 11f, ty + 5f, 4f, WHITE, 3f);

    rect(WINX, 0, n, r);
    cross(c, (r[0] + r[2]) / 2f, (r[1] + r[3]) / 2f, 8f, WHITE, 3.5f);
  }

  /** Texto do endereco em edicao: mostra o final se nao couber; cursor no fim; selecao pinta o fundo. */
  private static void editText(Canvas c, String t, float x0, float x1, float baseY, boolean caret, boolean sel) {
    P.setStyle(Paint.Style.FILL);
    P.setTextSize(20f);
    float maxW = x1 - x0 - 6f;
    if (t.length() == 0) {
      P.setColor(Color.argb(120, 255, 255, 255));
      c.drawText("Digite o endereco ou pesquisa", x0, baseY, P);
      if (caret) { P.setColor(WHITE); c.drawRect(x0 - 1f, baseY - 20f, x0 + 1f, baseY + 5f, P); }
      return;
    }
    String out = t;
    boolean cut = false;
    while (out.length() > 1 && P.measureText(out) > maxW) { out = out.substring(1); cut = true; }
    if (cut) out = "\u2026" + out.substring(1);
    float w = P.measureText(out);
    if (sel) {
      P.setColor(Color.argb(150, 94, 234, 212));
      R.set(x0 - 3f, baseY - 21f, x0 + w + 3f, baseY + 6f);
      c.drawRoundRect(R, 6f, 6f, P);
      P.setColor(Color.rgb(4, 32, 28));
    } else {
      P.setColor(WHITE);
    }
    c.drawText(out, x0, baseY, P);
    if (caret && !sel) {
      P.setColor(Color.rgb(94, 234, 212));
      c.drawRect(x0 + w + 2f, baseY - 20f, x0 + w + 4f, baseY + 5f, P);
    }
  }

  static String shortUrl(String u) {
    if (u == null) return "";
    String t = u;
    if (t.startsWith("https://")) t = t.substring(8);
    else if (t.startsWith("http://")) t = t.substring(7);
    if (t.startsWith("www.")) t = t.substring(4);
    if (t.endsWith("/")) t = t.substring(0, t.length() - 1);
    return t;
  }

  private static void fill(Canvas c, float x0, float y0, float x1, float y1, float rad, int col) {
    P.setStyle(Paint.Style.FILL);
    P.setColor(col);
    R.set(x0, y0, x1, y1);
    c.drawRoundRect(R, rad, rad, P);
  }

  private static void outline(Canvas c, float x0, float y0, float x1, float y1, float rad, int col, float w) {
    P.setStyle(Paint.Style.STROKE);
    P.setStrokeWidth(w);
    P.setColor(col);
    R.set(x0, y0, x1, y1);
    c.drawRoundRect(R, rad, rad, P);
  }

  private static void line(Canvas c, float x0, float y0, float x1, float y1, int col, float w) {
    P.setStyle(Paint.Style.STROKE);
    P.setStrokeWidth(w);
    P.setStrokeCap(Paint.Cap.ROUND);
    P.setColor(col);
    c.drawLine(x0, y0, x1, y1, P);
  }

  private static void cross(Canvas c, float cx, float cy, float h, int col, float w) {
    line(c, cx - h, cy - h, cx + h, cy + h, col, w);
    line(c, cx - h, cy + h, cx + h, cy - h, col, w);
  }

  /** dir = -1 seta para a esquerda, +1 para a direita. */
  private static void arrow(Canvas c, float cx, float cy, float dir, int col) {
    P.setStyle(Paint.Style.STROKE);
    P.setStrokeWidth(4f);
    P.setStrokeCap(Paint.Cap.ROUND);
    P.setColor(col);
    PATH.reset();
    PATH.moveTo(cx - dir * 3f, cy - 10f);
    PATH.lineTo(cx + dir * 7f, cy);
    PATH.lineTo(cx - dir * 3f, cy + 10f);
    c.drawPath(PATH, P);
    c.drawLine(cx + dir * 7f, cy, cx - dir * 10f, cy, P);
  }

  private static void textCenter(Canvas c, String t, float cx, float baseY, float maxW, float size, int col) {
    if (t == null) t = "";
    P.setStyle(Paint.Style.FILL);
    P.setColor(col);
    P.setTextSize(size);
    if (maxW < 8f) return;
    int cnt = P.breakText(t, true, maxW, null);
    String out = t;
    if (cnt < t.length()) out = t.substring(0, Math.max(0, cnt - 1)) + "…";
    float w = P.measureText(out);
    c.drawText(out, cx - w / 2f, baseY, P);
  }

  private static void text(Canvas c, String t, float x, float baseY, float maxW, float size, int col) {
    if (t == null) t = "";
    P.setStyle(Paint.Style.FILL);
    P.setColor(col);
    P.setTextSize(size);
    if (maxW < 8f) return;
    int cnt = P.breakText(t, true, maxW, null);
    String out = t;
    if (cnt < t.length()) out = t.substring(0, Math.max(0, cnt - 1)) + "…";
    c.drawText(out, x, baseY, P);
  }
}
EOF
cat > app/src/main/java/com/vr/launcher/ArPanel.java <<'EOF'
package com.vr.launcher;

import android.app.Presentation;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.SurfaceTexture;
import android.hardware.display.DisplayManager;
import android.hardware.display.VirtualDisplay;
import android.opengl.GLES11Ext;
import android.opengl.GLES20;
import android.os.Handler;
import android.os.Looper;
import android.os.SystemClock;
import android.view.InputDevice;
import android.view.MotionEvent;
import android.view.Surface;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputConnection;
import android.webkit.CookieManager;
import android.webkit.JavascriptInterface;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.FrameLayout;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.concurrent.atomic.AtomicBoolean;

/**
 * Uma janela do navegador transformada em textura OpenGL, com varias abas.
 * Modo VD: os WebViews rodam numa tela virtual (Presentation) que desenha direto na textura (GPU).
 * Modo SW: plano B. Os WebViews ficam atras do GL e sao copiados para a textura por software, uns 15 vezes por segundo.
 */
final class ArPanel {
  static final int VD = 0, SW = 1;
  static final int MAXT = 4;
  static volatile int defaultMode = VD;
  private static int seq = 0;

  /** Retrato imutavel do estado do navegador, lido pela thread do GL para desenhar a barra. */
  static final class Snap {
    final int ver, n, cur;
    final String[] titles;
    final String url;
    final boolean back, fwd;
    Snap(int ver, int n, int cur, String[] titles, String url, boolean back, boolean fwd) {
      this.ver = ver; this.n = n; this.cur = cur; this.titles = titles; this.url = url; this.back = back; this.fwd = fwd;
    }
  }

  private static final class Tab {
    String url;
    String title = "";
    WebView web;
    boolean loaded = false;
    Tab(String url) { this.url = url; }
  }

  final ArActivity act;
  final int pw, ph, dpi;
  final int id;
  final Handler ui = new Handler(Looper.getMainLooper());

  // ---- lado GL ----
  int tex = 0;
  SurfaceTexture st;
  Surface surf;
  final float[] stm = new float[16];
  final AtomicBoolean avail = new AtomicBoolean(false);
  volatile boolean got = false;
  volatile int frames = 0;

  // ---- lado UI ----
  volatile int mode = defaultMode;
  volatile String err = "";
  volatile String where = "";
  volatile Snap snap;
  private final ArrayList<Tab> tabs = new ArrayList<Tab>();
  private int cur = 0;
  private int ver = 0;
  private FrameLayout holder;
  private VirtualDisplay vd;
  private Presentation pres;
  private boolean running = false;
  private volatile boolean dead = false;
  private final String home;
  /** Painel do menu 3D: pagina propria (ArMenuPage) com ponte "ArMenu" para o Java. */
  final boolean menu;
  /** Teclado virtual: pagina propria (ArKbPage) com ponte "ArKb". */
  final boolean kb;
  /** Controles do video 360: pagina propria (ArVidPage) com a ponte "ArMenu". */
  final boolean vid;
  private long downTime = 0;
  private Runnable tick, watchdog;

  ArPanel(ArActivity act, int pw, int ph, int dpi, String url) {
    this(act, pw, ph, dpi, url, false);
  }

  ArPanel(ArActivity act, int pw, int ph, int dpi, String url, boolean menu) {
    this.act = act; this.pw = pw; this.ph = ph; this.dpi = dpi; this.home = url; this.menu = menu;
    this.kb = menu && ArActivity.KB_URL.equals(url);
    this.vid = menu && ArActivity.VID_URL.equals(url);
    this.id = ++seq;
    tabs.add(new Tab(url));
    android.opengl.Matrix.setIdentityM(stm, 0);
    snap = makeSnap();
  }

  /** Painel com varias abas ja abertas (vindas do modo original). */
  ArPanel(ArActivity act, int pw, int ph, int dpi, String[] urls, int cur0) {
    this(act, pw, ph, dpi, ArActivity.HOME, false);
    tabs.clear();
    for (int i = 0; urls != null && i < urls.length && i < MAXT; i++) tabs.add(new Tab(urls[i]));
    if (tabs.isEmpty()) tabs.add(new Tab(ArActivity.HOME));
    cur = Math.max(0, Math.min(tabs.size() - 1, cur0));
    snap = makeSnap();
  }

  /** Executa um trecho de JavaScript na aba atual (usado pelo menu). */
  void eval(final String js) {
    ui.post(new Runnable() {
      @Override public void run() {
        if (dead || cur >= tabs.size()) return;
        WebView w = tabs.get(cur).web;
        if (w != null) w.evaluateJavascript(js, null);
      }
    });
  }

  /** Aspas JavaScript para um texto qualquer. */
  static String jsq(String t) {
    StringBuilder b = new StringBuilder("'");
    for (int i = 0; i < t.length(); i++) {
      char c = t.charAt(i);
      if (c == '\\') b.append("\\\\");
      else if (c == '\'') b.append("\\'");
      else if (c == '\n') b.append("\\n");
      else if (c == '\r') b.append("\\r");
      else if (c == '<') b.append("\\u003c");
      else if (c == '\u2028') b.append("\\u2028");
      else if (c == '\u2029') b.append("\\u2029");
      else b.append(c);
    }
    return b.append('\'').toString();
  }

  /** Escreve texto no campo que esta com o foco na pagina (teclado virtual). */
  void typeText(String t) {
    eval("(function(t){try{var d=document,a=d.activeElement;"
      + "while(a&&a.tagName==='IFRAME'){var n=null;try{n=a.contentDocument.activeElement}catch(e){break}"
      + "if(!n||n===a.contentDocument.body)break;a=n;d=a.ownerDocument}"
      + "if(!a||a===d.body)return;"
      + "var ok=false;try{ok=d.execCommand('insertText',false,t)}catch(e){}"
      + "if(!ok&&a.value!==undefined){var s=a.selectionStart,e2=a.selectionEnd,v=a.value;"
      + "var nv=v.slice(0,s)+t+v.slice(e2);"
      + "var st=Object.getOwnPropertyDescriptor(Object.getPrototypeOf(a),'value');"
      + "if(st&&st.set)st.set.call(a,nv);else a.value=nv;"
      + "try{a.selectionStart=a.selectionEnd=s+t.length}catch(e){}"
      + "a.dispatchEvent(new Event('input',{bubbles:true}))}"
      + "}catch(e){}})(" + jsq(t) + ")");
  }

  /** Teclas especiais no campo com foco: "back" (apagar) e "enter". */
  void pressKey(String k) {
    if ("back".equals(k)) {
      eval("(function(){try{var d=document,a=d.activeElement;"
        + "while(a&&a.tagName==='IFRAME'){var n=null;try{n=a.contentDocument.activeElement}catch(e){break}"
        + "if(!n||n===a.contentDocument.body)break;a=n;d=a.ownerDocument}"
        + "if(!a||a===d.body)return;"
        + "var ok=false;try{ok=d.execCommand('delete')}catch(e){}"
        + "if(!ok&&a.value!==undefined){var s=a.selectionStart,e2=a.selectionEnd,v=a.value;"
        + "if(s===e2&&s>0){s--}"
        + "var nv=v.slice(0,s)+v.slice(e2);"
        + "var st=Object.getOwnPropertyDescriptor(Object.getPrototypeOf(a),'value');"
        + "if(st&&st.set)st.set.call(a,nv);else a.value=nv;"
        + "try{a.selectionStart=a.selectionEnd=s}catch(e){}"
        + "a.dispatchEvent(new Event('input',{bubbles:true}))}"
        + "}catch(e){}})()");
    } else if ("enter".equals(k)) {
      eval("(function(){try{var d=document,a=d.activeElement;"
        + "while(a&&a.tagName==='IFRAME'){var n=null;try{n=a.contentDocument.activeElement}catch(e){break}"
        + "if(!n||n===a.contentDocument.body)break;a=n;d=a.ownerDocument}"
        + "if(!a||a===d.body)return;"
        + "var o={key:'Enter',code:'Enter',keyCode:13,which:13,bubbles:true,cancelable:true};"
        + "var go=a.dispatchEvent(new KeyboardEvent('keydown',o));"
        + "a.dispatchEvent(new KeyboardEvent('keypress',o));"
        + "if(go){var ml=a.tagName==='TEXTAREA'||a.isContentEditable;"
        + "if(ml){try{d.execCommand('insertText',false,'\\n')}catch(e){}}"
        + "else if(a.form){if(a.form.requestSubmit)a.form.requestSubmit();else a.form.submit()}}"
        + "a.dispatchEvent(new KeyboardEvent('keyup',o));"
        + "}catch(e){}})()");
    }
  }

  /** Endereco digitado: endereco completo, dominio (acrescenta https://) ou pesquisa no Google. */
  void navigate(String text) {
    String u = text == null ? "" : text.trim();
    if (u.length() == 0) return;
    String l = u.toLowerCase();
    if (l.startsWith("http://") || l.startsWith("https://") || l.startsWith("about:") || l.startsWith("file:")) {
      // ja e um endereco
    } else if (u.indexOf(' ') < 0 && (u.indexOf('.') > 0 || l.startsWith("localhost"))) {
      u = "https://" + u;
    } else {
      try { u = "https://www.google.com/search?q=" + java.net.URLEncoder.encode(u, "UTF-8"); } catch (Throwable e) { return; }
    }
    go(u);
  }

  // =============================================================
  // GL thread
  // =============================================================

  void glInit() {
    int[] t = new int[1];
    GLES20.glGenTextures(1, t, 0);
    tex = t[0];
    GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, tex);
    GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE);
    GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE);
    GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR);
    GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR);
    st = null; surf = null;
    newSurface();
  }

  /** Libera a textura e a superficie (thread do GL). A UI desmonta os WebViews. */
  void glRelease() {
    dead = true;
    Surface s = surf;
    SurfaceTexture t = st;
    surf = null; st = null;
    if (s != null) { try { s.release(); } catch (Throwable e) { } }
    if (t != null) { try { t.release(); } catch (Throwable e) { } }
    if (tex != 0) {
      GLES20.glDeleteTextures(1, new int[]{tex}, 0);
      tex = 0;
    }
    destroy();
  }

  /** Cria uma SurfaceTexture nova na mesma textura e manda a UI ligar os WebViews nela. */
  void newSurface() {
    final Surface oldS = surf;
    final SurfaceTexture oldT = st;
    if (oldS != null) { try { oldS.release(); } catch (Throwable t) { } }
    if (oldT != null) { try { oldT.release(); } catch (Throwable t) { } }
    SurfaceTexture n = new SurfaceTexture(tex);
    n.setDefaultBufferSize(pw, ph);
    n.setOnFrameAvailableListener(new SurfaceTexture.OnFrameAvailableListener() {
      @Override public void onFrameAvailable(SurfaceTexture t) { avail.set(true); frames++; }
    });
    st = n;
    final Surface s = new Surface(n);
    surf = s;
    got = false;
    avail.set(false);
    frames = 0;
    ui.post(new Runnable() { @Override public void run() { attach(s); } });
  }

  /** Pega o quadro novo, se houver. Retorna true se ja existe imagem. */
  boolean update() {
    SurfaceTexture t = st;
    if (t != null && avail.getAndSet(false)) {
      try {
        t.updateTexImage();
        t.getTransformMatrix(stm);
        got = true;
      } catch (Throwable e) {
        err = "textura: " + e;
      }
    }
    return got;
  }

  // =============================================================
  // UI thread: tela virtual / software
  // =============================================================

  private void attach(Surface s) {
    if (dead || s != surf) return;        // janela fechada ou surface ja trocada
    detach();
    err = "";
    try {
      if (mode == VD) attachVd(s); else attachSw(s);
    } catch (Throwable t) {
      err = (mode == VD ? "tela virtual: " : "software: ") + t;
      if (mode == VD) {
        mode = SW;
        detach();
        try { attachSw(s); } catch (Throwable t2) { err += " | software: " + t2; }
      }
    }
    // plano B automatico: se o modo VD nao produzir nenhum quadro em 7 s
    final Surface cs = s;
    watchdog = new Runnable() {
      @Override public void run() {
        if (!dead && cs == surf && mode == VD && frames == 0) {
          err = "tela virtual sem imagem, trocando para software";
          mode = SW;
          act.queueGl(new Runnable() { @Override public void run() { if (!dead) newSurface(); } });
        }
      }
    };
    ui.postDelayed(watchdog, 7000);
  }

  private void attachVd(Surface s) {
    DisplayManager dm = (DisplayManager) act.getSystemService(Context.DISPLAY_SERVICE);
    vd = dm.createVirtualDisplay("ar-win-" + id, pw, ph, dpi, s, 0);
    if (vd == null) throw new IllegalStateException("createVirtualDisplay devolveu null");
    pres = new Presentation(act, vd.getDisplay());
    holder = new FrameLayout(pres.getContext());
    pres.setContentView(holder, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
    pres.show();
    buildTabs();
    where = "tela virtual " + pw + "x" + ph + " @" + dpi;
  }

  private void attachSw(final Surface s) {
    holder = new FrameLayout(act);
    act.addPanelView(holder, pw, ph);
    buildTabs();
    running = true;
    where = "software " + pw + "x" + ph;
    tick = new Runnable() {
      @Override public void run() {
        FrameLayout h = holder;
        if (!running || h == null || s != surf) return;
        try {
          Canvas c = s.lockCanvas(null);
          try { h.draw(c); } finally { s.unlockCanvasAndPost(c); }
        } catch (Throwable t) {
          err = "desenho: " + t;
        }
        ui.postDelayed(this, 70);
      }
    };
    ui.post(tick);
  }

  private void buildTabs() {
    for (int i = 0; i < tabs.size(); i++) {
      Tab t = tabs.get(i);
      t.web = newWeb(holder.getContext(), t);
      t.loaded = false;
      holder.addView(t.web, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
      t.web.setVisibility(i == cur ? View.VISIBLE : View.GONE);
    }
    load(tabs.get(cur));
    publish();
  }

  private void load(Tab t) {
    if (t.web != null && !t.loaded) {
      t.loaded = true;
      if (kb) t.web.loadDataWithBaseURL("https://vrlauncher.local/", ArKbPage.HTML, "text/html", "utf-8", null);
      else if (vid) t.web.loadDataWithBaseURL("https://vrlauncher.local/", ArVidPage.HTML, "text/html", "utf-8", null);
      else if (menu) t.web.loadDataWithBaseURL("https://vrlauncher.local/", ArMenuPage.HTML, "text/html", "utf-8", null);
      else t.web.loadUrl(t.url);
    }
  }

  /** Abre o endereco na aba atual (usado quando ja ha o maximo de janelas). */
  void go(final String url) {
    ui.post(new Runnable() {
      @Override public void run() {
        if (dead || cur >= tabs.size()) return;
        Tab t = tabs.get(cur);
        t.url = url;
        if (t.web != null) { t.loaded = true; t.web.loadUrl(url); }
        publish();
      }
    });
  }

  private void detach() {
    running = false;
    if (tick != null) ui.removeCallbacks(tick);
    if (watchdog != null) ui.removeCallbacks(watchdog);
    for (Tab t : tabs) {
      if (t.web != null) {
        String u = t.web.getUrl();
        if (u != null && u.startsWith("http")) t.url = u;
      }
    }
    if (pres != null) { try { pres.dismiss(); } catch (Throwable t) { } pres = null; }
    if (vd != null) { try { vd.release(); } catch (Throwable t) { } vd = null; }
    for (Tab t : tabs) {
      if (t.web != null) {
        ViewParent p = t.web.getParent();
        if (p instanceof ViewGroup) ((ViewGroup) p).removeView(t.web);
        try { t.web.stopLoading(); t.web.destroy(); } catch (Throwable e) { }
        t.web = null;
        t.loaded = false;
      }
    }
    if (holder != null) {
      ViewParent p = holder.getParent();
      if (p instanceof ViewGroup) ((ViewGroup) p).removeView(holder);
      holder = null;
    }
  }

  void destroy() {
    dead = true;
    ui.post(new Runnable() { @Override public void run() { detach(); } });
  }

  // =============================================================
  // Abas e navegacao (chamadas de qualquer thread)
  // =============================================================

  private Snap makeSnap() {
    int n = tabs.size();
    String[] titles = new String[n];
    for (int i = 0; i < n; i++) {
      Tab t = tabs.get(i);
      String s = t.title;
      if (s == null || s.length() == 0) s = ArChrome.shortUrl(t.url);
      if (s.length() == 0) s = "Nova aba";
      titles[i] = s;
    }
    Tab c = tabs.get(cur);
    String u = c.url;
    boolean b = false, f = false;
    if (c.web != null) {
      String wu = c.web.getUrl();
      if (wu != null) u = wu;
      b = c.web.canGoBack();
      f = c.web.canGoForward();
    }
    return new Snap(++ver, n, cur, titles, u, b, f);
  }

  private void publish() { snap = makeSnap(); }

  void newTab(final String u) {
    ui.post(new Runnable() {
      @Override public void run() {
        if (dead || tabs.size() >= MAXT) return;
        Tab t = new Tab(u == null ? home : u);
        tabs.add(t);
        if (holder != null) {
          t.web = newWeb(holder.getContext(), t);
          holder.addView(t.web, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        }
        select(tabs.size() - 1);
      }
    });
  }

  void selectTab(final int i) {
    ui.post(new Runnable() { @Override public void run() { if (!dead) select(i); } });
  }

  private void select(int i) {
    if (i < 0 || i >= tabs.size()) return;
    cur = i;
    for (int k = 0; k < tabs.size(); k++) {
      Tab t = tabs.get(k);
      if (t.web != null) t.web.setVisibility(k == cur ? View.VISIBLE : View.GONE);
    }
    load(tabs.get(cur));
    publish();
  }

  /** Fecha a aba. Se for a ultima, volta para a pagina inicial. */
  void closeTab(final int i) {
    ui.post(new Runnable() {
      @Override public void run() {
        if (dead || i < 0 || i >= tabs.size()) return;
        if (tabs.size() == 1) {
          Tab t = tabs.get(0);
          t.url = home;
          t.title = "";
          if (t.web != null) { t.loaded = true; t.web.loadUrl(home); }
          publish();
          return;
        }
        Tab t = tabs.remove(i);
        if (t.web != null) {
          ViewParent p = t.web.getParent();
          if (p instanceof ViewGroup) ((ViewGroup) p).removeView(t.web);
          try { t.web.stopLoading(); t.web.destroy(); } catch (Throwable e) { }
          t.web = null;
        }
        if (i < cur) cur--;
        if (cur >= tabs.size()) cur = tabs.size() - 1;
        select(cur);
      }
    });
  }

  void goBack() {
    ui.post(new Runnable() {
      @Override public void run() {
        Tab t = tabs.get(cur);
        if (t.web != null && t.web.canGoBack()) t.web.goBack();
      }
    });
  }

  void goForward() {
    ui.post(new Runnable() {
      @Override public void run() {
        Tab t = tabs.get(cur);
        if (t.web != null && t.web.canGoForward()) t.web.goForward();
      }
    });
  }

  /** Injeta um toque na aba atual. px/py em pixels da pagina (0..pw, 0..ph). */
  void touch(final int action, final float px, final float py) {
    ui.post(new Runnable() {
      @Override public void run() {
        if (dead || cur >= tabs.size()) return;
        WebView w = tabs.get(cur).web;
        if (w == null) return;
        long now = SystemClock.uptimeMillis();
        if (action == MotionEvent.ACTION_DOWN) downTime = now;
        MotionEvent e = MotionEvent.obtain(downTime, now, action, px, py, 0);
        e.setSource(InputDevice.SOURCE_TOUCHSCREEN);
        try { w.dispatchTouchEvent(e); } finally { e.recycle(); }
      }
    });
  }

  private static final String FOCUS_JS = "(function(){if(window.__arf)return;window.__arf=1;var lt=0;"
    + "['touchstart','mousedown','pointerdown'].forEach(function(n){document.addEventListener(n,function(){lt=Date.now()},true)});"
    + "document.addEventListener('focusin',function(e){var t=e.target;if(!t||Date.now()-lt>1500)return;"
    + "var ed=t.isContentEditable||t.tagName==='TEXTAREA'||(t.tagName==='INPUT'&&!/^(button|checkbox|radio|submit|range|color|file|image|reset|hidden)$/i.test(t.type||'text'));"
    + "try{window.ArWeb&&ArWeb.focus(!!ed)}catch(x){}},true)})()";

  /** WebView que nunca abre o teclado do celular. */
  static final class QuietWebView extends WebView {
    QuietWebView(Context c) { super(c); }
    @Override public boolean onCheckIsTextEditor() { return false; }
    @Override public InputConnection onCreateInputConnection(EditorInfo o) { return null; }
  }

  private WebView newWeb(Context c, final Tab tab) {
    final WebView v = new QuietWebView(c);
    v.setBackgroundColor(menu ? Color.rgb(14, 16, 22) : Color.WHITE);
    if (kb) {
      v.addJavascriptInterface(new Object() {
        @JavascriptInterface public void key(String k) { ArPanel.this.act.kbKey(k); }
      }, "ArKb");
    } else if (menu) {
      v.addJavascriptInterface(new Object() {
        @JavascriptInterface public void act(String a) { ArPanel.this.act.menuAction(a); }
        @JavascriptInterface public String state() { return ArPanel.this.act.menuState(); }
        @JavascriptInterface public String page() { return ArPanel.this.act.menuPage; }
        @JavascriptInterface public String spState() { return ArPanel.this.act.space.stateJson(); }
        @JavascriptInterface public String spLib() { return ArPanel.this.act.space.libJson(); }
        @JavascriptInterface public String spCat() { return ArPanel.this.act.space.catJson; }
      }, "ArMenu");
    } else {
      // avisa quando um campo de texto da pagina ganha o foco, para abrir o teclado virtual
      v.addJavascriptInterface(new Object() {
        @JavascriptInterface public void focus(boolean editable) {
          if (editable && cur < tabs.size() && tabs.get(cur) == tab) ArPanel.this.act.pageFocus(ArPanel.this);
        }
      }, "ArWeb");
    }
    WebSettings s = v.getSettings();
    s.setJavaScriptEnabled(true);
    s.setDomStorageEnabled(true);
    s.setMediaPlaybackRequiresUserGesture(false);
    CookieManager.getInstance().setAcceptThirdPartyCookies(v, true);
    v.setWebViewClient(new WebViewClient() {
      /** Miniaturas da biblioteca (/spatial/ID_t.jpg) para a pagina do menu. */
      @Override public WebResourceResponse shouldInterceptRequest(WebView view, WebResourceRequest r) {
        if (menu) {
          android.net.Uri u = r.getUrl();
          String path = u == null ? null : u.getPath();
          if (u != null && "vrlauncher.local".equals(u.getHost()) && path != null && path.startsWith("/spatial/")) {
            InputStream in = ArPanel.this.act.space.thumb(path.substring(9));
            if (in != null) return new WebResourceResponse("image/jpeg", null, in);
          }
        }
        return null;
      }
      @Override public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest r) {
        String u = r.getUrl().toString();
        return !(u.startsWith("http:") || u.startsWith("https:") || u.startsWith("about:") || u.startsWith("blob:") || u.startsWith("data:"));
      }
      @Override public void onPageFinished(WebView view, String u) {
        if (!menu) view.evaluateJavascript(FOCUS_JS, null);
        if (u != null && u.startsWith("http")) tab.url = u;
        publish();
      }
      @Override public void doUpdateVisitedHistory(WebView view, String u, boolean reload) {
        if (u != null && u.startsWith("http")) tab.url = u;
        publish();
      }
    });
    v.setWebChromeClient(new WebChromeClient() {
      @Override public void onReceivedTitle(WebView view, String title) {
        tab.title = title == null ? "" : title;
        publish();
      }
    });
    return v;
  }
}
EOF
cat > app/src/main/java/com/vr/launcher/ArOverlay.java <<'EOF'
package com.vr.launcher;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.view.View;

/**
 * Painel de texto de depuracao (canto superior esquerdo). A mao e o cursor sao desenhados dentro do GL,
 * sem camada extra, para nao somar atraso nem disputar a thread principal com o WebView.
 */
final class ArOverlay extends View {

  private volatile String[] lines = new String[0];
  private final Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG);
  private final float d;

  ArOverlay(Context c) {
    super(c);
    setWillNotDraw(false);
    setClickable(false);
    d = c.getResources().getDisplayMetrics().density;
  }

  void update(String[] l) {
    lines = l;
    postInvalidate();
  }

  @Override protected void onDraw(Canvas canvas) {
    String[] ln = lines;
    if (ln == null) return;
    paint.setStyle(Paint.Style.FILL);
    paint.setColor(Color.WHITE);
    paint.setTextSize(11f * d);
    paint.setShadowLayer(3f * d, 0f, 0f, Color.BLACK);
    float y = 18f * d;
    for (String t : ln) {
      if (t == null || t.length() == 0) continue;
      canvas.drawText(t, 10f * d, y, paint);
      y += 15f * d;
    }
    paint.clearShadowLayer();
  }
}
EOF
cat > app/src/main/java/com/vr/launcher/ArRenderer.java <<'EOF'
package com.vr.launcher;

import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.RectF;
import android.graphics.SurfaceTexture;
import android.graphics.Typeface;
import android.media.Image;
import android.opengl.GLES11Ext;
import android.opengl.GLES20;
import android.opengl.GLSurfaceView;
import android.opengl.GLUtils;
import android.opengl.Matrix;
import android.os.SystemClock;
import android.util.Size;
import android.view.MotionEvent;
import android.view.Surface;
import com.google.ar.core.Anchor;
import com.google.ar.core.Camera;
import com.google.ar.core.CameraConfig;
import com.google.ar.core.Coordinates2d;
import com.google.ar.core.Frame;
import com.google.ar.core.Pose;
import com.google.ar.core.Session;
import com.google.ar.core.TrackingState;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.io.File;
import java.util.ArrayList;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.CopyOnWriteArrayList;
import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

/**
 * Desenha o fundo da camera (ARCore) e as janelas ancoradas no mundo, e trata a mao:
 * pinca no corpo da janela = toque, na barra = mover, no canto = redimensionar, na barra de cima = navegador,
 * no "+" = nova janela. Punho fechado por 1 s sobre uma janela = fechar.
 */
final class ArRenderer implements GLSurfaceView.Renderer {

  // janela base (16:9) em metros; a escala s multiplica tudo
  static final float HW = 0.32f, HH = 0.18f, CORNER_R = 0.022f;
  // barra de mover (pilula branca embaixo da janela) e alca de redimensionar (canto inferior direito)
  static final float BAR_CY = -(HH + 0.028f), BAR_W = 0.20f, BAR_H = 0.014f, BAR_HIT_X = 0.16f, BAR_HIT_Y = 0.032f;
  static final float CS = 0.05f, CSX = HW - 0.013f, CSY = -HH + 0.013f, CS_HIT = 0.045f;
  // botao "+" (nova janela), ao lado da barra
  static final float PLUS_X = 0.225f, PLUS_S = 0.045f, PLUS_HIT = 0.028f;
  // barra do navegador, acima da janela
  static final float CH_GAP = 0.012f, CH_W = 2f * HW * 0.8f, CH_H = CH_W * ArChrome.DH / ArChrome.DW;
  static final float CHROME_Z = 0.004f;
  static final int MAX_WINS = 3;

  static final int R_NONE = 0, R_BODY = 1, R_BAR = 2, R_CORNER = 3, R_CHROME = 4, R_PLUS = 5, R_CURVE = 6, R_ICON = 7, R_KEY = 8, R_LINK = 9, R_BUBBLE = 10;
  // grupos: janelas lado a lado num arco de raio GRP_R em volta de quem usa
  static final float GGAP = 0.012f, GRP_R = 1.2f, BUB = 0.1f;
  // tela curva: meio angulo da curvatura (rad) e raio (arco = largura da janela)
  static final float CURVE_TH = 0.30f, RN = HW / CURVE_TH;
  static final int CN = 28;
  // menu 3D: trilho vertical de icones (so icones) com a aba ao lado direito
  static final int RAIL_N = 5;
  // RAIL_TOP: espaco do relogio no topo; o relogio tem a mesma largura dos icones
  static final float RAIL_P = 0.064f, RAIL_IC = 0.05f, RAIL_HALF = 0.04f, RAIL_DIST = 0.9f, RAIL_TOP = 0.05f, RAIL_H = RAIL_TOP + RAIL_N * RAIL_P;
  static final float CLOCK_W = RAIL_IC, CLOCK_H = 0.03f;
  // home, centralizar, espacial, apps, configuracoes (indices de makeGlyph)
  static final int[] RAIL_GLYPH = {0, 1, 3, 4, 5};
  static final String[] VIEW_NAMES = {"preenchida (corta)", "meio-termo", "inteira (faixas)", "esticada (tela cheia)"};
  // pinca: liga com as pontas coladas, so solta quando abre de verdade
  static final float PINCH_ON = 0.16f, PINCH_OFF = 0.26f;
  static final float S_MIN = 0.4f, S_MAX = 3f;
  static final long FIST_MS = 1000;
  // mover/redimensionar so comeca depois de segurar a pinca na barra/canto por um instante (evita arrasto acidental)
  static final long DWELL_MS = 220;
  // espera antes de criar a primeira janela, para o ARCore firmar a escala do mundo
  static final long SPAWN_WAIT_MS = 2500;
  private static final int[][] CONN = {
    {0, 1}, {1, 2}, {2, 3}, {3, 4}, {0, 5}, {5, 6}, {6, 7}, {7, 8}, {5, 9}, {9, 10}, {10, 11}, {11, 12},
    {9, 13}, {13, 14}, {14, 15}, {15, 16}, {13, 17}, {17, 18}, {18, 19}, {19, 20}, {0, 17}
  };

  /** Grupo de janelas coladas lado a lado (esquerda -> direita); g = moldura do grupo. */
  private static final class Grp {
    final ArrayList<Win> m = new ArrayList<Win>();
    Pose g;
  }

  private static final class Win {
    Pose pose; Anchor anchor; float s = 1f; final ArPanel panel;
    Grp group = null;
    boolean kb = false;        // teclado virtual (segue a janela dona)
    boolean min = false;       // minimizada: so aparece a bolha
    boolean hold = false;      // sendo movida/redimensionada: nao refaz a ancora
    boolean editing = false, urlSel = false;   // enderecos em edicao
    String urlBuf = "";
    long lockUntil = 0;        // bloqueada para interacao (alvo de agrupamento)
    int chromeSig = 0, bubTex = 0;
    boolean curved = false;   // tela curva (so as laterais, na horizontal)
    boolean hidden = false;   // aba do menu fechada
    boolean linked = false;   // aba do menu: segue o trilho
    boolean rail = false;     // o proprio trilho de icones (sem painel)
    boolean tabsOpen = false, chromeOpen = false;   // fileira de abas acima da barra do navegador
    final boolean menu;   // janela do menu 3D: sem barra de navegador, sem "+" nem curva, nao fecha
    int chromeTex = 0, chromeVer = -1;
    Bitmap chromeBmp;
    Win(Pose pose, Anchor anchor, ArPanel panel, boolean menu) { this.pose = pose; this.anchor = anchor; this.panel = panel; this.menu = menu; }
    Pose current() {
      Anchor a = anchor;
      return (a != null && a.getTrackingState() != TrackingState.STOPPED) ? a.getPose() : pose;
    }
  }

  private static final class Hit {
    final Win win; final float t, lx, ly; final int region, elem;
    Hit(Win win, float t, float lx, float ly, int region, int elem) {
      this.win = win; this.t = t; this.lx = lx; this.ly = ly; this.region = region; this.elem = elem;
    }
  }

  private final ArActivity act;
  private final ArHand tracker;

  volatile Session session;
  volatile ArOverlay overlay;
  volatile String focusText = "";
  volatile ArImu imu;
  volatile boolean hybridOn = true;       // 6DoF -> 3DoF quando o ARCore perde o rastreio
  volatile boolean stereo = false;        // tela dividida (um desenho por olho) para o oculos VR Box
  volatile int viewMode = 1;              // 0 preenchida (corta), 1 meio-termo, 2 inteira (faixas), 3 esticada (tela cheia)
  private volatile boolean vpDirty = true;
  volatile boolean viewportChanged = true;
  private volatile boolean recenterReq = false;
  private volatile int handRot = 90;

  // area de desenho: com a imagem inteira da camera ela pode ficar menor que a tela (faixas pretas)
  private int sw = 0, sh = 0, vpX = 0, vpY = 0, vpW = 0, vpH = 0;
  private float imgAspect = 0f;
  private static final float IPD = 0.064f;   // distancia entre os olhos virtuais (m)
  private final float[] eyeT = new float[16], eyeV = new float[16], vpMono = new float[16];
  private float cursorDepth = 1.5f, pxShift = 0f;
  private int vw = 0, vh = 0;
  private boolean camTexSet = false;
  private long lastFedTs = 0;
  private String glError = "";
  private String errorText = "";

  // camera de fundo
  private int camTex = 0, bgProg = 0, bgPosLoc = 0, bgUvLoc = 0, bgTexLoc = 0;
  private final FloatBuffer bgQuad = floatBuf(new float[]{-1f, -1f, 1f, -1f, -1f, 1f, 1f, 1f});
  private final FloatBuffer bgUv = floatBuf(new float[8]);

  // janelas
  private int winProg = 0, winPosLoc = 0, winUvLoc = 0, winMvpLoc = 0, winTexLoc = 0, winStmLoc = 0, winHalfLoc = 0, winRadLoc = 0, winFlatLoc = 0, winSLoc = 0, winDimLoc = 0;
  private final FloatBuffer winVerts = floatBuf(new float[]{-HW, -HH, 0f, HW, -HH, 0f, -HW, HH, 0f, HW, HH, 0f});
  private final FloatBuffer winUvs = floatBuf(new float[]{0f, 0f, 1f, 0f, 0f, 1f, 1f, 1f});

  // barra, alca, "+", destaque
  private int flatProg = 0, flatPosLoc = 0, flatUvLoc = 0, flatMvpLoc = 0, flatTexLoc = 0, flatColLoc = 0;
  private int barTex = 0, cornerTex = 0, roundTex = 0, discTex = 0, ringTex = 0;
  private final FloatBuffer unitVerts = floatBuf(new float[]{-0.5f, -0.5f, 0f, 0.5f, -0.5f, 0f, -0.5f, 0.5f, 0f, 0.5f, 0.5f, 0f});
  private final FloatBuffer unitUvs = floatBuf(new float[]{0f, 1f, 1f, 1f, 0f, 0f, 1f, 0f});

  private final float[] view = new float[16], proj = new float[16], vp = new float[16], invVp = new float[16];
  private final float[] model = new float[16], tmp = new float[16], mvp = new float[16];

  private final ArrayList<Win> wins = new ArrayList<Win>();
  private final CopyOnWriteArrayList<ArPanel> panels = new CopyOnWriteArrayList<ArPanel>();
  private boolean needSpawn = true;
  private final ArFuse fuse = new ArFuse();
  private boolean hybridActive = false, anchorLost = false;
  private float[] lastPos = null;
  private final float[] frozenPos = new float[3];
  private long blendT0 = 0;
  private final float[] rAr = new float[9], rG = new float[9], rF = new float[9], rB = new float[9];
  private final float[] qF = new float[4], qA = new float[4], qB = new float[4];
  private long trackOkSince = 0;
  private final float[] camP = new float[3];
  private final float dp;

  // rastreio do ARCore
  private boolean tracking = false, dim = false;
  private long lostSince = 0, lastLostMs = 0;
  private int lostCount = 0;
  private String lastReason = "-";
  private String trackText = "";
  private String camInfo = "";
  volatile String camCfgText = "";
  private Win lastActive = null;
  volatile java.util.List<String> initWins = null;   // janelas/abas do modo original
  private Pose lastCamPose = null;

  // teclado virtual, agrupar, minimizar
  private Win kbWin = null, kbOwner = null, dropT = null, lastTapWin = null;
  private int dropSide = 0;
  private long lastTapMs = 0;
  private Pose dragInv = null;
  private int winShadeLoc = 0, keyGlyph = 0, linkGlyph = 0;
  // controles do video 360 (abrem com pinca segurada 1 s no vazio, so dentro de um video)
  private Win vctlWin = null;
  private long holdStart = 0;
  private float holdX = 0f, holdY = 0f, holdProg = 0f;
  private boolean holdLatch = false;

  // espacial 360: panorama (imagem ou video) no lugar da camera, fixo no mundo, com fade
  private int spTex = 0, spProg = 0, spKind = 0;   // spKind: 1 imagem, 2 video
  private boolean spOes = false, spWant = false;
  private int spPosLoc = 0, spProjLoc = 0, spRotLoc = 0, spYawLoc = 0, spTexLoc = 0, spStmLoc = 0, spAlphaLoc = 0;
  private float spAlpha = 0f, spYaw = 0f;
  private SurfaceTexture spSt = null;
  private Surface spSurf = null;
  private final AtomicBoolean spAvail = new AtomicBoolean(false);
  private final float[] spStm = new float[16], invProj = new float[16], rot3 = new float[9];
  private final FloatBuffer spQuad = floatBuf(new float[]{-1f, -1f, 1f, -1f, -1f, 1f, 1f, 1f});
  private long spLastMs = 0;

  // menu 3D
  private Win railWin = null, tabWin = null;
  private boolean menuOpen = false;
  private float menuReveal = 0f;
  private int menuTab = -1;
  private final int[] icoTex = new int[RAIL_N];
  private int curveGlyph = 0, clockTex = 0;
  private Bitmap clockBmp = null;
  private long clockSlot = -1;
  private long lastPeaceMs = 0;
  // gesto de dois dedos descendo (abre / fecha / traz o menu)
  private boolean peace = false, swActive = false, swDone = false;
  private int peaceN = 0, swMode = 0;
  private float swProg = 0f, swY0 = 0f;
  private long swT = 0;

  // malhas curvas
  private final FloatBuffer curveVerts = floatBuf(curveMesh(true)), curveUvs = floatBuf(curveMesh(false));
  private final float[] dynV = new float[150], dynU = new float[100];
  private final FloatBuffer dynVerts = floatBuf(new float[150]), dynUvs = floatBuf(new float[100]);
  private boolean bend = false, dynBound = false;
  private int winHalfVLoc = 0;

  // fps
  private long fpsT0 = 0, arTs = 0;
  private int glN = 0, arN = 0;
  private float glFps = 0f, arFps = 0f;

  // mao e cursor (coordenadas de tela)
  private long lastSeq = 0, tDet = 0, seenMs = 0, lastFrameMs = 0;
  private float frameDt = 0.016f;
  private final float[] viewPts = new float[42];
  private boolean viewValid = false;
  private float[] skel = null;
  private final ArHand.OneEuro fX = new ArHand.OneEuro(1.5f, 0.02f, 1f), fY = new ArHand.OneEuro(1.5f, 0.02f, 1f);
  private boolean firstSample = true;
  private float cx = 0f, cy = 0f;
  private float ratio = 1f, sizeS = 0.1f;
  private float pfx = 0f, pfy = 0f, vxc = 0f, vyc = 0f;
  private long prevDetMs = 0;
  private float handAgeMs = 0f;
  private int sizeOut = 0, handN = 0;
  private boolean pinch = false, handFist = false;
  private int pinchN = 0, fistN = 0;
  private boolean pinchWasOn = false;

  private int hoverRegion = R_NONE, hoverElem = 0, regElem = 0;
  private Win hoverWin = null;

  // arrastos em andamento
  private Win dragWin = null, sizeWin = null, touchWin = null;
  private float grabDist = 1f, grabSize = 0.1f, grabLx = 0f, grabLy = 0f, distS = 1f;
  private float sizeS0 = 1f, sizeD0 = 0.1f;
  private float lastPx = -1f, lastPy = -1f;
  private final float[] pl = new float[3];
  private long lastClick = 0;
  private Hit pend = null;
  private long pendSince = 0;

  // punho para fechar
  private Win fistWin = null;
  private long fistStart = 0, fistHitMs = 0;
  private float fistProg = 0f;
  private boolean fistLatched = false;

  private String message = "";
  private long messageUntil = 0, lastHud = 0;
  private String[] hudLines = new String[0];

  ArRenderer(ArActivity act, ArHand tracker) {
    this.act = act; this.tracker = tracker;
    this.dp = act.getResources().getDisplayMetrics().density;
  }

  void recenter() { recenterReq = true; }

  /** A camera (configuracao) mudou: relê tamanho da textura e refaz a area de desenho. */
  void onCameraChanged() {
    camInfo = "";
    vpDirty = true;
    viewportChanged = true;
  }

  /** Plano B de depuracao: troca o modo de todos os paineis (tela virtual / software). */
  void toggleMode() {
    act.queueGl(new Runnable() {
      @Override public void run() {
        int m = ArPanel.defaultMode == ArPanel.VD ? ArPanel.SW : ArPanel.VD;
        ArPanel.defaultMode = m;
        for (ArPanel p : panels) { p.mode = m; p.newSurface(); }
        say(m == ArPanel.VD ? "Painel: tela virtual" : "Painel: software");
      }
    });
  }

  /** Chamado pela activity ao fechar. */
  void shutdown() {
    for (ArPanel p : panels) p.destroy();
  }

  // =============================================================
  // Ciclo GL
  // =============================================================

  @Override public void onSurfaceCreated(GL10 gl, EGLConfig config) {
    GLES20.glClearColor(0f, 0f, 0f, 1f);

    int[] t = new int[1];
    GLES20.glGenTextures(1, t, 0);
    camTex = t[0];
    GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, camTex);
    GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE);
    GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE);
    GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR);
    GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR);
    camTexSet = false;

    // contexto GL novo: o panorama antigo se perdeu
    spTex = 0; spProg = 0; spKind = 0; spWant = false; spAlpha = 0f;
    if (spSurf != null) { try { spSurf.release(); } catch (Throwable e) { } spSurf = null; }
    if (spSt != null) { try { spSt.release(); } catch (Throwable e) { } spSt = null; }
    act.space.left();

    glError = "";
    bgProg = program(BG_VS, BG_FS);
    bgPosLoc = GLES20.glGetAttribLocation(bgProg, "a_Position");
    bgUvLoc = GLES20.glGetAttribLocation(bgProg, "a_TexCoord");
    bgTexLoc = GLES20.glGetUniformLocation(bgProg, "u_Texture");

    winProg = program(WIN_VS, WIN_FS);
    winPosLoc = GLES20.glGetAttribLocation(winProg, "a_Pos");
    winUvLoc = GLES20.glGetAttribLocation(winProg, "a_Uv");
    winMvpLoc = GLES20.glGetUniformLocation(winProg, "u_Mvp");
    winTexLoc = GLES20.glGetUniformLocation(winProg, "u_Tex");
    winStmLoc = GLES20.glGetUniformLocation(winProg, "u_Stm");
    winHalfLoc = GLES20.glGetUniformLocation(winProg, "u_Half");
    winRadLoc = GLES20.glGetUniformLocation(winProg, "u_R");
    winFlatLoc = GLES20.glGetUniformLocation(winProg, "u_Flat");
    winSLoc = GLES20.glGetUniformLocation(winProg, "u_S");
    winDimLoc = GLES20.glGetUniformLocation(winProg, "u_Dim");
    winHalfVLoc = GLES20.glGetUniformLocation(winProg, "u_HalfV");
    winShadeLoc = GLES20.glGetUniformLocation(winProg, "u_Shade");

    flatProg = program(FLAT_VS, FLAT_FS);
    flatPosLoc = GLES20.glGetAttribLocation(flatProg, "a_Pos");
    flatUvLoc = GLES20.glGetAttribLocation(flatProg, "a_Uv");
    flatMvpLoc = GLES20.glGetUniformLocation(flatProg, "u_Mvp");
    flatTexLoc = GLES20.glGetUniformLocation(flatProg, "u_Tex");
    flatColLoc = GLES20.glGetUniformLocation(flatProg, "u_Col");

    barTex = bitmapTex(makeBar());
    cornerTex = bitmapTex(makeCorner());
    roundTex = bitmapTex(makeRound());
    discTex = bitmapTex(makeDisc());
    ringTex = bitmapTex(makeRing());
    curveGlyph = bitmapTex(makeGlyph(7));
    keyGlyph = bitmapTex(makeGlyph(8));
    linkGlyph = bitmapTex(makeGlyph(9));
    for (int k = 0; k < RAIL_N; k++) icoTex[k] = bitmapTex(makeGlyph(RAIL_GLYPH[k]));
    clockBmp = Bitmap.createBitmap(200, 120, Bitmap.Config.ARGB_8888);
    clockTex = emptyTex2d();
    clockSlot = -1;

    // contexto GL novo (raro): refaz as texturas das janelas que ja existiam
    for (Win w : wins) {
      w.panel.glInit();
      w.chromeTex = emptyTex2d();
      w.chromeVer = -1;
    }
  }

  @Override public void onSurfaceChanged(GL10 gl, int width, int height) {
    sw = width;
    sh = height;
    vpDirty = true;
  }

  /** Define a area de desenho conforme o modo de imagem (cortada, meio-termo, inteira com faixas ou esticada). */
  private void updateViewport() {
    if (sw <= 0 || sh <= 0) return;
    int mode = viewMode;
    final int cw = stereo ? sw / 2 : sw;   // largura da area de um olho
    if (cw <= 0) return;
    if (mode == 0 || imgAspect <= 0f) {
      vpX = 0; vpY = 0; vpW = cw; vpH = sh; vw = cw; vh = sh;
    } else {
      float ia = cw >= sh ? imgAspect : 1f / imgAspect;   // proporcao da imagem da camera na orientacao da tela
      float sa = (float) cw / sh;
      float a = mode == 1 ? (float) Math.sqrt(ia * sa) : ia;
      int fw, fh;
      if (sa > a) { fh = sh; fw = Math.round(sh * a); }
      else { fw = cw; fh = Math.round(cw / a); }
      if (mode == 3) {
        // imagem inteira esticada ate encher a tela: o ARCore enxerga a proporcao da camera, so o desenho e esticado
        vpX = 0; vpY = 0; vpW = cw; vpH = sh;
        vh = sh; vw = Math.round(sh * ia);
      } else {
        vpW = fw; vpH = fh; vw = fw; vh = fh;
        vpX = (cw - fw) / 2;
        vpY = (sh - fh) / 2;
      }
    }
    viewportChanged = true;
  }

  void toggleView() {
    viewMode = (viewMode + 1) % 4;
    vpDirty = true;
    say("Imagem: " + VIEW_NAMES[viewMode]);
  }

  /** Liga/desliga a tela dividida (VR Box): a area de desenho passa a ser metade da tela, uma vez por olho. */
  void setStereo(boolean on) {
    stereo = on;
    vpDirty = true;
    viewportChanged = true;
    say(on ? "Estereo ligado" : "Estereo desligado");
  }

  void toggleStereo() { setStereo(!stereo); }

  void toggleHybrid() {
    hybridOn = !hybridOn;
    say(hybridOn ? "Modo hibrido ligado (giroscopio)" : "Modo hibrido desligado");
  }

  @Override public void onDrawFrame(GL10 gl) {
    GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT | GLES20.GL_DEPTH_BUFFER_BIT);
    if (vpDirty) { vpDirty = false; updateViewport(); }
    GLES20.glViewport(vpX, vpY, vpW, vpH);
    Session s = session;
    if (s == null) return;
    long nowMs = SystemClock.uptimeMillis();
    countFps(nowMs);

    try {
      if (!camTexSet) {
        s.setCameraTextureName(camTex);
        camTexSet = true;
      }
      if (viewportChanged && vw > 0 && vh > 0) {
        s.setDisplayGeometry(act.displayRotation(), vw, vh);
        viewportChanged = false;
      }

      for (Win w : wins) w.panel.update();

      Frame frame = s.update();
      Camera camera = frame.getCamera();
      long fts = frame.getTimestamp();
      if (fts != arTs) { arTs = fts; arN++; }

      if (frame.hasDisplayGeometryChanged()) {
        bgQuad.position(0);
        bgUv.position(0);
        frame.transformCoordinates2d(Coordinates2d.OPENGL_NORMALIZED_DEVICE_COORDINATES, bgQuad, Coordinates2d.TEXTURE_NORMALIZED, bgUv);
        bgQuad.position(0);
        bgUv.position(0);
        probeRotation(frame);
      }

      updateSpace(nowMs);

      camera.getProjectionMatrix(proj, 0, 0.1f, 30f);
      trackStats(camera, nowMs);
      Pose camPose = resolveCamera(s, camera, nowMs);   // preenche "view": ARCore ou, sem rastreio, giroscopio
      Matrix.multiplyMM(vp, 0, proj, 0, view, 0);
      Matrix.invertM(invVp, 0, vp, 0);
      if (camInfo.length() == 0) readCamInfo(s, camera);

      lastCamPose = camPose;
      if (recenterReq) {
        recenterReq = false;
        if (spKind != 0) spYaw = heading(camPose) - (float) Math.PI;
        if (!needSpawn && tracking) centerAll(s, camPose);
      }
      float[] ct = camPose.getTranslation();
      camP[0] = ct[0]; camP[1] = ct[1]; camP[2] = ct[2];
      if (tracking) { if (trackOkSince == 0) trackOkSince = nowMs; } else trackOkSince = 0;
      if (needSpawn && tracking && nowMs - trackOkSince >= SPAWN_WAIT_MS) {
        createInitialLayout(s, camPose);
        needSpawn = false;
      }
      maintainAnchors(s);

      if (!dim) feedTracker(frame);
      updateInteraction(s, frame, ct);
      animateMenu(frameDt);
      placeTab();
      placeKb();

      drawEyes();
      errorText = "";
    } catch (Throwable e) {
      errorText = e.toString();
    }
    publishOverlay();
  }

  /** Desenha a cena uma vez (tela normal) ou duas (estereo: olho esquerdo e direito, lado a lado). */
  private void drawEyes() {
    final boolean st = stereo;
    final int cw = st ? sw / 2 : sw;
    final float[] mono = vpMono;
    if (st) System.arraycopy(vp, 0, mono, 0, 16);
    final int eyes = st ? 2 : 1;
    for (int e = 0; e < eyes; e++) {
      GLES20.glViewport(vpX + e * cw, vpY, vpW, vpH);
      if (st) {
        // olho esquerdo: a camera anda meia distancia interpupilar para a esquerda (o mundo desloca para a direita)
        Matrix.setIdentityM(eyeT, 0);
        eyeT[12] = e == 0 ? IPD * 0.5f : -IPD * 0.5f;
        Matrix.multiplyMM(eyeV, 0, eyeT, 0, view, 0);
        Matrix.multiplyMM(vp, 0, proj, 0, eyeV, 0);
      }
      if (spKind == 0 || spAlpha < 0.99f) drawBackground();
      drawSpace();
      pxShift = st ? (e == 0 ? 1f : -1f) * IPD * 0.5f * proj[0] * (vw * 0.5f) / Math.max(0.3f, cursorDepth) : 0f;
      drawWindows();
      drawHand();
      pxShift = 0f;
    }
    if (st) System.arraycopy(mono, 0, vp, 0, 16);
  }

  private void countFps(long now) {
    glN++;
    if (fpsT0 == 0) fpsT0 = now;
    if (now - fpsT0 >= 1000) {
      float k = 1000f / (now - fpsT0);
      glFps = glN * k;
      arFps = arN * k;
      glN = 0; arN = 0; fpsT0 = now;
    }
  }

  /** Controla se o ARCore esta rastreando. Sem rastreio a imagem das janelas escurece e a mao nao pega nada. */
  private void trackStats(Camera camera, long now) {
    tracking = camera.getTrackingState() == TrackingState.TRACKING;
    if (tracking) {
      if (lostSince != 0) { lastLostMs = now - lostSince; lostSince = 0; }
      trackText = "rastreando";
    } else {
      if (lostSince == 0) { lostSince = now; lostCount++; }
      lastReason = String.valueOf(camera.getTrackingFailureReason());
      trackText = "SEM RASTREIO (" + lastReason + ")";
    }
  }

  private static void poseToMat(Pose p, float[] m) {
    float[] x = p.getXAxis(), y = p.getYAxis(), z = p.getZAxis();
    m[0] = x[0]; m[1] = y[0]; m[2] = z[0];
    m[3] = x[1]; m[4] = y[1]; m[5] = z[1];
    m[6] = x[2]; m[7] = y[2]; m[8] = z[2];
  }

  /** view = inverso da pose da camera (posicao p, rotacao r camera->mundo). */
  private void buildView(float[] p, float[] r, float[] out) {
    for (int c = 0; c < 3; c++) {
      for (int rr = 0; rr < 3; rr++) out[c * 4 + rr] = r[3 * c + rr];
      out[c * 4 + 3] = 0f;
    }
    for (int rr = 0; rr < 3; rr++) out[12 + rr] = -(r[rr] * p[0] + r[3 + rr] * p[1] + r[6 + rr] * p[2]);
    out[15] = 1f;
  }

  /**
   * Decide de onde vem a camera virtual. Com rastreio: ARCore (6DoF), e o giroscopio e calibrado em paralelo.
   * Sem rastreio: a posicao fica onde estava e a orientacao segue o giroscopio (3DoF), em vez de congelar a tela.
   * Ao voltar o rastreio, a transicao e suavizada; se o ARCore reiniciou o mundo, as janelas sao re-ancoradas.
   */
  private Pose resolveCamera(Session s, Camera camera, long now) {
    Pose ar = camera.getDisplayOrientedPose();
    ArImu im = imu;
    boolean imuOk = im != null && im.get(rG);
    poseToMat(ar, rAr);

    if (tracking) {
      if (imuOk && hybridOn) fuse.feed(rAr, rG);
      if (hybridActive) {
        hybridActive = false;
        boolean reset = anchorLost;
        anchorLost = false;
        if (imuOk && fuse.usable() && lastPos != null) {
          if (reset) {
            // o ARCore comecou um mundo novo: leva as janelas para ele mantendo a posicao relativa a camera
            fuse.fused(rG, rF);
            ArFuse.quatFromMat(rF, qF);
            Pose pf = new Pose(lastPos, qF);
            Pose conv = ar.compose(pf.inverse());
            for (Win w : wins) w.pose = conv.compose(w.pose);
            if (railWin != null) railWin.pose = conv.compose(railWin.pose);
            say("Rastreio refeito: janelas reposicionadas");
          } else {
            System.arraycopy(lastPos, 0, frozenPos, 0, 3);
            blendT0 = now;
          }
        }
      }
      if (!hybridActive) anchorLost = false;   // ancora derrubada com o rastreio normal nao e "mundo novo"
      float[] t = ar.getTranslation();
      if (lastPos == null) lastPos = new float[3];
      lastPos[0] = t[0]; lastPos[1] = t[1]; lastPos[2] = t[2];
    } else if (hybridOn && imuOk && fuse.usable() && lastPos != null && lostSince != 0) {
      hybridActive = true;
    }
    if (!hybridOn) hybridActive = false;
    dim = !tracking && !hybridActive && lostSince != 0 && now - lostSince > 300;

    if (hybridActive && imuOk && fuse.fused(rG, rF)) {
      buildView(lastPos, rF, view);
      ArFuse.quatFromMat(rF, qF);
      return new Pose(lastPos, qF);
    }
    if (blendT0 != 0) {
      float k = (now - blendT0) / 400f;
      if (k >= 1f || !imuOk || !fuse.fused(rG, rF)) {
        blendT0 = 0;
      } else {
        float[] t = ar.getTranslation();
        float[] pos = {frozenPos[0] + (t[0] - frozenPos[0]) * k, frozenPos[1] + (t[1] - frozenPos[1]) * k, frozenPos[2] + (t[2] - frozenPos[2]) * k};
        ArFuse.quatFromMat(rF, qF);
        ArFuse.quatFromMat(rAr, qA);
        ArFuse.nlerp(qF, qA, k, qB);
        ArFuse.matFromQuat(qB, rB);
        buildView(pos, rB, view);
        return new Pose(pos, qB);
      }
    }
    camera.getViewMatrix(view, 0);
    return ar;
  }

  private void readCamInfo(Session s, Camera camera) {
    try {
      CameraConfig cc = s.getCameraConfig();
      Size t = cc.getTextureSize();
      Size im = cc.getImageSize();
      camInfo = "cam: textura " + t.getWidth() + "x" + t.getHeight() + "  imagem " + im.getWidth() + "x" + im.getHeight() + camCfgText;
      try {
        float[] fl = camera.getImageIntrinsics().getFocalLength();
        int[] dm = camera.getImageIntrinsics().getImageDimensions();
        float fh = (float) Math.toDegrees(2.0 * Math.atan(dm[0] / (2.0 * fl[0])));
        float fv = (float) Math.toDegrees(2.0 * Math.atan(dm[1] / (2.0 * fl[1])));
        camInfo += "  fov " + Math.round(fh) + "x" + Math.round(fv);
      } catch (Throwable e2) { }
      float lo = Math.min(t.getWidth(), t.getHeight());
      if (lo > 0f) { imgAspect = Math.max(t.getWidth(), t.getHeight()) / lo; vpDirty = true; }
    } catch (Throwable e) {
      camInfo = "cam: ?";
    }
  }

  /** Descobre como girar a imagem da camera para ficar "em pe" na tela atual (0, 90, 180 ou 270). */
  private void probeRotation(Frame frame) {
    float[] in = {0f, 0f, 1f, 0f, 0f, 1f};
    float[] out = new float[6];
    frame.transformCoordinates2d(Coordinates2d.IMAGE_NORMALIZED, in, Coordinates2d.VIEW, out);
    float ex = out[2] - out[0], ey = out[3] - out[1];   // para onde aponta o eixo x da imagem na tela
    int r;
    if (Math.abs(ex) >= Math.abs(ey)) r = ex >= 0f ? 0 : 180;
    else r = ey >= 0f ? 90 : 270;
    handRot = r;
  }

  private void feedTracker(Frame frame) {
    long ts = frame.getTimestamp();
    if (ts == lastFedTs || !tracker.wants()) return;
    try {
      Image img = frame.acquireCameraImage();
      try {
        if (tracker.submit(img, handRot)) lastFedTs = ts;
      } finally {
        img.close();
      }
    } catch (Exception e) {
      // imagem ainda indisponivel
    }
  }

  // =============================================================
  // Janelas
  // =============================================================

  private ArPanel newPanel(String url, boolean menu) {
    ArPanel p = new ArPanel(act, ArActivity.PW, ArActivity.PH, ArActivity.DPI, url, menu);
    p.glInit();
    panels.add(p);
    return p;
  }

  private ArPanel newPanelTabs(String[] urls, int cur) {
    ArPanel p = new ArPanel(act, ArActivity.PW, ArActivity.PH, ArActivity.DPI, urls, cur);
    p.glInit();
    panels.add(p);
    return p;
  }

  private Win addWindow(Session s, Pose pose, String url, boolean menu) {
    return addWindowP(s, pose, newPanel(url, menu), menu, true);
  }

  private Win addWindowP(Session s, Pose pose, ArPanel panel, boolean menu, boolean anchored) {
    Win w = new Win(pose, anchored ? anchorOf(s, pose) : null, panel, menu);
    if (!menu) {
      w.chromeBmp = Bitmap.createBitmap(ArChrome.BW, ArChrome.BH, Bitmap.Config.ARGB_8888);
      w.chromeTex = emptyTex2d();
    }
    wins.add(w);
    return w;
  }

  private int webCount() {
    int n = 0;
    for (Win w : wins) if (!w.menu) n++;
    return n;
  }

  private Win firstWeb() {
    for (Win w : wins) if (!w.menu) return w;
    return null;
  }

  private static Anchor anchorOf(Session s, Pose p) {
    try { return s.createAnchor(p); } catch (Throwable e) { return null; }
  }

  /** Direcao (rad, a partir de +z) para onde a camera olha no plano horizontal. */
  private static float heading(Pose cp) {
    float[] t = cp.getTranslation();
    float[] f = cp.transformPoint(new float[]{0f, 0f, -1f});
    float fx = f[0] - t[0], fz = f[2] - t[2];
    if (fx * fx + fz * fz < 1e-6f) return (float) Math.PI;
    return (float) Math.atan2(fx, fz);
  }

  private static Pose facing(float px, float py, float pz, float cx, float cz) {
    float yaw = (float) Math.atan2(cx - px, cz - pz);
    return new Pose(new float[]{px, py, pz}, new float[]{0f, (float) Math.sin(yaw / 2f), 0f, (float) Math.cos(yaw / 2f)});
  }

  /** Posicao da janela i de k, num arco a 1,2 m a frente, todas viradas para a camera. */
  private Pose arcPose(Pose cp, int i, int k) {
    float[] t = cp.getTranslation();
    float dist = 1.2f, step = (2f * HW + 0.06f) / dist;
    float a = heading(cp) - (i - (k - 1) / 2f) * step;
    return facing(t[0] + dist * (float) Math.sin(a), t[1], t[2] + dist * (float) Math.cos(a), t[0], t[2]);
  }

  /** Cria so o que estava aberto no modo original (nenhuma janela, se nao havia nenhuma) e o menu. */
  private void createInitialLayout(Session s, Pose cp) {
    java.util.List<String> L = initWins;
    int k = L == null ? 0 : Math.min(L.size(), MAX_WINS);
    for (int i = 0; i < k; i++) {
      try {
        String[] parts = L.get(i).split("\n");
        int cur = Integer.parseInt(parts[0].trim());
        String[] urls = new String[parts.length - 1];
        System.arraycopy(parts, 1, urls, 0, urls.length);
        if (urls.length == 0) continue;
        Win w = addWindowP(s, arcPose(cp, i, k), newPanelTabs(urls, cur), false, true);
        if (lastActive == null) lastActive = w;
      } catch (Throwable e) { }
    }
    initWins = null;
    railWin = new Win(cp, null, null, true);
    railWin.rail = true;
    float left = k > 0 ? (k - 1) / 2f * ((2f * HW + 0.06f) / 1.2f) + HW / 1.2f + 0.16f : 0.15f;
    placeRailBeside(s, cp, Math.min(0.42f, left));
    menuOpen = false;   // o menu so abre com o gesto
    menuReveal = 0f;
    ensureTab(s);
  }

  /** Cria (escondida) a janela da aba do menu, para abrir sem espera. */
  private void ensureTab(Session s) {
    if (tabWin != null || s == null || railWin == null) return;
    tabWin = addWindowP(s, railWin.current(), newPanel(ArActivity.MENU_URL, true), true, false);
    tabWin.linked = true;
    tabWin.s = 0.85f;
    tabWin.hidden = true;
  }

  /** Trilho a esquerda (off rad) da direcao em que a camera olha, com o topo um pouco acima do centro. */
  private void placeRailBeside(Session s, Pose cp, float off) {
    float[] t = cp.getTranslation();
    float a = heading(cp) + off;
    setRailPose(s, facing(t[0] + RAIL_DIST * (float) Math.sin(a), t[1] + RAIL_H / 2f, t[2] + RAIL_DIST * (float) Math.cos(a), t[0], t[2]));
  }

  /** Trilho com o topo no ponto onde o raio (mao ou olhar) cruza a distancia do menu. */
  private void placeRailAtRay(Session s, float[] cam, float[] dir) {
    setRailPose(s, facing(cam[0] + dir[0] * RAIL_DIST, cam[1] + dir[1] * RAIL_DIST, cam[2] + dir[2] * RAIL_DIST, cam[0], cam[2]));
  }

  private void setRailPose(Session s, Pose p) {
    if (railWin == null) return;
    if (railWin.anchor != null) { try { railWin.anchor.detach(); } catch (Throwable e) { } railWin.anchor = null; }
    railWin.pose = p;
    if (tracking) railWin.anchor = anchorOf(s, p);
  }

  /** Centralizar: traz janelas e menu para a frente, sem fechar nada. Grupos continuam juntos. */
  private void centerAll(Session s, Pose cp) {
    resetInteraction();
    ArrayList<ArrayList<Win>> units = new ArrayList<ArrayList<Win>>();
    ArrayList<Win> seen = new ArrayList<Win>();
    for (Win w : wins) {
      if (w.menu || seen.contains(w)) continue;
      ArrayList<Win> u = new ArrayList<Win>(unit(w));
      seen.addAll(u);
      units.add(u);
    }
    float[] span = new float[units.size()];
    float total = 0f;
    for (int i = 0; i < units.size(); i++) {
      ArrayList<Win> u = units.get(i);
      float sp = 0f;
      for (Win w : u) sp += 2f * (float) Math.atan(HW * w.s / GRP_R);
      sp += (u.size() - 1) * GGAP / GRP_R;
      span[i] = sp;
      total += sp;
    }
    float gapA = 0.06f / GRP_R;
    if (units.size() > 1) total += (units.size() - 1) * gapA;
    float[] t = cp.getTranslation();
    float h = heading(cp);
    float cum = 0f;
    for (int i = 0; i < units.size(); i++) {
      ArrayList<Win> u = units.get(i);
      float a = h + total / 2f - (cum + span[i] / 2f);
      cum += span[i] + gapA;
      Pose G = facing(t[0] + GRP_R * (float) Math.sin(a), t[1], t[2] + GRP_R * (float) Math.cos(a), t[0], t[2]);
      Win w0 = u.get(0);
      if (w0.group != null) {
        w0.group.g = G;
        layoutGroup(w0.group, G);
      } else {
        w0.pose = G;
        if (w0.anchor != null) { try { w0.anchor.detach(); } catch (Throwable e) { } w0.anchor = null; }
        if (tracking) w0.anchor = anchorOf(s, G);
      }
    }
    float left = units.isEmpty() ? 0.15f : total / 2f + 0.16f;
    placeRailBeside(s, cp, Math.min(0.42f, left));
    if (menuOpen) menuReveal = 0f;
    say("Janelas centralizadas");
  }

  // =============================================================
  // Grupos de janelas
  // =============================================================

  private ArrayList<Win> unit(Win w) {
    if (w.group != null) return w.group.m;
    ArrayList<Win> l = new ArrayList<Win>();
    l.add(w);
    return l;
  }

  /** Angulo (rad) do centro de cada janela do grupo no arco; as bordas se encostam com um vao pequeno. */
  private static float[] groupAngles(Grp g) {
    int n = g.m.size();
    float[] a = new float[n], hw = new float[n];
    float tot = 0f;
    for (int i = 0; i < n; i++) { hw[i] = (float) Math.atan(HW * g.m.get(i).s / GRP_R); tot += 2f * hw[i]; }
    tot += (n - 1) * GGAP / GRP_R;
    float x = -tot / 2f;
    for (int i = 0; i < n; i++) { a[i] = x + hw[i]; x += 2f * hw[i] + GGAP / GRP_R; }
    return a;
  }

  /** Pose de uma janela do arco, relativa a moldura do grupo (+z da moldura aponta para quem olha). */
  private static Pose localOf(float ph) {
    return new Pose(new float[]{GRP_R * (float) Math.sin(ph), 0f, GRP_R * (1f - (float) Math.cos(ph))},
      new float[]{0f, (float) Math.sin(-ph / 2f), 0f, (float) Math.cos(-ph / 2f)});
  }

  private Pose groupFrame(Grp g) {
    return g.m.get(0).current().compose(localOf(groupAngles(g)[0]).inverse());
  }

  /** Poe todas as janelas do grupo no lugar, a partir da moldura G. As ancoras sao refeitas depois. */
  private void layoutGroup(Grp g, Pose G) {
    float[] ph = groupAngles(g);
    for (int i = 0; i < g.m.size(); i++) {
      Win m = g.m.get(i);
      m.pose = G.compose(localOf(ph[i]));
      if (m.anchor != null) { try { m.anchor.detach(); } catch (Throwable e) { } m.anchor = null; }
    }
  }

  private void leaveGroup(Win w) {
    Grp g = w.group;
    if (g == null) return;
    g.m.remove(w);
    w.group = null;
    if (g.m.size() < 2) {
      for (Win m : g.m) m.group = null;
      g.m.clear();
    }
  }

  private static boolean endFree(Win b, int side) {
    Grp g = b.group;
    return g == null || (side > 0 ? g.m.get(g.m.size() - 1) == b : g.m.get(0) == b);
  }

  private boolean canJoin(Win a, Win b, int side) {
    if (a == null || b == null || a == b || a.menu || b.menu || a.min || b.min || side == 0) return false;
    if (a.group != null && a.group == b.group) return false;
    if (unit(a).size() + unit(b).size() > MAX_WINS) return false;
    return endFree(b, side);
  }

  /** Procura a janela que fica "embaixo" da que esta sendo arrastada (o raio passa pelo centro dela). */
  private void findDrop(float[] camPos) {
    Win a = dragWin;
    if (a == null || a.menu || a.linked) { clearDrop(); return; }
    float[] c = a.pose.getTranslation();
    float dx = c[0] - camPos[0], dy = c[1] - camPos[1], dz = c[2] - camPos[2];
    float len = (float) Math.sqrt(dx * dx + dy * dy + dz * dz);
    if (len < 0.05f) { clearDrop(); return; }
    float[] d = {dx / len, dy / len, dz / len};
    Win best = null;
    float bestT = 1e9f;
    int bestSide = 0;
    for (Win b : wins) {
      if (b == a || b.menu || b.hidden || b.min) continue;
      if (!planeHit(b, camPos, d, pl)) continue;
      float lx = pl[0] / b.s, ly = pl[1] / b.s;
      if (Math.abs(lx) > HW || Math.abs(ly) > HH) continue;
      int sd = lx >= 0f ? 1 : -1;
      if (b == dropT && Math.abs(lx) < 0.08f && dropSide != 0) sd = dropSide;   // histerese perto do meio
      if (!canJoin(a, b, sd)) continue;
      if (best == null || pl[2] < bestT) { best = b; bestT = pl[2]; bestSide = sd; }
    }
    if (best != null) {
      if (best != dropT) say("Solte para agrupar");
      best.lockUntil = SystemClock.uptimeMillis() + 700;
      dropT = best;
      dropSide = bestSide;
    } else {
      clearDrop();
    }
  }

  private void clearDrop() { dropT = null; dropSide = 0; }

  /** Junta a unidade de a (janela ou grupo) a de b, do lado indicado. b fica onde esta. */
  private void joinGroups(Win a, Win b, int side) {
    ArrayList<Win> ua = new ArrayList<Win>(unit(a)), ub = new ArrayList<Win>(unit(b));
    Grp g = new Grp();
    if (side > 0) { g.m.addAll(ub); g.m.addAll(ua); } else { g.m.addAll(ua); g.m.addAll(ub); }
    Pose bp = b.current();
    for (Win m : g.m) { m.group = g; m.hold = false; }
    float[] ph = groupAngles(g);
    Pose G = bp.compose(localOf(ph[g.m.indexOf(b)]).inverse());
    g.g = G;
    layoutGroup(g, G);
    b.lockUntil = SystemClock.uptimeMillis() + 700;
    a.lockUntil = b.lockUntil;
    say("Janelas agrupadas");
  }

  /** Corrente entre duas janelas: separa o grupo naquele ponto. */
  private void splitGroup(Win w) {
    Grp g = w.group;
    if (g == null) return;
    int i = g.m.indexOf(w);
    if (i <= 0) return;
    ArrayList<Win> L = new ArrayList<Win>(g.m.subList(0, i)), R = new ArrayList<Win>(g.m.subList(i, g.m.size()));
    for (Win m : g.m) m.group = null;
    g.m.clear();
    nudge(L, -0.04f);
    nudge(R, 0.04f);
    say("Janelas separadas");
  }

  private void nudge(ArrayList<Win> l, float dx) {
    for (Win m : l) {
      m.pose = m.current().compose(Pose.makeTranslation(dx, 0f, 0f));
      if (m.anchor != null) { try { m.anchor.detach(); } catch (Throwable e) { } m.anchor = null; }
    }
    if (l.size() > 1) {
      Grp ng = new Grp();
      ng.m.addAll(l);
      for (Win m : l) m.group = ng;
    }
  }

  // =============================================================
  // Minimizar (toque duplo na barra) e restaurar (toque na bolha)
  // =============================================================

  private void barTap(Win w, long now) {
    if (w.menu || w.kb || w.min) return;
    if (lastTapWin == w && now - lastTapMs < 800) { lastTapWin = null; minimize(w); }
    else { lastTapWin = w; lastTapMs = now; }
  }

  private void minimize(Win w) {
    if (w.menu || w.min) return;
    leaveGroup(w);
    if (kbOwner == w) hideKb();
    w.editing = false;
    w.tabsOpen = false;
    String letter = "\u2022";
    ArPanel.Snap sn = w.panel.snap;
    if (sn != null && sn.cur >= 0 && sn.cur < sn.titles.length) {
      String t = sn.titles[sn.cur];
      for (int i = 0; i < t.length(); i++) {
        if (Character.isLetterOrDigit(t.charAt(i))) { letter = t.substring(i, i + 1).toUpperCase(); break; }
      }
    }
    if (w.bubTex != 0) GLES20.glDeleteTextures(1, new int[]{w.bubTex}, 0);
    w.bubTex = bitmapTex(makeBubble(letter));
    w.min = true;
    if (lastActive == w) lastActive = null;
    say("Janela minimizada (toque na bolha para voltar)");
  }

  private void restore(Win w) {
    if (!w.min) return;
    w.min = false;
    if (w.bubTex != 0) { GLES20.glDeleteTextures(1, new int[]{w.bubTex}, 0); w.bubTex = 0; }
    w.lockUntil = SystemClock.uptimeMillis() + 500;
    lastActive = w;
    say("Janela restaurada");
  }

  // =============================================================
  // Teclado virtual e edicao do endereco
  // =============================================================

  private void ensureKb(Win owner) {
    if (kbWin != null || session == null) return;
    kbWin = addWindowP(session, owner.current(), newPanel(ArActivity.KB_URL, true), true, false);
    kbWin.kb = true;
    kbWin.s = 0.85f;
    kbWin.hidden = true;
  }

  private void showKb(Win owner) {
    ensureKb(owner);
    if (kbWin == null) return;
    if (kbOwner != null && kbOwner != owner) kbOwner.editing = false;
    kbOwner = owner;
    kbWin.hidden = false;
    placeKb();
  }

  private void hideKb() {
    if (kbOwner != null) kbOwner.editing = false;
    kbOwner = null;
    if (kbWin != null) kbWin.hidden = true;
  }

  private void toggleKb(Win w) {
    if (kbWin != null && !kbWin.hidden && kbOwner == w) hideKb();
    else showKb(w);
  }

  /** O teclado fica logo abaixo da janela dona, acompanhando quando ela se move. */
  private void placeKb() {
    if (kbWin == null || kbWin.hidden) return;
    Win o = kbOwner;
    if (o == null || !wins.contains(o) || o.min) { hideKb(); return; }
    float y = -(HH * o.s + 0.09f * o.s + HH * kbWin.s);
    kbWin.pose = o.current().compose(Pose.makeTranslation(0f, y, 0f));
  }

  void pageFocus(ArPanel p) {
    for (Win w : wins) {
      if (w.panel == p && !w.menu && !w.min) {
        if (!(kbWin != null && !kbWin.hidden && kbOwner == w)) showKb(w);
        return;
      }
    }
  }

  private void startUrlEdit(Win w) {
    ArPanel.Snap sn = w.panel.snap;
    showKb(w);
    if (kbWin == null) return;
    w.urlBuf = sn == null || sn.url == null ? "" : sn.url;
    w.urlSel = w.urlBuf.length() > 0;
    w.editing = true;
  }

  /** Tecla vinda do teclado virtual (thread do GL). Texto vai para o endereco em edicao ou para o campo da pagina. */
  void kbKey(String tok) {
    if (tok == null) return;
    if (tok.equals("k:close")) { hideKb(); return; }
    Win o = kbOwner;
    if (o == null || !wins.contains(o)) return;
    if (o.editing) {
      if (tok.startsWith("t:")) {
        if (o.urlSel) { o.urlBuf = ""; o.urlSel = false; }
        if (o.urlBuf.length() < 400) o.urlBuf += tok.substring(2);
      } else if (tok.equals("k:back")) {
        if (o.urlSel) { o.urlBuf = ""; o.urlSel = false; }
        else if (o.urlBuf.length() > 0) o.urlBuf = o.urlBuf.substring(0, o.urlBuf.length() - 1);
      } else if (tok.equals("k:enter")) {
        String t = o.urlBuf;
        o.editing = false;
        hideKb();
        o.panel.navigate(t);
      }
      return;
    }
    if (tok.startsWith("t:")) o.panel.typeText(tok.substring(2));
    else if (tok.equals("k:back")) o.panel.pressKey("back");
    else if (tok.equals("k:enter")) o.panel.pressKey("enter");
  }

  private void spawnFront(Session s, String url) {
    Pose cp = lastCamPose;
    if (cp == null) return;
    lastActive = addWindow(s, arcPose(cp, 0, 1), url, false);
    say("Nova janela");
  }

  /** Nova janela logo ao lado direito de outra, com a mesma orientacao. */
  private void newWindowNear(Session s, Win src, String url) {
    if (webCount() >= MAX_WINS) { say("Maximo de " + MAX_WINS + " janelas"); return; }
    float dx = HW * src.s + 0.06f + HW;
    Pose p = src.current().compose(Pose.makeTranslation(dx, 0f, 0f));
    Win w = addWindow(s, p, url == null ? ArActivity.HOME : url, false);
    lastActive = w;
    say("Nova janela");
  }

  /** Abrir um app pelo menu: janela nova se couber; senao, carrega na ultima janela usada. */
  void openApp(String url) {
    Session s = session;
    if (s == null) return;
    Win src = (lastActive != null && wins.contains(lastActive)) ? lastActive : firstWeb();
    if (src == null) { spawnFront(s, url); return; }
    if (webCount() < MAX_WINS) {
      newWindowNear(s, src, url);
    } else {
      src.panel.go(url);
      say("Aberto na ultima janela");
    }
  }

  private void removeWindow(Win w) {
    if (dragWin == w) dragWin = null;
    if (sizeWin == w) sizeWin = null;
    if (touchWin == w) touchWin = null;
    if (hoverWin == w) { hoverWin = null; hoverRegion = R_NONE; }
    if (lastActive == w) lastActive = null;
    if (fistWin == w) { fistWin = null; fistProg = 0f; }
    if (dropT == w) clearDrop();
    if (lastTapWin == w) lastTapWin = null;
    if (kbOwner == w) hideKb();
    leaveGroup(w);
    if (w.bubTex != 0) { GLES20.glDeleteTextures(1, new int[]{w.bubTex}, 0); w.bubTex = 0; }
    wins.remove(w);
    if (w.anchor != null) { try { w.anchor.detach(); } catch (Throwable e) { } w.anchor = null; }
    panels.remove(w.panel);
    w.panel.glRelease();
    if (w.chromeTex != 0) { GLES20.glDeleteTextures(1, new int[]{w.chromeTex}, 0); w.chromeTex = 0; }
    if (w.chromeBmp != null) { w.chromeBmp.recycle(); w.chromeBmp = null; }
  }

  private void closeWindow(Win w) {
    if (w.menu) return;
    removeWindow(w);
    say("Janela fechada");
  }

  /** Mantem cada janela presa a uma ancora valida; se o ARCore derrubar a ancora, recria na ultima posicao boa. */
  private void maintainAnchors(Session s) {
    for (Win w : wins) { if (!w.linked && !w.kb) maintain1(s, w); }
    if (railWin != null) maintain1(s, railWin);
  }

  private void maintain1(Session s, Win w) {
    {
      if (w == dragWin || w.hold || (w == railWin && dragWin != null && dragWin.linked)) return;
      Anchor a = w.anchor;
      if (a != null) {
        TrackingState st = a.getTrackingState();
        if (st == TrackingState.TRACKING) w.pose = a.getPose();
        else if (st == TrackingState.STOPPED) { w.anchor = null; anchorLost = true; }
      }
      if (w.anchor == null && tracking) w.anchor = anchorOf(s, w.pose);
    }
  }

  private void drawWindows() {
    if (winProg == 0) return;

    // barra do navegador: so redesenha o bitmap quando algo mudou (aba, titulo, endereco)
    for (Win w : wins) {
      ArPanel.Snap sn = w.panel.snap;
      boolean caret = w.editing && ((System.currentTimeMillis() / 500L) & 1L) == 0L;
      int sig = w.editing ? (w.urlBuf.hashCode() * 31 + (w.urlSel ? 2 : 0) + (caret ? 1 : 0) + 7) : 0;
      if (sn != null && (sn.ver != w.chromeVer || w.tabsOpen != w.chromeOpen || sig != w.chromeSig) && w.chromeBmp != null) {
        ArChrome.draw(w.chromeBmp, sn, w.tabsOpen, w.editing ? w.urlBuf : null, caret, w.urlSel);
        w.chromeSig = sig;
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, w.chromeTex);
        GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0, w.chromeBmp, 0);
        w.chromeVer = sn.ver;
        w.chromeOpen = w.tabsOpen;
      }
    }

    final float dimV = dim ? 0.45f : 1f;
    GLES20.glEnable(GLES20.GL_DEPTH_TEST);
    GLES20.glDisable(GLES20.GL_CULL_FACE);
    GLES20.glEnable(GLES20.GL_BLEND);
    GLES20.glBlendFunc(GLES20.GL_ONE, GLES20.GL_ONE_MINUS_SRC_ALPHA);
    GLES20.glUseProgram(winProg);
    GLES20.glActiveTexture(GLES20.GL_TEXTURE0);
    GLES20.glUniform1i(winTexLoc, 0);
    GLES20.glUniform1f(winDimLoc, dimV);
    GLES20.glEnableVertexAttribArray(winPosLoc);
    GLES20.glEnableVertexAttribArray(winUvLoc);
    for (Win w : wins) {
      if (w.hidden || w.min) continue;
      GLES20.glUniform2f(winShadeLoc, w == dropT ? (float) dropSide : 0f, w == dropT ? 1f : 0f);
      FloatBuffer vb = w.curved ? curveVerts : winVerts, ub = w.curved ? curveUvs : winUvs;
      vb.position(0);
      ub.position(0);
      GLES20.glVertexAttribPointer(winPosLoc, 3, GLES20.GL_FLOAT, false, 0, vb);
      GLES20.glVertexAttribPointer(winUvLoc, 2, GLES20.GL_FLOAT, false, 0, ub);
      GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, w.panel.tex);
      GLES20.glUniformMatrix4fv(winStmLoc, 1, false, w.panel.stm, 0);
      GLES20.glUniform1f(winFlatLoc, w.panel.got ? 0f : 1f);
      GLES20.glUniform2f(winHalfLoc, HW * w.s, HH * w.s);
      GLES20.glUniform2f(winHalfVLoc, HW * w.s, HH * w.s);
      GLES20.glUniform1f(winRadLoc, CORNER_R * w.s);
      GLES20.glUniform1f(winSLoc, w.s);
      modelOf(w);
      Matrix.multiplyMM(mvp, 0, vp, 0, model, 0);
      GLES20.glUniformMatrix4fv(winMvpLoc, 1, false, mvp, 0);
      GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, w.curved ? (CN + 1) * 2 : 4);
    }
    GLES20.glDisableVertexAttribArray(winPosLoc);
    GLES20.glDisableVertexAttribArray(winUvLoc);

    // barra, alca, botoes, navegador e menu: por cima, com transparencia
    if (flatProg == 0) return;
    GLES20.glDepthMask(false);
    GLES20.glUseProgram(flatProg);
    GLES20.glUniform1i(flatTexLoc, 0);
    bindUnit();
    GLES20.glEnableVertexAttribArray(flatPosLoc);
    GLES20.glEnableVertexAttribArray(flatUvLoc);
    boolean idle = dragWin == null && sizeWin == null;
    for (Win w : wins) {
      if (w.hidden) continue;
      if (w.min) { drawBubble(w, idle && hoverWin == w, dimV); continue; }
      modelOf(w);
      boolean hov = idle && hoverWin == w;
      boolean barOn = (dragWin == w) || (hov && hoverRegion == R_BAR);
      boolean cornOn = (sizeWin == w) || (hov && hoverRegion == R_CORNER);
      boolean barAct = dragWin == w, cornAct = sizeWin == w;
      float ba = barOn ? 0.95f : 0.55f, ca = cornOn ? 0.95f : 0.5f;
      if (!w.kb) quad(barTex, 0f, BAR_CY, BAR_W * (barOn ? 1.15f : 0.62f), BAR_H * (barOn ? 1.2f : 0.7f), barAct ? 0.37f : 1f, barAct ? 0.92f : 1f, barAct ? 0.83f : 1f, ba, dimV);
      if (!w.kb) quad(cornerTex, CSX, CSY, CS * (cornOn ? 1.2f : 0.8f), CS * (cornOn ? 1.2f : 0.8f), cornAct ? 0.37f : 1f, cornAct ? 0.92f : 1f, cornAct ? 0.83f : 1f, ca, dimV);
      if (!w.menu) {
        boolean curveOn = hov && hoverRegion == R_CURVE;
        iconBtn(curveGlyph, -PLUS_X, BAR_CY, PLUS_S * (curveOn ? 1.2f : 0.9f), curveOn, w.curved, 1f, dimV);
        boolean keyOn = hov && hoverRegion == R_KEY, kbShown = kbWin != null && !kbWin.hidden && kbOwner == w;
        iconBtn(keyGlyph, PLUS_X, BAR_CY, PLUS_S * (keyOn ? 1.2f : 0.9f), keyOn, kbShown, 1f, dimV);
        if (w.group != null && w.group.m.indexOf(w) > 0) {
          boolean lh = hov && hoverRegion == R_LINK;
          iconBtn(linkGlyph, chainX(w), chainY(), 0.05f * (lh ? 1.2f : 0.95f), lh, false, 1f, dimV);
        }
      }
      if (w == dropT && dropSide != 0) iconBtn(linkGlyph, dropSide * HW / 2f, 0f, 0.1f, false, true, 1f, dimV);
      if (w.chromeVer >= 0) quad(w.chromeTex, 0f, HH + CH_GAP + CH_H / 2f, CH_W, CH_H, 1f, 1f, 1f, 1f, dimV);
      if (hov && hoverRegion == R_CHROME) highlight(w, hoverElem, dimV);
    }
    drawRail(dimV, idle);
    if (dynBound) bindUnit();
    GLES20.glDisableVertexAttribArray(flatPosLoc);
    GLES20.glDisableVertexAttribArray(flatUvLoc);
    GLES20.glDepthMask(true);
    GLES20.glDisable(GLES20.GL_BLEND);
  }

  /** Bolha da janela minimizada: disco com a inicial do site, no lugar da janela. */
  private void drawBubble(Win w, boolean hov, float dimV) {
    if (w.bubTex == 0) return;
    w.current().toMatrix(model, 0);
    bend = false;
    float sz = BUB * (hov ? 1.15f : 1f);
    quad(w.bubTex, 0f, 0f, sz, sz, 1f, 1f, 1f, 1f, dimV);
  }

  private static float chainX(Win w) { return -(HW + 0.006f / w.s); }
  private static float chainY() { return HH + CH_GAP + CH_H / 2f; }

  /** Trilho do menu: so icones, um abaixo do outro; aparecem descendo. */
  private void drawRail(float dimV, boolean idle) {
    Win rw = railWin;
    if (rw == null || menuReveal < 0.01f) return;
    modelOf(rw);
    boolean hov = idle && hoverWin == rw;
    float rv = menuReveal * (RAIL_N + 2);
    float ac = Math.max(0f, Math.min(1f, rv));
    if (ac > 0f && clockTex != 0 && clockBmp != null) {
      updateClock();
      float ec = ac * ac * (3f - 2f * ac);
      quad(clockTex, 0f, -0.019f + (1f - ec) * 0.05f, CLOCK_W * (0.8f + 0.2f * ec), CLOCK_H * (0.8f + 0.2f * ec), 1f, 1f, 1f, ec, dimV);
    }
    for (int k = 0; k < RAIL_N; k++) {
      float a = Math.max(0f, Math.min(1f, rv - (k + 1)));
      if (a <= 0f) continue;
      float e = a * a * (3f - 2f * a);
      float y = -(RAIL_TOP + (k + 0.5f) * RAIL_P) + (1f - e) * 0.05f;
      boolean hot = hov && hoverRegion == R_ICON && hoverElem == k;
      boolean sel = k >= 2 && menuTab == k && tabWin != null && !tabWin.hidden;
      float sc = (0.7f + 0.3f * e) * (hot ? 1.15f : 1f);
      iconBtn(icoTex[k], 0f, y, RAIL_IC * sc, hot, sel, e, dimV);
    }
    if (menuReveal > 0.9f) {
      boolean barOn = (dragWin == rw) || (hov && hoverRegion == R_BAR);
      boolean act = dragWin == rw;
      quad(barTex, 0f, -RAIL_H - 0.034f, 0.07f * (barOn ? 1.25f : 0.8f), 0.008f * (barOn ? 1.5f : 1f), act ? 0.37f : 1f, act ? 0.92f : 1f, act ? 0.83f : 1f, barOn ? 0.95f : 0.55f, dimV);
    }
  }

  /** Botao redondo "de vidro": fundo quase transparente com aro fino e icone branco; claro sob a mao, verde-agua quando ligado. */
  private void iconBtn(int glyph, float x, float y, float size, boolean hot, boolean on, float alpha, float dimV) {
    boolean solid = hot || on;
    if (hot) quad(discTex, x, y, size, size, 1f, 1f, 1f, 0.92f * alpha, dimV);
    else if (on) quad(discTex, x, y, size, size, 0.37f, 0.92f, 0.83f, 0.92f * alpha, dimV);
    else {
      quad(discTex, x, y, size, size, 0.16f, 0.2f, 0.28f, 0.22f * alpha, dimV);
      quad(ringTex, x, y, size, size, 1f, 1f, 1f, 0.42f * alpha, dimV);
    }
    if (!solid) quad(glyph, x + size * 0.025f, y - size * 0.025f, size * 0.62f, size * 0.62f, 0f, 0f, 0f, 0.35f * alpha, dimV);
    quad(glyph, x, y, size * 0.62f, size * 0.62f, solid ? 0.07f : 1f, solid ? 0.08f : 1f, solid ? 0.1f : 1f, alpha, dimV);
  }

  /** model = pose da janela * escala (curva: escala uniforme, a malha ja tem a profundidade). */
  private void modelOf(Win w) {
    w.current().toMatrix(model, 0);
    Matrix.scaleM(model, 0, w.s, w.s, w.curved ? w.s : 1f);
    bend = w.curved;
  }

  private void bindUnit() {
    unitVerts.position(0);
    unitUvs.position(0);
    GLES20.glVertexAttribPointer(flatPosLoc, 3, GLES20.GL_FLOAT, false, 0, unitVerts);
    GLES20.glVertexAttribPointer(flatUvLoc, 2, GLES20.GL_FLOAT, false, 0, unitUvs);
    dynBound = false;
  }

  /** Desenha um quadrado texturizado em coordenadas locais da janela (escala 1). Cor pre-multiplicada. */
  private void quad(int tex, float x, float y, float sx, float sy, float r, float g, float b, float a, float dimV) {
    if (bend) { curvedQuad(tex, x, y, sx, sy, r, g, b, a, dimV); return; }
    if (dynBound) bindUnit();
    System.arraycopy(model, 0, tmp, 0, 16);
    Matrix.translateM(tmp, 0, x, y, CHROME_Z);
    Matrix.scaleM(tmp, 0, sx, sy, 1f);
    Matrix.multiplyMM(mvp, 0, vp, 0, tmp, 0);
    GLES20.glUniformMatrix4fv(flatMvpLoc, 1, false, mvp, 0);
    GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, tex);
    GLES20.glUniform4f(flatColLoc, r * a * dimV, g * a * dimV, b * a * dimV, a);
    GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4);
  }

  /** Mesmo quadrado, mas acompanhando a curva da janela (x = comprimento de arco). */
  private void curvedQuad(int tex, float x, float y, float sx, float sy, float r, float g, float b, float a, float dimV) {
    int m = Math.max(1, Math.min(24, Math.round(sx / 0.04f)));
    int k = 0, ku = 0;
    for (int i = 0; i <= m; i++) {
      float u = i / (float) m, ph = (x - sx / 2f + sx * u) / RN;
      float px = (float) (RN * Math.sin(ph)), pz = (float) (RN * (1.0 - Math.cos(ph))) + CHROME_Z;
      dynV[k++] = px; dynV[k++] = y - sy / 2f; dynV[k++] = pz;
      dynV[k++] = px; dynV[k++] = y + sy / 2f; dynV[k++] = pz;
      dynU[ku++] = u; dynU[ku++] = 1f; dynU[ku++] = u; dynU[ku++] = 0f;
    }
    dynVerts.clear(); dynVerts.put(dynV, 0, k); dynVerts.position(0);
    dynUvs.clear(); dynUvs.put(dynU, 0, ku); dynUvs.position(0);
    GLES20.glVertexAttribPointer(flatPosLoc, 3, GLES20.GL_FLOAT, false, 0, dynVerts);
    GLES20.glVertexAttribPointer(flatUvLoc, 2, GLES20.GL_FLOAT, false, 0, dynUvs);
    dynBound = true;
    Matrix.multiplyMM(mvp, 0, vp, 0, model, 0);
    GLES20.glUniformMatrix4fv(flatMvpLoc, 1, false, mvp, 0);
    GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, tex);
    GLES20.glUniform4f(flatColLoc, r * a * dimV, g * a * dimV, b * a * dimV, a);
    GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, (m + 1) * 2);
  }

  /** Destaque (verde-agua translucido) sobre o elemento da barra do navegador sob o cursor. */
  private void highlight(Win w, int elem, float dimV) {
    int code = elem & 0xFF, idx = elem >> 8;
    if (code == ArChrome.NONE || code == ArChrome.URL) return;
    ArPanel.Snap sn = w.panel.snap;
    if (sn == null) return;
    float[] r = new float[4];
    ArChrome.rect(code, idx, sn.n, r);
    float x = ((r[0] + r[2]) / 2f / ArChrome.DW - 0.5f) * CH_W;
    float y = HH + CH_GAP + (1f - (r[1] + r[3]) / 2f / ArChrome.DH) * CH_H;
    float sx = (r[2] - r[0]) / ArChrome.DW * CH_W, sy = (r[3] - r[1]) / ArChrome.DH * CH_H;
    float a = 0.38f;
    quad(roundTex, x, y, sx, sy, 0.37f, 0.92f, 0.83f, a, dimV);
  }

  // =============================================================
  // Mao: cursor, pinca, toque, mover, redimensionar, navegador, punho
  // =============================================================

  private void resetInteraction() {
    if (touchWin != null) sendTouch(touchWin, MotionEvent.ACTION_CANCEL, lastPx, lastPy);
    dragWin = null; sizeWin = null; touchWin = null;
    for (Win w : wins) w.hold = false;
    clearDrop();
    pinchWasOn = false;
    fistWin = null; fistProg = 0f; fistLatched = false;
  }

  /** Esqueceu a mao (sumiu por mais de 350 ms): volta tudo ao inicio. */
  private void resetHand() {
    viewValid = false; pinch = false; pinchN = 0; handN = 0; fistN = 0; handFist = false; peace = false; peaceN = 0;
    firstSample = true; sizeOut = 0;
    fX.reset(); fY.reset();
    vxc = 0f; vyc = 0f; pend = null;
  }

  private void onDetection(Frame frame, ArHand.Result r, long now) {
    long cap = tracker.latestSubmit;
    tDet = (cap > 0 && cap <= now) ? cap : now;   // quando a imagem foi capturada, nao quando a IA terminou
    if (r == null) {
      viewValid = false;   // o estado da pinca fica ate a mao sumir de vez
      return;
    }
    seenMs = now;
    handN++;
    frame.transformCoordinates2d(Coordinates2d.IMAGE_NORMALIZED, r.pts, Coordinates2d.VIEW, viewPts);
    viewValid = true;
    ratio = r.ratio;

    // tamanho da mao: ignora saltos bruscos isolados (erro da IA), aceita se se repetirem
    if (firstSample) {
      sizeS = r.size;
    } else {
      float rel = r.size / Math.max(sizeS, 0.0001f);
      if (rel > 1.45f || rel < 0.69f) {
        if (++sizeOut >= 3) { sizeS = r.size; sizeOut = 0; }
      } else {
        sizeOut = 0;
        sizeS += (r.size - sizeS) * 0.3f;
      }
    }

    handFist = r.fist;
    fistN = handFist ? fistN + 1 : 0;
    peace = !handFist && computePeace();
    peaceN = peace ? peaceN + 1 : 0;
    pinch = (handFist || peace) ? false : (pinch ? ratio < PINCH_OFF : ratio < PINCH_ON);
    pinchN = pinch ? pinchN + 1 : 0;

    // ponto do cursor: ponta do indicador com a mao aberta, meio da pinca com a mao fechando
    float w = Math.max(0f, Math.min(1f, (0.6f - ratio) / 0.35f));
    float x8 = viewPts[16], y8 = viewPts[17], x4 = viewPts[8], y4 = viewPts[9];
    float rx = x8 * (1f - w) + (x4 + x8) * 0.5f * w;
    float ry = y8 * (1f - w) + (y4 + y8) * 0.5f * w;
    fX.f(rx, now);
    fY.f(ry, now);
    if (firstSample) {
      cx = fX.x; cy = fY.x; firstSample = false;
      pfx = fX.x; pfy = fY.x; vxc = 0f; vyc = 0f;
    } else {
      float dtd = Math.max(0.02f, (now - prevDetMs) / 1000f);
      vxc += ((fX.x - pfx) / dtd - vxc) * 0.6f;
      vyc += ((fY.x - pfy) / dtd - vyc) * 0.6f;
      pfx = fX.x; pfy = fY.x;
    }
    prevDetMs = now;
  }

  private void updateInteraction(Session s, Frame frame, float[] camPos) {
    long now = SystemClock.uptimeMillis();
    float dt = lastFrameMs == 0 ? 0.016f : Math.min(0.1f, (now - lastFrameMs) / 1000f);
    lastFrameMs = now;
    frameDt = dt;

    long sq = tracker.detSeq;
    if (sq != lastSeq) {
      lastSeq = sq;
      onDetection(frame, tracker.latest, now);
    }
    boolean has = seenMs > 0 && now - seenMs < 350;
    if (!has && (handN != 0 || pinch || handFist || skel != null)) resetHand();

    if (has) {
      // compensa o atraso: a imagem da mao tem "age" ms de idade; projeta o movimento ate agora
      float age = Math.min(0.15f, Math.max(0f, (now - tDet) / 1000f));
      handAgeMs = age * 1000f;
      float lead = age + 0.016f;
      float lim = Math.max(40f, vw * 0.12f);
      float dxp = Math.max(-lim, Math.min(lim, vxc * lead)), dyp = Math.max(-lim, Math.min(lim, vyc * lead));
      float kc = 1f - (float) Math.exp(-dt * 45f), ks = 1f - (float) Math.exp(-dt * 40f);
      cx += (fX.x + dxp - cx) * kc;
      cy += (fY.x + dyp - cy) * kc;
      if (viewValid) {
        if (skel == null) skel = viewPts.clone();
        else for (int i = 0; i < 42; i += 2) {
          skel[i] += (viewPts[i] + dxp - skel[i]) * ks;
          skel[i + 1] += (viewPts[i + 1] + dyp - skel[i + 1]) * ks;
        }
      }
    } else {
      skel = null;
    }

    if (peace) lastPeaceMs = now;
    boolean peaceEff = has && skel != null && !handFist && ((peace && peaceN >= 2) || (swActive && now - lastPeaceMs < 250));
    updateMenuGesture(s, peaceEff, camPos, now);

    boolean fistOn = has && handFist && fistN >= 3;
    // sem rastreio do ARCore ou com a mao fechada, nada e pego nem arrastado
    boolean pinchOn = has && !fistOn && pinch && pinchN >= 2 && handN >= 3 && (tracking || hybridActive) && !dim;
    hoverRegion = R_NONE;
    hoverElem = 0;
    hoverWin = null;

    float[] dir = null;
    Hit hit = null;
    if (has && vw > 0) {
      dir = rayDir(cx, cy, camPos);
      hit = raycast(camPos, dir);
      if (hit != null) { hoverWin = hit.win; hoverRegion = hit.region; hoverElem = hit.elem; }
      float cd = hit != null ? hit.t : 1.5f;
      cursorDepth += (Math.max(0.3f, Math.min(6f, cd)) - cursorDepth) * 0.35f;
    }

    if (pinchOn && !pinchWasOn) {
      pend = null;
      if (hit != null) {
        // mover e redimensionar pedem um instante de pinca firme; toque e botoes agem na hora
        if (hit.region == R_BAR || hit.region == R_CORNER) { pend = hit; pendSince = now; }
        else grab(s, hit, now);
      }
    } else if (!pinchOn && pinchWasOn) {
      if (pend != null && pend.region == R_BAR) barTap(pend.win, now);   // pinca rapida na barra: toque
      release(s);
      pend = null;
    }
    if (pinchOn && pend != null) {
      if (hit != null && hit.win == pend.win && hit.region == pend.region) {
        if (now - pendSince >= DWELL_MS) { Hit hh = hit; pend = null; grab(s, hh, now); }
      } else {
        pend = null;   // saiu da barra/canto antes de confirmar: ignora
      }
    }
    pinchWasOn = pinchOn;
    updateHold(s, pinchOn, hit, camPos, dir, now);

    if (pinchOn && dir != null) {
      if (sizeWin != null) doResize(camPos, dir);
      else if (dragWin != null) doDrag(camPos, dir);
      else if (touchWin != null) doTouchMove(camPos, dir);
    }

    updateFist(fistOn, hit, now);
  }

  /** Pinca segurada 1 s no vazio, dentro de um video 360: abre (ou fecha) os controles do video. */
  private void updateHold(Session s, boolean pinchOn, Hit hit, float[] cam, float[] dir, long now) {
    boolean can = spKind == 2 && spWant && pinchOn && hit == null && dir != null && !pinchWasOnGrab();
    if (!can) {
      holdStart = 0;
      holdProg = 0f;
      if (!pinchOn) holdLatch = false;
      return;
    }
    if (holdLatch) return;
    float lim = Math.max(40f, vw * 0.06f);
    if (holdStart == 0 || Math.hypot(cx - holdX, cy - holdY) > lim) { holdStart = now; holdX = cx; holdY = cy; }
    holdProg = Math.min(1f, (now - holdStart) / 1000f);
    if (holdProg >= 1f) {
      holdLatch = true;
      holdStart = 0;
      holdProg = 0f;
      toggleVctl(s, cam, dir);
    }
  }

  private boolean pinchWasOnGrab() { return dragWin != null || sizeWin != null || touchWin != null; }

  private void ensureVctl(Session s, Pose p) {
    if (vctlWin != null || s == null) return;
    vctlWin = addWindowP(s, p, newPanel(ArActivity.VID_URL, true), true, false);
    vctlWin.s = 0.7f;
    vctlWin.hidden = true;
  }

  private void toggleVctl(Session s, float[] cam, float[] dir) {
    if (vctlWin != null && !vctlWin.hidden) { hideVctl(); return; }
    Pose p = facing(cam[0] + dir[0] * 0.9f, cam[1] + dir[1] * 0.9f, cam[2] + dir[2] * 0.9f, cam[0], cam[2]);
    ensureVctl(s, p);
    if (vctlWin == null) return;
    if (vctlWin.anchor != null) { try { vctlWin.anchor.detach(); } catch (Throwable e) { } vctlWin.anchor = null; }
    vctlWin.pose = p;
    vctlWin.hidden = false;
    vctlWin.lockUntil = SystemClock.uptimeMillis() + 400;
  }

  void hideVctl() {
    if (vctlWin != null) vctlWin.hidden = true;
  }

  /** Punho fechado por 1 s sobre uma janela = fechar a janela. */
  private void updateFist(boolean fistOn, Hit hit, long now) {
    if (!fistOn) {
      fistLatched = false;
      fistWin = null;
      fistProg = 0f;
      return;
    }
    if (fistLatched) return;
    Win w = (hit != null && !hit.win.menu && !hit.win.min) ? hit.win : null;   // o menu e as bolhas nao fecham com o punho
    if (w != null) {
      if (fistWin != w) { fistWin = w; fistStart = now; }
      fistHitMs = now;
    } else if (fistWin == null || now - fistHitMs > 300) {
      fistWin = null;
      fistProg = 0f;
      return;
    }
    fistProg = Math.min(1f, (now - fistStart) / (float) FIST_MS);
    if (fistProg >= 1f && fistWin != null) {
      Win c = fistWin;
      fistLatched = true;
      fistWin = null;
      fistProg = 0f;
      closeWindow(c);
    }
  }

  private void grab(Session s, Hit h, long now) {
    Win w = h.win;
    if (!w.menu) lastActive = w;
    if (h.region == R_ICON) {
      if (now - lastClick > 350) { lastClick = now; menuSelect(h.elem); }
    } else if (h.region == R_CORNER) {
      if (w.group != null) {
        w.group.g = groupFrame(w.group);
        for (Win m : w.group.m) {
          m.pose = m.current();
          m.hold = true;
          if (m.anchor != null) { try { m.anchor.detach(); } catch (Throwable e) { } m.anchor = null; }
        }
      }
      sizeWin = w;
      sizeS0 = w.s;
      sizeD0 = Math.max(0.05f, (float) Math.hypot(h.lx, h.ly));
    } else if (h.region == R_BAR) {
      w.pose = w.current();
      if (w.linked && railWin != null) {
        railWin.pose = railWin.current();
        if (railWin.anchor != null) { try { railWin.anchor.detach(); } catch (Throwable e) { } railWin.anchor = null; }
      } else {
        if (w.group != null) {
          w.group.g = groupFrame(w.group);
          dragInv = localOf(groupAngles(w.group)[w.group.m.indexOf(w)]).inverse();
        }
        for (Win m : unit(w)) {
          m.pose = m.current();
          m.hold = true;
          if (m.anchor != null) { try { m.anchor.detach(); } catch (Throwable e) { } m.anchor = null; }
        }
      }
      clearDrop();
      dragWin = w;
      grabDist = h.t;
      grabSize = Math.max(sizeS, 0.001f);
      grabLx = h.lx;
      grabLy = h.ly;
      distS = h.t;
    } else if (h.region == R_BODY) {
      touchWin = w;
      lastPx = toPx(w, h.lx / w.s, true);
      lastPy = toPx(w, h.ly / w.s, false);
      sendTouch(w, MotionEvent.ACTION_DOWN, lastPx, lastPy);
    } else if (h.region == R_CURVE) {
      if (now - lastClick > 400) { lastClick = now; w.curved = !w.curved; say(w.curved ? "Tela curva" : "Tela plana"); }
    } else if (h.region == R_KEY) {
      if (now - lastClick > 400) { lastClick = now; toggleKb(w); }
    } else if (h.region == R_LINK) {
      if (now - lastClick > 400) { lastClick = now; splitGroup(w); }
    } else if (h.region == R_BUBBLE) {
      if (now - lastClick > 400) { lastClick = now; restore(w); }
    } else if (h.region == R_PLUS) {
      if (now - lastClick > 400) { lastClick = now; newWindowNear(s, w, null); }
    } else if (h.region == R_CHROME) {
      if (now - lastClick > 400) { lastClick = now; chromeAction(w, h.elem); }
    }
  }

  private void chromeAction(Win w, int elem) {
    int code = elem & 0xFF, idx = elem >> 8;
    ArPanel.Snap sn = w.panel.snap;
    int n = sn == null ? 1 : sn.n;
    if (code != ArChrome.URL && w.editing) { w.editing = false; hideKb(); }
    switch (code) {
      case ArChrome.TAB:
        w.panel.selectTab(idx);
        break;
      case ArChrome.TABX:
        if (n == 1) closeWindow(w);
        else w.panel.closeTab(idx);
        break;
      case ArChrome.TABS:
        w.tabsOpen = !w.tabsOpen;
        break;
      case ArChrome.NEW:
        if (n >= ArPanel.MAXT) say("Maximo de " + ArPanel.MAXT + " abas");
        else w.panel.newTab(null);
        break;
      case ArChrome.WINX:
        closeWindow(w);
        break;
      case ArChrome.BACK:
        w.panel.goBack();
        break;
      case ArChrome.FWD:
        w.panel.goForward();
        break;
      case ArChrome.URL:
        startUrlEdit(w);
        break;
      default:
        break;
    }
  }

  private void release(Session s) {
    if (touchWin != null) {
      sendTouch(touchWin, MotionEvent.ACTION_UP, lastPx, lastPy);
      touchWin = null;
    }
    Win sw = sizeWin;
    sizeWin = null;
    if (sw != null) for (Win m : unit(sw)) m.hold = false;
    Win w = dragWin;
    if (w != null) {
      dragWin = null;
      if (w.linked && railWin != null) {
        if (tracking) railWin.anchor = anchorOf(s, railWin.pose);
      } else if (dropT != null && canJoin(w, dropT, dropSide)) {
        joinGroups(w, dropT, dropSide);
      } else {
        for (Win m : unit(w)) {
          m.hold = false;
          if (tracking) m.anchor = anchorOf(s, m.pose);   // sem rastreio, maintainAnchors prende depois
        }
      }
      clearDrop();
    }
  }

  private void doResize(float[] camPos, float[] dir) {
    Win w = sizeWin;
    if (!planeHit(w, camPos, dir, pl)) return;
    float d = (float) Math.hypot(pl[0], pl[1]);
    float target = Math.max(S_MIN, Math.min(S_MAX, sizeS0 * d / sizeD0));
    w.s += (target - w.s) * 0.5f;
    if (w.group != null && w.group.g != null) layoutGroup(w.group, w.group.g);
  }

  /** Mover: a janela segue a mira do dedo; a distancia vem do tamanho da mao (mao mais perto = janela mais perto). */
  private void doDrag(float[] camPos, float[] dir) {
    Win w = dragWin;
    float d = grabDist * grabSize / Math.max(sizeS, 0.001f);
    d = Math.max(0.3f, Math.min(6f, d));
    distS += (d - distS) * (1f - (float) Math.exp(-frameDt * 12f));
    float pX = camPos[0] + dir[0] * distS, pY = camPos[1] + dir[1] * distS, pZ = camPos[2] + dir[2] * distS;
    float yaw = (float) Math.atan2(camPos[0] - pX, camPos[2] - pZ);
    float c = (float) Math.cos(yaw), sn = (float) Math.sin(yaw);
    float offX = grabLx * c, offY = grabLy, offZ = -grabLx * sn;
    float tx = pX - offX, ty = pY - offY, tz = pZ - offZ;
    // suaviza o alvo: um quadro ruim da mao nao teleporta a janela
    float[] cp = w.pose.getTranslation();
    float k = 1f - (float) Math.exp(-frameDt * 22f);
    float nx = cp[0] + (tx - cp[0]) * k, ny = cp[1] + (ty - cp[1]) * k, nz = cp[2] + (tz - cp[2]) * k;
    Pose np = new Pose(new float[]{nx, ny, nz}, new float[]{0f, (float) Math.sin(yaw / 2f), 0f, (float) Math.cos(yaw / 2f)});
    w.pose = np;
    if (w.linked && railWin != null) railWin.pose = np.compose(Pose.makeTranslation(-tabOffX(), -tabOffY(), 0f));
    if (w.group != null && dragInv != null) {
      Pose G = np.compose(dragInv);
      w.group.g = G;
      layoutGroup(w.group, G);
    }
    if (!w.linked && !w.menu) findDrop(camPos);
  }

  private void doTouchMove(float[] camPos, float[] dir) {
    Win w = touchWin;
    if (!planeHit(w, camPos, dir, pl)) return;
    float px = toPx(w, pl[0] / w.s, true), py = toPx(w, pl[1] / w.s, false);
    if (Math.abs(px - lastPx) < 0.5f && Math.abs(py - lastPy) < 0.5f) return;
    lastPx = px; lastPy = py;
    sendTouch(w, MotionEvent.ACTION_MOVE, px, py);
  }

  /** Coordenada local da janela (em metros, escala 1) para pixel da pagina. */
  private static float toPx(Win w, float local, boolean horizontal) {
    int pw = w.panel.pw, ph = w.panel.ph;
    float p = horizontal ? (local + HW) / (2f * HW) * pw : (HH - local) / (2f * HH) * ph;
    float max = (horizontal ? pw : ph) - 1f;
    return Math.max(0f, Math.min(max, p));
  }

  private void sendTouch(Win w, int action, float px, float py) {
    w.panel.touch(action, px, py);
  }

  private float[] rayDir(float px, float py, float[] cam) {
    float nx = 2f * px / vw - 1f, ny = 1f - 2f * py / vh;
    float[] v = {nx, ny, 1f, 1f};
    float[] o = new float[4];
    Matrix.multiplyMV(o, 0, invVp, 0, v, 0);
    float dx = o[0] / o[3] - cam[0], dy = o[1] / o[3] - cam[1], dz = o[2] / o[3] - cam[2];
    float len = (float) Math.sqrt(dx * dx + dy * dy + dz * dz);
    if (len > 0f) { dx /= len; dy /= len; dz /= len; }
    return new float[]{dx, dy, dz};
  }

  private Hit raycast(float[] o, float[] d) {
    Hit best = null;
    long nowR = SystemClock.uptimeMillis();
    for (int i = -1; i < wins.size(); i++) {
      Win w = i < 0 ? railWin : wins.get(i);
      if (w == null || w.hidden || (w.rail && menuReveal < 0.05f) || w.lockUntil > nowR) continue;
      if (!planeHit(w, o, d, pl)) continue;
      int reg;
      if (w.min) { regElem = 0; reg = Math.hypot(pl[0], pl[1]) <= BUB * 0.6f ? R_BUBBLE : R_NONE; }
      else reg = region(w, pl[0] / w.s, pl[1] / w.s);
      if (reg == R_NONE) continue;
      if (best == null || pl[2] < best.t) best = new Hit(w, pl[2], pl[0], pl[1], reg, regElem);
    }
    return best;
  }

  /** Cruza o raio com o plano da janela. out = {x local, y local, t} em metros reais. */
  private boolean planeHit(Win w, float[] o, float[] d, float[] out) {
    Pose inv = w.current().inverse();
    float[] lo = inv.transformPoint(o);
    float[] ld = inv.rotateVector(d);
    if (w.curved && !w.min) return cylHit(w, lo, ld, out);
    if (Math.abs(ld[2]) < 1e-4f) return false;
    float t = -lo[2] / ld[2];
    if (t <= 0f) return false;
    out[0] = lo[0] + t * ld[0];
    out[1] = lo[1] + t * ld[1];
    out[2] = t;
    return true;
  }

  /** Tela curva: cruza o raio com o cilindro (eixo vertical). out[0] = comprimento de arco, como se fosse plana. */
  private boolean cylHit(Win w, float[] lo, float[] ld, float[] out) {
    float r = RN * w.s;
    float ox = lo[0], oz = lo[2] - r;
    float a = ld[0] * ld[0] + ld[2] * ld[2];
    if (a < 1e-8f) return false;
    float b = ox * ld[0] + oz * ld[2];
    float c = ox * ox + oz * oz - r * r;
    float disc = b * b - a * c;
    if (disc < 0f) return false;
    float sq = (float) Math.sqrt(disc);
    for (int i = 0; i < 2; i++) {
      float t = (i == 0 ? -b - sq : -b + sq) / a;
      if (t <= 0f) continue;
      float hx = ox + t * ld[0], hz = oz + t * ld[2];
      if (hz >= 0f) continue;   // lado de tras do cilindro
      float ph = (float) Math.atan2(hx, -hz);
      if (Math.abs(ph) > CURVE_TH + 0.14f) continue;
      out[0] = r * ph;
      out[1] = lo[1] + t * ld[1];
      out[2] = t;
      return true;
    }
    return false;
  }

  /** x, y em metros com a janela na escala 1. Define regElem quando cai na barra do navegador. */
  private int region(Win w, float x, float y) {
    regElem = 0;
    if (w.rail) {
      float barY = -RAIL_H - 0.034f;
      if (Math.abs(x) <= 0.05f && Math.abs(y - barY) <= 0.026f && menuReveal > 0.9f) return R_BAR;
      if (Math.abs(x) <= 0.036f && y <= -RAIL_TOP && y >= -RAIL_H) {
        int k = Math.min(RAIL_N - 1, (int) ((-y - RAIL_TOP) / RAIL_P));
        if (menuReveal * (RAIL_N + 2) - (k + 1) > 0.6f) { regElem = k; return R_ICON; }
      }
      return R_NONE;
    }
    if (w.kb) return (Math.abs(x) <= HW && Math.abs(y) <= HH) ? R_BODY : R_NONE;
    if (!w.menu && w.group != null && w.group.m.indexOf(w) > 0
      && Math.abs(x - chainX(w)) <= 0.03f && Math.abs(y - chainY()) <= 0.03f) return R_LINK;
    if (Math.abs(x - CSX) <= CS_HIT && Math.abs(y - CSY) <= CS_HIT) return R_CORNER;
    if (!w.menu && Math.abs(x - PLUS_X) <= PLUS_HIT && Math.abs(y - BAR_CY) <= PLUS_HIT) return R_KEY;
    if (!w.menu && Math.abs(x + PLUS_X) <= PLUS_HIT && Math.abs(y - BAR_CY) <= PLUS_HIT) return R_CURVE;
    if (Math.abs(x) <= BAR_HIT_X && Math.abs(y - BAR_CY) <= BAR_HIT_Y) return R_BAR;
    if (Math.abs(x) <= HW && Math.abs(y) <= HH) return R_BODY;
    float y0 = HH + CH_GAP;
    if (!w.menu && y >= y0 - 0.006f && y <= y0 + CH_H + 0.006f && Math.abs(x) <= CH_W / 2f + 0.006f) {
      ArPanel.Snap sn = w.panel.snap;
      if (sn != null) {
        float dx = Math.max(0f, Math.min(ArChrome.DW, (x / CH_W + 0.5f) * ArChrome.DW));
        float dy = Math.max(0f, Math.min(ArChrome.DH, (1f - (y - y0) / CH_H) * ArChrome.DH));
        int e = ArChrome.hit(dx, dy, sn.n, sn.cur, w.tabsOpen);
        if (e != ArChrome.NONE) { regElem = e; return R_CHROME; }
      }
    }
    return R_NONE;
  }

  // =============================================================
  // Menu 3D (trilho de icones) e gesto de dois dedos descendo
  // =============================================================

  private static float dd(float[] v, int a, int b) {
    return (float) Math.hypot(v[2 * a] - v[2 * b], v[2 * a + 1] - v[2 * b + 1]);
  }

  /**
   * Dois dedos (indicador e medio) esticados para cima e juntos; anelar e mindinho dobrados.
   * O polegar nao importa (solto, dobrado ou encostado). Tolerante a mao inclinada.
   */
  private boolean computePeace() {
    float[] v = viewPts;
    float palm = dd(v, 0, 9);
    if (palm < 1f) return false;
    float d8 = dd(v, 8, 0), d12 = dd(v, 12, 0);
    float e8 = d8 / Math.max(dd(v, 6, 0), 1f), e12 = d12 / Math.max(dd(v, 10, 0), 1f);
    float e16 = dd(v, 16, 0) / Math.max(dd(v, 14, 0), 1f), e20 = dd(v, 20, 0) / Math.max(dd(v, 18, 0), 1f);
    // pontas dos dois dedos acima do pulso e a mao mais ou menos em pe
    boolean up8 = (v[1] - v[17]) > 0.35f * d8, up12 = (v[1] - v[25]) > 0.35f * d12;
    boolean straight = e8 > 1.1f && e12 > 1.1f;
    boolean others = e16 < 1.2f && e20 < 1.2f;
    boolean together = dd(v, 8, 12) / palm < 0.6f;
    return straight && others && up8 && up12 && together;
  }

  /**
   * Dois dedos descendo: com o menu fechado, abre (os icones surgem descendo atras da mao); com o menu aberto, fecha.
   * Soltar no meio do caminho termina o que passou da metade. Depois de concluir, so um gesto novo (mao solta) age.
   */
  private void updateMenuGesture(Session s, boolean on, float[] cam, long now) {
    if (on && railWin != null) {
      float px = (skel[16] + skel[24]) * 0.5f, py = (skel[17] + skel[25]) * 0.5f;
      if (!swActive || (!swDone && now - swT > 1200)) {
        swActive = true; swDone = false; swY0 = py; swT = now; swProg = 0f;
        if (!menuOpen) {
          swMode = 1;
          placeRailAtRay(s, cam, rayDir(px, py, cam));
          menuReveal = 0f;
        } else {
          swMode = 2;
        }
      } else if (py < swY0) {
        swY0 = py; swT = now;
      }
      swProg = Math.max(0f, Math.min(1f, (py - swY0) / (0.25f * Math.max(1f, vh))));
      if (!swDone) {
        if (swMode == 1) {
          menuReveal = swProg;
          if (swProg >= 1f) { menuOpen = true; swDone = true; }
        } else if (swMode == 2) {
          menuReveal = 1f - swProg;
          if (swProg >= 1f) { hideMenu(); swDone = true; }
        }
      }
    } else if (swActive) {
      if (!swDone) {
        if (swMode == 1) menuOpen = swProg >= 0.5f;
        else if (swMode == 2) { if (swProg >= 0.5f) hideMenu(); }
      }
      swActive = false; swMode = 0; swDone = false;
    }
  }

  /** Os icones surgem (ou somem) descendo; durante o gesto quem manda e a mao. */
  private void animateMenu(float dt) {
    if (swActive && !swDone && (swMode == 1 || swMode == 2)) return;
    float target = menuOpen ? 1f : 0f;
    float d = target - menuReveal;
    float step = 2.8f * dt;
    menuReveal += Math.max(-step, Math.min(step, d));
  }

  /** Relogio do menu: HH:MM, com os dois pontos piscando; redesenha duas vezes por segundo. */
  private void updateClock() {
    long slot = System.currentTimeMillis() / 500L;
    if (slot == clockSlot) return;
    clockSlot = slot;
    java.util.Calendar cal = java.util.Calendar.getInstance();
    String hh = String.format("%02d", cal.get(java.util.Calendar.HOUR_OF_DAY)), mm = String.format("%02d", cal.get(java.util.Calendar.MINUTE));
    Bitmap b = clockBmp;
    b.eraseColor(0);
    Canvas c = new Canvas(b);
    Paint p = new Paint(Paint.ANTI_ALIAS_FLAG);
    p.setStyle(Paint.Style.FILL);
    p.setTypeface(Typeface.create("sans-serif-light", Typeface.NORMAL));
    p.setLetterSpacing(0.1f);
    p.setShadowLayer(7f, 0f, 2f, Color.argb(170, 0, 0, 0));
    p.setColor(Color.WHITE);
    p.setTextSize(64f);
    float wh = p.measureText(hh), wm = p.measureText(mm), wc = p.measureText(":");
    float x = (200f - (wh + wc + wm)) / 2f, base = 78f;
    c.drawText(hh, x, base, p);
    p.setColor(Color.argb((slot & 1L) == 0L ? 255 : 90, 255, 255, 255));
    c.drawText(":", x + wh, base - 3f, p);
    p.setColor(Color.WHITE);
    c.drawText(mm, x + wh + wc, base, p);
    GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, clockTex);
    GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0, b, 0);
  }

  private void hideMenu() {
    menuOpen = false;
    closeTab();
  }

  private float tabOffX() { return RAIL_HALF + 0.035f + HW * (tabWin != null ? tabWin.s : 0.85f); }
  private float tabOffY() { return -RAIL_H / 2f; }

  /** A aba do menu fica sempre ao lado direito do trilho. */
  private void placeTab() {
    if (tabWin == null || railWin == null || dragWin == tabWin) return;
    tabWin.pose = railWin.current().compose(Pose.makeTranslation(tabOffX(), tabOffY(), 0f));
  }

  private void menuSelect(int k) {
    if (k == 0) { closeTab(); return; }
    if (k == 1) { recenter(); return; }
    if (menuTab == k && tabWin != null && !tabWin.hidden) { closeTab(); return; }
    openTab(k == 2 ? "space" : k == 3 ? "apps" : "cfg", k);
  }

  private void openTab(String name, int k) {
    ensureTab(session);
    if (tabWin == null) return;
    act.menuPage = name;
    tabWin.panel.eval("show('" + name + "')");
    tabWin.hidden = false;
    menuTab = k;
    placeTab();
  }

  private void closeTab() {
    menuTab = -1;
    if (tabWin != null) tabWin.hidden = true;
  }

  private static float[] curveMesh(boolean pos) {
    float[] a = new float[(CN + 1) * 2 * (pos ? 3 : 2)];
    int k = 0;
    for (int i = 0; i <= CN; i++) {
      float u = i / (float) CN, ph = (u * 2f - 1f) * HW / RN;
      float px = (float) (RN * Math.sin(ph)), pz = (float) (RN * (1.0 - Math.cos(ph)));
      for (int r = 0; r < 2; r++) {
        float y = r == 0 ? -HH : HH;
        if (pos) { a[k++] = px; a[k++] = y; a[k++] = pz; } else { a[k++] = u; a[k++] = r; }
      }
    }
    return a;
  }

  private void say(String m) {
    message = m;
    messageUntil = SystemClock.uptimeMillis() + 2500;
  }

  /** Texto de depuracao: atualiza so 4 vezes por segundo, na View pequena do canto. */
  private void publishOverlay() {
    ArOverlay ov = overlay;
    if (ov == null) return;
    long now = SystemClock.uptimeMillis();
    if (now - lastHud < 250) return;
    lastHud = now;
    String l1 = "AR: " + (hybridActive ? "SEM RASTREIO -> 3DoF (giroscopio)" : trackText) + "  perdas: " + lostCount + (lostCount > 0 ? "  motivo: " + lastReason + "  ultima: " + lastLostMs + " ms" : "");
    String l2 = "gl: " + Math.round(glFps) + " fps  ar: " + Math.round(arFps) + " fps  " + camInfo;
    String l3 = "mao: " + (skel != null ? "sim" : "nao") + "  pinca: " + String.format("%.2f", ratio) + (handFist ? "  PUNHO" : "")
      + "  ia(" + tracker.delegateName + "): " + Math.round(tracker.detFps) + " fps / " + Math.round(tracker.detMs) + " ms"
      + "  atraso: " + Math.round(handAgeMs) + " ms";
    int noAnchor = 0;
    for (Win w : wins) if (w.anchor == null && !w.linked && !w.kb) noAnchor++;
    String st = dragWin != null ? "mover" : sizeWin != null ? "redimensionar" : touchWin != null ? "toque" : dropT != null ? "agrupar" : fistProg > 0f ? "punho" : pend != null ? "segurando..." : "-";
    String l4 = "janelas: " + webCount() + " (+menu)" + "  sem ancora: " + noAnchor + "  acao: " + st;
    String l5 = "cam: " + fmt(camP[0]) + " " + fmt(camP[1]) + " " + fmt(camP[2]) + " m";
    if (!wins.isEmpty()) {
      float[] wt = wins.get(0).current().getTranslation();
      float dx = wt[0] - camP[0], dy = wt[1] - camP[1], dz = wt[2] - camP[2];
      l5 += "   distancia da janela 1: " + fmt((float) Math.sqrt(dx * dx + dy * dy + dz * dz)) + " m";
    }
    String l6 = "", l7 = "";
    if (!wins.isEmpty()) {
      ArPanel p = wins.get(0).panel;
      l6 = "painel 1: " + p.where + "  quadros: " + p.frames + (p.got ? "" : " (sem imagem)");
      l7 = p.err;
    }
    if (l7.length() == 0) l7 = !"ok".equals(tracker.status) ? tracker.status : tracker.note;
    String l8 = glError.length() > 0 ? glError : errorText;
    String l9 = needSpawn ? "Firmando o rastreio do ARCore... olhe em volta devagar" : (now < messageUntil ? message : "");
    ArImu im = imu;
    String l10 = focusText + "  |  imagem: " + VIEW_NAMES[viewMode]
      + "  |  hibrido: " + (hybridOn ? (im == null || !im.available ? "sem giroscopio" : fuse.status()) : "desligado");
    String l11 = "2 toques: topo-esq painel | topo-dir recentrar | topo-meio imagem | base-esq IA | base-dir foco | base-meio hibrido | meio-esq voltar ao modo original | meio-dir camera | gesto 2 dedos descendo: menu";
    ov.update(new String[]{l1, l2, l3, l4, l5, l6, l7, l8, l9, l10, l11});
  }

  private static String fmt(float v) { return String.format("%.2f", v); }

  // =============================================================
  // Mao desenhada no proprio GL (sem camada extra por cima)
  // =============================================================

  /** Quadrado em pixels de tela: centro (x,y), tamanho w x h, girado por ang. */
  private void sq(int tex, float x, float y, float w, float h, float ang, float r, float g, float b, float a) {
    float c = (float) Math.cos(ang), sn = (float) Math.sin(ang);
    float[] m = mvp;
    for (int i = 0; i < 16; i++) m[i] = 0f;
    m[0] = 2f * c * w / vw;   m[1] = -2f * sn * w / vh;
    m[4] = -2f * sn * h / vw; m[5] = -2f * c * h / vh;
    m[10] = 1f;
    m[12] = 2f * (x + pxShift) / vw - 1f; m[13] = 1f - 2f * y / vh; m[15] = 1f;
    GLES20.glUniformMatrix4fv(flatMvpLoc, 1, false, m, 0);
    GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, tex);
    GLES20.glUniform4f(flatColLoc, r * a, g * a, b * a, a);
    GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4);
  }

  private void drawHand() {
    float[] k = skel;
    if (k == null || flatProg == 0 || vw == 0) return;
    GLES20.glDisable(GLES20.GL_DEPTH_TEST);
    GLES20.glEnable(GLES20.GL_BLEND);
    GLES20.glBlendFunc(GLES20.GL_ONE, GLES20.GL_ONE_MINUS_SRC_ALPHA);
    GLES20.glUseProgram(flatProg);
    GLES20.glActiveTexture(GLES20.GL_TEXTURE0);
    GLES20.glUniform1i(flatTexLoc, 0);
    unitVerts.position(0);
    unitUvs.position(0);
    GLES20.glVertexAttribPointer(flatPosLoc, 3, GLES20.GL_FLOAT, false, 0, unitVerts);
    GLES20.glVertexAttribPointer(flatUvLoc, 2, GLES20.GL_FLOAT, false, 0, unitUvs);
    GLES20.glEnableVertexAttribArray(flatPosLoc);
    GLES20.glEnableVertexAttribArray(flatUvLoc);

    // esqueleto (sem disparidade: fica no plano da tela); so o cursor acompanha a profundidade do que ele toca
    final float shiftKeep = pxShift;
    pxShift = 0f;
    for (int[] c : CONN) {
      float x0 = k[2 * c[0]], y0 = k[2 * c[0] + 1], x1 = k[2 * c[1]], y1 = k[2 * c[1] + 1];
      float dx = x1 - x0, dy = y1 - y0;
      float len = (float) Math.sqrt(dx * dx + dy * dy);
      sq(roundTex, (x0 + x1) * 0.5f, (y0 + y1) * 0.5f, len, 2.2f * dp, (float) Math.atan2(dy, dx), 1f, 1f, 1f, 0.42f);
    }
    for (int i = 0; i < 21; i++) sq(discTex, k[2 * i], k[2 * i + 1], 5.5f * dp, 5.5f * dp, 0f, 1f, 1f, 1f, 0.6f);

    // cursor
    pxShift = shiftKeep;
    float r = 1f, g = 1f, b = 1f;
    if (pinchWasOn) { r = 0.37f; g = 0.92f; b = 0.83f; }
    else if (hoverRegion == R_BAR) { r = 1f; g = 0.84f; b = 0f; }
    else if (hoverRegion == R_CORNER) { r = 0f; g = 0.9f; b = 0.46f; }
    else if (hoverRegion == R_PLUS || hoverRegion == R_CHROME || hoverRegion == R_CURVE || hoverRegion == R_ICON || hoverRegion == R_KEY || hoverRegion == R_LINK || hoverRegion == R_BUBBLE) { r = 0.37f; g = 0.92f; b = 0.83f; }
    float dia = (pinchWasOn ? 20f : 32f) * dp;
    sq(ringTex, cx, cy, dia, dia, 0f, r, g, b, 1f);
    sq(discTex, cx, cy, 8f * dp, 8f * dp, 0f, r, g, b, 1f);

    // punho segurado: anel vermelho que enche em 1 s
    if (handFist && fistN >= 3) {
      sq(ringTex, cx, cy, 52f * dp, 52f * dp, 0f, 1f, 0.32f, 0.32f, 0.35f);
      int n = Math.round(fistProg * 28f);
      for (int i = 0; i < n; i++) {
        double a = -Math.PI / 2.0 + i * (2.0 * Math.PI / 28.0);
        sq(discTex, cx + (float) Math.cos(a) * 26f * dp, cy + (float) Math.sin(a) * 26f * dp, 6f * dp, 6f * dp, 0f, 1f, 0.32f, 0.32f, 1f);
      }
    }

    // pinca segurada no video: anel verde-agua que enche em 1 s
    if (holdProg > 0.02f) {
      sq(ringTex, cx, cy, 52f * dp, 52f * dp, 0f, 0.37f, 0.92f, 0.83f, 0.35f);
      int n = Math.round(holdProg * 28f);
      for (int i = 0; i < n; i++) {
        double a = -Math.PI / 2.0 + i * (2.0 * Math.PI / 28.0);
        sq(discTex, cx + (float) Math.cos(a) * 26f * dp, cy + (float) Math.sin(a) * 26f * dp, 6f * dp, 6f * dp, 0f, 0.37f, 0.92f, 0.83f, 1f);
      }
    }

    GLES20.glDisableVertexAttribArray(flatPosLoc);
    GLES20.glDisableVertexAttribArray(flatUvLoc);
    GLES20.glDisable(GLES20.GL_BLEND);
    GLES20.glEnable(GLES20.GL_DEPTH_TEST);
  }

  // =============================================================
  // Fundo, programas e texturas
  // =============================================================

  private void drawBackground() {
    GLES20.glDisable(GLES20.GL_DEPTH_TEST);
    GLES20.glDepthMask(false);
    GLES20.glUseProgram(bgProg);
    GLES20.glActiveTexture(GLES20.GL_TEXTURE0);
    GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, camTex);
    GLES20.glUniform1i(bgTexLoc, 0);
    bgQuad.position(0);
    bgUv.position(0);
    GLES20.glVertexAttribPointer(bgPosLoc, 2, GLES20.GL_FLOAT, false, 0, bgQuad);
    GLES20.glVertexAttribPointer(bgUvLoc, 2, GLES20.GL_FLOAT, false, 0, bgUv);
    GLES20.glEnableVertexAttribArray(bgPosLoc);
    GLES20.glEnableVertexAttribArray(bgUvLoc);
    GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4);
    GLES20.glDisableVertexAttribArray(bgPosLoc);
    GLES20.glDisableVertexAttribArray(bgUvLoc);
    GLES20.glDepthMask(true);
  }

  // =============================================================
  // Espacial 360
  // =============================================================

  private float yawNow() {
    return lastCamPose != null ? heading(lastCamPose) - (float) Math.PI : 0f;
  }

  /** Imagem 360 equiretangular (thread do GL). Entra com fade; o centro da imagem fica na frente de quem olha. */
  void startSpaceImage(Bitmap b) {
    boolean had = spKind != 0;
    hideVctl();
    releaseSpace();
    if (!ensureSpaceProg(false)) {
      b.recycle();
      act.space.say("Espacial indisponivel neste aparelho");
      act.space.left();
      return;
    }
    int[] t = new int[1];
    GLES20.glGenTextures(1, t, 0);
    GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, t[0]);
    int w = b.getWidth(), h = b.getHeight();
    boolean pot = (w & (w - 1)) == 0 && (h & (h - 1)) == 0;
    GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR);
    GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR);
    GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_S, pot ? GLES20.GL_REPEAT : GLES20.GL_CLAMP_TO_EDGE);
    GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE);
    GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0, b, 0);
    b.recycle();
    spTex = t[0];
    spKind = 1;
    spWant = true;
    spYaw = yawNow();
    if (!had) spAlpha = 0f;
  }

  /** Video 360: o MediaPlayer desenha no Surface de uma textura externa que este renderer le a cada quadro. */
  void startSpaceVideo(File f) {
    boolean had = spKind != 0;
    releaseSpace();
    if (!ensureSpaceProg(true)) {
      act.space.say("Espacial indisponivel neste aparelho");
      act.space.left();
      return;
    }
    int[] t = new int[1];
    GLES20.glGenTextures(1, t, 0);
    GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, t[0]);
    GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE);
    GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE);
    GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR);
    GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR);
    spTex = t[0];
    SurfaceTexture st = new SurfaceTexture(spTex);
    spAvail.set(false);
    st.setOnFrameAvailableListener(new SurfaceTexture.OnFrameAvailableListener() {
      @Override public void onFrameAvailable(SurfaceTexture x) { spAvail.set(true); }
    });
    spSt = st;
    spSurf = new Surface(st);
    android.opengl.Matrix.setIdentityM(spStm, 0);
    spKind = 2;
    spWant = true;
    spYaw = yawNow();
    if (!had) spAlpha = 0f;
    act.space.openVideo(f, spSurf);
  }

  /** Sai do espacial: o panorama some com fade e depois libera a textura. */
  void exitSpace() {
    hideVctl();
    spWant = false;
    act.space.left();
  }

  private void releaseSpace() {
    if (spSurf != null) { try { spSurf.release(); } catch (Throwable e) { } spSurf = null; }
    if (spSt != null) { try { spSt.release(); } catch (Throwable e) { } spSt = null; }
    if (spTex != 0) { GLES20.glDeleteTextures(1, new int[]{spTex}, 0); spTex = 0; }
    spKind = 0;
  }

  /** Fade do panorama e, no video, o quadro novo. */
  private void updateSpace(long now) {
    float dt = spLastMs == 0 ? 0.016f : Math.min(0.1f, (now - spLastMs) / 1000f);
    spLastMs = now;
    if (spKind == 0) { spAlpha = 0f; return; }
    float tgt = spWant ? 1f : 0f, step = dt / 0.7f;
    spAlpha += Math.max(-step, Math.min(step, tgt - spAlpha));
    if (spKind == 2 && spSt != null && spAvail.getAndSet(false)) {
      try { spSt.updateTexImage(); spSt.getTransformMatrix(spStm); } catch (Throwable e) { }
    }
    if (!spWant && spAlpha <= 0.005f) releaseSpace();
  }

  private boolean ensureSpaceProg(boolean oes) {
    if (spProg != 0 && spOes == oes) return true;
    if (spProg != 0) { GLES20.glDeleteProgram(spProg); spProg = 0; }
    String head = oes ? "#extension GL_OES_EGL_image_external : require\n#define OES 1\n" : "";
    String fs = head
      + "#ifdef GL_FRAGMENT_PRECISION_HIGH\nprecision highp float;\n#else\nprecision mediump float;\n#endif\n"
      + "varying vec2 v_Ndc;\n"
      + "uniform mat4 u_InvProj;\nuniform mat3 u_Rot;\nuniform float u_Yaw;\nuniform float u_A;\n"
      + "#ifdef OES\nuniform samplerExternalOES u_Tex;\nuniform mat4 u_Stm;\n#else\nuniform sampler2D u_Tex;\n#endif\n"
      + "void main() {\n"
      + "  vec4 p = u_InvProj * vec4(v_Ndc, 1.0, 1.0);\n"
      + "  vec3 w = u_Rot * normalize(p.xyz / p.w);\n"
      + "  float c = cos(u_Yaw), s = sin(u_Yaw);\n"
      + "  vec3 r = vec3(c * w.x - s * w.z, w.y, s * w.x + c * w.z);\n"
      + "  float az = atan(r.x, -r.z);\n"
      + "  float el = asin(clamp(r.y, -1.0, 1.0));\n"
      + "#ifdef OES\n"
      + "  vec2 uv = (u_Stm * vec4(az * 0.15915494 + 0.5, 0.5 + el * 0.31830989, 0.0, 1.0)).xy;\n"
      + "#else\n"
      + "  vec2 uv = vec2(az * 0.15915494 + 0.5, 0.5 - el * 0.31830989);\n"
      + "#endif\n"
      + "  vec3 col = texture2D(u_Tex, uv).rgb;\n"
      + "  gl_FragColor = vec4(col * u_A, u_A);\n"
      + "}\n";
    String vs = "attribute vec2 a_Pos;\nvarying vec2 v_Ndc;\nvoid main() { v_Ndc = a_Pos; gl_Position = vec4(a_Pos, 0.0, 1.0); }\n";
    int pr = program(vs, fs);
    if (pr == 0) return false;
    spProg = pr;
    spOes = oes;
    spPosLoc = GLES20.glGetAttribLocation(pr, "a_Pos");
    spProjLoc = GLES20.glGetUniformLocation(pr, "u_InvProj");
    spRotLoc = GLES20.glGetUniformLocation(pr, "u_Rot");
    spYawLoc = GLES20.glGetUniformLocation(pr, "u_Yaw");
    spAlphaLoc = GLES20.glGetUniformLocation(pr, "u_A");
    spTexLoc = GLES20.glGetUniformLocation(pr, "u_Tex");
    spStmLoc = GLES20.glGetUniformLocation(pr, "u_Stm");
    return true;
  }

  /** Desenha o panorama em volta da camera (so a rotacao conta, como se estivesse no infinito). */
  private void drawSpace() {
    if (spKind == 0 || spProg == 0 || spTex == 0 || spAlpha <= 0.005f) return;
    float e = spAlpha * spAlpha * (3f - 2f * spAlpha);
    Matrix.invertM(invProj, 0, proj, 0);
    for (int j = 0; j < 3; j++) for (int i = 0; i < 3; i++) rot3[j * 3 + i] = view[i * 4 + j];
    GLES20.glDisable(GLES20.GL_DEPTH_TEST);
    GLES20.glDepthMask(false);
    GLES20.glEnable(GLES20.GL_BLEND);
    GLES20.glBlendFunc(GLES20.GL_ONE, GLES20.GL_ONE_MINUS_SRC_ALPHA);
    GLES20.glUseProgram(spProg);
    GLES20.glUniformMatrix4fv(spProjLoc, 1, false, invProj, 0);
    GLES20.glUniformMatrix3fv(spRotLoc, 1, false, rot3, 0);
    GLES20.glUniform1f(spYawLoc, spYaw);
    GLES20.glUniform1f(spAlphaLoc, e);
    if (spOes) GLES20.glUniformMatrix4fv(spStmLoc, 1, false, spStm, 0);
    GLES20.glActiveTexture(GLES20.GL_TEXTURE0);
    GLES20.glBindTexture(spOes ? GLES11Ext.GL_TEXTURE_EXTERNAL_OES : GLES20.GL_TEXTURE_2D, spTex);
    GLES20.glUniform1i(spTexLoc, 0);
    spQuad.position(0);
    GLES20.glVertexAttribPointer(spPosLoc, 2, GLES20.GL_FLOAT, false, 0, spQuad);
    GLES20.glEnableVertexAttribArray(spPosLoc);
    GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4);
    GLES20.glDisableVertexAttribArray(spPosLoc);
    GLES20.glDepthMask(true);
    GLES20.glDisable(GLES20.GL_BLEND);
  }

  private static Bitmap makeBar() {
    Bitmap b = Bitmap.createBitmap(256, 32, Bitmap.Config.ARGB_8888);
    Canvas c = new Canvas(b);
    Paint p = new Paint(Paint.ANTI_ALIAS_FLAG);
    p.setColor(Color.WHITE);
    c.drawRoundRect(new RectF(0f, 6f, 256f, 26f), 10f, 10f, p);
    return b;
  }

  private static Bitmap makeCorner() {
    Bitmap b = Bitmap.createBitmap(128, 128, Bitmap.Config.ARGB_8888);
    Canvas c = new Canvas(b);
    Paint p = new Paint(Paint.ANTI_ALIAS_FLAG);
    p.setColor(Color.WHITE);
    p.setStyle(Paint.Style.STROKE);
    p.setStrokeWidth(14f);
    p.setStrokeCap(Paint.Cap.ROUND);
    Path path = new Path();
    path.moveTo(114f, 12f);
    path.lineTo(114f, 70f);
    path.quadTo(114f, 114f, 70f, 114f);
    path.lineTo(12f, 114f);
    c.drawPath(path, p);
    return b;
  }

  /** Icones brancos sobre fundo transparente (96x96): 0 home, 1 centralizar, 2 ajuda, 3 espacial, 4 apps, 5 config, 6 "+", 7 tela curva. */
  private static Bitmap makeGlyph(int k) {
    Bitmap b = Bitmap.createBitmap(96, 96, Bitmap.Config.ARGB_8888);
    Canvas c = new Canvas(b);
    Paint p = new Paint(Paint.ANTI_ALIAS_FLAG);
    p.setColor(Color.WHITE);
    p.setStyle(Paint.Style.STROKE);
    p.setStrokeWidth(7f);
    p.setStrokeCap(Paint.Cap.ROUND);
    Path pa = new Path();
    switch (k) {
      case 0:   // casa
        pa.moveTo(14f, 50f); pa.lineTo(48f, 22f); pa.lineTo(82f, 50f);
        pa.moveTo(24f, 44f); pa.lineTo(24f, 78f); pa.lineTo(41f, 78f); pa.lineTo(41f, 58f); pa.lineTo(55f, 58f); pa.lineTo(55f, 78f); pa.lineTo(72f, 78f); pa.lineTo(72f, 44f);
        c.drawPath(pa, p);
        break;
      case 1:   // mira
        c.drawCircle(48f, 48f, 11f, p);
        c.drawLine(48f, 12f, 48f, 28f, p); c.drawLine(48f, 68f, 48f, 84f, p);
        c.drawLine(12f, 48f, 28f, 48f, p); c.drawLine(68f, 48f, 84f, 48f, p);
        break;
      case 2: { // ajuda
        c.drawCircle(48f, 48f, 35f, p);
        p.setStyle(Paint.Style.FILL);
        p.setTextAlign(Paint.Align.CENTER);
        p.setTextSize(54f);
        p.setFakeBoldText(true);
        c.drawText("?", 48f, 67f, p);
        break;
      }
      case 3:   // mundos: paisagem (sol e montanhas) dentro de uma moldura
        p.setStrokeWidth(6f);
        c.drawRoundRect(new RectF(12f, 20f, 84f, 76f), 14f, 14f, p);
        c.drawCircle(63f, 39f, 6f, p);
        pa.moveTo(18f, 68f); pa.lineTo(38f, 46f); pa.lineTo(52f, 60f); pa.lineTo(62f, 52f); pa.lineTo(78f, 68f);
        c.drawPath(pa, p);
        break;
      case 4:   // apps
        p.setStrokeWidth(6f);
        c.drawRoundRect(new RectF(15f, 15f, 42f, 42f), 8f, 8f, p);
        c.drawRoundRect(new RectF(54f, 15f, 81f, 42f), 8f, 8f, p);
        c.drawRoundRect(new RectF(15f, 54f, 42f, 81f), 8f, 8f, p);
        c.drawRoundRect(new RectF(54f, 54f, 81f, 81f), 8f, 8f, p);
        break;
      case 5:   // ajustes
        c.drawLine(14f, 32f, 48f, 32f, p); c.drawLine(72f, 32f, 84f, 32f, p); c.drawCircle(60f, 32f, 10f, p);
        c.drawLine(14f, 64f, 24f, 64f, p); c.drawLine(48f, 64f, 84f, 64f, p); c.drawCircle(36f, 64f, 10f, p);
        break;
      case 6:   // +
        p.setStrokeWidth(9f);
        c.drawLine(22f, 48f, 74f, 48f, p);
        c.drawLine(48f, 22f, 48f, 74f, p);
        break;
      case 8:   // teclado: caixa com fileiras de teclas e a barra de espaco
        p.setStrokeWidth(6f);
        c.drawRoundRect(new RectF(10f, 26f, 86f, 70f), 9f, 9f, p);
        p.setStrokeWidth(7f);
        for (int i = 0; i < 4; i++) { c.drawLine(24f + i * 16f, 39f, 24.1f + i * 16f, 39f, p); c.drawLine(24f + i * 16f, 50f, 24.1f + i * 16f, 50f, p); }
        c.drawLine(30f, 60f, 66f, 60f, p);
        break;
      case 9:   // corrente: dois elos
        p.setStrokeWidth(7f);
        c.save();
        c.rotate(-45f, 48f, 48f);
        c.drawRoundRect(new RectF(8f, 36f, 56f, 60f), 12f, 12f, p);
        c.drawRoundRect(new RectF(40f, 36f, 88f, 60f), 12f, 12f, p);
        c.restore();
        break;
      default:  // tela curva: monitor visto de cima, so as laterais dobram
        p.setStrokeWidth(8f);
        pa.moveTo(14f, 34f); pa.quadTo(48f, 52f, 82f, 34f);
        pa.moveTo(14f, 34f); pa.lineTo(14f, 62f);
        pa.moveTo(82f, 34f); pa.lineTo(82f, 62f);
        pa.moveTo(14f, 62f); pa.quadTo(48f, 80f, 82f, 62f);
        c.drawPath(pa, p);
        break;
    }
    return b;
  }

  /** Bolha da janela minimizada: disco escuro com anel claro e a inicial do site. */
  private static Bitmap makeBubble(String letter) {
    Bitmap b = Bitmap.createBitmap(128, 128, Bitmap.Config.ARGB_8888);
    Canvas c = new Canvas(b);
    Paint p = new Paint(Paint.ANTI_ALIAS_FLAG);
    p.setStyle(Paint.Style.FILL);
    p.setColor(Color.argb(225, 18, 20, 28));
    c.drawCircle(64f, 64f, 60f, p);
    p.setStyle(Paint.Style.STROKE);
    p.setStrokeWidth(5f);
    p.setColor(Color.argb(170, 255, 255, 255));
    c.drawCircle(64f, 64f, 58f, p);
    p.setStyle(Paint.Style.FILL);
    p.setColor(Color.WHITE);
    p.setTextAlign(Paint.Align.CENTER);
    p.setTextSize(66f);
    p.setFakeBoldText(true);
    c.drawText(letter, 64f, 87f, p);
    return b;
  }

  /** Retangulo arredondado branco que ocupa a imagem toda (usado para destacar botoes). */
  private static Bitmap makeRound() {
    Bitmap b = Bitmap.createBitmap(64, 64, Bitmap.Config.ARGB_8888);
    Canvas c = new Canvas(b);
    Paint p = new Paint(Paint.ANTI_ALIAS_FLAG);
    p.setColor(Color.WHITE);
    c.drawRoundRect(new RectF(0f, 0f, 64f, 64f), 18f, 18f, p);
    return b;
  }

  private static Bitmap makeDisc() {
    Bitmap b = Bitmap.createBitmap(64, 64, Bitmap.Config.ARGB_8888);
    Canvas c = new Canvas(b);
    Paint p = new Paint(Paint.ANTI_ALIAS_FLAG);
    p.setColor(Color.WHITE);
    c.drawCircle(32f, 32f, 30f, p);
    return b;
  }

  private static Bitmap makeRing() {
    Bitmap b = Bitmap.createBitmap(64, 64, Bitmap.Config.ARGB_8888);
    Canvas c = new Canvas(b);
    Paint p = new Paint(Paint.ANTI_ALIAS_FLAG);
    p.setColor(Color.WHITE);
    p.setStyle(Paint.Style.STROKE);
    p.setStrokeWidth(6f);
    c.drawCircle(32f, 32f, 28f, p);
    return b;
  }

  private static int emptyTex2d() {
    int[] t = new int[1];
    GLES20.glGenTextures(1, t, 0);
    GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, t[0]);
    GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR);
    GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR);
    GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE);
    GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE);
    return t[0];
  }

  private static int bitmapTex(Bitmap bmp) {
    int t = emptyTex2d();
    GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0, bmp, 0);
    bmp.recycle();
    return t;
  }

  private int program(String vs, String fs) {
    int v = shader(GLES20.GL_VERTEX_SHADER, vs);
    int f = shader(GLES20.GL_FRAGMENT_SHADER, fs);
    if (v == 0 || f == 0) return 0;
    int p = GLES20.glCreateProgram();
    GLES20.glAttachShader(p, v);
    GLES20.glAttachShader(p, f);
    GLES20.glLinkProgram(p);
    int[] ok = new int[1];
    GLES20.glGetProgramiv(p, GLES20.GL_LINK_STATUS, ok, 0);
    if (ok[0] == 0) {
      glError = "link: " + GLES20.glGetProgramInfoLog(p);
      return 0;
    }
    return p;
  }

  private int shader(int type, String src) {
    int sh = GLES20.glCreateShader(type);
    GLES20.glShaderSource(sh, src);
    GLES20.glCompileShader(sh);
    int[] ok = new int[1];
    GLES20.glGetShaderiv(sh, GLES20.GL_COMPILE_STATUS, ok, 0);
    if (ok[0] == 0) {
      glError = "shader: " + GLES20.glGetShaderInfoLog(sh);
      return 0;
    }
    return sh;
  }

  private static FloatBuffer floatBuf(float[] a) {
    FloatBuffer fb = ByteBuffer.allocateDirect(a.length * 4).order(ByteOrder.nativeOrder()).asFloatBuffer();
    fb.put(a);
    fb.position(0);
    return fb;
  }

  private static final String BG_VS =
    "attribute vec4 a_Position;\n" +
    "attribute vec2 a_TexCoord;\n" +
    "varying vec2 v_TexCoord;\n" +
    "void main() { gl_Position = a_Position; v_TexCoord = a_TexCoord; }\n";

  private static final String BG_FS =
    "#extension GL_OES_EGL_image_external : require\n" +
    "precision mediump float;\n" +
    "varying vec2 v_TexCoord;\n" +
    "uniform samplerExternalOES u_Texture;\n" +
    "void main() { gl_FragColor = texture2D(u_Texture, v_TexCoord); }\n";

  // janela: textura externa (WebView) com cantos arredondados
  private static final String WIN_VS =
    "uniform mat4 u_Mvp;\n" +
    "uniform float u_S;\n" +
    "uniform vec2 u_HalfV;\n" +
    "attribute vec4 a_Pos;\n" +
    "attribute vec2 a_Uv;\n" +
    "varying vec2 v_Uv;\n" +
    "varying vec2 v_P;\n" +
    "void main() { gl_Position = u_Mvp * a_Pos; v_Uv = a_Uv; v_P = (a_Uv - 0.5) * 2.0 * u_HalfV; }\n";

  private static final String WIN_FS =
    "#extension GL_OES_EGL_image_external : require\n" +
    "#ifdef GL_FRAGMENT_PRECISION_HIGH\n" +
    "precision highp float;\n" +
    "#else\n" +
    "precision mediump float;\n" +
    "#endif\n" +
    "varying vec2 v_Uv;\n" +
    "varying vec2 v_P;\n" +
    "uniform samplerExternalOES u_Tex;\n" +
    "uniform mat4 u_Stm;\n" +
    "uniform vec2 u_Half;\n" +
    "uniform float u_R;\n" +
    "uniform float u_Flat;\n" +
    "uniform float u_Dim;\n" +
    "uniform vec2 u_Shade;\n" +
    "void main() {\n" +
    "  vec2 q = abs(v_P) - (u_Half - vec2(u_R));\n" +
    "  float d = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - u_R;\n" +
    "  if (d > 0.0008) discard;\n" +
    "  float al = 1.0 - smoothstep(-0.0006, 0.0006, d);\n" +
    "  vec2 uv = (u_Stm * vec4(v_Uv, 0.0, 1.0)).xy;\n" +
    "  vec3 c = texture2D(u_Tex, uv).rgb;\n" +
    "  c = mix(c, vec3(0.08, 0.09, 0.12), u_Flat) * u_Dim;\n" +
    "  float on = step(0.5, abs(u_Shade.x));\n" +
    "  float sd = on * step(0.0, u_Shade.x * v_P.x);\n" +
    "  c = mix(c, vec3(0.02, 0.03, 0.05), sd * 0.62);\n" +
    "  float seam = sd * (1.0 - smoothstep(0.0, 0.010, u_Half.x - abs(v_P.x)));\n" +
    "  c = mix(c, vec3(0.37, 0.92, 0.83), seam * 0.95);\n" +
    "  c = mix(c, vec3(1.0), smoothstep(-0.0028, -0.0010, d) * 0.22);\n" +
    "  gl_FragColor = vec4(c * al, al);\n" +
    "}\n";

  private static final String FLAT_VS =
    "uniform mat4 u_Mvp;\n" +
    "attribute vec4 a_Pos;\n" +
    "attribute vec2 a_Uv;\n" +
    "varying vec2 v_Uv;\n" +
    "void main() { gl_Position = u_Mvp * a_Pos; v_Uv = a_Uv; }\n";

  private static final String FLAT_FS =
    "precision mediump float;\n" +
    "varying vec2 v_Uv;\n" +
    "uniform sampler2D u_Tex;\n" +
    "uniform vec4 u_Col;\n" +
    "void main() { gl_FragColor = texture2D(u_Tex, v_Uv) * u_Col; }\n";
}
EOF
cat > app/src/main/java/com/vr/launcher/ArActivity.java <<'EOF'
package com.vr.launcher;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.hardware.display.DisplayManager;
import android.opengl.GLSurfaceView;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.Display;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.util.Size;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.Toast;
import com.google.ar.core.ArCoreApk;
import com.google.ar.core.CameraConfig;
import com.google.ar.core.CameraConfigFilter;
import com.google.ar.core.Config;
import com.google.ar.core.Session;
import java.io.File;
import java.util.ArrayList;
import java.util.EnumSet;
import java.util.List;

/**
 * "VR Launcher AR": versao com ARCore. As janelas ficam ancoradas no ambiente.
 * Ate 3 janelas com navegador (abas, voltar/avancar, fechar), mao, mover/redimensionar/tocar, punho fecha.
 */
public class ArActivity extends Activity {

  static final String HOME = "https://www.google.com/";
  // janela base: 960x540 px a 280 dpi (mesma densidade que o app atual usa no Moto G8)
  static final int PW = 960, PH = 540, DPI = 280;
  // mesmos enderecos dos apps do menu original (MainActivity)
  static final String[] APP_URLS = {
    "https://m.youtube.com/", "https://www.google.com/", "https://pt.m.wikipedia.org/", "https://discord.com/app",
    "https://web.whatsapp.com/", "https://www.reddit.com/", "https://www.openstreetmap.org/", "https://news.google.com/"
  };
  static final String MENU_URL = "about:menu";
  static final String KB_URL = "about:kb";
  static final String VID_URL = "about:vid";
  /** Aba do menu que a pagina deve mostrar (lida pela pagina via ArMenu.page()). */
  volatile String menuPage = "apps";

  private FrameLayout root;
  private GLSurfaceView gl;
  private ArRenderer renderer;
  private ArOverlay overlay;
  private ArHand tracker;
  /** Espacial 360: biblioteca, loja e video. */
  ArSpace space;
  private Session session;
  private boolean installRequested = false;
  private final Handler ui = new Handler(Looper.getMainLooper());
  private float density = 1f;
  private long tapL = 0, tapR = 0, tapBL = 0, tapBR = 0, tapTM = 0, tapBM = 0, tapML = 0;
  private SharedPreferences prefs;
  private ArImu imu;
  private boolean focusFixed = false;
  private List<CameraConfig> camCfgs = new ArrayList<CameraConfig>();
  private int camIdx = -1;
  private long tapMR = 0;

  private final DisplayManager.DisplayListener dl = new DisplayManager.DisplayListener() {
    @Override public void onDisplayAdded(int id) { }
    @Override public void onDisplayRemoved(int id) { }
    @Override public void onDisplayChanged(int id) {
      // celular girou entre paisagem esquerda e direita: o ARCore precisa saber
      if (id == Display.DEFAULT_DISPLAY && renderer != null) renderer.viewportChanged = true;
    }
  };

  @Override protected void onCreate(Bundle b) {
    super.onCreate(b);
    getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
    // o teclado do celular nunca aparece: so o teclado virtual do AR
    getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);
    if (android.os.Build.VERSION.SDK_INT >= 28) {
      WindowManager.LayoutParams lp = getWindow().getAttributes();
      lp.layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES;
      getWindow().setAttributes(lp);
    }
    density = getResources().getDisplayMetrics().density;

    prefs = getSharedPreferences("ar", MODE_PRIVATE);
    focusFixed = prefs.getBoolean("focusFixed", false);
    // IA da mao na GPU por padrao (a CPU chegou a 240 ms por quadro junto com o ARCore); cai para CPU se falhar
    tracker = new ArHand(getApplicationContext(), prefs.getBoolean("gpu", true));
    imu = new ArImu(getApplicationContext());
    overlay = new ArOverlay(this);
    space = new ArSpace(this);
    renderer = new ArRenderer(this, tracker);
    renderer.imu = imu;
    // padrao 0 = imagem preenchida e cortada, igual ao app original (CameraX FILL_CENTER)
    renderer.viewMode = prefs.getInt("view3", 0);
    renderer.hybridOn = prefs.getBoolean("hybrid", true);
    renderer.stereo = prefs.getBoolean("stereo", false);
    renderer.overlay = overlay;
    // janelas e abas que estavam abertas no modo original: cada item = "indice da aba atual" + "\n" + enderecos
    if (b == null) {
      try { renderer.initWins = getIntent().getStringArrayListExtra("wins"); } catch (Throwable t) { renderer.initWins = null; }
    }

    gl = new GLSurfaceView(this);
    gl.setPreserveEGLContextOnPause(true);
    gl.setEGLContextClientVersion(2);
    gl.setEGLConfigChooser(8, 8, 8, 8, 16, 0);
    gl.setRenderer(renderer);
    gl.setRenderMode(GLSurfaceView.RENDERMODE_CONTINUOUSLY);

    root = new FrameLayout(this);
    root.addView(gl, new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
    // so o painel de texto, pequeno, no canto: nada de camada de tela cheia por cima do GL
    FrameLayout.LayoutParams hud = new FrameLayout.LayoutParams((int) (520f * density), (int) (200f * density));
    hud.gravity = Gravity.TOP | Gravity.START;
    root.addView(overlay, hud);
    overlay.setVisibility(renderer.stereo ? View.GONE : View.VISIBLE);
    setContentView(root);

    DisplayManager dm = (DisplayManager) getSystemService(DISPLAY_SERVICE);
    dm.registerDisplayListener(dl, ui);
  }

  // ---- usados pelo renderer e pelo painel ----

  @SuppressWarnings("deprecation")
  int displayRotation() {
    return getWindowManager().getDefaultDisplay().getRotation();
  }

  void queueGl(Runnable r) {
    if (gl != null) gl.queueEvent(r);
  }

  /** Modo plano B do painel: o WebView fica por tras do GL, mas ainda "visivel" para o Android. */
  void addPanelView(View v, int w, int h) {
    root.addView(v, 0, new FrameLayout.LayoutParams(w, h));
  }

  // ---- ciclo de vida ----

  @Override protected void onResume() {
    super.onResume();
    if (checkSelfPermission(Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
      requestPermissions(new String[]{Manifest.permission.CAMERA}, 1);
      return;
    }
    try {
      if (session == null) {
        ArCoreApk.InstallStatus st = ArCoreApk.getInstance().requestInstall(this, !installRequested);
        if (st == ArCoreApk.InstallStatus.INSTALL_REQUESTED) {
          installRequested = true;
          return;
        }
        Session s = new Session(this);
        pickCamera(s);
        configure(s);
        session = s;
        renderer.session = s;
      }
      session.resume();
    } catch (Exception e) {
      // sem ARCore neste aparelho (ou falha ao abrir a camera): volta para o modo original
      Toast.makeText(this, "Modo 6DoF indisponivel: " + e, Toast.LENGTH_LONG).show();
      ui.postDelayed(new Runnable() { @Override public void run() { exitToOriginal(); } }, 2500);
      return;
    }
    gl.onResume();
    imu.start();
    space.resume();
  }

  @Override protected void onPause() {
    super.onPause();
    imu.stop();
    space.pause();
    if (session != null) {
      gl.onPause();
      session.pause();
    }
  }

  @Override protected void onDestroy() {
    DisplayManager dm = (DisplayManager) getSystemService(DISPLAY_SERVICE);
    dm.unregisterDisplayListener(dl);
    tracker.close();
    imu.close();
    renderer.shutdown();
    space.left();
    if (session != null) { session.close(); session = null; }
    super.onDestroy();
  }

  @Override public void onRequestPermissionsResult(int code, String[] perms, int[] res) {
    super.onRequestPermissionsResult(code, perms, res);
    if (res.length == 0 || res[0] != PackageManager.PERMISSION_GRANTED) {
      Toast.makeText(this, "Preciso da permissao da camera", Toast.LENGTH_LONG).show();
      exitToOriginal();
    }
  }

  /** Voltar = sair do modo 6DoF e voltar ao modo original. */
  @Override public void onBackPressed() {
    exitToOriginal();
  }

  @Override public void onWindowFocusChanged(boolean focus) {
    super.onWindowFocusChanged(focus);
    if (focus) {
      getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_FULLSCREEN | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
        | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY | View.SYSTEM_UI_FLAG_LAYOUT_STABLE | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
        | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION);
    }
  }

  /** Depuracao: 2 toques rapidos num canto. Topo: painel (esq) / recentrar (dir). Base: IA cpu-gpu (esq) / foco (dir). */
  @Override public boolean onTouchEvent(MotionEvent e) {
    if (e.getAction() != MotionEvent.ACTION_DOWN) return super.onTouchEvent(e);
    float w = root.getWidth(), h = root.getHeight(), z = 100f * density;
    boolean left = e.getX() < z, right = e.getX() > w - z, top = e.getY() < z, bottom = e.getY() > h - z;
    long now = System.currentTimeMillis();
    if (top && left) {
      if (now - tapL < 600) { tapL = 0; renderer.toggleMode(); } else tapL = now;
    } else if (top && right) {
      if (now - tapR < 600) { tapR = 0; renderer.recenter(); } else tapR = now;
    } else if (bottom && left) {
      if (now - tapBL < 600) { tapBL = 0; tracker.toggleDelegate(); savePrefs(); } else tapBL = now;
    } else if (bottom && right) {
      if (now - tapBR < 600) { tapBR = 0; toggleFocus(); } else tapBR = now;
    } else if (top && Math.abs(e.getX() - w / 2f) < z) {
      if (now - tapTM < 600) { tapTM = 0; renderer.toggleView(); savePrefs(); } else tapTM = now;
    } else if (bottom && Math.abs(e.getX() - w / 2f) < z) {
      if (now - tapBM < 600) { tapBM = 0; renderer.toggleHybrid(); savePrefs(); } else tapBM = now;
    } else if (left && Math.abs(e.getY() - h / 2f) < z) {
      if (now - tapML < 600) { tapML = 0; exitToOriginal(); } else tapML = now;
    } else if (right && Math.abs(e.getY() - h / 2f) < z) {
      if (now - tapMR < 600) { tapMR = 0; cycleCamera(); } else tapMR = now;
    } else {
      return super.onTouchEvent(e);
    }
    return true;
  }

  // ---- menu 3D (pagina HTML dentro de uma janela do AR) ----

  /** Chamado pela pagina do menu (thread da ponte JS). */
  void menuAction(final String a) {
    if (a == null) return;
    if ("orig".equals(a)) { exitToOriginal(); return; }
    if ("center".equals(a)) { renderer.recenter(); return; }
    if ("gpu".equals(a)) { tracker.toggleDelegate(); savePrefs(); return; }
    if ("hybrid".equals(a)) { renderer.toggleHybrid(); savePrefs(); return; }
    if ("stereo".equals(a)) {
      final boolean on = !renderer.stereo;
      queueGl(new Runnable() { @Override public void run() { renderer.setStereo(on); } });
      ui.post(new Runnable() { @Override public void run() { overlay.setVisibility(on ? View.GONE : View.VISIBLE); } });
      renderer.stereo = on;
      savePrefs();
      return;
    }
    if (a.startsWith("sp:")) { space.command(a); return; }
    if (a.startsWith("app:")) {
      try {
        final int i = Integer.parseInt(a.substring(4));
        if (i >= 0 && i < APP_URLS.length) queueGl(new Runnable() { @Override public void run() { renderer.openApp(APP_URLS[i]); } });
      } catch (Throwable t) { }
    }
  }

  // ---- espacial 360: do ArSpace (qualquer thread) para o GL ----

  void startSpaceImage(final Bitmap b) {
    queueGl(new Runnable() { @Override public void run() { renderer.startSpaceImage(b); } });
  }

  void startSpaceVideo(final File f) {
    queueGl(new Runnable() { @Override public void run() { renderer.startSpaceVideo(f); } });
  }

  void hideVctl() {
    queueGl(new Runnable() { @Override public void run() { renderer.hideVctl(); } });
  }

  void exitSpace() {
    queueGl(new Runnable() { @Override public void run() { renderer.exitSpace(); } });
  }

  /** Importar do aparelho: abre o seletor de arquivos (imagens e MP4). */
  void pickMedia() {
    runOnUiThread(new Runnable() {
      @Override public void run() {
        try {
          Intent i = new Intent(Intent.ACTION_OPEN_DOCUMENT);
          i.addCategory(Intent.CATEGORY_OPENABLE);
          i.setType("*/*");
          i.putExtra(Intent.EXTRA_MIME_TYPES, new String[]{"image/*", "video/mp4"});
          i.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true);
          startActivityForResult(i, ArSpace.REQ_PICK);
        } catch (Throwable t) {
          space.say("Nao consegui abrir o seletor");
        }
      }
    });
  }

  @Override protected void onActivityResult(int req, int res, Intent data) {
    super.onActivityResult(req, res, data);
    if (req == ArSpace.REQ_PICK) space.onPicked(res, data);
  }

  /** Tecla do teclado virtual (thread da ponte JS): vai para a thread do GL. */
  void kbKey(final String k) {
    if (k == null) return;
    queueGl(new Runnable() { @Override public void run() { renderer.kbKey(k); } });
  }

  /** Um campo de texto de uma pagina ganhou o foco: abre o teclado virtual daquela janela. */
  void pageFocus(final ArPanel p) {
    queueGl(new Runnable() { @Override public void run() { renderer.pageFocus(p); } });
  }

  String menuState() {
    return "{\"gpu\":" + tracker.wantsGpu() + ",\"hybrid\":" + renderer.hybridOn + ",\"stereo\":" + renderer.stereo + "}";
  }

  // ---- camera: mesma proporcao do app original (16:9, preenchendo a tela) ----

  private static boolean is169(Size sz) {
    if (sz == null || sz.getHeight() <= 0) return false;
    float r = Math.max(sz.getWidth(), sz.getHeight()) / (float) Math.min(sz.getWidth(), sz.getHeight());
    return Math.abs(r - 16f / 9f) < 0.03f;
  }

  /** Prefere configuracao 16:9 (textura e imagem), como o CameraX do app original; imagem de 640 a 1280 px para a IA. */
  private static int autoPick(List<CameraConfig> l) {
    int best = 0;
    float bs = -1f;
    for (int i = 0; i < l.size(); i++) {
      Size t = l.get(i).getTextureSize(), im = l.get(i).getImageSize();
      float sc = 0f;
      if (is169(t)) sc += 100f;
      if (is169(im)) sc += 50f;
      float ta = t == null ? 0f : (float) t.getWidth() * t.getHeight();
      sc += Math.min(ta, 2073600f) / 2073600f * 20f;
      int iw = im == null ? 0 : Math.max(im.getWidth(), im.getHeight());
      if (iw >= 640 && iw <= 1280) sc += 10f;
      if (sc > bs) { bs = sc; best = i; }
    }
    return best;
  }

  private void pickCamera(Session s) {
    try {
      CameraConfigFilter f = new CameraConfigFilter(s);
      f.setFacingDirection(CameraConfig.FacingDirection.BACK);
      f.setTargetFps(EnumSet.of(CameraConfig.TargetFps.TARGET_FPS_30));
      List<CameraConfig> l = s.getSupportedCameraConfigs(f);
      if (l == null || l.isEmpty()) return;
      camCfgs = l;
      int want = prefs.getInt("camcfg", -1);
      camIdx = (want >= 0 && want < l.size()) ? want : autoPick(l);
      s.setCameraConfig(l.get(camIdx));
      renderer.camCfgText = "  cfg " + (camIdx + 1) + "/" + l.size();
    } catch (Throwable t) {
      renderer.camCfgText = "  cfg ?";
    }
  }

  /** Depuracao: troca a configuracao da camera (pausa, troca e retoma a sessao). */
  private void cycleCamera() {
    if (session == null || camCfgs.size() < 2) { Toast.makeText(this, "Sem outras configuracoes de camera", Toast.LENGTH_SHORT).show(); return; }
    try {
      camIdx = (camIdx + 1) % camCfgs.size();
      prefs.edit().putInt("camcfg", camIdx).apply();
      gl.onPause();
      session.pause();
      session.setCameraConfig(camCfgs.get(camIdx));
      session.resume();
      gl.onResume();
      renderer.camCfgText = "  cfg " + (camIdx + 1) + "/" + camCfgs.size();
      renderer.onCameraChanged();
      Toast.makeText(this, "Camera: configuracao " + (camIdx + 1) + "/" + camCfgs.size(), Toast.LENGTH_SHORT).show();
    } catch (Throwable t) {
      Toast.makeText(this, "Camera: " + t, Toast.LENGTH_LONG).show();
    }
  }

  // ---- configuracao do ARCore: so o que usamos ----

  private void configure(Session s) {
    // igual ao projeto de teste: foco e imagem mais recente; o resto fica no padrao do ARCore
    Config c = new Config(s);
    c.setFocusMode(focusFixed ? Config.FocusMode.FIXED : Config.FocusMode.AUTO);
    c.setUpdateMode(Config.UpdateMode.LATEST_CAMERA_IMAGE);
    s.configure(c);
    renderer.focusText = "foco: " + (focusFixed ? "fixo (mais estavel no mundo)" : "automatico (mao mais nitida)");
  }

  private void savePrefs() {
    try {
      prefs.edit().putBoolean("focusFixed", focusFixed).putBoolean("gpu", tracker.wantsGpu())
        .putInt("view3", renderer.viewMode).putBoolean("hybrid", renderer.hybridOn).putBoolean("stereo", renderer.stereo).apply();
    } catch (Throwable t) { }
  }

  /** Volta para o modo original do VR Launcher (sem AR). */
  void exitToOriginal() {
    runOnUiThread(new Runnable() {
      @Override public void run() {
        try {
          startActivity(new Intent(ArActivity.this, MainActivity.class));
          finish();
        } catch (Throwable t) {
          Toast.makeText(ArActivity.this, "Nao consegui voltar: " + t, Toast.LENGTH_LONG).show();
        }
      }
    });
  }

  /** Teste: foco fixo evita que a lente "respire" ao chegar perto de algo, o que pode enganar o rastreio. */
  private void toggleFocus() {
    focusFixed = !focusFixed;
    try {
      if (session != null) configure(session);
      savePrefs();
      Toast.makeText(this, focusFixed ? "Foco fixo" : "Foco automatico", Toast.LENGTH_SHORT).show();
    } catch (Throwable t) {
      Toast.makeText(this, "Foco: " + t, Toast.LENGTH_LONG).show();
    }
  }
}
EOF
cat > app/src/main/java/com/vr/launcher/ArMenuPage.java <<'EOF'
package com.vr.launcher;

/** Pagina HTML gerada (menu.html). */
final class ArMenuPage {
  static final String HTML =
    "<!doctype html>\n" +
    "<html><head><meta charset=\"utf-8\">\n" +
    "<meta name=\"viewport\" content=\"width=device-width,initial-scale=1,user-scalable=no\">\n" +
    "<style>\n" +
    "*{box-sizing:border-box;-webkit-tap-highlight-color:transparent;-webkit-user-select:none;user-select:none}\n" +
    "html,body{margin:0;height:100%;background:#0e1016;color:#fff;font-family:system-ui,-apple-system,sans-serif;overflow:hidden}\n" +
    "#app{display:flex;height:100%}\n" +
    "#rail{width:168px;flex:none;padding:8px;display:flex;flex-direction:column;gap:5px;background:#151822}\n" +
    ".mi{flex:1;display:flex;align-items:center;gap:8px;padding:0 9px;border-radius:12px;font-size:14px;white-space:nowrap;background:rgba(255,255,255,.07)}\n" +
    ".mi svg{width:22px;height:22px;flex:none;fill:none;stroke:currentColor;stroke-width:1.6;stroke-linecap:round;stroke-linejoin:round}\n" +
    ".mi.on{background:rgba(255,255,255,.24)}\n" +
    ".mi:active,.ai:active,.row:active,.bt:active{background:#fff;color:#000}\n" +
    "#main{flex:1;padding:14px 16px;display:flex;flex-direction:column;min-width:0}\n" +
    "h1{font-size:13px;font-weight:300;letter-spacing:2px;opacity:.7;margin:0 0 8px;height:18px}\n" +
    ".pg{display:none;flex:1;min-height:0}\n" +
    ".pg.on{display:flex;flex-direction:column}\n" +
    ".grid{display:grid;grid-template-columns:repeat(4,1fr);grid-template-rows:repeat(2,1fr);gap:8px;flex:1}\n" +
    ".ai{border-radius:14px;background:rgba(255,255,255,.09);display:flex;flex-direction:column;align-items:center;justify-content:center;gap:6px;font-size:12px}\n" +
    ".lg{width:44px;height:44px;border-radius:12px;background:#fff;color:#000;font-weight:600;font-size:22px;display:flex;align-items:center;justify-content:center;overflow:hidden}\n" +
    ".lg img{width:30px;height:30px}\n" +
    ".row{display:flex;align-items:center;gap:12px;padding:6px 12px;border-radius:14px;background:rgba(255,255,255,.09);margin-bottom:6px;min-height:52px}\n" +
    ".chev{font-size:26px;opacity:.7;width:40px;text-align:center}\n" +
    ".hd{display:flex;align-items:center;gap:10px;margin:-2px 0 8px}\n" +
    ".back{padding:7px 14px;border-radius:14px;background:rgba(255,255,255,.12);font-size:14px}\n" +
    ".hd h1{margin:0}\n" +
    ".row .t{flex:1}\n" +
    ".row b{font-size:16px;display:block;margin-bottom:2px}\n" +
    ".row span{font-size:12px;opacity:.78;line-height:1.25;display:block}\n" +
    ".sw{width:58px;height:32px;border-radius:16px;background:rgba(255,255,255,.28);position:relative;flex:none}\n" +
    ".sw i{position:absolute;left:3px;top:3px;width:26px;height:26px;border-radius:50%;background:#fff;transition:left .15s}\n" +
    ".sw.on{background:#3ddc84}\n" +
    ".sw.on i{left:29px}\n" +
    ".hl{display:grid;grid-template-columns:1fr 1fr;gap:6px 14px;flex:1;align-content:start}\n" +
    ".hi{font-size:12.5px;line-height:1.3;opacity:.92;padding:3px 0}\n" +
    ".hi b{font-weight:600}\n" +
    ".big{font-size:26px;font-weight:300;letter-spacing:1px;margin:14px 0 4px}\n" +
    ".sub{font-size:14px;opacity:.75;line-height:1.4}\n" +
    ".bts{display:flex;gap:10px;margin-top:18px}\n" +
    ".bt{flex:1;height:58px;border-radius:14px;background:rgba(255,255,255,.12);display:flex;align-items:center;justify-content:center;font-size:16px}\n" +
    ".soon{margin:auto;text-align:center;font-size:15px;opacity:.7;line-height:1.5}\n" +
    "#p-space .hd{margin:-2px 0 6px;min-height:34px}\n" +
    "#p-space .hd h1{margin:0;flex:1}\n" +
    ".hb{display:flex;align-items:center;justify-content:center;gap:5px;height:32px;min-width:32px;padding:0 10px;border-radius:16px;background:rgba(255,255,255,.12);font-size:13px;margin-left:6px}\n" +
    ".hb svg{width:17px;height:17px;fill:none;stroke:currentColor;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}\n" +
    ".hb.on{background:#5eead4;color:#04201c}\n" +
    ".hb:active,.tl:active,.cb:active{background:#fff;color:#000}\n" +
    ".pgn{font-size:13px;opacity:.7;min-width:34px;text-align:center}\n" +
    ".sgrid{flex:1;min-height:0;display:grid;grid-template-columns:repeat(3,1fr);grid-template-rows:repeat(2,1fr);gap:8px}\n" +
    ".tl{position:relative;border-radius:14px;overflow:hidden;background:rgba(255,255,255,.09) center/cover no-repeat;display:flex;align-items:center;justify-content:center;flex-direction:column;gap:4px;font-size:13px}\n" +
    ".tl svg{width:30px;height:30px;fill:none;stroke:currentColor;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round}\n" +
    ".tl .nm{position:absolute;left:0;right:0;top:0;padding:5px 9px 14px;font-size:12px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;background:linear-gradient(rgba(0,0,0,.75),transparent);text-align:left}\n" +
    ".tl.on{box-shadow:inset 0 0 0 3px #5eead4}\n" +
    ".tl.rm{box-shadow:inset 0 0 0 2px rgba(255,130,130,.8)}\n" +
    ".tl .cf{position:absolute;inset:0;background:rgba(8,10,14,.9);display:flex;flex-direction:column;align-items:center;justify-content:center;gap:8px;font-size:12px;text-align:center;padding:4px}\n" +
    ".cf .bs{display:flex;gap:8px}\n" +
    ".cb{min-width:54px;height:30px;border-radius:15px;background:rgba(255,255,255,.18);display:flex;align-items:center;justify-content:center;font-size:13px;padding:0 10px}\n" +
    ".dlb{position:absolute;left:6px;right:6px;bottom:6px;height:26px;border-radius:13px;background:rgba(14,16,22,.9);border:1px solid rgba(255,255,255,.3);display:flex;align-items:center;justify-content:center;font-size:12px;overflow:hidden}\n" +
    ".dlb i{position:absolute;left:0;top:0;bottom:0;width:0;background:rgba(94,234,212,.85)}\n" +
    ".dlb span{position:relative;text-shadow:0 1px 3px #000}\n" +
    ".dlb.ok{background:rgba(94,234,212,.92);color:#04201c;border-color:transparent}\n" +
    ".smsg{margin:auto;text-align:center;font-size:14px;opacity:.8;line-height:1.5;display:flex;flex-direction:column;gap:12px;align-items:center}\n" +
    ".vw{flex:1;display:flex;flex-direction:column;justify-content:center;gap:14px}\n" +
    ".vn{font-size:15px;opacity:.85;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}\n" +
    ".vtop{display:flex;justify-content:space-between;font-size:13px;opacity:.8}\n" +
    ".vbar{position:relative;height:34px}\n" +
    ".vtr{position:absolute;left:0;right:0;top:13px;height:8px;border-radius:4px;background:rgba(255,255,255,.22);overflow:hidden}\n" +
    ".vf{height:100%;width:0;background:#fff}\n" +
    ".vk{position:absolute;top:8px;left:-9px;width:18px;height:18px;border-radius:50%;background:#fff}\n" +
    ".vrow{display:flex;gap:6px;justify-content:center;flex-wrap:wrap}\n" +
    ".vrow .hb{height:40px;min-width:40px;margin:0}\n" +
    "#toast{position:absolute;left:50%;bottom:8px;transform:translateX(-50%);background:rgba(0,0,0,.78);padding:6px 14px;border-radius:14px;font-size:12px;display:none;max-width:90%;text-align:center}\n" +
    "</style></head>\n" +
    "<body><div id=\"app\">\n" +
    "<div id=\"main\">\n" +
    "  <div class=\"pg\" id=\"p-help\"><div class=\"hd\"><div class=\"back\" data-go=\"cfg\">&lsaquo; Voltar</div><h1>AJUDA</h1></div><div class=\"hl\">\n" +
    "    <div class=\"hi\"><b>Pin&ccedil;a</b> (polegar + indicador) &mdash; toca e clica</div>\n" +
    "    <div class=\"hi\"><b>Pin&ccedil;a na barra</b> e arrastar &mdash; move; <b>no canto</b> e puxar &mdash; muda o tamanho</div>\n" +
    "    <div class=\"hi\"><b>Bot&otilde;es embaixo</b> &mdash; tela curva (esquerda) e teclado virtual (direita)</div>\n" +
    "    <div class=\"hi\"><b>Arrastar uma janela sobre outra</b> &mdash; agrupa; o bot&atilde;o de corrente (em cima) separa</div>\n" +
    "    <div class=\"hi\"><b>Toque duplo na barra</b> &mdash; minimiza; toque na bolha restaura</div>\n" +
    "    <div class=\"hi\"><b>Punho fechado por 1 s</b> na janela &mdash; fecha a janela</div>\n" +
    "    <div class=\"hi\"><b>Dois dedos juntos e esticados, descendo</b> &mdash; abre ou fecha o menu</div>\n" +
    "  </div></div>\n" +
    "  <div class=\"pg\" id=\"p-space\"><div class=\"hd\" id=\"sh\"></div><div id=\"sb\" style=\"flex:1;min-height:0;display:flex;flex-direction:column\"></div></div>\n" +
    "  <div class=\"pg\" id=\"p-apps\"><h1>APPS</h1><div class=\"grid\" id=\"grid\"></div></div>\n" +
    "  <div class=\"pg\" id=\"p-cfg\"><h1>CONFIGURA&Ccedil;&Otilde;ES</h1>\n" +
    "    <div class=\"row\" data-act=\"orig\"><div class=\"t\"><b>Modo 6DoF (AR)</b><span id=\"s6\">Ligado. Desligue para voltar ao modo original.</span></div><div class=\"sw on\" id=\"sw6\"><i></i></div></div>\n" +
    "    <div class=\"row\" data-act=\"gpu\"><div class=\"t\"><b>IA da m&atilde;o na GPU</b><span>Mais r&aacute;pido. Se travar, use a CPU.</span></div><div class=\"sw\" id=\"swg\"><i></i></div></div>\n" +
    "    <div class=\"row\" data-go=\"help\"><div class=\"t\"><b>Ajuda e gestos</b><span>Como usar a m&atilde;o no modo 6DoF.</span></div><div class=\"chev\">&rsaquo;</div></div>\n" +
    "    <div class=\"row\" data-act=\"stereo\"><div class=\"t\"><b>Est&eacute;reo (VR Box)</b><span>Divide a tela em duas, uma imagem para cada olho.</span></div><div class=\"sw\" id=\"sws\"><i></i></div></div>\n" +
    "    <div class=\"row\" data-act=\"hybrid\"><div class=\"t\"><b>Modo h&iacute;brido</b><span>Usa o girosc&oacute;pio quando o ARCore perde o rastreio.</span></div><div class=\"sw\" id=\"swh\"><i></i></div></div>\n" +
    "  </div>\n" +
    "</div></div>\n" +
    "<div id=\"toast\"></div>\n" +
    "<script>\n" +
    "var A=window.ArMenu,cur='home';\n" +
    "function act(a){try{A.act(a)}catch(e){}}\n" +
    "var NAMES=['YouTube','Google','Wikip\u00e9dia','Discord','WhatsApp','Reddit','Mapas','Not\u00edcias'];\n" +
    "var DOM=['youtube.com','google.com','wikipedia.org','discord.com','whatsapp.com','reddit.com','openstreetmap.org','news.google.com'];\n" +
    "var grid=document.getElementById('grid');\n" +
    "NAMES.forEach(function(n,i){var d=document.createElement('div');d.className='ai';\n" +
    "  var lg=document.createElement('div');lg.className='lg';var im=new Image();\n" +
    "  im.onerror=function(){lg.textContent=n.charAt(0);im.remove();};\n" +
    "  im.src='https://www.google.com/s2/favicons?domain='+DOM[i]+'&sz=128';lg.appendChild(im);\n" +
    "  var sp=document.createElement('span');sp.textContent=n;d.appendChild(lg);d.appendChild(sp);\n" +
    "  d.onclick=function(){act('app:'+i);};grid.appendChild(d);});\n" +
    "function show(n){cur=n;if(n==='space'){S.sel=null;S.sig='';setTimeout(sTick,0);sRender();}\n" +
    "  ['help','space','apps','cfg'].forEach(function(k){\n" +
    "    document.getElementById('p-'+k).className='pg'+(k===n?' on':'');});\n" +
    "  if(n==='cfg')refresh();}\n" +
    "function refresh(){var s={};try{s=JSON.parse(A.state())}catch(e){}\n" +
    "  document.getElementById('swg').className='sw'+(s.gpu?' on':'');\n" +
    "  document.getElementById('swh').className='sw'+(s.hybrid?' on':'');\n" +
    "  document.getElementById('sws').className='sw'+(s.stereo?' on':'');}\n" +
    "document.querySelectorAll('[data-go]').forEach(function(e){e.onclick=function(){show(e.getAttribute('data-go'));};});\n" +
    "document.querySelectorAll('[data-act]').forEach(function(e){e.onclick=function(){\n" +
    "  var a=e.getAttribute('data-act');act(a);\n" +
    "  if(a==='orig'){document.getElementById('s6').textContent='Voltando ao modo original...';document.getElementById('sw6').className='sw';}\n" +
    "  else if(a==='gpu'||a==='hybrid'||a==='stereo'){setTimeout(refresh,350);}};});\n" +
    "\n" +
    "/* ---------- Espacial 360 ---------- */\n" +
    "var IC={\n" +
    " plus:'<svg viewBox=\"0 0 24 24\"><path d=\"M12 5v14M5 12h14\"/></svg>',\n" +
    " trash:'<svg viewBox=\"0 0 24 24\"><path d=\"M4 7h16\"/><path d=\"M9 7V4h6v3\"/><path d=\"M6 7l1 13h10l1-13\"/><path d=\"M10 11v6M14 11v6\"/></svg>',\n" +
    " out:'<svg viewBox=\"0 0 24 24\"><path d=\"M14 4h5a1 1 0 0 1 1 1v14a1 1 0 0 1-1 1h-5\"/><path d=\"M10 16l-4-4 4-4M6 12h10\"/></svg>',\n" +
    " back:'<svg viewBox=\"0 0 24 24\"><path d=\"M15 5l-7 7 7 7\"/></svg>',\n" +
    " phone:'<svg viewBox=\"0 0 24 24\"><rect x=\"7\" y=\"2.5\" width=\"10\" height=\"19\" rx=\"2.5\"/><path d=\"M11 18.5h2\"/></svg>',\n" +
    " cloud:'<svg viewBox=\"0 0 24 24\"><path d=\"M7 18a4.5 4.5 0 0 1-.6-8.96A6 6 0 0 1 18 8.5a4 4 0 0 1-.5 9.5z\"/><path d=\"M12 10v6M9.5 13.5L12 16l2.5-2.5\"/></svg>',\n" +
    " restart:'<svg viewBox=\"0 0 24 24\"><path d=\"M6 5v14\"/><path d=\"M18 6l-9 6 9 6z\"/></svg>',\n" +
    " rew:'<svg viewBox=\"0 0 24 24\"><path d=\"M11 6l-7 6 7 6z\"/><path d=\"M20 6l-7 6 7 6z\"/></svg>',\n" +
    " play:'<svg viewBox=\"0 0 24 24\"><path d=\"M8 5l11 7-11 7z\"/></svg>',\n" +
    " pause:'<svg viewBox=\"0 0 24 24\"><path d=\"M9 5v14\"/><path d=\"M15 5v14\"/></svg>',\n" +
    " fwd:'<svg viewBox=\"0 0 24 24\"><path d=\"M13 6l7 6-7 6z\"/><path d=\"M4 6l7 6-7 6z\"/></svg>',\n" +
    " vol:'<svg viewBox=\"0 0 24 24\"><path d=\"M4 9h4l5-4v14l-5-4H4z\"/><path d=\"M16.5 9a4 4 0 0 1 0 6\"/><path d=\"M19 6.5a8 8 0 0 1 0 11\"/></svg>',\n" +
    " mute:'<svg viewBox=\"0 0 24 24\"><path d=\"M4 9h4l5-4v14l-5-4H4z\"/><path d=\"M17 9.5l4.5 5M21.5 9.5l-4.5 5\"/></svg>',\n" +
    " loop:'<svg viewBox=\"0 0 24 24\"><path d=\"M17 3l3 3-3 3\"/><path d=\"M4 12V9a3 3 0 0 1 3-3h13\"/><path d=\"M7 21l-3-3 3-3\"/><path d=\"M20 12v3a3 3 0 0 1-3 3H4\"/></svg>'\n" +
    "};\n" +
    "var S={view:'lib',page:0,sel:null,del:false,lib:[],cat:[],cp:0,st:{},libVer:-1,catVer:-1,msgSeq:-1,sig:'',tt:0};\n" +
    "var PER=5,PERS=6;\n" +
    "function esc(t){return String(t).replace(/[&<>\"]/g,function(c){return{'&':'&amp;','<':'&lt;','>':'&gt;','\"':'&quot;'}[c]})}\n" +
    "function fmt(ms){var s=Math.floor((ms||0)/1000),m=Math.floor(s/60),r=s%60;return m+':'+(r<10?'0':'')+r}\n" +
    "function fsz(b){if(!b)return'';if(b>=1e9)return(b/1e9).toFixed(1)+' GB';if(b>=1e6)return Math.round(b/1e6)+' MB';return Math.max(1,Math.round(b/1e3))+' KB'}\n" +
    "function hb(c,html,on){return'<div class=\"hb'+(on?' on':'')+'\" data-c=\"'+c+'\">'+html+'</div>'}\n" +
    "function pager(n,p,per){var np=Math.max(1,Math.ceil(n/per));if(np<2)return'';\n" +
    "  return hb('prev','&#8249;')+'<span class=\"pgn\">'+(p+1)+'/'+np+'</span>'+hb('next','&#8250;')}\n" +
    "function sRender(){\n" +
    "  var st=S.st||{},h=document.getElementById('sh'),b=document.getElementById('sb'),x='';\n" +
    "  if(S.view==='choose'){\n" +
    "    h.innerHTML=hb('back',IC.back+'<span>Voltar</span>')+'<h1 style=\"margin-left:10px\">IMPORTAR</h1>';\n" +
    "    b.innerHTML='<div class=\"sgrid\" style=\"grid-template-columns:1fr 1fr;grid-template-rows:1fr\">'\n" +
    "      +'<div class=\"tl\" data-c=\"dev\">'+IC.phone+'<span>Do dispositivo</span></div>'\n" +
    "      +'<div class=\"tl\" data-c=\"store\">'+IC.cloud+'<span>Da loja</span></div></div>';\n" +
    "    return}\n" +
    "  if(S.view==='store'){\n" +
    "    h.innerHTML=hb('back',IC.back+'<span>Voltar</span>')+'<h1 style=\"margin-left:10px\">LOJA</h1>'+pager(S.cat.length,S.cp,PERS);\n" +
    "    var n=S.cat.length;\n" +
    "    if(!n){\n" +
    "      b.innerHTML='<div class=\"smsg\">'+(st.loading?'Carregando cat&aacute;logo&hellip;':(st.err?esc(st.err)+'<div class=\"hb\" data-c=\"fetch\">Tentar de novo</div>':'A loja est&aacute; vazia'))+'</div>';\n" +
    "      return}\n" +
    "    var np=Math.max(1,Math.ceil(n/PERS));if(S.cp>=np)S.cp=np-1;\n" +
    "    var have=st.have||[],dl=st.dl||{},busy=Object.keys(dl).length>0;\n" +
    "    b.innerHTML='<div class=\"sgrid\">'+S.cat.slice(S.cp*PERS,S.cp*PERS+PERS).map(function(it){\n" +
    "      var bt;\n" +
    "      if(dl.hasOwnProperty(it.id)){var p=dl[it.id];bt='<div class=\"dlb\"><i data-p=\"'+esc(it.id)+'\" style=\"width:'+(p>=0?p:100)+'%\"></i><span data-t=\"'+esc(it.id)+'\">'+(p>=0?p+'%':'Baixando\u2026')+'</span></div>'}\n" +
    "      else if(have.indexOf(it.id)>=0)bt='<div class=\"dlb ok\">&#10003; Baixado</div>';\n" +
    "      else bt='<div class=\"dlb\" data-c=\"dl:'+esc(it.id)+'\"><span>Baixar'+(it.tamanho?' &middot; '+fsz(it.tamanho):'')+'</span></div>';\n" +
    "      return'<div class=\"tl\" style=\"'+(it.miniatura?'background-image:url('+JSON.stringify(it.miniatura).replace(/\"/g,\"'\")+')':'')+'\"><div class=\"nm\">'+(it.tipo==='video'?'&#9654; ':'')+esc(it.nome)+'</div>'+bt+'</div>'}).join('')+'</div>';\n" +
    "    return}\n" +
    "  // biblioteca\n" +
    "  var n2=S.lib.length,np2=Math.max(1,Math.ceil(n2/PER));if(S.page>=np2)S.page=np2-1;\n" +
    "  h.innerHTML='<h1>MUNDOS'+(st.active&&st.video?' <small style=\"opacity:.55;letter-spacing:0;font-size:11px;margin-left:8px\">pin&ccedil;a 1 s no v&iacute;deo = controles</small>':'')+'</h1>'+pager(n2,S.page,PER)\n" +
    "    +(st.active?hb('exit',IC.out+'<span>Sair</span>'):(n2?hb('trash',IC.trash,S.del):''));\n" +
    "  var cells=S.del?'':'<div class=\"tl\" data-c=\"add\">'+IC.plus+'<span>Importar</span></div>';\n" +
    "  cells+=S.lib.slice(S.page*PER,S.page*PER+PER).map(function(it){\n" +
    "    var c='<div class=\"tl'+(it.id===st.active?' on':'')+(S.del?' rm':'')+'\" data-c=\"sel:'+it.id+'\" style=\"background-image:url(/spatial/'+it.id+'_t.jpg)\"><div class=\"nm\">'+(it.type==='video'?'&#9654; ':'')+esc(it.name)+'</div>';\n" +
    "    if(S.sel===it.id&&S.del)c+='<div class=\"cf\"><span>Deletar item?</span><div class=\"bs\"><div class=\"cb\" data-c=\"yes\">Sim</div><div class=\"cb\" data-c=\"no\">N&atilde;o</div></div></div>';\n" +
    "    return c+'</div>'}).join('');\n" +
    "  b.innerHTML='<div class=\"sgrid\">'+cells+'</div>';\n" +
    "}\n" +
    "function sCmd(c){\n" +
    "  var st=S.st||{};\n" +
    "  if(c==='prev'||c==='next'){var d=c==='prev'?-1:1;\n" +
    "    if(S.view==='store'){var np=Math.max(1,Math.ceil(S.cat.length/PERS));S.cp=(S.cp+d+np)%np}\n" +
    "    else{var np2=Math.max(1,Math.ceil(S.lib.length/PER));S.page=(S.page+d+np2)%np2;S.sel=null}\n" +
    "    sRender();return}\n" +
    "  if(c==='trash'){S.del=!S.del;S.sel=null;sRender();return}\n" +
    "  if(c==='add'){S.view='choose';sRender();return}\n" +
    "  if(c==='back'){S.view=S.view==='store'?'choose':'lib';sRender();return}\n" +
    "  if(c==='dev'){S.view='lib';sRender();act('sp:import');return}\n" +
    "  if(c==='store'){S.view='store';S.cp=0;sRender();act('sp:fetch');return}\n" +
    "  if(c==='fetch'){act('sp:fetch');return}\n" +
    "  if(c==='exit'){act('sp:exit');return}\n" +
    "  if(c==='no'){S.sel=null;sRender();return}\n" +
    "  if(c==='yes'){var id=S.sel;S.sel=null;if(id){if(S.del)act('sp:del:'+id)}sRender();return}\n" +
    "  if(c.indexOf('sel:')===0){var q=c.slice(4);\n" +
    "    if(S.del){S.sel=S.sel===q?null:q;sRender();return}\n" +
    "    act('sp:enter:'+q);return}\n" +
    "  if(c.indexOf('dl:')===0){act('sp:'+c);return}\n" +
    "}\n" +
    "document.getElementById('p-space').addEventListener('click',function(e){\n" +
    "  var t=e.target;while(t&&t!==this&&!(t.getAttribute&&t.getAttribute('data-c')))t=t.parentNode;\n" +
    "  if(t&&t.getAttribute&&t.getAttribute('data-c')){\n" +
    "    if(t.getAttribute('data-c').indexOf('v:')===0||true)sCmd(t.getAttribute('data-c'));return}\n" +
    "});\n" +
    "function toast(m){var d=document.getElementById('toast');d.textContent=m;d.style.display='block';clearTimeout(S.tt);S.tt=setTimeout(function(){d.style.display='none'},3200)}\n" +
    "function sTick(){\n" +
    "  if(cur!=='space')return;\n" +
    "  var s={};try{s=JSON.parse(A.spState())}catch(e){return}\n" +
    "  var old=S.st||{};S.st=s;\n" +
    "  var re=false;\n" +
    "  if(s.libVer!==S.libVer){S.libVer=s.libVer;try{S.lib=JSON.parse(A.spLib())}catch(e){S.lib=[]}re=true}\n" +
    "  if(s.catVer!==S.catVer){S.catVer=s.catVer;try{S.cat=JSON.parse(A.spCat())}catch(e){S.cat=[]}re=true}\n" +
    "  if(s.msgSeq!==S.msgSeq){if(S.msgSeq>=0&&s.msg)toast(s.msg);S.msgSeq=s.msgSeq}\n" +
    "  var sig=[s.loading,s.err,s.active,s.video,s.playing,s.muted,s.loop,s.speed,(s.have||[]).length,Object.keys(s.dl||{}).join(',')].join('|');\n" +
    "  if(sig!==S.sig){S.sig=sig;re=true}\n" +
    "  if(re){sRender();return}\n" +
    "  var dl=s.dl||{};\n" +
    "  Object.keys(dl).forEach(function(k){var p=dl[k];\n" +
    "    document.querySelectorAll('[data-p]').forEach(function(e){if(e.getAttribute('data-p')===k)e.style.width=(p>=0?p:100)+'%'});\n" +
    "    document.querySelectorAll('[data-t]').forEach(function(e){if(e.getAttribute('data-t')===k)e.textContent=p>=0?p+'%':'Baixando\u2026'})});\n" +
    "}\n" +
    "setInterval(sTick,400);\n" +
    "var w0='apps';try{w0=A.page()||'apps'}catch(e){}show(w0);\n" +
    "</script></body></html>\n" +
    "\n";
}
EOF
cat > app/src/main/java/com/vr/launcher/ArKbPage.java <<'EOF'
package com.vr.launcher;

/** Pagina HTML gerada (kb.html). */
final class ArKbPage {
  static final String HTML =
    "<!doctype html>\n" +
    "<html><head><meta charset=\"utf-8\">\n" +
    "<meta name=\"viewport\" content=\"width=device-width,initial-scale=1,user-scalable=no\">\n" +
    "<style>\n" +
    "*{box-sizing:border-box;-webkit-tap-highlight-color:transparent;-webkit-user-select:none;user-select:none}\n" +
    "html,body{margin:0;height:100%;background:#0e1016;color:#fff;font-family:system-ui,-apple-system,sans-serif;overflow:hidden}\n" +
    "#kb{position:absolute;left:8px;right:8px;top:8px;bottom:8px;display:flex;flex-direction:column;gap:4px}\n" +
    ".r{flex:1;display:flex;gap:4px;min-height:0}\n" +
    ".k{flex:1;display:flex;align-items:center;justify-content:center;border-radius:10px;background:rgba(255,255,255,.11);font-size:22px;font-weight:400;min-width:0}\n" +
    ".k.u{flex:.8;font-size:18px;opacity:.9;background:rgba(255,255,255,.07)}\n" +
    ".k.w15{flex:1.5}\n" +
    ".k.sp{flex:5.2}\n" +
    ".k.fn{background:rgba(255,255,255,.2);font-size:17px}\n" +
    ".k.on{background:#5eead4;color:#04201c}\n" +
    ".k.p{background:#fff;color:#000}\n" +
    ".k svg{width:24px;height:24px;fill:none;stroke:currentColor;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}\n" +
    ".k.dead.on{background:#5eead4;color:#04201c}\n" +
    "</style></head><body>\n" +
    "<div id=\"kb\"></div>\n" +
    "<script>\n" +
    "(function () {\n" +
    "  var A = window.ArKb;\n" +
    "  var ICON = {\n" +
    "    back: '<svg viewBox=\"0 0 24 24\"><path d=\"M9 5h11a1 1 0 0 1 1 1v12a1 1 0 0 1-1 1H9l-6-7z\"/><path d=\"M13 9.5l5 5M18 9.5l-5 5\"/></svg>',\n" +
    "    enter: '<svg viewBox=\"0 0 24 24\"><path d=\"M20 5v8a2 2 0 0 1-2 2H5\"/><path d=\"M9 11l-4 4 4 4\"/></svg>',\n" +
    "    shift: '<svg viewBox=\"0 0 24 24\"><path d=\"M12 4l8 9h-5v7H9v-7H4z\"/></svg>',\n" +
    "    caps: '<svg viewBox=\"0 0 24 24\"><path d=\"M12 3l8 8h-5v6H9v-6H4z\"/><path d=\"M9 21h6\"/></svg>',\n" +
    "    down: '<svg viewBox=\"0 0 24 24\"><path d=\"M6 9l6 6 6-6\"/></svg>'\n" +
    "  };\n" +
    "  var ACC = {\n" +
    "    '\\u00b4': { a: '\\u00e1', e: '\\u00e9', i: '\\u00ed', o: '\\u00f3', u: '\\u00fa', A: '\\u00c1', E: '\\u00c9', I: '\\u00cd', O: '\\u00d3', U: '\\u00da', c: '\\u00e7', C: '\\u00c7' },\n" +
    "    '`': { a: '\\u00e0', e: '\\u00e8', i: '\\u00ec', o: '\\u00f2', u: '\\u00f9', A: '\\u00c0', E: '\\u00c8', I: '\\u00cc', O: '\\u00d2', U: '\\u00d9' },\n" +
    "    '^': { a: '\\u00e2', e: '\\u00ea', i: '\\u00ee', o: '\\u00f4', u: '\\u00fb', A: '\\u00c2', E: '\\u00ca', I: '\\u00ce', O: '\\u00d4', U: '\\u00db' },\n" +
    "    '~': { a: '\\u00e3', o: '\\u00f5', n: '\\u00f1', A: '\\u00c3', O: '\\u00d5', N: '\\u00d1' }\n" +
    "  };\n" +
    "  var shift = 0, sym = false, dead = null, last = 0;\n" +
    "  var el = document.getElementById('kb');\n" +
    "\n" +
    "  var LET = ['qwertyuiop', 'asdfghjkl\\u00e7', 'zxcvbnm'];\n" +
    "  var SYM = ['1234567890', '@#$%&-+()/', '*\"\\':;!?'];\n" +
    "\n" +
    "  function send(t) { try { if (A) A.key(t); } catch (e) { } }\n" +
    "  function out(ch) {\n" +
    "    var ch0 = dead !== null || shift === 1;\n" +
    "    if (dead) {\n" +
    "      var d = dead, m = ACC[d];\n" +
    "      dead = null;\n" +
    "      if (m && m[ch]) ch = m[ch];\n" +
    "      else if (ch !== ' ') ch = d + ch;\n" +
    "      else ch = d;\n" +
    "    }\n" +
    "    send('t:' + ch);\n" +
    "    if (shift === 1) { shift = 0; }\n" +
    "    if (ch0) render();\n" +
    "  }\n" +
    "  function act(a) {\n" +
    "    if (a === 'shift') { shift = shift === 0 ? 1 : (shift === 1 ? 2 : 0); render(); return; }\n" +
    "    if (a === 'sym') { sym = !sym; render(); return; }\n" +
    "    if (a === 'back') { if (dead) { dead = null; render(); } else send('k:back'); return; }\n" +
    "    if (a === 'enter') { send('k:enter'); return; }\n" +
    "    if (a === 'close') { send('k:close'); return; }\n" +
    "    if (a === 'space') { out(' '); return; }\n" +
    "    if (a.indexOf('d:') === 0) { dead = dead === a.slice(2) ? null : a.slice(2); render(); return; }\n" +
    "    if (a.indexOf('x:') === 0) { out(a.slice(2)); return; }\n" +
    "  }\n" +
    "\n" +
    "  function key(row, label, a, cls, html) {\n" +
    "    var d = document.createElement('div');\n" +
    "    d.className = 'k' + (cls ? ' ' + cls : '');\n" +
    "    if (html) d.innerHTML = html; else d.textContent = label;\n" +
    "    d.setAttribute('data-a', a);\n" +
    "    row.appendChild(d);\n" +
    "    return d;\n" +
    "  }\n" +
    "  function mk() { var r = document.createElement('div'); r.className = 'r'; el.appendChild(r); return r; }\n" +
    "\n" +
    "  function render() {\n" +
    "    el.innerHTML = '';\n" +
    "    var r = mk();\n" +
    "    ['\\u00b4', '`', '^', '~'].forEach(function (c) { key(r, c, 'd:' + c, 'u dead' + (dead === c ? ' on' : '')); });\n" +
    "    key(r, '/', 'x:/', 'u'); key(r, '.com', 'x:.com', 'u'); key(r, '@', 'x:@', 'u'); key(r, '-', 'x:-', 'u'); key(r, '_', 'x:_', 'u');\n" +
    "    key(r, '', 'close', 'u fn', ICON.down);\n" +
    "    var rows = sym ? SYM : LET;\n" +
    "    for (var i = 0; i < 3; i++) {\n" +
    "      r = mk();\n" +
    "      if (i === 2) key(r, '', 'shift', 'w15 fn' + (shift ? ' on' : ''), shift === 2 ? ICON.caps : ICON.shift);\n" +
    "      if (i === 2 && sym) { /* simbolos: sem shift */ r.firstChild.style.visibility = 'hidden'; }\n" +
    "      rows[i].split('').forEach(function (c) {\n" +
    "        var ch = (!sym && shift) ? c.toUpperCase() : c;\n" +
    "        key(r, ch, 'x:' + ch, '');\n" +
    "      });\n" +
    "      if (i === 2) key(r, '', 'back', 'w15 fn', ICON.back);\n" +
    "    }\n" +
    "    r = mk();\n" +
    "    key(r, sym ? 'abc' : '?123', 'sym', 'w15 fn');\n" +
    "    key(r, '', 'x:,', '', null).textContent = ',';\n" +
    "    key(r, '', 'space', 'sp').textContent = '';\n" +
    "    key(r, '.', 'x:.', '');\n" +
    "    key(r, '', 'enter', 'w15 fn', ICON.enter);\n" +
    "  }\n" +
    "\n" +
    "  function hit(e) {\n" +
    "    var t = e.target;\n" +
    "    while (t && t !== el && !(t.getAttribute && t.getAttribute('data-a'))) t = t.parentNode;\n" +
    "    return (t && t.getAttribute) ? t : null;\n" +
    "  }\n" +
    "  var rep = null, repT = null;\n" +
    "  function stopRep() { if (rep) { clearTimeout(rep); rep = null; } if (repT) { clearInterval(repT); repT = null; } }\n" +
    "  document.addEventListener('touchstart', function (e) {\n" +
    "    e.preventDefault();\n" +
    "    var t = hit(e);\n" +
    "    if (!t) return;\n" +
    "    var now = Date.now();\n" +
    "    if (now - last < 70) return;\n" +
    "    last = now;\n" +
    "    var a = t.getAttribute('data-a');\n" +
    "    t.classList.add('p');\n" +
    "    setTimeout(function () { t.classList.remove('p'); }, 130);\n" +
    "    act(a);\n" +
    "    if (a === 'back') {\n" +
    "      stopRep();\n" +
    "      rep = setTimeout(function () { repT = setInterval(function () { send('k:back'); }, 70); }, 450);\n" +
    "    }\n" +
    "  }, { passive: false });\n" +
    "  document.addEventListener('touchend', stopRep, true);\n" +
    "  document.addEventListener('touchcancel', stopRep, true);\n" +
    "  render();\n" +
    "})();\n" +
    "</script>\n" +
    "</body></html>\n" +
    "\n";
}
EOF
cat > app/src/main/java/com/vr/launcher/ArVidPage.java <<'EOF'
package com.vr.launcher;

/** Pagina HTML gerada (vid.html). */
final class ArVidPage {
  static final String HTML =
    "<!doctype html>\n" +
    "<html><head><meta charset=\"utf-8\">\n" +
    "<meta name=\"viewport\" content=\"width=device-width,initial-scale=1,user-scalable=no\">\n" +
    "<style>\n" +
    "*{box-sizing:border-box;-webkit-tap-highlight-color:transparent;-webkit-user-select:none;user-select:none}\n" +
    "html,body{margin:0;height:100%;background:#0e1016;color:#fff;font-family:system-ui,-apple-system,sans-serif;overflow:hidden}\n" +
    "#w{position:absolute;inset:0;padding:16px 22px;display:flex;flex-direction:column;justify-content:space-between}\n" +
    ".top{display:flex;align-items:center;gap:10px}\n" +
    ".nm{flex:1;font-size:16px;opacity:.85;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;letter-spacing:.5px}\n" +
    ".tm{display:flex;justify-content:space-between;font-size:14px;opacity:.8;font-variant-numeric:tabular-nums}\n" +
    ".bar{position:relative;height:40px}\n" +
    ".tr{position:absolute;left:0;right:0;top:16px;height:8px;border-radius:4px;background:rgba(255,255,255,.22);overflow:hidden}\n" +
    ".vf{height:100%;width:0;background:#fff}\n" +
    ".vk{position:absolute;top:10px;left:-10px;width:20px;height:20px;border-radius:50%;background:#fff}\n" +
    ".row{display:flex;gap:8px;justify-content:center}\n" +
    ".b{display:flex;align-items:center;justify-content:center;gap:4px;height:52px;min-width:52px;padding:0 12px;border-radius:26px;background:rgba(255,255,255,.12);font-size:15px}\n" +
    ".b svg{width:24px;height:24px;fill:none;stroke:currentColor;stroke-width:1.9;stroke-linecap:round;stroke-linejoin:round}\n" +
    ".b.on{background:#5eead4;color:#04201c}\n" +
    ".b:active{background:#fff;color:#000}\n" +
    ".x{height:40px;min-width:40px;border-radius:20px}\n" +
    "</style></head><body><div id=\"w\">\n" +
    "<div class=\"top\"><div class=\"nm\" id=\"nm\"></div><div class=\"b x\" data-c=\"close\"><svg viewBox=\"0 0 24 24\"><path d=\"M6 6l12 12M18 6L6 18\"/></svg></div></div>\n" +
    "<div><div class=\"tm\"><span id=\"tt\">0:00 / 0:00</span><span id=\"sp\">1&times;</span></div>\n" +
    "<div class=\"bar\" id=\"bar\"><div class=\"tr\"><div class=\"vf\" id=\"vf\"></div></div><div class=\"vk\" id=\"vk\"></div></div></div>\n" +
    "<div class=\"row\" id=\"row\"></div>\n" +
    "</div>\n" +
    "<script>\n" +
    "var A=window.ArMenu;\n" +
    "function act(a){try{A.act(a)}catch(e){}}\n" +
    "var IC={\n" +
    " restart:'<svg viewBox=\"0 0 24 24\"><path d=\"M6 5v14\"/><path d=\"M18 6l-9 6 9 6z\"/></svg>',\n" +
    " rew:'<svg viewBox=\"0 0 24 24\"><path d=\"M11 6l-7 6 7 6z\"/><path d=\"M20 6l-7 6 7 6z\"/></svg>',\n" +
    " play:'<svg viewBox=\"0 0 24 24\"><path d=\"M8 5l11 7-11 7z\"/></svg>',\n" +
    " pause:'<svg viewBox=\"0 0 24 24\"><path d=\"M9 5v14\"/><path d=\"M15 5v14\"/></svg>',\n" +
    " fwd:'<svg viewBox=\"0 0 24 24\"><path d=\"M13 6l7 6-7 6z\"/><path d=\"M4 6l7 6-7 6z\"/></svg>',\n" +
    " vol:'<svg viewBox=\"0 0 24 24\"><path d=\"M4 9h4l5-4v14l-5-4H4z\"/><path d=\"M16.5 9a4 4 0 0 1 0 6\"/><path d=\"M19 6.5a8 8 0 0 1 0 11\"/></svg>',\n" +
    " mute:'<svg viewBox=\"0 0 24 24\"><path d=\"M4 9h4l5-4v14l-5-4H4z\"/><path d=\"M17 9.5l4.5 5M21.5 9.5l-4.5 5\"/></svg>',\n" +
    " loop:'<svg viewBox=\"0 0 24 24\"><path d=\"M17 3l3 3-3 3\"/><path d=\"M4 12V9a3 3 0 0 1 3-3h13\"/><path d=\"M7 21l-3-3 3-3\"/><path d=\"M20 12v3a3 3 0 0 1-3 3H4\"/></svg>'\n" +
    "};\n" +
    "function fmt(ms){var s=Math.floor((ms||0)/1000),m=Math.floor(s/60),r=s%60;return m+':'+(r<10?'0':'')+r}\n" +
    "function bt(c,h,on){return'<div class=\"b'+(on?' on':'')+'\" data-c=\"'+c+'\">'+h+'</div>'}\n" +
    "var S={},sig='',dur=0;\n" +
    "function render(){\n" +
    "  document.getElementById('row').innerHTML=bt('seek:0',IC.restart)+bt('rel:-10000',IC.rew+'<span>10</span>')+bt('play',S.playing?IC.pause:IC.play)\n" +
    "   +bt('rel:10000','<span>10</span>'+IC.fwd)+bt('speed','<span>'+(S.speed||1)+'&times;</span>')+bt('mute',S.muted?IC.mute:IC.vol)+bt('loop',IC.loop,S.loop);\n" +
    "}\n" +
    "function tick(){\n" +
    "  var s;try{s=JSON.parse(A.spState())}catch(e){return}\n" +
    "  S=s;dur=s.dur||0;\n" +
    "  var g=[s.playing,s.muted,s.loop,s.speed].join('|');\n" +
    "  if(g!==sig){sig=g;render()}\n" +
    "  document.getElementById('nm').textContent=s.name||'';\n" +
    "  document.getElementById('tt').textContent=fmt(s.pos)+' / '+fmt(s.dur);\n" +
    "  document.getElementById('sp').innerHTML=(s.speed||1)+'&times;';\n" +
    "  var f=dur>0?Math.min(1,s.pos/dur):0;\n" +
    "  document.getElementById('vf').style.width=(f*100)+'%';\n" +
    "  document.getElementById('vk').style.left='calc('+(f*100)+'% - 10px)';\n" +
    "}\n" +
    "document.addEventListener('click',function(e){\n" +
    "  var t=e.target;while(t&&t!==document&&!(t.getAttribute&&t.getAttribute('data-c')))t=t.parentNode;\n" +
    "  if(t&&t.getAttribute&&t.getAttribute('data-c')){var c=t.getAttribute('data-c');\n" +
    "    if(c==='close')act('sp:vclose');else act('sp:v:'+c);setTimeout(tick,250);return}\n" +
    "  var bar=document.getElementById('bar');\n" +
    "  if(bar.contains(e.target)&&dur>0){var r=bar.getBoundingClientRect();\n" +
    "    act('sp:v:seek:'+Math.round(Math.max(0,Math.min(1,(e.clientX-r.left)/r.width))*dur));setTimeout(tick,250)}\n" +
    "});\n" +
    "render();tick();setInterval(tick,400);\n" +
    "</script></body></html>\n" +
    "\n";
}
EOF
cat > app/src/main/java/com/vr/launcher/ArSpace.java <<'EOF'
package com.vr.launcher;

import android.content.ClipData;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.MediaMetadataRetriever;
import android.media.MediaPlayer;
import android.media.PlaybackParams;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;
import android.provider.OpenableColumns;
import android.view.Surface;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicBoolean;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 * Espacial 360 do modo 6DoF: biblioteca (a mesma pasta "spatial" do modo original), loja do GitHub,
 * importacao do aparelho e player de video 360. A tela fica na pagina do menu (ArMenuPage); aqui so tem logica.
 */
final class ArSpace {

  static final int REQ_PICK = 7001;
  static final String STORE_URL = "https://raw.githubusercontent.com/GabrielOliveira64/VrLauncher/main/loja/catalogo.json";
  static final float[] SPEEDS = {0.5f, 0.75f, 1f, 1.25f, 1.5f, 2f};

  private final ArActivity act;
  private final File dir;
  private final Handler ui = new Handler(Looper.getMainLooper());

  // estado lido pela pagina (por polling)
  volatile int libVer = 0, catVer = 0, msgSeq = 0;
  volatile boolean loading = false;
  volatile String err = "", msg = "", catJson = "[]";
  volatile String active = "";
  volatile boolean activeVideo = false;
  volatile String activeName = "";
  private final ConcurrentHashMap<String, Integer> dl = new ConcurrentHashMap<String, Integer>();
  private final HashMap<String, String[]> catItems = new HashMap<String, String[]>();   // id -> {url, tipo, nome}
  private final AtomicBoolean busy = new AtomicBoolean(false);
  private int cnt = 0;
  private String lastId = null, note = "";

  // player de video 360
  private MediaPlayer mp = null;
  private volatile boolean ready = false;
  private boolean wantPlay = true, muted = false, loop = true, resumeAfter = false;
  private int spd = 2;
  private volatile int pos = 0, dur = 0;
  private volatile boolean playing = false;
  private Runnable tick;

  ArSpace(ArActivity act) {
    this.act = act;
    this.dir = new File(act.getFilesDir(), "spatial");
    this.dir.mkdirs();
  }

  void say(String m) {
    msg = m == null ? "" : m;
    msgSeq++;
  }

  static String q(String s) {
    if (s == null) s = "";
    StringBuilder b = new StringBuilder("\"");
    for (int i = 0; i < s.length(); i++) {
      char c = s.charAt(i);
      if (c == '"') b.append("\\\"");
      else if (c == '\\') b.append("\\\\");
      else if (c == '\n') b.append("\\n");
      else if (c == '\r') b.append("\\r");
      else if (c == '\t') b.append("\\t");
      else if (c < 32 || c == ' ' || c == ' ') b.append(String.format("\\u%04x", (int) c));
      else b.append(c);
    }
    return b.append('"').toString();
  }

  // =============================================================
  // Comandos vindos da pagina do menu ("sp:...")
  // =============================================================

  void command(String a) {
    if (a == null || !a.startsWith("sp:")) return;
    String c = a.substring(3);
    if (c.startsWith("enter:")) enter(c.substring(6));
    else if (c.equals("exit")) act.exitSpace();
    else if (c.equals("vclose")) act.hideVctl();
    else if (c.startsWith("del:")) delete(c.substring(4));
    else if (c.equals("import")) act.pickMedia();
    else if (c.equals("fetch")) fetchCatalog();
    else if (c.startsWith("dl:")) download(c.substring(3));
    else if (c.startsWith("v:")) videoCmd(c.substring(2));
  }

  // =============================================================
  // Biblioteca
  // =============================================================

  /** Lista da biblioteca em JSON: [{"id","name","type"}], mais novos primeiro. */
  String libJson() {
    JSONArray arr = new JSONArray();
    try {
      File[] fs = dir.listFiles();
      if (fs != null) {
        ArrayList<String> ids = new ArrayList<String>();
        for (File f : fs) { String n = f.getName(); if (n.endsWith(".txt")) ids.add(n.substring(0, n.length() - 4)); }
        Collections.sort(ids, Collections.reverseOrder());
        for (String id : ids) {
          boolean isV = new File(dir, id + ".mp4").exists();
          if (!isV && !new File(dir, id + ".jpg").exists()) continue;
          JSONObject jo = new JSONObject();
          jo.put("id", id);
          jo.put("name", readText(new File(dir, id + ".txt"), id));
          jo.put("type", isV ? "video" : "image");
          arr.put(jo);
        }
      }
    } catch (Throwable e) { }
    return arr.toString();
  }

  private static String readText(File f, String def) {
    try {
      FileInputStream fi = new FileInputStream(f);
      try {
        byte[] bb = new byte[(int) Math.min(f.length(), 400L)];
        int rd = fi.read(bb);
        return new String(bb, 0, Math.max(rd, 0), "UTF-8");
      } finally { fi.close(); }
    } catch (Throwable e) { return def; }
  }

  private static void writeText(File f, String t) throws Exception {
    FileOutputStream fo = new FileOutputStream(f);
    try { fo.write(t.getBytes("UTF-8")); } finally { fo.close(); }
  }

  boolean delete(String id) {
    if (id == null || !id.matches("[0-9]+")) return false;
    if (id.equals(active)) act.exitSpace();
    boolean ok = false;
    String[] sf = {".jpg", ".mp4", "_t.jpg", ".txt", ".src"};
    for (String s : sf) { File f = new File(dir, id + s); if (f.exists() && f.delete()) ok = true; }
    libVer++;
    if (!ok) say("Nao consegui deletar");
    return ok;
  }

  /** Miniatura da biblioteca para a pagina do menu: /spatial/ID_t.jpg. */
  InputStream thumb(String name) {
    try {
      if (name == null || !name.matches("[0-9]+_t\\.jpg")) return null;
      File f = new File(dir, name);
      return f.exists() ? new FileInputStream(f) : null;
    } catch (Throwable e) { return null; }
  }

  File imageFile(String id) { return new File(dir, id + ".jpg"); }
  File videoFile(String id) { return new File(dir, id + ".mp4"); }

  /** Entra no item: imagem 360 (decodifica e manda ao GL) ou video 360 (MediaPlayer no Surface do GL). */
  void enter(final String id) {
    if (id == null || !id.matches("[0-9]+")) return;
    // tocar no mundo que ja esta aberto = sair dele
    if (id.equals(active)) { act.exitSpace(); return; }
    final File v = videoFile(id), j = imageFile(id);
    activeName = readText(new File(dir, id + ".txt"), "");
    if (v.exists()) {
      active = id;
      activeVideo = true;
      act.startSpaceVideo(v);
    } else if (j.exists()) {
      active = id;
      activeVideo = false;
      closeVideo();
      new Thread(new Runnable() {
        @Override public void run() {
          try {
            BitmapFactory.Options o = new BitmapFactory.Options();
            Bitmap b = BitmapFactory.decodeFile(j.getAbsolutePath(), o);
            if (b == null) throw new Exception("imagem invalida");
            act.startSpaceImage(b);
          } catch (Throwable t) {
            say("Nao consegui abrir a imagem");
            active = "";
          }
        }
      }).start();
    }
  }

  /** O renderer saiu do modo espacial. */
  void left() {
    active = "";
    activeVideo = false;
    closeVideo();
  }

  // =============================================================
  // Loja (catalogo no GitHub)
  // =============================================================

  private static boolean storeUrlOk(String u) {
    if (u == null) return false;
    String l = u.toLowerCase();
    return l.startsWith("https://github.com/gabrieloliveira64/") || l.startsWith("https://raw.githubusercontent.com/gabrieloliveira64/");
  }

  void fetchCatalog() {
    if (loading) return;
    loading = true;
    err = "";
    new Thread(new Runnable() {
      @Override public void run() {
        String res = "[]", e = "";
        try {
          java.net.HttpURLConnection c = (java.net.HttpURLConnection) new java.net.URL(STORE_URL + "?t=" + System.currentTimeMillis()).openConnection();
          c.setConnectTimeout(15000);
          c.setReadTimeout(15000);
          c.setRequestProperty("Cache-Control", "no-cache");
          int code = c.getResponseCode();
          if (code != 200) throw new Exception(code == 404 ? "Catalogo nao encontrado (404)" : "Erro HTTP " + code);
          InputStream in = c.getInputStream();
          ByteArrayOutputStream bo = new ByteArrayOutputStream();
          byte[] b = new byte[8192];
          int n;
          while ((n = in.read(b)) > 0) { bo.write(b, 0, n); if (bo.size() > 1000000) throw new Exception("Catalogo grande demais"); }
          in.close();
          JSONArray src = new JSONArray(bo.toString("UTF-8")), out = new JSONArray();
          HashMap<String, String[]> items = new HashMap<String, String[]>();
          for (int i = 0; i < src.length(); i++) {
            JSONObject o = src.optJSONObject(i);
            if (o == null) continue;
            String id = o.optString("id", ""), tp = o.optString("tipo", ""), url = o.optString("url", ""), th = o.optString("miniatura", "");
            if (!id.matches("[A-Za-z0-9_-]{1,60}") || !(tp.equals("imagem") || tp.equals("video")) || !storeUrlOk(url)) continue;
            String nome = o.optString("nome", id);
            JSONObject r = new JSONObject();
            r.put("id", id);
            r.put("nome", nome);
            r.put("tipo", tp);
            r.put("tamanho", o.optLong("tamanho", 0));
            r.put("miniatura", storeUrlOk(th) ? th : "");
            out.put(r);
            items.put(id, new String[]{url, tp, nome});
          }
          res = out.toString();
          synchronized (catItems) { catItems.clear(); catItems.putAll(items); }
        } catch (Throwable t) {
          e = String.valueOf(t.getMessage());
          if (t instanceof java.net.UnknownHostException) e = "Sem conexao com a internet";
        }
        catJson = res;
        err = e;
        loading = false;
        catVer++;
      }
    }).start();
  }

  /** Ids da loja que ja estao na biblioteca (arquivo .src guarda o id da loja). */
  String haveJson() {
    StringBuilder b = new StringBuilder("[");
    boolean first = true;
    try {
      File[] fs = dir.listFiles();
      if (fs != null) for (File f : fs) {
        String n = f.getName();
        if (!n.endsWith(".src")) continue;
        String id = n.substring(0, n.length() - 4);
        if (!new File(dir, id + ".mp4").exists() && !new File(dir, id + ".jpg").exists()) continue;
        if (!first) b.append(',');
        first = false;
        b.append(q(readText(f, "")));
      }
    } catch (Throwable e) { }
    return b.append(']').toString();
  }

  void download(final String sid) {
    final String[] it;
    synchronized (catItems) { it = catItems.get(sid); }
    if (it == null) { say("Item invalido"); return; }
    if (!busy.compareAndSet(false, true)) { say("Aguarde o download atual"); return; }
    dl.put(sid, 0);
    final String url = it[0], tipo = it[1], nome = it[2];
    new Thread(new Runnable() {
      @Override public void run() {
        boolean isV = "video".equals(tipo);
        String id = String.valueOf(System.currentTimeMillis() * 10 + (cnt++ % 10));
        File tmp = new File(dir, id + ".part"), mp4 = new File(dir, id + ".mp4");
        boolean ok = false;
        String e = "";
        try {
          java.net.HttpURLConnection c = (java.net.HttpURLConnection) new java.net.URL(url).openConnection();
          c.setConnectTimeout(15000);
          c.setReadTimeout(30000);
          int code = c.getResponseCode();
          if (code != 200) throw new Exception("Erro HTTP " + code);
          long len = c.getContentLength();
          InputStream in = c.getInputStream();
          FileOutputStream fo = new FileOutputStream(isV ? mp4 : tmp);
          long got = 0, lastMs = 0;
          int lastP = -2;
          try {
            byte[] buf = new byte[65536];
            int n;
            while ((n = in.read(buf)) > 0) {
              fo.write(buf, 0, n);
              got += n;
              long now = android.os.SystemClock.elapsedRealtime();
              int p = len > 0 ? (int) (got * 100 / len) : -1;
              if (p != lastP && now - lastMs > 200) { lastP = p; lastMs = now; dl.put(sid, p); }
            }
          } finally { fo.close(); in.close(); }
          if (len > 0 && got != len) throw new Exception("Download incompleto");
          if (isV) {
            finishVideo(id, mp4, nome);
            writeText(new File(dir, id + ".src"), sid);
          } else {
            lastId = null;
            importImageFile(tmp, nome);
            if (lastId == null) throw new Exception("Nao consegui processar a imagem");
            writeText(new File(dir, lastId + ".src"), sid);
          }
          ok = true;
        } catch (Throwable t) {
          e = String.valueOf(t.getMessage());
          if (t instanceof java.net.UnknownHostException) e = "Sem conexao com a internet";
        } finally {
          tmp.delete();
          if (!ok) { mp4.delete(); new File(dir, id + "_t.jpg").delete(); new File(dir, id + ".txt").delete(); }
          busy.set(false);
          dl.remove(sid);
        }
        libVer++;
        say(ok ? "Baixado e adicionado a biblioteca" : (e.length() == 0 ? "Falha no download" : e));
      }
    }).start();
  }

  // =============================================================
  // Importar do aparelho
  // =============================================================

  void onPicked(int res, Intent data) {
    final ArrayList<Uri> uris = new ArrayList<Uri>();
    if (res == android.app.Activity.RESULT_OK && data != null) {
      ClipData cd = data.getClipData();
      if (cd != null) { for (int i = 0; i < cd.getItemCount(); i++) uris.add(cd.getItemAt(i).getUri()); }
      else if (data.getData() != null) uris.add(data.getData());
    }
    if (uris.isEmpty()) return;
    new Thread(new Runnable() {
      @Override public void run() {
        say("Importando...");
        int ok = 0;
        String e = "";
        for (Uri u : uris) {
          try { importUri(u); ok++; } catch (Throwable t) { e = String.valueOf(t.getMessage()); }
        }
        String m = ok > 0 ? (ok == 1 ? "Item importado" : ok + " itens importados") : ("Nao consegui importar: " + e);
        if (ok > 0 && note.length() > 0) m += " - " + note;
        note = "";
        libVer++;
        say(m);
      }
    }).start();
  }

  private void importUri(Uri u) throws Exception {
    String name = "imagem";
    Cursor c = act.getContentResolver().query(u, new String[]{OpenableColumns.DISPLAY_NAME}, null, null, null);
    if (c != null) { try { if (c.moveToFirst() && c.getString(0) != null) name = c.getString(0); } finally { c.close(); } }
    String low = name.toLowerCase();
    String mt = act.getContentResolver().getType(u);
    boolean vid = (mt != null && mt.startsWith("video/")) || low.endsWith(".mp4") || low.endsWith(".m4v");
    int dot = name.lastIndexOf('.');
    if (dot > 0) name = name.substring(0, dot);
    String id = String.valueOf(System.currentTimeMillis() * 10 + (cnt++ % 10));
    File out = new File(dir, id + (vid ? ".mp4" : ".part"));
    boolean ok = false;
    try {
      InputStream in = act.getContentResolver().openInputStream(u);
      if (in == null) throw new Exception("nao consegui abrir o arquivo");
      FileOutputStream fo = new FileOutputStream(out);
      try { byte[] buf = new byte[65536]; int n; while ((n = in.read(buf)) > 0) fo.write(buf, 0, n); }
      finally { fo.close(); in.close(); }
      if (vid) finishVideo(id, out, name); else importImageFile(out, name);
      ok = true;
    } finally {
      if (!vid) out.delete();
      else if (!ok) out.delete();
    }
  }

  /** Imagem equiretangular (2:1) reduzida para 1024, 2048 ou 4096 de largura, com miniatura. */
  private void importImageFile(File f, String name) throws Exception {
    BitmapFactory.Options o = new BitmapFactory.Options();
    o.inJustDecodeBounds = true;
    BitmapFactory.decodeFile(f.getAbsolutePath(), o);
    if (o.outWidth <= 0 || o.outHeight <= 0) throw new Exception("formato nao suportado (use JPG ou PNG)");
    int tw = o.outWidth >= 3072 ? 4096 : (o.outWidth >= 1536 ? 2048 : 1024), th = tw / 2;
    int ss = 1;
    while (o.outWidth / (ss * 2) >= tw) ss *= 2;
    BitmapFactory.Options o2 = new BitmapFactory.Options();
    o2.inSampleSize = ss;
    Bitmap b = BitmapFactory.decodeFile(f.getAbsolutePath(), o2);
    if (b == null) throw new Exception("nao consegui ler a imagem");
    Bitmap s = (b.getWidth() == tw && b.getHeight() == th) ? b : Bitmap.createScaledBitmap(b, tw, th, true);
    if (s != b) b.recycle();
    String id = String.valueOf(System.currentTimeMillis() * 10 + (cnt++ % 10));
    FileOutputStream fo = new FileOutputStream(new File(dir, id + ".jpg"));
    try { s.compress(Bitmap.CompressFormat.JPEG, 90, fo); } finally { fo.close(); }
    Bitmap t = Bitmap.createScaledBitmap(s, 320, 160, true);
    fo = new FileOutputStream(new File(dir, id + "_t.jpg"));
    try { t.compress(Bitmap.CompressFormat.JPEG, 80, fo); } finally { fo.close(); }
    writeText(new File(dir, id + ".txt"), name);
    lastId = id;
    t.recycle();
    s.recycle();
  }

  /** Confere que o MP4 e um video, gera a miniatura e o nome. */
  private void finishVideo(String id, File mp4, String name) throws Exception {
    MediaMetadataRetriever mr = new MediaMetadataRetriever();
    Bitmap fr = null;
    int vw = 0;
    try {
      mr.setDataSource(mp4.getAbsolutePath());
      String ws = mr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH);
      if (ws != null) vw = Integer.parseInt(ws);
      fr = mr.getFrameAtTime(1000000L, MediaMetadataRetriever.OPTION_CLOSEST_SYNC);
      if (fr == null) fr = mr.getFrameAtTime();
    } finally { mr.release(); }
    if (vw <= 0) throw new Exception("nao parece um video MP4 valido");
    Bitmap t = fr != null ? Bitmap.createScaledBitmap(fr, 320, 160, true) : Bitmap.createBitmap(320, 160, Bitmap.Config.ARGB_8888);
    FileOutputStream fo = new FileOutputStream(new File(dir, id + "_t.jpg"));
    try { t.compress(Bitmap.CompressFormat.JPEG, 80, fo); } finally { fo.close(); }
    writeText(new File(dir, id + ".txt"), name);
    if (vw > 3840) note = "video acima de 4K pode travar neste celular";
  }

  // =============================================================
  // Player de video 360 (MediaPlayer desenhando no Surface do GL)
  // =============================================================

  void openVideo(final File f, final Surface sf) {
    ui.post(new Runnable() {
      @Override public void run() {
        closeVideoNow();
        wantPlay = true;
        try {
          final MediaPlayer m = new MediaPlayer();
          mp = m;
          ready = false;
          pos = 0;
          dur = 0;
          m.setDataSource(f.getAbsolutePath());
          m.setSurface(sf);
          m.setLooping(loop);
          m.setVolume(muted ? 0f : 1f, muted ? 0f : 1f);
          m.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
            @Override public void onPrepared(MediaPlayer p) {
              if (mp != p) return;
              ready = true;
              dur = p.getDuration();
              applySpeed();
              if (wantPlay) p.start();
            }
          });
          m.setOnErrorListener(new MediaPlayer.OnErrorListener() {
            @Override public boolean onError(MediaPlayer p, int what, int extra) {
              if (mp != p) return true;
              say("Falha no video (erro " + what + "/" + extra + ")");
              act.exitSpace();
              return true;
            }
          });
          m.prepareAsync();
          startTick();
          ui.postDelayed(new Runnable() {
            @Override public void run() {
              if (mp == m && !ready) { say("O video demorou demais para carregar"); act.exitSpace(); }
            }
          }, 25000);
        } catch (Throwable t) {
          say("Nao consegui abrir o video");
          act.exitSpace();
        }
      }
    });
  }

  private void startTick() {
    if (tick != null) ui.removeCallbacks(tick);
    tick = new Runnable() {
      @Override public void run() {
        MediaPlayer m = mp;
        if (m == null) return;
        try { if (ready) { pos = m.getCurrentPosition(); dur = m.getDuration(); playing = m.isPlaying(); } } catch (Throwable t) { }
        ui.postDelayed(this, 250);
      }
    };
    ui.post(tick);
  }

  private void applySpeed() {
    MediaPlayer m = mp;
    if (m == null || android.os.Build.VERSION.SDK_INT < 23) return;
    try {
      boolean was = m.isPlaying();
      m.setPlaybackParams(new PlaybackParams().setSpeed(SPEEDS[spd]));
      if (!was && ready && !wantPlay) m.pause();
    } catch (Throwable t) { }
  }

  private void closeVideoNow() {
    if (tick != null) { ui.removeCallbacks(tick); tick = null; }
    MediaPlayer m = mp;
    mp = null;
    ready = false;
    playing = false;
    pos = 0;
    dur = 0;
    if (m != null) {
      try { m.setOnPreparedListener(null); m.setOnErrorListener(null); m.stop(); } catch (Throwable t) { }
      try { m.release(); } catch (Throwable t) { }
    }
  }

  void closeVideo() {
    ui.post(new Runnable() { @Override public void run() { closeVideoNow(); } });
  }

  void pause() {
    ui.post(new Runnable() {
      @Override public void run() {
        MediaPlayer m = mp;
        resumeAfter = playing;
        if (m != null && ready) { try { if (m.isPlaying()) m.pause(); } catch (Throwable t) { } }
      }
    });
  }

  void resume() {
    ui.post(new Runnable() {
      @Override public void run() {
        MediaPlayer m = mp;
        if (m != null && ready && resumeAfter) { try { m.start(); } catch (Throwable t) { } }
        resumeAfter = false;
      }
    });
  }

  private void videoCmd(final String c) {
    ui.post(new Runnable() {
      @Override public void run() {
        MediaPlayer m = mp;
        if (m == null) return;
        try {
          if (c.equals("play")) {
            if (ready) { if (m.isPlaying()) { m.pause(); wantPlay = false; playing = false; } else { m.start(); wantPlay = true; playing = true; } }
          } else if (c.startsWith("seek:")) {
            if (ready) { int t = Math.max(0, Math.min(m.getDuration(), Integer.parseInt(c.substring(5)))); m.seekTo(t); pos = t; }
          } else if (c.startsWith("rel:")) {
            if (ready) { int t = Math.max(0, Math.min(m.getDuration(), m.getCurrentPosition() + Integer.parseInt(c.substring(4)))); m.seekTo(t); pos = t; }
          } else if (c.equals("mute")) {
            muted = !muted;
            m.setVolume(muted ? 0f : 1f, muted ? 0f : 1f);
          } else if (c.equals("loop")) {
            loop = !loop;
            m.setLooping(loop);
          } else if (c.equals("speed")) {
            spd = (spd + 1) % SPEEDS.length;
            applySpeed();
          }
        } catch (Throwable t) { }
      }
    });
  }

  // =============================================================
  // Estado para a pagina
  // =============================================================

  String stateJson() {
    StringBuilder b = new StringBuilder("{");
    b.append("\"libVer\":").append(libVer).append(",\"catVer\":").append(catVer)
      .append(",\"loading\":").append(loading).append(",\"err\":").append(q(err))
      .append(",\"msg\":").append(q(msg)).append(",\"msgSeq\":").append(msgSeq)
      .append(",\"name\":").append(q(activeName)).append(",\"active\":").append(q(active)).append(",\"video\":").append(activeVideo)
      .append(",\"pos\":").append(pos).append(",\"dur\":").append(dur).append(",\"playing\":").append(playing)
      .append(",\"muted\":").append(muted).append(",\"loop\":").append(loop)
      .append(",\"speed\":").append(SPEEDS[spd]).append(",\"dl\":{");
    boolean first = true;
    for (Map.Entry<String, Integer> e : dl.entrySet()) {
      if (!first) b.append(',');
      first = false;
      b.append(q(e.getKey())).append(':').append(e.getValue().intValue());
    }
    b.append("},\"have\":").append(haveJson()).append('}');
    return b.toString();
  }
}
EOF
