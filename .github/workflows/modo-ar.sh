#!/usr/bin/env bash
# Modo AR (6DoF) do VR Launcher: tudo do 6DoF fica neste arquivo.
# Para atualizar: envie um modo-ar.sh novo para o repositorio, substituindo este.
set -e
echo "modo-ar.sh: Fase 17 - app unico GBWorld VR (2026-11-19)"
mkdir -p app/src/main/java/com/vr/launcher
cat > /tmp/vr_orig_ui.js <<'JSEOF'
var tabAju = mk2('tab', '<div class="tt">AJUSTES</div><div class="cfl"></div>'); tabAju.style.zIndex = 200;
var CFGV = { vol: 50, bri: 50, room: 0, zoom: 1, pOn: 16, pOff: 26 }, SLS = [], ZB = [];
function cfgRead() { try { if (window.Android && Android.getCfg) { var o = JSON.parse(Android.getCfg()); for (var k in o) CFGV[k] = o[k]; } } catch (e) { } }
function cfgSet(k, v) { CFGV[k] = v; try { if (window.Android && Android.setCfg) Android.setCfg(k, Math.round(v)); } catch (e) { } }
function setZoom(z) { window.__zoom = z; WINS.forEach(function (w) { w.R = 800 * z; }); GROUPS.forEach(function (g) { g.R = 800 * z; }); }
function applyAll() {
  SLS.forEach(function (s) { s.paint(); });
  ZB.forEach(function (q) { q.el.classList.toggle('on', q.z === CFGV.zoom); });
  window.__pOn = CFGV.pOn / 100; window.__pOff = CFGV.pOff / 100;
}
function cfgSync() { cfgRead(); if (window.__zoom !== CFGV.zoom) setZoom(CFGV.zoom); applyAll(); }
function mkSlider(list, tg, key, title, desc, mn, mx) {
  var r = document.createElement('div'); r.className = 'cfr sr';
  r.innerHTML = '<div class="cft"><b>' + title + '</b><span>' + desc + '</span></div><div class="sld"><div class="stk"><i></i></div><u></u></div><div class="scv"></div>';
  list.appendChild(r);
  var sd = r.querySelector('.sld'), fl = r.querySelector('.stk i'), kn = r.querySelector('u'), lb = r.querySelector('.scv');
  var lastS = 0, tmr = null;
  SLS.push({ paint: function () {
    var v = Math.max(mn, Math.min(mx, CFGV[key])), f = (v - mn) / (mx - mn);
    fl.style.width = (f * 100) + '%'; kn.style.left = 'calc(' + (f * 100) + '% - 14px)'; lb.textContent = Math.round(v) + '%';
  } });
  tg.push({ k: 'sld', el: sd, drag: function (x) {
    var rc = sd.getBoundingClientRect(); if (rc.width < 2) return;
    var f = Math.max(0, Math.min(1, (x - rc.left) / rc.width)), v = Math.round(mn + f * (mx - mn));
    if (v === Math.round(CFGV[key])) return;
    CFGV[key] = v;
    if (key === 'pOn' && CFGV.pOff < v + 4) CFGV.pOff = v + 4;
    if (key === 'pOff' && CFGV.pOn > v - 4) CFGV.pOn = v - 4;
    applyAll();
    var n = performance.now(); clearTimeout(tmr);
    if (n - lastS > 70) { lastS = n; cfgSet(key, v); } else tmr = setTimeout(function () { cfgSet(key, CFGV[key]); }, 90);
  } });
}
(function () {
  var l = tabCfg.querySelector('.cfl'), r = document.createElement('div');
  r.className = 'cfr';
  r.innerHTML = '<div class="cft"><b>Zoom da interface</b><span>Distância das janelas: quanto maior, mais longe.</span></div><div class="cfg5"></div>';
  l.appendChild(r);
  var box = r.querySelector('.cfg5');
  for (var z = 1; z <= 5; z++) (function (z) {
    var b = document.createElement('div'); b.className = 'cfb'; b.textContent = z + 'x'; box.appendChild(b);
    ZB.push({ el: b, z: z });
    T_cfg.push({ k: 'btn', el: b, fn: function () { cfgSet('zoom', z); setZoom(z); applyAll(); toast('Zoom da interface: ' + z + 'x'); } });
  })(z);
  var c = document.createElement('div'); c.className = 'cfr';
  c.innerHTML = '<div class="cft"><b>Clique</b><span>Como a mão clica.</span></div><div class="cfg5"><div class="cfb on">Pinça</div><div class="cfb off">Empurrar</div></div>';
  l.appendChild(c);
  var cb = c.querySelectorAll('.cfb');
  T_cfg.push({ k: 'btn', el: cb[0], fn: function () { toast('Clique por pinça'); } });
  T_cfg.push({ k: 'btn', el: cb[1], fn: function () { toast('Empurrar: em breve'); } });
  mkSlider(l, T_cfg, 'pOn', 'Fechar a pinça', 'Distância dos dedos para clicar.', 6, 30);
  mkSlider(l, T_cfg, 'pOff', 'Soltar a pinça', 'Distância dos dedos para soltar.', 10, 50);
  var la = tabAju.querySelector('.cfl');
  mkSlider(la, T_aju, 'vol', 'Volume', 'Volume geral do celular.', 0, 100);
  mkSlider(la, T_aju, 'bri', 'Brilho da tela', 'Brilho do celular.', 2, 100);
  mkSlider(la, T_aju, 'room', 'Brilho do quarto', 'Escurece a imagem da câmera.', 0, 100);
})();
cfgSync();
JSEOF
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
soft(UI, "miSpace = null;", "miSpace = null, T_cfg = [], miCfg = null;", 'miCfg = null')
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
 "tabApps.style.zIndex = 200; tabHelp.style.zIndex = 200; tabSpace.style.zIndex = 200;", 'var tabCfg = mk2')
soft(UI, "['space', tabSpace]]", "['space', tabSpace], ['cfg', tabCfg]]", "['cfg', tabCfg]")
soft(UI, "tabSpace.style.display = TAB === 'space' ? 'flex' : 'none';", "tabSpace.style.display = TAB === 'space' ? 'flex' : 'none'; tabCfg.style.display = TAB === 'cfg' ? 'flex' : 'none';", SK)
soft(UI, "miSpace.classList.toggle('on', TAB === 'space');", "miSpace.classList.toggle('on', TAB === 'space'); miCfg.classList.toggle('on', TAB === 'cfg');", SK)
soft(UI, "(TAB === 'space' ? tabSpace : null)", "(TAB === 'space' ? tabSpace : (TAB === 'cfg' ? tabCfg : null))", "TAB === 'cfg' ? tabCfg")
soft(UI, "else if (TAB === 'space') t = t.concat(T_space);", "else if (TAB === 'space') t = t.concat(T_space); else if (TAB === 'cfg') t = t.concat(T_cfg);", SK)
soft(UI, "RHS.space].forEach", "RHS.space, RHS.cfg].forEach", 'RHS.cfg')
soft(UI, "'.mi.hand,.ai.hand{background:#fff;color:#000}',",
 "'.mi.hand,.ai.hand{background:#fff;color:#000}', '.cfl{flex:1;display:flex;flex-direction:column;gap:8px}', " +
 "'.cfr{display:flex;align-items:center;gap:22px;padding:10px 22px;border-radius:26px;background:rgba(255,255,255,.08);border:1px solid rgba(255,255,255,.12)}', " +
 "'.cfr.hand{background:#fff;color:#000}', '.cft{flex:1;display:flex;flex-direction:column;gap:6px}', '.cft b{font-size:24px;font-weight:600}', '.cft span{font-size:16px;font-weight:300;opacity:.8;line-height:1.25}', " +
 "'.cfs{width:84px;height:44px;border-radius:22px;background:rgba(255,255,255,.25);position:relative;flex:none}', '.cfs i{position:absolute;left:5px;top:5px;width:34px;height:34px;border-radius:50%;background:#fff;transition:left .2s}', " +
 "'.cfr.hand .cfs{background:rgba(0,0,0,.3)}', '.cfr.hand .cfs i{background:#000}', '.cfr.on .cfs{background:#3ddc84}', '.cfr.on .cfs i{left:45px}'," +
 "'.cfg5{display:flex;gap:8px;flex:none}', '.cfb{min-width:64px;height:46px;padding:0 12px;border-radius:14px;background:rgba(255,255,255,.14);display:flex;align-items:center;justify-content:center;font-size:21px;font-weight:500}', '.cfb.on{background:#5eead4;color:#04201c}', '.cfb.off{opacity:.45}', '.cfb.hand{background:#fff;color:#000}', " +
 "'.sld{position:relative;height:60px;flex:1.3;min-width:0}', '.stk{position:absolute;left:0;right:0;top:25px;height:10px;border-radius:5px;background:rgba(255,255,255,.25);overflow:hidden}', '.stk i{display:block;height:100%;width:0;background:#fff}', '.sld u{position:absolute;top:16px;left:0;width:28px;height:28px;border-radius:50%;background:#fff;box-shadow:0 2px 6px rgba(0,0,0,.5);text-decoration:none}', '.sld.hand u,.sld.hand .stk i{background:#5eead4}', '.scv{width:74px;text-align:right;font-size:21px;flex:none}', '.cfr.sr .cft{flex:1}',", SK)
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


soft(UI, "grid-template-rows:repeat(3,1fr);grid-auto-flow:column", "grid-template-rows:repeat(4,1fr);grid-auto-flow:column", "repeat(4,1fr);grid-auto-flow:column")
soft(UI, "T_cfg = [], miCfg = null;", "T_cfg = [], miCfg = null, T_aju = [], miAju = null;", 'T_aju')
soft(UI, "    ['cfg', 'Configurações', function () { setTab('cfg'); }]", "    ['aju', 'Ajustes', function () { setTab('aju'); }],\n    ['cfg', 'Configurações', function () { setTab('cfg'); }]", "setTab('aju')")
soft(UI, """cfg: '<path d="M4 7h9M17 7h3M4 17h3M11 17h9"/><circle cx="15" cy="7" r="2"/><circle cx="9" cy="17" r="2"/>',""", """aju: '<path d="M4 7h9M17 7h3M4 17h3M11 17h9"/><circle cx="15" cy="7" r="2"/><circle cx="9" cy="17" r="2"/>',
    cfg: '<circle cx="12" cy="12" r="3"/><circle cx="12" cy="12" r="6.5"/><path d="M12 2.5v3M12 18.5v3M2.5 12h3M18.5 12h3M5.3 5.3l2.1 2.1M16.6 16.6l2.1 2.1M18.7 5.3l-2.1 2.1M7.4 16.6l-2.1 2.1"/>',""", "aju: '<path")
soft(UI, "if (m[0] === 'cfg') miCfg = d;", "if (m[0] === 'cfg') miCfg = d; if (m[0] === 'aju') miAju = d;", "miAju = d")
soft(UI, "tabApps.style.zIndex = 200; tabHelp.style.zIndex = 200; tabSpace.style.zIndex = 200;", open('/tmp/vr_orig_ui.js', encoding='utf-8').read() + "\ntabApps.style.zIndex = 200; tabHelp.style.zIndex = 200; tabSpace.style.zIndex = 200;", "var tabAju")
soft(UI, "['cfg', tabCfg]]", "['cfg', tabCfg], ['aju', tabAju]]", "['aju', tabAju]")
soft(UI, "tabCfg.style.display = TAB === 'cfg' ? 'flex' : 'none';", "tabCfg.style.display = TAB === 'cfg' ? 'flex' : 'none'; tabAju.style.display = TAB === 'aju' ? 'flex' : 'none';", "tabAju.style.display")
soft(UI, "miCfg.classList.toggle('on', TAB === 'cfg');", "miCfg.classList.toggle('on', TAB === 'cfg'); miAju.classList.toggle('on', TAB === 'aju');", "miAju.classList")
soft(UI, "(TAB === 'cfg' ? tabCfg : null)", "(TAB === 'cfg' ? tabCfg : (TAB === 'aju' ? tabAju : null))", "tabAju : null")
soft(UI, "else if (TAB === 'cfg') t = t.concat(T_cfg);", "else if (TAB === 'cfg') t = t.concat(T_cfg); else if (TAB === 'aju') t = t.concat(T_aju);", "T_aju)")
soft(UI, "RHS.space, RHS.cfg].forEach", "RHS.space, RHS.cfg, RHS.aju].forEach", "RHS.aju")
soft(UI, "  function setTab(t) {\n", "  function setTab(t) {\n    try { cfgSync(); } catch (e) { }\n", "try { cfgSync(); }")
soft(UI, "function rn(o) { return clamp(o.R, 240, 2400); }", "function rn(o) { return clamp(o.R, 240, 6000); }", "240, 6000")
soft(UI, "s: 0.85, R: 800,", "s: 0.85, R: 800 * (window.__zoom || 1),", "800 * (window.__zoom")
HAND = 'app/src/main/assets/hand.js'
soft(HAND, "pinch = pinch ? ratio < 0.26 : ratio < 0.16;", "pinch = pinch ? ratio < (window.__pOff || 0.26) : ratio < (window.__pOn || 0.16);", "window.__pOff")
soft(HAND, "      if (pt.k === 'win') {\n        if (!grab) grab", "      if (pt.k === 'sld') { pt.drag(cx, cy); }\n      else if (pt.k === 'win') {\n        if (!grab) grab", "pt.k === 'sld'")

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

soft(MA, '  boolean stereoOn = false;\n', """  boolean stereoOn = false;
  View roomV;
  /* ---- ajustes: volume, brilho da tela, brilho do quarto, zoom, pinca (guardados em "ar", os mesmos do modo 6DoF) ---- */
  String cfgJson() {
    android.content.SharedPreferences pf = getSharedPreferences("ar", MODE_PRIVATE);
    int vol = 50, bri = pf.getInt("bri", -1);
    try { android.media.AudioManager am = (android.media.AudioManager) getSystemService(AUDIO_SERVICE); int mx = am.getStreamMaxVolume(3); vol = mx <= 0 ? 0 : Math.round(100f * am.getStreamVolume(3) / mx); } catch (Throwable t) { }
    if (bri < 0) { try { bri = Math.round(100f * android.provider.Settings.System.getInt(getContentResolver(), android.provider.Settings.System.SCREEN_BRIGHTNESS, 128) / 255f); } catch (Throwable t) { bri = 50; } }
    return "{\\"vol\\":" + vol + ",\\"bri\\":" + bri + ",\\"room\\":" + pf.getInt("room", 0) + ",\\"zoom\\":" + pf.getInt("zoom", 1)
      + ",\\"pOn\\":" + Math.round(pf.getFloat("pOn", 0.16f) * 100f) + ",\\"pOff\\":" + Math.round(pf.getFloat("pOff", 0.26f) * 100f) + "}";
  }
  void applyRoom(int v) { if (roomV != null) roomV.setAlpha(0.96f * Math.max(0, Math.min(100, v)) / 100f); }
  void applyBrightness(int v) {
    try {
      WindowManager.LayoutParams lp = getWindow().getAttributes();
      lp.screenBrightness = v < 0 ? WindowManager.LayoutParams.BRIGHTNESS_OVERRIDE_NONE : Math.max(0.02f, Math.min(1f, v / 100f));
      getWindow().setAttributes(lp);
    } catch (Throwable t) { }
  }
  void cfgSet(String k, int v) {
    android.content.SharedPreferences pf = getSharedPreferences("ar", MODE_PRIVATE);
    try {
      if ("vol".equals(k)) {
        android.media.AudioManager am = (android.media.AudioManager) getSystemService(AUDIO_SERVICE);
        int mx = am.getStreamMaxVolume(3);
        am.setStreamVolume(3, Math.round(mx * Math.max(0, Math.min(100, v)) / 100f), 0);
      } else if ("bri".equals(k)) { int b = Math.max(2, Math.min(100, v)); pf.edit().putInt("bri", b).apply(); applyBrightness(b); }
      else if ("room".equals(k)) { int r = Math.max(0, Math.min(100, v)); pf.edit().putInt("room", r).apply(); applyRoom(r); }
      else if ("zoom".equals(k)) pf.edit().putInt("zoom", Math.max(1, Math.min(5, v))).apply();
      else if ("pOn".equals(k) || "pOff".equals(k)) {
        float on = pf.getFloat("pOn", 0.16f), off = pf.getFloat("pOff", 0.26f), f = Math.max(0.05f, Math.min(0.6f, v / 100f));
        if ("pOn".equals(k)) { on = f; if (off < on + 0.04f) off = on + 0.04f; } else { off = f; if (on > off - 0.04f) on = off - 0.04f; }
        pf.edit().putFloat("pOn", Math.max(0.05f, on)).putFloat("pOff", Math.min(0.6f, off)).apply();
      }
    } catch (Throwable t) { }
  }
""", 'String cfgJson()')
soft(MA, '    @JavascriptInterface public boolean getStereo()', '    @JavascriptInterface public String getCfg() { return cfgJson(); }\n    @JavascriptInterface public void setCfg(final String k, final int v) { ui.post(() -> cfgSet(k, v)); }\n    @JavascriptInterface public boolean getStereo()', 'public String getCfg')
soft(MA, '    root.addView(previewView, new FrameLayout.LayoutParams(-1, -1));\n', '    root.addView(previewView, new FrameLayout.LayoutParams(-1, -1));\n    roomV = new View(this); roomV.setBackgroundColor(0xFF000000); roomV.setAlpha(0f);\n    root.addView(roomV, new FrameLayout.LayoutParams(-1, -1));\n    try { android.content.SharedPreferences pf0 = getSharedPreferences("ar", MODE_PRIVATE); applyRoom(pf0.getInt("room", 0)); applyBrightness(pf0.getInt("bri", -1)); } catch (Throwable t) { }\n', 'roomV = new View')
PY
python3 - <<'PY2'
import os, re, base64
# ---- app unico: GBWorld VR (so o modo 6DoF abre; o modo original fica sem icone) ----
mf = 'app/src/main/AndroidManifest.xml'
m = open(mf, encoding='utf-8').read()
if 'ic_launcher' not in m:
    m = re.sub(r'(<activity android:name="\.MainActivity".*?)<intent-filter>.*?</intent-filter>', r'\1', m, count=1, flags=re.S)
    m = m.replace('android:label="VR Launcher"', 'android:label="GBWorld VR" android:icon="@mipmap/ic_launcher"', 1)
    m = m.replace('android:label="VR Launcher AR"', 'android:label="GBWorld VR"', 1)
    open(mf, 'w', encoding='utf-8').write(m)
    print('manifest: app unico GBWorld VR')
else:
    print('ja aplicado em', mf)
ICONS = {'mipmap-mdpi/ic_launcher.png': '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', 'mipmap-hdpi/ic_launcher.png': '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', 'mipmap-xhdpi/ic_launcher.png': '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', 'mipmap-xxhdpi/ic_launcher.png': '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', 'mipmap-xxxhdpi/ic_launcher.png': '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', 'drawable-xxxhdpi/ic_launcher_fg.png': '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'}
for rel, b64 in ICONS.items():
    d = 'app/src/main/res/' + rel
    os.makedirs(os.path.dirname(d), exist_ok=True)
    open(d, 'wb').write(base64.b64decode(b64))
os.makedirs('app/src/main/res/mipmap-anydpi-v26', exist_ok=True)
os.makedirs('app/src/main/res/values', exist_ok=True)
open('app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml', 'w').write('<?xml version="1.0" encoding="utf-8"?>\n<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n  <background android:drawable="@color/ic_launcher_bg"/>\n  <foreground android:drawable="@drawable/ic_launcher_fg"/>\n</adaptive-icon>\n')
open('app/src/main/res/values/ic_launcher_bg.xml', 'w').write('<?xml version="1.0" encoding="utf-8"?>\n<resources><color name="ic_launcher_bg">#000000</color></resources>\n')
GR = """
// copia o APK com o nome do app (o app-debug.apk original continua existindo)
tasks.matching { it.name == 'assembleDebug' }.configureEach {
  doLast {
    def d = file("$buildDir/outputs/apk/debug")
    if (new File(d, 'app-debug.apk').exists()) {
      copy { from d; include 'app-debug.apk'; into d; rename 'app-debug.apk', 'GBWorld VR.apk' }
    }
  }
}
"""
g = open('app/build.gradle', encoding='utf-8').read()
if 'GBWorld VR.apk' not in g:
    open('app/build.gradle', 'w', encoding='utf-8').write(g + GR)
    print('gradle: GBWorld VR.apk')
PY2
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
  volatile boolean freezeYaw = false;

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
    if (best >= 0 && ready && spd < 1.5f && !(freezeYaw && yawInit)) yawUpdate(rAr, rG);
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
  volatile int pw, ph;
  final int dpi;
  /** Opcoes do navegador, globais (valem para todas as janelas): zoom das paginas (%) e modo computador. */
  static volatile int zoomPct = 100;
  static volatile boolean desktop = false;
  static final String UA_DESKTOP = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36";
  private android.view.View fsView = null;
  private WebChromeClient.CustomViewCallback fsCb = null;
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
  /** Menu dos tres pontinhos da janela: pagina propria (ArMorePage). */
  final boolean more;
  /** Tela de boas-vindas: pagina propria (ArHelloPage) com a ponte "ArMenu". */
  final boolean hello;
  private long downTime = 0;
  private Runnable tick, watchdog;

  ArPanel(ArActivity act, int pw, int ph, int dpi, String url) {
    this(act, pw, ph, dpi, url, false);
  }

  ArPanel(ArActivity act, int pw, int ph, int dpi, String url, boolean menu) {
    this.act = act; this.pw = pw; this.ph = ph; this.dpi = dpi; this.home = url; this.menu = menu;
    this.kb = menu && ArActivity.KB_URL.equals(url);
    this.vid = menu && ArActivity.VID_URL.equals(url);
    this.more = menu && ArActivity.MORE_URL.equals(url);
    this.hello = menu && ArActivity.HELLO_URL.equals(url);
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
      else if (hello) t.web.loadDataWithBaseURL("https://vrlauncher.local/", ArHelloPage.HTML, "text/html", "utf-8", null);
      else if (more) t.web.loadDataWithBaseURL("https://vrlauncher.local/", ArMorePage.HTML, "text/html", "utf-8", null);
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

  static String zoomJs() {
    return "(function(){try{document.documentElement.style.zoom='" + (zoomPct / 100f) + "';}catch(e){}})()";
  }

  /** Aplica as opcoes globais do navegador (modo computador, zoom) nas abas desta janela. */
  void applyBrowser() {
    if (menu) return;
    ui.post(new Runnable() {
      @Override public void run() {
        for (Tab t : tabs) {
          if (t.web == null) continue;
          WebSettings ws = t.web.getSettings();
          boolean changed = desktop != (ws.getUserAgentString() != null && ws.getUserAgentString().contains("X11; Linux x86_64"));
          if (changed) {
            ws.setUserAgentString(desktop ? UA_DESKTOP : null);
            ws.setUseWideViewPort(desktop);
            ws.setLoadWithOverviewMode(desktop);
            t.web.reload();
          } else {
            t.web.evaluateJavascript(zoomJs(), null);
          }
        }
      }
    });
  }

  /** Muda a resolucao da pagina (proporcao da janela): refaz a superficie; as paginas recarregam. Thread do GL. */
  void resize(int w, int h) {
    if (w == pw && h == ph) return;
    pw = w; ph = h;
    newSurface();
  }

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
    v.setBackgroundColor(menu ? Color.BLACK : Color.WHITE);
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
        @JavascriptInterface public String sites() { return ArPanel.this.act.sitesJson(); }
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
          if (u != null && "vrlauncher.local".equals(u.getHost()) && path != null && path.startsWith("/font/")) {
            InputStream fin = ArFont.open(path);
            if (fin != null) return new WebResourceResponse("font/woff2", null, fin);
          }
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
        if (!menu) { view.evaluateJavascript(FOCUS_JS, null); view.evaluateJavascript(zoomJs(), null); }
        if (u != null && u.startsWith("http")) tab.url = u;
        publish();
      }
      @Override public void doUpdateVisitedHistory(WebView view, String u, boolean reload) {
        if (u != null && u.startsWith("http")) tab.url = u;
        publish();
      }
    });
    if (!menu) {
      s.setUserAgentString(desktop ? UA_DESKTOP : null);
      s.setUseWideViewPort(desktop);
      s.setLoadWithOverviewMode(desktop);
    }
    v.setWebChromeClient(new WebChromeClient() {
      /** Tela cheia de video (YouTube etc.): o video enche so esta janela. */
      @Override public void onShowCustomView(android.view.View view, CustomViewCallback cb) {
        if (menu || holder == null) { if (cb != null) cb.onCustomViewHidden(); return; }
        if (fsView != null) { onHideCustomView(); }
        fsView = view; fsCb = cb;
        holder.addView(view, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        for (Tab t : tabs) if (t.web != null) t.web.setVisibility(View.GONE);
      }
      @Override public void onHideCustomView() {
        android.view.View fv = fsView;
        if (fv == null) return;
        fsView = null;
        if (holder != null) holder.removeView(fv);
        WebChromeClient.CustomViewCallback c = fsCb; fsCb = null;
        if (c != null) { try { c.onCustomViewHidden(); } catch (Throwable e) { } }
        for (int i = 0; i < tabs.size(); i++) if (tabs.get(i).web != null) tabs.get(i).web.setVisibility(i == cur ? View.VISIBLE : View.GONE);
      }
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
  // proporcao das janelas do navegador: 16:9, 21:9, 32:9, 9:16 (meia largura, meia altura, pixels da pagina)
  static final float[] AR_HW = {0.32f, 0.36f, 0.40f, 0.18f}, AR_HH = {0.18f, 0.1543f, 0.1125f, 0.32f};
  static final int[] AR_PW = {960, 1260, 1920, 540}, AR_PH = {540, 540, 540, 960};
  static final int RAIL_N = 7;
  // RAIL_TOP: espaco do relogio no topo; o relogio tem a mesma largura dos icones
  static final float RAIL_P = 0.064f, RAIL_IC = 0.05f, RAIL_HALF = 0.04f, RAIL_DIST = 0.9f, RAIL_TOP = 0.05f, RAIL_H = RAIL_TOP + RAIL_N * RAIL_P;
  static final float CLOCK_W = RAIL_IC, CLOCK_H = 0.03f;
  // home, centralizar, mundos, apps, ajustes (sliders), configuracoes (engrenagem) (indices de makeGlyph)
  static final int[] RAIL_GLYPH = {0, 1, 3, 14, 4, 5, 11};
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
    float hw = HW, hh = HH;   // meia largura/altura (m, escala 1): muda com a proporcao das janelas do navegador
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
  volatile float pinchOn = PINCH_ON, pinchOff = PINCH_OFF;   // distancia (relativa a mao) para fechar e para soltar a pinca
  volatile float roomDim = 0f;            // brilho do quarto: camada escura sobre a camera (0 a 1)
  volatile int zoom = 1;                  // distancia das janelas: 1x a 5x
  private float zoomApplied = 1f;
  private int bgDimLoc = -1, bgT0Loc = -1, bgTXLoc = -1, bgTYLoc = -1, bgCenterLoc = -1, bgStrLoc = -1, bgTimeLoc = -1, bgAspLoc = -1;
  // efeito de distorcao do gesto do menu (intensidade reduzida em relacao ao original)
  private static final float DIST_GAIN = 0.6f;
  private float distTarget = 0f, distStrength = 0f, distCx = 0f, distCy = 0f, distStrNow = 0f;
  private long distPulseNs = 0L;
  private final long startNs = System.nanoTime();
  volatile int aspectIdx = 0;
  private final FloatBuffer[] winVA = new FloatBuffer[4], curVA = new FloatBuffer[4];
  private Win drawW = null, moreWin = null, moreOwner = null;
  volatile boolean moreCurved = false;
  volatile boolean stereo = false;        // tela dividida (um desenho por olho) para o oculos VR Box
  volatile int viewMode = 1;              // 0 preenchida (corta), 1 meio-termo, 2 inteira (faixas), 3 esticada (tela cheia)
  private volatile boolean vpDirty = true;
  volatile boolean viewportChanged = true;
  private volatile boolean recenterReq = false;
  private volatile int handRot = 90;

  // area de desenho: com a imagem inteira da camera ela pode ficar menor que a tela (faixas pretas)
  private int sw = 0, sh = 0, vpX = 0, vpY = 0, vpW = 0, vpH = 0;
  private float imgAspect = 0f;
  private static final float IPD = 0.064f;   // padrao da distancia entre os olhos virtuais (m)
  // correcao de lente (so no modo estereo)
  volatile float ipdMm = 64f, sepMm = 0f, vOffMm = 0f, sizePct = 100f, distPct = 100f, fovDeg = 90f;   // valores do modo personalizado
  volatile int lensMode = 0;   // 0 Cardboard (predefinido), 1 personalizado
  // modo Cardboard: IPD 64 mm, sem deslocamentos, distorcao do Cardboard V2 (k1 0,34 / k2 0,55) e 90 graus de campo de visao
  float eIpd() { return lensMode == 0 ? 64f : ipdMm; }
  float eSep() { return lensMode == 0 ? 0f : sepMm; }
  float eVoff() { return lensMode == 0 ? 0f : vOffMm; }
  float eSize() { return lensMode == 0 ? 100f : sizePct; }
  float eDist() { return lensMode == 0 ? 100f : distPct; }
  float eFov() { return lensMode == 0 ? 90f : fovDeg; }
  private final float[] spProjM = new float[16];
  private int lnProg = 0, lnPos = -1, lnK1 = -1, lnK2 = -1, lnTex = -1, lnAsp = -1;
  private int lnFbo = 0, lnTexId = 0, lnDepth = 0, lnW = 0, lnH = 0;
  private boolean lnBad = false;
  private static final String LN_VS =
    "attribute vec2 a_Position;\nvarying vec2 v_Uv;\n" +
    "void main() { gl_Position = vec4(a_Position, 0.0, 1.0); v_Uv = a_Position * 0.5 + 0.5; }\n";
  private static final String LN_FS =
    "precision mediump float;\nvarying vec2 v_Uv;\nuniform sampler2D u_Tex;\nuniform float u_K1;\nuniform float u_K2;\nuniform float u_Asp;\n" +
    "void main() { vec2 q = v_Uv * 2.0 - 1.0; vec2 a = vec2(q.x * u_Asp, q.y); float r2 = dot(a, a) * 0.25;\n" +
    "  vec2 src = q * (1.0 + u_K1 * r2 + u_K2 * r2 * r2); vec2 uv = src * 0.5 + 0.5;\n" +
    "  if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);\n" +
    "  else gl_FragColor = vec4(texture2D(u_Tex, uv).rgb, 1.0); }\n";

  private boolean lensFbo(int w, int h) {
    if (lnBad) return false;
    if (lnProg == 0) {
      lnProg = program(LN_VS, LN_FS);
      if (lnProg == 0) { lnBad = true; return false; }
      lnPos = GLES20.glGetAttribLocation(lnProg, "a_Position");
      lnK1 = GLES20.glGetUniformLocation(lnProg, "u_K1");
      lnK2 = GLES20.glGetUniformLocation(lnProg, "u_K2");
      lnTex = GLES20.glGetUniformLocation(lnProg, "u_Tex");
      lnAsp = GLES20.glGetUniformLocation(lnProg, "u_Asp");
    }
    if (lnFbo != 0 && lnW == w && lnH == h) return true;
    int[] t = new int[1];
    if (lnFbo != 0) {
      t[0] = lnFbo; GLES20.glDeleteFramebuffers(1, t, 0);
      t[0] = lnTexId; GLES20.glDeleteTextures(1, t, 0);
      t[0] = lnDepth; GLES20.glDeleteRenderbuffers(1, t, 0);
      lnFbo = 0;
    }
    GLES20.glGenTextures(1, t, 0); lnTexId = t[0];
    GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, lnTexId);
    GLES20.glTexImage2D(GLES20.GL_TEXTURE_2D, 0, GLES20.GL_RGBA, w, h, 0, GLES20.GL_RGBA, GLES20.GL_UNSIGNED_BYTE, null);
    GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR);
    GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR);
    GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE);
    GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE);
    GLES20.glGenRenderbuffers(1, t, 0); lnDepth = t[0];
    GLES20.glBindRenderbuffer(GLES20.GL_RENDERBUFFER, lnDepth);
    GLES20.glRenderbufferStorage(GLES20.GL_RENDERBUFFER, GLES20.GL_DEPTH_COMPONENT16, w, h);
    GLES20.glGenFramebuffers(1, t, 0); lnFbo = t[0];
    GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, lnFbo);
    GLES20.glFramebufferTexture2D(GLES20.GL_FRAMEBUFFER, GLES20.GL_COLOR_ATTACHMENT0, GLES20.GL_TEXTURE_2D, lnTexId, 0);
    GLES20.glFramebufferRenderbuffer(GLES20.GL_FRAMEBUFFER, GLES20.GL_DEPTH_ATTACHMENT, GLES20.GL_RENDERBUFFER, lnDepth);
    boolean ok = GLES20.glCheckFramebufferStatus(GLES20.GL_FRAMEBUFFER) == GLES20.GL_FRAMEBUFFER_COMPLETE;
    GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, 0);
    lnW = w; lnH = h;
    if (!ok) { lnBad = true; lnFbo = 0; return false; }
    return true;
  }
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
  private int winProg = 0, winPosLoc = 0, winUvLoc = 0, winMvpLoc = 0, winTexLoc = 0, winStmLoc = 0, winHalfLoc = 0, winRadLoc = 0, winFlatLoc = 0, winSLoc = 0, winDimLoc = 0, winGlassLoc = 0;
  private final FloatBuffer winVerts = floatBuf(new float[]{-HW, -HH, 0f, HW, -HH, 0f, -HW, HH, 0f, HW, HH, 0f});
  private final FloatBuffer winUvs = floatBuf(new float[]{0f, 0f, 1f, 0f, 0f, 1f, 1f, 1f});

  // barra, alca, "+", destaque
  private int flatProg = 0, flatPosLoc = 0, flatUvLoc = 0, flatMvpLoc = 0, flatTexLoc = 0, flatColLoc = 0;
  private int barTex = 0, cornerTex = 0, roundTex = 0, discTex = 0, ringTex = 0, thinTex = 0;
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
  private volatile int spLayout = 0;
  int spLayoutNow() { return spLayout; }
  private volatile int spAuto = 0, layMode = 0;   // layMode: 0 automatico, 1 2D, 2 top-bottom, 3 lado a lado
  int layModeNow() { return layMode; }
  private void applyLayMode() { spLayout = layMode == 0 ? spAuto : layMode - 1; }
  void cycleLayout() {
    layMode = (layMode + 1) % 4;
    applyLayMode();
    say(new String[]{"Video: automatico", "Video 2D / mono", "Video 3D top-bottom", "Video 3D lado a lado"}[layMode]);
  }
  private int spLayLoc = -1, curEye = 0;   // spLayout: 0 mono, 1 top-bottom, 2 lado a lado
  private int spPosLoc = 0, spProjLoc = 0, spRotLoc = 0, spYawLoc = 0, spTexLoc = 0, spStmLoc = 0, spAlphaLoc = 0;
  private float spAlpha = 0f, spYaw = 0f;
  // o panorama segue so o giroscopio (liso, sem os saltos de relocalizacao do ARCore)
  private final float[] spView = new float[16], rP = new float[9];
  private boolean spGyro = false;
  volatile float sharp = 0.4f;   // nitidez do panorama (0..1)
  private int spPxLoc = -1, spShLoc = -1;
  private SurfaceTexture spSt = null;
  private Surface spSurf = null;
  private final AtomicBoolean spAvail = new AtomicBoolean(false);
  private final float[] spStm = new float[16], invProj = new float[16], rot3 = new float[9];
  private final FloatBuffer spQuad = floatBuf(new float[]{-1f, -1f, 1f, -1f, -1f, 1f, 1f, 1f});
  private long spLastMs = 0;

  // menu 3D
  private Win railWin = null, tabWin = null, helloWin = null;
  // zoom do menu (1..5; 2 = tamanho original)
  volatile int menuZoom = 2;
  private float menuScaleApplied = 1f;
  private static final float[] MENU_SCALE = {0.7f, 1f, 1.3f, 1.6f, 2f};
  private float menuScale() { return MENU_SCALE[Math.max(0, Math.min(4, menuZoom - 1))]; }
  // tela de boas-vindas: 0 oculta, 1 pergunta o nome, 2 saudacao, 3 sumindo
  volatile int helloMode = 0;
  volatile String helloText = "", helloBuf = "";
  private boolean helloDone = false;
  private long helloT = 0;
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
    bgDimLoc = GLES20.glGetUniformLocation(bgProg, "u_Dim");
    bgT0Loc = GLES20.glGetUniformLocation(bgProg, "u_T0");
    bgTXLoc = GLES20.glGetUniformLocation(bgProg, "u_TX");
    bgTYLoc = GLES20.glGetUniformLocation(bgProg, "u_TY");
    bgCenterLoc = GLES20.glGetUniformLocation(bgProg, "u_Center");
    bgStrLoc = GLES20.glGetUniformLocation(bgProg, "u_Strength");
    bgTimeLoc = GLES20.glGetUniformLocation(bgProg, "u_Time");
    bgAspLoc = GLES20.glGetUniformLocation(bgProg, "u_Aspect");

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
    winGlassLoc = GLES20.glGetUniformLocation(winProg, "u_Glass");
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
    thinTex = bitmapTex(makeThinRing());
    curveGlyph = bitmapTex(makeGlyph(12));
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
        if (spKind != 0) spYaw = panoHeading(camPose) - (float) Math.PI;
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
      if (!needSpawn && tracking && zoomApplied != zoom) {
        float kz = zoom / zoomApplied;
        zoomApplied = zoom;
        rescaleLayout(s, camPose, kz);
      }

      if (!dim) feedTracker(frame);
      distTarget = 0f;
      updateInteraction(s, frame, ct);
      animateMenu(frameDt);
      {
        float pulse = Math.max(0f, 1f - (System.nanoTime() - distPulseNs) / 800000000f);
        distStrength += (distTarget - distStrength) * Math.min(1f, frameDt * 10f);
        distStrNow = Math.max(distStrength, 1.2f * pulse) * DIST_GAIN;
      }
      {
        float ms = menuScale();
        if (ms != menuScaleApplied && railWin != null) {
          menuScaleApplied = ms;
          railWin.s = ms;
          if (tabWin != null) tabWin.s = RAIL_H / (2f * HH) * ms;
        }
      }
      updateHello(nowMs);
      placeTab();
      placeKb();
      placeMore();

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
    final float ipdM = eIpd() / 1000f;
    final float pxMm = act.getResources().getDisplayMetrics().xdpi / 25.4f;
    final float pyMm = act.getResources().getDisplayMetrics().ydpi / 25.4f;
    final float k1 = eDist() / 100f * 0.34f, k2 = eDist() / 100f * 0.55f;
    final boolean dist = st && eDist() > 0.5f && lensFbo(vpW, vpH);
    final float scl = st ? Math.max(0.3f, eSize() / 100f) : 1f;
    final int rw = Math.round(vpW * scl), rh = Math.round(vpH * scl);
    for (int e = 0; e < eyes; e++) {
      int x, y = 0, w = vpW, h = vpH;
      if (st) {
        w = rw; h = rh;
        float sgn = e == 0 ? -1f : 1f;
        x = e * cw + vpX + (vpW - rw) / 2 + Math.round(sgn * eSep() * 0.5f * pxMm);
        y = vpY + (vpH - rh) / 2 + Math.round(eVoff() * pyMm);
        GLES20.glEnable(GLES20.GL_SCISSOR_TEST);
        GLES20.glScissor(e * cw, 0, cw, sh);
      } else {
        x = vpX;
        y = vpY;
      }
      if (dist) {
        GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, lnFbo);
        GLES20.glDisable(GLES20.GL_SCISSOR_TEST);
        GLES20.glViewport(0, 0, vpW, vpH);
        GLES20.glClearColor(0f, 0f, 0f, 1f);
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT | GLES20.GL_DEPTH_BUFFER_BIT);
      } else {
        GLES20.glViewport(x, y, w, h);
      }
      curEye = e;
      if (st) {
        // olho esquerdo: a camera anda meia distancia interpupilar para a esquerda (o mundo desloca para a direita)
        Matrix.setIdentityM(eyeT, 0);
        eyeT[12] = e == 0 ? ipdM * 0.5f : -ipdM * 0.5f;
        Matrix.multiplyMM(eyeV, 0, eyeT, 0, view, 0);
        Matrix.multiplyMM(vp, 0, proj, 0, eyeV, 0);
      }
      if (spKind == 0 || spAlpha < 0.99f) drawBackground();
      drawSpace();
      pxShift = st ? (e == 0 ? 1f : -1f) * ipdM * 0.5f * proj[0] * (vw * 0.5f) / Math.max(0.3f, cursorDepth) : 0f;
      drawWindows();
      drawHand();
      pxShift = 0f;
      if (dist) {
        GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, 0);
        GLES20.glEnable(GLES20.GL_SCISSOR_TEST);
        GLES20.glScissor(e * cw, 0, cw, sh);
        GLES20.glViewport(x, y, w, h);
        GLES20.glDisable(GLES20.GL_DEPTH_TEST);
        GLES20.glDisable(GLES20.GL_BLEND);
        GLES20.glUseProgram(lnProg);
        GLES20.glActiveTexture(GLES20.GL_TEXTURE0);
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, lnTexId);
        GLES20.glUniform1i(lnTex, 0);
        GLES20.glUniform1f(lnK1, k1);
        GLES20.glUniform1f(lnK2, k2);
        GLES20.glUniform1f(lnAsp, (float) vpW / Math.max(1, vpH));
        spQuad.position(0);
        GLES20.glVertexAttribPointer(lnPos, 2, GLES20.GL_FLOAT, false, 0, spQuad);
        GLES20.glEnableVertexAttribArray(lnPos);
        GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4);
        GLES20.glDisableVertexAttribArray(lnPos);
        GLES20.glEnable(GLES20.GL_DEPTH_TEST);
      }
    }
    GLES20.glDisable(GLES20.GL_SCISSOR_TEST);
    GLES20.glViewport(vpX, vpY, vpW, vpH);
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
      fuse.freezeYaw = spKind != 0;   // com o panorama aberto o desvio de direcao nao e mais puxado para o ARCore
      if (imuOk && (hybridOn || spKind != 0)) fuse.feed(rAr, rG);
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

    spGyro = spKind != 0 && imuOk && fuse.fused(rG, rP);
    if (spGyro) {
      buildView(ZERO3, rP, spView);
    }
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
    ArPanel p = new ArPanel(act, menu ? ArActivity.PW : AR_PW[aspectIdx], menu ? ArActivity.PH : AR_PH[aspectIdx], ArActivity.DPI, url, menu);
    p.glInit();
    panels.add(p);
    return p;
  }

  private ArPanel newPanelTabs(String[] urls, int cur) {
    ArPanel p = new ArPanel(act, AR_PW[aspectIdx], AR_PH[aspectIdx], ArActivity.DPI, urls, cur);
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
      w.hw = AR_HW[aspectIdx]; w.hh = AR_HH[aspectIdx];
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
    float dist = 1.2f * zoom, step = (2f * AR_HW[aspectIdx] + 0.06f) / dist;
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
    zoomApplied = zoom;
    railWin = new Win(cp, null, null, true);
    railWin.rail = true;
    float left = k > 0 ? (k - 1) / 2f * ((2f * AR_HW[aspectIdx] + 0.06f) / (1.2f * zoom)) + AR_HW[aspectIdx] / (1.2f * zoom) + 0.16f : 0.15f;
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
    tabWin.s = RAIL_H / (2f * HH) * menuScale();   // a aba tem a altura do menu
    tabWin.hidden = true;
  }

  /** Trilho a esquerda (off rad) da direcao em que a camera olha, com o topo um pouco acima do centro. */
  private void placeRailBeside(Session s, Pose cp, float off) {
    float[] t = cp.getTranslation();
    float a = heading(cp) + off;
    setRailPose(s, facing(t[0] + RAIL_DIST * (float) Math.sin(a), t[1] + RAIL_H * menuScale() / 2f, t[2] + RAIL_DIST * (float) Math.cos(a), t[0], t[2]));
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
  /** Zoom da interface mudou: afasta (ou aproxima) todas as janelas da camera na mesma direcao, sem mexer no menu. */
  private void rescaleLayout(Session s, Pose cp, float k) {
    resetInteraction();
    float[] c = cp.getTranslation();
    ArrayList<Win> seen = new ArrayList<Win>();
    for (Win w : wins) {
      if (w.menu || seen.contains(w)) continue;
      ArrayList<Win> u = new ArrayList<Win>(unit(w));
      seen.addAll(u);
      Win w0 = u.get(0);
      Pose G = w0.group != null ? w0.group.g : w0.pose;
      float[] t = G.getTranslation();
      Pose n = new Pose(new float[]{c[0] + (t[0] - c[0]) * k, c[1] + (t[1] - c[1]) * k, c[2] + (t[2] - c[2]) * k}, G.getRotationQuaternion());
      if (w0.group != null) {
        w0.group.g = n;
        layoutGroup(w0.group, n);
      } else {
        w0.pose = n;
        if (w0.anchor != null) { try { w0.anchor.detach(); } catch (Throwable e) { } w0.anchor = null; }
        if (tracking) w0.anchor = anchorOf(s, n);
      }
    }
    say("Zoom da interface: " + Math.round(zoom) + "x");
  }

  private void centerAll(Session s, Pose cp) {
    resetInteraction();
    zoomApplied = zoom;
    final float RZ = GRP_R * zoom;   // distancia das janelas (zoom da interface)
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
      for (Win w : u) sp += 2f * (float) Math.atan(w.hw * w.s / RZ);
      sp += (u.size() - 1) * GGAP / RZ;
      span[i] = sp;
      total += sp;
    }
    float gapA = 0.06f / RZ;
    if (units.size() > 1) total += (units.size() - 1) * gapA;
    float[] t = cp.getTranslation();
    float h = heading(cp);
    float cum = 0f;
    for (int i = 0; i < units.size(); i++) {
      ArrayList<Win> u = units.get(i);
      float a = h + total / 2f - (cum + span[i] / 2f);
      cum += span[i] + gapA;
      Pose G = facing(t[0] + RZ * (float) Math.sin(a), t[1], t[2] + RZ * (float) Math.cos(a), t[0], t[2]);
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
    for (int i = 0; i < n; i++) { hw[i] = (float) Math.atan(g.m.get(i).hw * g.m.get(i).s / GRP_R); tot += 2f * hw[i]; }
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
      if (Math.abs(lx) > b.hw || Math.abs(ly) > b.hh) continue;
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
    if (moreOwner == w) hideMore();
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

  // ---- menu dos tres pontinhos: curva, modo computador, zoom do navegador, proporcao ----

  private void toggleMore(Win w) {
    if (moreWin != null && !moreWin.hidden && moreOwner == w) { hideMore(); return; }
    Session s = session;
    if (moreWin == null && s != null) {
      moreWin = addWindowP(s, w.current(), newPanel(ArActivity.MORE_URL, true), true, false);
      moreWin.s = 0.62f;
          }
    if (moreWin == null) return;
    moreOwner = w;
    moreCurved = w.curved;
    refreshFav();
    moreWin.hidden = false;
    moreWin.lockUntil = SystemClock.uptimeMillis() + 300;
    placeMore();
  }

  volatile boolean moreFav = false;

  private void refreshFav() {
    Win o = moreOwner;
    ArPanel.Snap sn = o == null ? null : o.panel.snap;
    moreFav = sn != null && sn.url != null && act.siteHas(sn.url);
  }

  /** O teclado virtual para campos das paginas do proprio menu (ex.: adicionar site manualmente). */
  void menuKb(boolean on) {
    if (on) { if (tabWin != null && !tabWin.hidden) showKb(tabWin); }
    else if (kbOwner == tabWin && tabWin != null) hideKb();
  }

  private void hideMore() {
    moreOwner = null;
    if (moreWin != null) moreWin.hidden = true;
  }

  private void placeMore() {
    if (moreWin == null || moreWin.hidden) return;
    Win o = moreOwner;
    if (o == null || !wins.contains(o) || o.min) { hideMore(); return; }
    moreCurved = o.curved;
    float dx = o.hw * o.s + 0.03f + HW * moreWin.s;
    moreWin.pose = o.current().compose(Pose.makeTranslation(dx, 0f, 0.012f));
  }

  /** "more:..." vindo da pagina das opcoes (thread do GL). */
  void moreAction(String a) {
    try {
      if ("more:curve".equals(a)) {
        Win o = moreOwner;
        if (o != null) { o.curved = !o.curved; moreCurved = o.curved; say(o.curved ? "Tela curva" : "Tela plana"); }
      } else if ("more:desktop".equals(a)) {
        ArPanel.desktop = !ArPanel.desktop;
        for (Win w : wins) if (!w.menu) w.panel.applyBrowser();
        say(ArPanel.desktop ? "Modo computador" : "Modo celular");
      } else if ("more:fav".equals(a)) {
        Win o = moreOwner;
        ArPanel.Snap sn = o == null ? null : o.panel.snap;
        if (sn != null && sn.url != null) {
          boolean now = act.siteToggle(sn.url);
          say(now ? "Adicionado a aba Web" : "Removido da aba Web");
        }
        refreshFav();
      } else if (a.startsWith("more:zoom:")) {
        ArPanel.zoomPct = Math.max(50, Math.min(100, Integer.parseInt(a.substring(10))));
        for (Win w : wins) if (!w.menu) w.panel.applyBrowser();
      } else if (a.startsWith("more:ar:")) {
        setAspect(Integer.parseInt(a.substring(8)));
      }
    } catch (Throwable t) { }
  }

  /** Proporcao global das janelas do navegador: refaz o tamanho da pagina de cada uma (elas recarregam). */
  private void setAspect(int i) {
    i = Math.max(0, Math.min(3, i));
    if (i == aspectIdx) return;
    aspectIdx = i;
    for (Win w : wins) {
      if (w.menu) continue;
      w.hw = AR_HW[i]; w.hh = AR_HH[i];
      w.panel.resize(AR_PW[i], AR_PH[i]);
    }
    say("Proporcao: " + new String[]{"16:9", "21:9", "32:9", "9:16"}[i]);
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
    float y = -(o.hh * o.s + 0.09f * o.s + HH * kbWin.s);
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
    if (o == helloWin) { helloKey(tok); return; }
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

  // ---- tela de boas-vindas ----

  private void updateHello(long now) {
    if (helloDone) return;
    Session s = session;
    if (helloMode == 0) {
      // so depois de carregar a IA da mao e de o ARCore comecar a rastrear (layout inicial criado)
      if (s == null || needSpawn || railWin == null || lastCamPose == null || !tracking || !act.handReady()) return;
      if (helloWin == null) {
        Pose cp = lastCamPose;
        float[] t = cp.getTranslation();
        float h = heading(cp);
        Pose p = facing(t[0] + 1.1f * (float) Math.sin(h), t[1], t[2] + 1.1f * (float) Math.cos(h), t[0], t[2]);
        helloWin = addWindowP(s, p, newPanel(ArActivity.HELLO_URL, true), true, false);
        helloWin.s = 1.15f;
      }
      helloWin.hidden = false;
      String nm = act.nick();
      helloBuf = "";
      helloT = now;
      if (nm.length() == 0) {
        helloText = "Ol\u00e1, como voc\u00ea se chama?";
        helloMode = 1;
        showKb(helloWin);
      } else {
        helloText = "Ol\u00e1, bem vindo de volta, " + nm;
        helloMode = 2;
      }
    } else if (helloMode == 1) {
      if (kbWin == null || kbWin.hidden || kbOwner != helloWin) showKb(helloWin);
    } else if (helloMode == 2) {
      if (now - helloT > 3200) { helloMode = 3; helloT = now; }
    } else if (helloMode == 3) {
      if (now - helloT > 900) {
        helloMode = 0;
        helloDone = true;
        if (helloWin != null) helloWin.hidden = true;
        if (kbOwner == helloWin) hideKb();
      }
    }
  }

  private void helloKey(String tok) {
    if (helloMode != 1) return;
    if (tok.startsWith("t:")) {
      String t = tok.substring(2);
      if (helloBuf.length() + t.length() <= 20) helloBuf += t;
    } else if (tok.equals("k:back")) {
      if (helloBuf.length() > 0) helloBuf = helloBuf.substring(0, helloBuf.length() - 1);
    } else if (tok.equals("k:enter")) {
      String n = helloBuf.trim();
      if (n.length() == 0) return;
      act.setNick(n);
      helloText = "Prazer, " + n;
      helloMode = 2;
      helloT = SystemClock.uptimeMillis();
      hideKb();
    }
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
    float dx = src.hw * src.s + 0.06f + src.hw;
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
    if (moreOwner == w) hideMore();
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
    for (Win w : wins) { if (!w.linked && !w.kb && w != moreWin) maintain1(s, w); }
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
      FloatBuffer vb = w.curved ? curveVertsOf(w) : winVertsOf(w), ub = w.curved ? curveUvs : winUvs;
      vb.position(0);
      ub.position(0);
      GLES20.glVertexAttribPointer(winPosLoc, 3, GLES20.GL_FLOAT, false, 0, vb);
      GLES20.glVertexAttribPointer(winUvLoc, 2, GLES20.GL_FLOAT, false, 0, ub);
      GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, w.panel.tex);
      GLES20.glUniformMatrix4fv(winStmLoc, 1, false, w.panel.stm, 0);
      GLES20.glUniform1f(winFlatLoc, w.panel.got ? 0f : 1f);
      GLES20.glUniform2f(winHalfLoc, w.hw * w.s, w.hh * w.s);
      GLES20.glUniform2f(winHalfVLoc, w.hw * w.s, w.hh * w.s);
      GLES20.glUniform1f(winRadLoc, CORNER_R * w.s);
      GLES20.glUniform1f(winSLoc, w.s);
      GLES20.glUniform1f(winGlassLoc, w == helloWin ? 2f : (w == tabWin || w == moreWin) ? 1f : 0f);
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
      if (!w.kb && w != helloWin) quad(barTex, 0f, barCy(w), BAR_W * (barOn ? 1.15f : 0.62f), BAR_H * (barOn ? 1.2f : 0.7f), barAct ? 0.37f : 1f, barAct ? 0.92f : 1f, barAct ? 0.83f : 1f, ba, dimV);
      if (!w.kb && w != helloWin) quad(cornerTex, w.hw - 0.013f, -w.hh + 0.013f, CS * (cornOn ? 1.2f : 0.8f), CS * (cornOn ? 1.2f : 0.8f), cornAct ? 0.37f : 1f, cornAct ? 0.92f : 1f, cornAct ? 0.83f : 1f, ca, dimV);
      if (!w.menu) {
        boolean curveOn = hov && hoverRegion == R_CURVE;
        iconBtn(curveGlyph, -PLUS_X, barCy(w), PLUS_S * (curveOn ? 1.2f : 0.9f), curveOn, moreWin != null && !moreWin.hidden && moreOwner == w, 1f, dimV);
        boolean keyOn = hov && hoverRegion == R_KEY, kbShown = kbWin != null && !kbWin.hidden && kbOwner == w;
        iconBtn(keyGlyph, PLUS_X, barCy(w), PLUS_S * (keyOn ? 1.2f : 0.9f), keyOn, kbShown, 1f, dimV);
        if (w.group != null && w.group.m.indexOf(w) > 0) {
          boolean lh = hov && hoverRegion == R_LINK;
          iconBtn(linkGlyph, chainX(w), chainY(w), 0.05f * (lh ? 1.2f : 0.95f), lh, false, 1f, dimV);
        }
      }
      if (w == dropT && dropSide != 0) iconBtn(linkGlyph, dropSide * w.hw / 2f, 0f, 0.1f, false, true, 1f, dimV);
      if (w.chromeVer >= 0) quad(w.chromeTex, 0f, chainY(w), chW(w), chH(w), 1f, 1f, 1f, 1f, dimV);
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

  private static float chainX(Win w) { return -(w.hw + 0.006f / w.s); }
  private static float chW(Win w) { return 2f * w.hw * 0.8f; }
  private static float chH(Win w) { return chW(w) * ArChrome.DH / ArChrome.DW; }
  private static float chainY(Win w) { return w.hh + CH_GAP + chH(w) / 2f; }
  private static float barCy(Win w) { return -(w.hh + 0.028f); }
  private static float rnOf(Win w) { return w.hw / CURVE_TH; }

  private FloatBuffer winVertsOf(Win w) {
    int a = w.menu ? 0 : aspectIdx;
    if (a == 0) return winVerts;
    if (winVA[a] == null) winVA[a] = floatBuf(new float[]{-w.hw, -w.hh, 0f, w.hw, -w.hh, 0f, -w.hw, w.hh, 0f, w.hw, w.hh, 0f});
    return winVA[a];
  }

  private FloatBuffer curveVertsOf(Win w) {
    int a = w.menu ? 0 : aspectIdx;
    if (a == 0) return curveVerts;
    if (curVA[a] == null) curVA[a] = floatBuf(curveMesh(true, w.hw, w.hh));
    return curVA[a];
  }

  /** Trilho do menu: so icones, um abaixo do outro; aparecem descendo. */
  /** O botao de centralizar so aparece com alguma janela web aberta. */
  private boolean centerHidden() {
    for (Win w : wins) if (!w.menu && !w.kb && !w.rail && !w.hidden) return false;
    return true;
  }

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
    final boolean chd = centerHidden();
    for (int k = 0; k < RAIL_N; k++) {
      if (chd && k == 1) continue;
      int pos = chd && k > 1 ? k - 1 : k;
      float a = Math.max(0f, Math.min(1f, rv - (pos + 1)));
      if (a <= 0f) continue;
      float e = a * a * (3f - 2f * a);
      float y = -(RAIL_TOP + (pos + 0.5f) * RAIL_P) + (1f - e) * 0.05f;
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
      quad(discTex, x, y, size, size, 0.16f, 0.2f, 0.28f, 0.05f * alpha, dimV);
      quad(thinTex, x, y, size, size, 1f, 1f, 1f, 0.17f * alpha, dimV);
    }
    if (!solid) quad(glyph, x + size * 0.025f, y - size * 0.025f, size * 0.62f, size * 0.62f, 0f, 0f, 0f, 0.35f * alpha, dimV);
    quad(glyph, x, y, size * 0.62f, size * 0.62f, solid ? 0.07f : 1f, solid ? 0.08f : 1f, solid ? 0.1f : 1f, alpha, dimV);
  }

  /** model = pose da janela * escala (curva: escala uniforme, a malha ja tem a profundidade). */
  private void modelOf(Win w) {
    drawW = w;
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
      float u = i / (float) m, ph = (x - sx / 2f + sx * u) / rnOf(drawW);
      float px = (float) (rnOf(drawW) * Math.sin(ph)), pz = (float) (rnOf(drawW) * (1.0 - Math.cos(ph))) + CHROME_Z;
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
    float x = ((r[0] + r[2]) / 2f / ArChrome.DW - 0.5f) * chW(w);
    float y = w.hh + CH_GAP + (1f - (r[1] + r[3]) / 2f / ArChrome.DH) * chH(w);
    float sx = (r[2] - r[0]) / ArChrome.DW * chW(w), sy = (r[3] - r[1]) / ArChrome.DH * chH(w);
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
    pinch = (handFist || peace) ? false : (pinch ? ratio < pinchOff : ratio < pinchOn);
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
    boolean peaceEff = has && skel != null && !handFist && ((peace && peaceN >= 5) || (swActive && now - lastPeaceMs < 250));
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
      if (now - lastClick > 400) { lastClick = now; toggleMore(w); }
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
    float p = horizontal ? (local + w.hw) / (2f * w.hw) * pw : (w.hh - local) / (2f * w.hh) * ph;
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
    float r = rnOf(w) * w.s;
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
    if (w == helloWin) return R_NONE;
    if (w.rail) {
      float barY = -RAIL_H - 0.034f;
      if (Math.abs(x) <= 0.05f && Math.abs(y - barY) <= 0.026f && menuReveal > 0.9f) return R_BAR;
      if (Math.abs(x) <= 0.036f && y <= -RAIL_TOP && y >= -RAIL_H) {
        boolean chd = centerHidden();
        int pos = Math.min(RAIL_N - 1 - (chd ? 1 : 0), (int) ((-y - RAIL_TOP) / RAIL_P));
        int k = chd && pos >= 1 ? pos + 1 : pos;
        if (menuReveal * (RAIL_N + 2) - (pos + 1) > 0.6f) { regElem = k; return R_ICON; }
      }
      return R_NONE;
    }
    if (w.kb) return (Math.abs(x) <= w.hw && Math.abs(y) <= w.hh) ? R_BODY : R_NONE;
    if (!w.menu && w.group != null && w.group.m.indexOf(w) > 0
      && Math.abs(x - chainX(w)) <= 0.03f && Math.abs(y - chainY(w)) <= 0.03f) return R_LINK;
    if (Math.abs(x - (w.hw - 0.013f)) <= CS_HIT && Math.abs(y - (-w.hh + 0.013f)) <= CS_HIT) return R_CORNER;
    if (!w.menu && Math.abs(x - PLUS_X) <= PLUS_HIT && Math.abs(y - barCy(w)) <= PLUS_HIT) return R_KEY;
    if (!w.menu && Math.abs(x + PLUS_X) <= PLUS_HIT && Math.abs(y - barCy(w)) <= PLUS_HIT) return R_CURVE;
    if (Math.abs(x) <= BAR_HIT_X && Math.abs(y - barCy(w)) <= BAR_HIT_Y) return R_BAR;
    if (Math.abs(x) <= w.hw && Math.abs(y) <= w.hh) return R_BODY;
    float y0 = w.hh + CH_GAP, CHW = chW(w), CHH = chH(w);
    if (!w.menu && y >= y0 - 0.006f && y <= y0 + CHH + 0.006f && Math.abs(x) <= CHW / 2f + 0.006f) {
      ArPanel.Snap sn = w.panel.snap;
      if (sn != null) {
        float dx = Math.max(0f, Math.min(ArChrome.DW, (x / CHW + 0.5f) * ArChrome.DW));
        float dy = Math.max(0f, Math.min(ArChrome.DH, (1f - (y - y0) / CHH) * ArChrome.DH));
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
  private boolean swBlock = false;
  static final long SW_MIN_MS = 500;     // o gesto do menu precisa durar pelo menos isso

  private void updateMenuGesture(Session s, boolean on, float[] cam, long now) {
    if (!on) swBlock = false;
    if (on && railWin != null && !swBlock) {
      float px = (skel[16] + skel[24]) * 0.5f, py = (skel[17] + skel[25]) * 0.5f;
      if (!swActive || (!swDone && now - swT > 1200)) {
        if (!menuOpen) {
          // com a mao em cima de uma janela o menu nao abre
          Hit hh = raycast(cam, rayDir(px, py, cam));
          if (hh != null && hh.win != railWin && hh.win != tabWin) { swBlock = true; swActive = false; swMode = 0; return; }
        }
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
      // descer uns 40% da tela, e durante pelo menos 0,5 s; os primeiros 15% sao ignorados (tremida)
      float raw = Math.max(0f, Math.min(1f, (py - swY0) / (0.40f * Math.max(1f, vh))));
      float tf = Math.min(1f, (now - swT) / (float) SW_MIN_MS);
      if (!swDone) {
        distTarget = 0.25f + 0.75f * Math.max(0f, Math.min(1f, (py - swY0) / (0.40f * Math.max(1f, vh))));
        distCx = 2f * px / Math.max(1f, vw) - 1f;
        distCy = 1f - 2f * py / Math.max(1f, vh);
      }
      swProg = Math.min(Math.max(0f, (raw - 0.15f) / 0.85f), tf);
      if (!swDone) {
        if (swMode == 1) {
          menuReveal = swProg;
          if (swProg >= 1f) { menuOpen = true; swDone = true; distPulseNs = System.nanoTime(); }
        } else if (swMode == 2) {
          menuReveal = 1f - swProg;
          if (swProg >= 1f) { hideMenu(); swDone = true; distPulseNs = System.nanoTime(); }
        }
      }
    } else if (swActive) {
      if (!swDone) {
        // gesto interrompido: o menu volta ao estado de antes (nao abre nem fecha pela metade)
        if (swMode == 1) menuOpen = false;
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

  private float railS() { return railWin != null ? railWin.s : 1f; }
  private float tabOffX() { return (RAIL_HALF + 0.035f) * railS() + HW * (tabWin != null ? tabWin.s : 0.85f); }
  private float tabOffY() { return -RAIL_H * railS() / 2f; }

  /** A aba do menu fica sempre ao lado direito do trilho. */
  private void placeTab() {
    if (tabWin == null || railWin == null || dragWin == tabWin) return;
    tabWin.pose = railWin.current().compose(Pose.makeTranslation(tabOffX(), tabOffY(), 0f));
  }

  private void menuSelect(int k) {
    if (k == 0) { closeTab(); return; }
    if (k == 1) { recenter(); return; }
    if (menuTab == k && tabWin != null && !tabWin.hidden) { closeTab(); return; }
    openTab(k == 2 ? "space" : k == 3 ? "web" : k == 4 ? "apps" : k == 5 ? "aju" : "cfg", k);
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

  private static float[] curveMesh(boolean pos) { return curveMesh(pos, HW, HH); }

  private static float[] curveMesh(boolean pos, float hw, float hh) {
    final float rn = hw / CURVE_TH;
    float[] a = new float[(CN + 1) * 2 * (pos ? 3 : 2)];
    int k = 0;
    for (int i = 0; i <= CN; i++) {
      float u = i / (float) CN, ph = (u * 2f - 1f) * hw / rn;
      float px = (float) (rn * Math.sin(ph)), pz = (float) (rn * (1.0 - Math.cos(ph)));
      for (int r = 0; r < 2; r++) {
        float y = r == 0 ? -hh : hh;
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
    for (Win w : wins) if (w.anchor == null && !w.linked && !w.kb && w != moreWin) noAnchor++;
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
    GLES20.glUniform1f(bgDimLoc, 1f - 0.96f * Math.max(0f, Math.min(1f, roomDim)));
    bgUv.position(0);
    float t0x = bgUv.get(0), t0y = bgUv.get(1);
    GLES20.glUniform2f(bgT0Loc, t0x, t0y);
    GLES20.glUniform2f(bgTXLoc, bgUv.get(2) - t0x, bgUv.get(3) - t0y);
    GLES20.glUniform2f(bgTYLoc, bgUv.get(4) - t0x, bgUv.get(5) - t0y);
    GLES20.glUniform2f(bgCenterLoc, distCx, distCy);
    GLES20.glUniform1f(bgStrLoc, distStrNow);
    GLES20.glUniform1f(bgTimeLoc, ((System.nanoTime() - startNs) / 1000000L % 1000000L) / 1000f);
    GLES20.glUniform1f(bgAspLoc, vh > 0 ? (float) vw / vh : 1f);
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

  private static final float[] ZERO3 = new float[3];

  /** Direcao para onde o usuario olha, pelo mesmo referencial do panorama (giroscopio quando ele esta em uso). */
  private float panoHeading(Pose cp) {
    if (spGyro) {
      float fx = -rP[2], fz = -rP[8];
      if (fx * fx + fz * fz > 1e-6f) return (float) Math.atan2(fx, fz);
    }
    return heading(cp);
  }

  private float yawNow() {
    return lastCamPose != null ? panoHeading(lastCamPose) - (float) Math.PI : 0f;
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
    GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MIN_FILTER, pot ? GLES20.GL_LINEAR_MIPMAP_LINEAR : GLES20.GL_LINEAR);
    GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR);
    GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_S, pot ? GLES20.GL_REPEAT : GLES20.GL_CLAMP_TO_EDGE);
    GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE);
    GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0, b, 0);
    if (pot) GLES20.glGenerateMipmap(GLES20.GL_TEXTURE_2D);
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
    spAuto = act.space.layoutOf(f);
    layMode = 0;
    applyLayMode();
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
      + "uniform mat4 u_InvProj;\nuniform mat3 u_Rot;\nuniform float u_Yaw;\nuniform float u_A;\nuniform vec4 u_Lay;\n"
      + "#ifdef OES\nuniform samplerExternalOES u_Tex;\nuniform mat4 u_Stm;\n#else\nuniform sampler2D u_Tex;\n#endif\n"
      + "uniform vec2 u_Px;\nuniform float u_Sharp;\n"
      + "vec2 uvOf(vec2 n) {\n"
      + "  vec4 p = u_InvProj * vec4(n, 1.0, 1.0);\n"
      + "  vec3 w = u_Rot * normalize(p.xyz / p.w);\n"
      + "  float c = cos(u_Yaw), s = sin(u_Yaw);\n"
      + "  vec3 r = vec3(c * w.x - s * w.z, w.y, s * w.x + c * w.z);\n"
      + "  float az = atan(r.x, -r.z);\n"
      + "  float el = asin(clamp(r.y, -1.0, 1.0));\n"
      + "#ifdef OES\n"
      + "  vec2 b = vec2(az * 0.15915494 + 0.5, 0.5 + el * 0.31830989);\n"
      + "  b = b * u_Lay.xz + u_Lay.yw;\n"
      + "  return (u_Stm * vec4(b, 0.0, 1.0)).xy;\n"
      + "#else\n"
      + "  return vec2(az * 0.15915494 + 0.5, 0.5 - el * 0.31830989);\n"
      + "#endif\n"
      + "}\n"
      + "void main() {\n"
      + "  vec3 col = texture2D(u_Tex, uvOf(v_Ndc)).rgb;\n"
      + "  if (u_Sharp > 0.01) {\n"
      + "    vec3 bl = texture2D(u_Tex, uvOf(v_Ndc + vec2(u_Px.x, 0.0))).rgb + texture2D(u_Tex, uvOf(v_Ndc - vec2(u_Px.x, 0.0))).rgb\n"
      + "            + texture2D(u_Tex, uvOf(v_Ndc + vec2(0.0, u_Px.y))).rgb + texture2D(u_Tex, uvOf(v_Ndc - vec2(0.0, u_Px.y))).rgb;\n"
      + "    col = clamp(col + (col - bl * 0.25) * u_Sharp, 0.0, 1.0);\n"
      + "  }\n"
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
    spLayLoc = GLES20.glGetUniformLocation(pr, "u_Lay");
    spPxLoc = GLES20.glGetUniformLocation(pr, "u_Px");
    spShLoc = GLES20.glGetUniformLocation(pr, "u_Sharp");
    return true;
  }

  /** Desenha o panorama em volta da camera (so a rotacao conta, como se estivesse no infinito). */
  private void drawSpace() {
    if (spKind == 0 || spProg == 0 || spTex == 0 || spAlpha <= 0.005f) return;
    float e = spAlpha * spAlpha * (3f - 2f * spAlpha);
    if (stereo) {
      // panorama com campo de visao proprio (a camera do celular e estreita e dava efeito de zoom)
      Matrix.perspectiveM(spProjM, 0, eFov(), (float) vpW / Math.max(1, vpH), 0.1f, 30f);
      Matrix.invertM(invProj, 0, spProjM, 0);
    } else {
      Matrix.invertM(invProj, 0, proj, 0);
    }
    final float[] vw3 = spGyro ? spView : view;
    for (int j = 0; j < 3; j++) for (int i = 0; i < 3; i++) rot3[j * 3 + i] = vw3[i * 4 + j];
    GLES20.glDisable(GLES20.GL_DEPTH_TEST);
    GLES20.glDepthMask(false);
    GLES20.glEnable(GLES20.GL_BLEND);
    GLES20.glBlendFunc(GLES20.GL_ONE, GLES20.GL_ONE_MINUS_SRC_ALPHA);
    GLES20.glUseProgram(spProg);
    GLES20.glUniformMatrix4fv(spProjLoc, 1, false, invProj, 0);
    GLES20.glUniformMatrix3fv(spRotLoc, 1, false, rot3, 0);
    GLES20.glUniform1f(spYawLoc, spYaw);
    GLES20.glUniform2f(spPxLoc, 2f / Math.max(1, vpW), 2f / Math.max(1, vpH));
    GLES20.glUniform1f(spShLoc, sharp * 1.5f);
    GLES20.glUniform1f(spAlphaLoc, e);
    if (spOes) GLES20.glUniformMatrix4fv(spStmLoc, 1, false, spStm, 0);
    // video estereo: olho esquerdo = metade de cima (top-bottom) ou da esquerda; direito = a outra. Sem estereo na tela, so o olho esquerdo.
    int ey = stereo ? curEye : 0;
    if (spLayout == 1) GLES20.glUniform4f(spLayLoc, 1f, 0f, 0.5f, ey == 0 ? 0.5f : 0f);
    else if (spLayout == 2) GLES20.glUniform4f(spLayLoc, 0.5f, ey == 0 ? 0f : 0.5f, 1f, 0f);
    else GLES20.glUniform4f(spLayLoc, 1f, 0f, 1f, 0f);
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
      case 11: { // engrenagem: aro com 8 dentes e furo central
        p.setStrokeWidth(6f);
        c.drawCircle(48f, 48f, 20f, p);
        c.drawCircle(48f, 48f, 7f, p);
        for (int i = 0; i < 8; i++) {
          double an = i * Math.PI / 4.0;
          float ca = (float) Math.cos(an), sa = (float) Math.sin(an);
          c.drawLine(48f + ca * 27f, 48f + sa * 27f, 48f + ca * 36f, 48f + sa * 36f, p);
        }
        break;
      }
      case 14:  // web: globo com meridiano e paralelos
        p.setStrokeWidth(6f);
        c.drawCircle(48f, 48f, 32f, p);
        c.drawOval(new RectF(32f, 16f, 64f, 80f), p);
        c.drawLine(16f, 48f, 80f, 48f, p);
        c.drawLine(22f, 31f, 74f, 31f, p);
        c.drawLine(22f, 65f, 74f, 65f, p);
        break;
      case 13:  // oculos: duas lentes e a ponte
        p.setStrokeWidth(6f);
        c.drawCircle(28f, 52f, 16f, p); c.drawCircle(68f, 52f, 16f, p);
        c.drawLine(44f, 50f, 52f, 50f, p);
        c.drawLine(12f, 48f, 8f, 36f, p); c.drawLine(84f, 48f, 88f, 36f, p);
        break;
      case 12:  // tres pontinhos
        p.setStyle(Paint.Style.FILL);
        c.drawCircle(48f, 22f, 7f, p); c.drawCircle(48f, 48f, 7f, p); c.drawCircle(48f, 74f, 7f, p);
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

  private static Bitmap makeThinRing() {
    Bitmap b = Bitmap.createBitmap(128, 128, Bitmap.Config.ARGB_8888);
    Canvas c = new Canvas(b);
    Paint p = new Paint(Paint.ANTI_ALIAS_FLAG);
    p.setColor(Color.WHITE);
    p.setStyle(Paint.Style.STROKE);
    p.setStrokeWidth(2f);
    c.drawCircle(64f, 64f, 61f, p);
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
    "varying vec2 v_Ndc;\n" +
    "void main() { gl_Position = a_Position; v_TexCoord = a_TexCoord; v_Ndc = a_Position.xy; }\n";

  // com u_Strength > 0: ondas + giro + aberracao cromatica + brilho ao redor de u_Center (efeito "outra dimensao" do gesto do menu)
  private static final String BG_FS =
    "#extension GL_OES_EGL_image_external : require\n" +
    "#ifdef GL_FRAGMENT_PRECISION_HIGH\nprecision highp float;\n#else\nprecision mediump float;\n#endif\n" +
    "varying vec2 v_TexCoord;\nvarying vec2 v_Ndc;\n" +
    "uniform samplerExternalOES u_Texture;\nuniform float u_Dim;\n" +
    "uniform vec2 u_T0;\nuniform vec2 u_TX;\nuniform vec2 u_TY;\nuniform vec2 u_Center;\n" +
    "uniform float u_Strength;\nuniform float u_Time;\nuniform float u_Aspect;\n" +
    "vec2 tcOf(vec2 n) { return u_T0 + (n.x * 0.5 + 0.5) * u_TX + (n.y * 0.5 + 0.5) * u_TY; }\n" +
    "void main() {\n" +
    "  if (u_Strength < 0.002) { gl_FragColor = vec4(texture2D(u_Texture, v_TexCoord).rgb * u_Dim, 1.0); return; }\n" +
    "  vec2 p = v_Ndc - u_Center;\n  p.x *= u_Aspect;\n  float r = length(p);\n  float rad = 0.5;\n" +
    "  float fall = exp(-(r * r) / (rad * rad));\n  float wave = sin(r * 22.0 - u_Time * 7.0);\n" +
    "  vec2 dir = p / max(r, 0.0001);\n  float amp = u_Strength * fall;\n" +
    "  vec2 q = p + dir * wave * 0.035 * amp;\n" +
    "  float ang = amp * 0.9 * (1.0 - smoothstep(0.0, rad * 1.6, r));\n  float cs = cos(ang);\n  float sn = sin(ang);\n" +
    "  q = vec2(cs * q.x - sn * q.y, sn * q.x + cs * q.y);\n" +
    "  vec2 n2 = vec2(q.x / u_Aspect, q.y) + u_Center;\n" +
    "  vec2 off = dir * amp * 0.018;\n  off.x = off.x / u_Aspect;\n" +
    "  float cr = texture2D(u_Texture, tcOf(n2 + off)).r;\n  float cg = texture2D(u_Texture, tcOf(n2)).g;\n  float cb = texture2D(u_Texture, tcOf(n2 - off)).b;\n" +
    "  vec3 col = vec3(cr, cg, cb);\n  float rr = (r - 0.18) / 0.16;\n" +
    "  float glow = amp * (0.25 + 0.15 * wave) * exp(-(rr * rr));\n  col += vec3(0.20, 0.45, 0.75) * glow * 0.6;\n" +
    "  gl_FragColor = vec4(col * u_Dim, 1.0);\n}\n";

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
    "uniform float u_Glass;\n" +
    "uniform float u_Dim;\n" +
    "uniform vec2 u_Shade;\n" +
    "void main() {\n" +
    "  vec2 q = abs(v_P) - (u_Half - vec2(u_R));\n" +
    "  float d = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - u_R;\n" +
    "  if (d > 0.0008) discard;\n" +
    "  float al = 1.0 - smoothstep(-0.0006, 0.0006, d);\n" +
    "  vec2 uv = (u_Stm * vec4(v_Uv, 0.0, 1.0)).xy;\n" +
    "  vec3 c = texture2D(u_Tex, uv).rgb;\n" +
    "  c = mix(c, vec3(0.08, 0.09, 0.12), u_Flat * max(0.0, 1.0 - u_Glass)) * u_Dim;\n" +
    "  float on = step(0.5, abs(u_Shade.x));\n" +
    "  float sd = on * step(0.0, u_Shade.x * v_P.x);\n" +
    "  c = mix(c, vec3(0.02, 0.03, 0.05), sd * 0.62);\n" +
    "  float seam = sd * (1.0 - smoothstep(0.0, 0.010, u_Half.x - abs(v_P.x)));\n" +
    "  c = mix(c, vec3(0.37, 0.92, 0.83), seam * 0.95);\n" +
    "  c = mix(c, vec3(1.0), smoothstep(-0.0028, -0.0010, d) * 0.22 * (1.0 - step(1.5, u_Glass)));\n" +
    "  float ga = mix(1.0, clamp(0.09 + 1.25 * max(c.r, max(c.g, c.b)), 0.0, 1.0), min(u_Glass, 1.0));\n" +
    "  if (u_Glass > 1.5) {\n" +
    "    float tx = max(c.r, c.g);\n" +
    "    ga = clamp(1.25 * tx + max(0.0, c.b - tx) * 1.6, 0.0, 1.0);\n" +
    "    c = vec3(c.r, c.g, min(c.b, tx));\n" +
    "  }\n" +
    "  gl_FragColor = vec4(c * al, ga * al);\n" +
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
import android.media.AudioManager;
import android.provider.Settings;
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
  static final String MORE_URL = "about:more";
  static final String HELLO_URL = "about:hello";
  /** Aba do menu que a pagina deve mostrar (lida pela pagina via ArMenu.page()). */
  volatile String menuPage = "web";

  private FrameLayout root;
  private GLSurfaceView gl;
  ArRenderer renderer;
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
    renderer.pinchOn = prefs.getFloat("pOn", ArRenderer.PINCH_ON);
    renderer.pinchOff = prefs.getFloat("pOff", ArRenderer.PINCH_OFF);
    renderer.roomDim = prefs.getInt("room", 0) / 100f;
    renderer.sharp = prefs.getInt("sharp", 40) / 100f;
    renderer.menuZoom = Math.max(1, Math.min(5, prefs.getInt("mz", 2)));
    renderer.ipdMm = prefs.getInt("ipd", 64);
    renderer.sepMm = prefs.getInt("sep", 0);
    renderer.vOffMm = prefs.getInt("vsep", 0);
    renderer.sizePct = prefs.getInt("lsize", 100);
    renderer.distPct = prefs.getInt("ldist2", 100);
    renderer.fovDeg = prefs.getInt("lfov", 90);
    renderer.lensMode = prefs.getInt("lmode", 0);
    renderer.zoom = Math.max(1, Math.min(5, prefs.getInt("zoom", 1)));
    applyBrightness(prefs.getInt("bri", -1));
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
    if (a.startsWith("set:")) { setValue(a); return; }
    if (a.startsWith("more:")) { final String ma = a; queueGl(new Runnable() { @Override public void run() { renderer.moreAction(ma); } }); return; }
    if (a.startsWith("sp:")) { space.command(a); return; }
    if (a.startsWith("sites:")) { prefs.edit().putString("sites", a.substring(6)).apply(); return; }
    if (a.startsWith("open:")) {
      final String u = a.substring(5);
      if (u.startsWith("http")) queueGl(new Runnable() { @Override public void run() { renderer.openApp(u); } });
      return;
    }
    if (a.equals("kb:on")) { queueGl(new Runnable() { @Override public void run() { renderer.menuKb(true); } }); return; }
    if (a.equals("kb:off")) { queueGl(new Runnable() { @Override public void run() { renderer.menuKb(false); } }); return; }
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

  void cycleLayout() {
    queueGl(new Runnable() { @Override public void run() { renderer.cycleLayout(); } });
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

  // ---- lista de sites da aba Web ----

  private static final String DEFAULT_SITES = "[{\"n\":\"YouTube\",\"u\":\"https://m.youtube.com/\"},{\"n\":\"Google\",\"u\":\"https://www.google.com/\"},"
    + "{\"n\":\"Wikip\u00e9dia\",\"u\":\"https://pt.m.wikipedia.org/\"},{\"n\":\"Discord\",\"u\":\"https://discord.com/app\"},"
    + "{\"n\":\"WhatsApp\",\"u\":\"https://web.whatsapp.com/\"},{\"n\":\"Reddit\",\"u\":\"https://www.reddit.com/\"},"
    + "{\"n\":\"Mapas\",\"u\":\"https://www.openstreetmap.org/\"},{\"n\":\"Not\u00edcias\",\"u\":\"https://news.google.com/\"}]";

  String sitesJson() { return prefs.getString("sites", DEFAULT_SITES); }

  private static String hostOf(String u) {
    try {
      String h = android.net.Uri.parse(u).getHost();
      if (h == null) return "";
      return h.startsWith("www.") ? h.substring(4) : h;
    } catch (Throwable t) { return ""; }
  }

  boolean siteHas(String url) {
    try {
      String h = hostOf(url);
      if (h.length() == 0) return false;
      org.json.JSONArray a = new org.json.JSONArray(sitesJson());
      for (int i = 0; i < a.length(); i++) if (h.equals(hostOf(a.getJSONObject(i).getString("u")))) return true;
    } catch (Throwable t) { }
    return false;
  }

  /** Favorito: adiciona o site da janela a aba Web (ou remove, se ja estiver la). Devolve true se agora e favorito. */
  boolean siteToggle(String url) {
    try {
      String h = hostOf(url);
      if (h.length() == 0 || !url.startsWith("http")) return false;
      org.json.JSONArray a = new org.json.JSONArray(sitesJson());
      org.json.JSONArray out = new org.json.JSONArray();
      boolean had = false;
      for (int i = 0; i < a.length(); i++) {
        org.json.JSONObject o = a.getJSONObject(i);
        if (h.equals(hostOf(o.getString("u")))) had = true; else out.put(o);
      }
      if (!had) {
        String nm = h.replaceFirst("^(m|web|pt|mobile)\\.", "");
        int d = nm.indexOf('.');
        if (d > 0) nm = nm.substring(0, d);
        if (nm.length() > 0) nm = Character.toUpperCase(nm.charAt(0)) + nm.substring(1);
        org.json.JSONObject o = new org.json.JSONObject();
        o.put("n", nm.length() == 0 ? "Site" : nm);
        o.put("u", url);
        out.put(o);
      }
      prefs.edit().putString("sites", out.toString()).apply();
      return !had;
    } catch (Throwable t) { return false; }
  }

  String nick() { return prefs.getString("nick", ""); }
  void setNick(String n) { prefs.edit().putString("nick", n).apply(); }
  boolean handReady() { return !"carregando modelo...".equals(tracker.status); }

  private static String q(String s) {
    if (s == null) return "\"\"";
    StringBuilder b = new StringBuilder("\"");
    for (int i = 0; i < s.length(); i++) {
      char c = s.charAt(i);
      if (c == '"' || c == '\\') b.append('\\').append(c);
      else if (c < 32) b.append(' ');
      else b.append(c);
    }
    return b.append('"').toString();
  }

  String menuState() {
    return "{\"gpu\":" + tracker.wantsGpu() + ",\"hybrid\":" + renderer.hybridOn + ",\"stereo\":" + renderer.stereo
      + ",\"vol\":" + volumeNow() + ",\"bri\":" + brightnessNow() + ",\"room\":" + Math.round(renderer.roomDim * 100f)
      + ",\"curved\":" + renderer.moreCurved + ",\"desktop\":" + ArPanel.desktop + ",\"bz\":" + ArPanel.zoomPct + ",\"ar\":" + renderer.aspectIdx
      + ",\"lmode\":" + renderer.lensMode + ",\"ipd\":" + Math.round(renderer.eIpd()) + ",\"sep\":" + Math.round(renderer.eSep()) + ",\"vsep\":" + Math.round(renderer.eVoff()) + ",\"lsize\":" + Math.round(renderer.eSize()) + ",\"ldist\":" + Math.round(renderer.eDist()) + ",\"lfov\":" + Math.round(renderer.eFov()) + ",\"sharp\":" + Math.round(renderer.sharp * 100f)
      + ",\"fav\":" + renderer.moreFav + ",\"mz\":" + renderer.menuZoom + ",\"hm\":" + renderer.helloMode + ",\"ht\":" + q(renderer.helloText) + ",\"hb\":" + q(renderer.helloBuf)
      + ",\"zoom\":" + renderer.zoom + ",\"pOn\":" + Math.round(renderer.pinchOn * 100f) + ",\"pOff\":" + Math.round(renderer.pinchOff * 100f) + "}";
  }

  // ---- ajustes (volume, brilho da tela, brilho do quarto, zoom da interface, pinca) ----

  private int volumeNow() {
    try {
      AudioManager am = (AudioManager) getSystemService(AUDIO_SERVICE);
      int mx = am.getStreamMaxVolume(AudioManager.STREAM_MUSIC);
      return mx <= 0 ? 0 : Math.round(100f * am.getStreamVolume(AudioManager.STREAM_MUSIC) / mx);
    } catch (Throwable t) { return 50; }
  }

  private int brightnessNow() {
    int b = prefs.getInt("bri", -1);
    if (b >= 0) return b;
    try { return Math.round(100f * Settings.System.getInt(getContentResolver(), Settings.System.SCREEN_BRIGHTNESS, 128) / 255f); } catch (Throwable t) { return 50; }
  }

  /** v < 0: segue o brilho do sistema. */
  private void applyBrightness(final int v) {
    ui.post(new Runnable() {
      @Override public void run() {
        try {
          WindowManager.LayoutParams lp = getWindow().getAttributes();
          lp.screenBrightness = v < 0 ? WindowManager.LayoutParams.BRIGHTNESS_OVERRIDE_NONE : Math.max(0.02f, Math.min(1f, v / 100f));
          getWindow().setAttributes(lp);
        } catch (Throwable t) { }
      }
    });
  }

  /** "set:chave:valor" vindo do menu. */
  private void setValue(String a) {
    try {
      String[] p = a.split(":");
      String k = p[1];
      int v = Integer.parseInt(p[2].trim());
      if ("vol".equals(k)) {
        AudioManager am = (AudioManager) getSystemService(AUDIO_SERVICE);
        int mx = am.getStreamMaxVolume(AudioManager.STREAM_MUSIC);
        am.setStreamVolume(AudioManager.STREAM_MUSIC, Math.round(mx * Math.max(0, Math.min(100, v)) / 100f), 0);
        return;
      }
      if ("bri".equals(k)) { prefs.edit().putInt("bri", Math.max(2, Math.min(100, v))).apply(); applyBrightness(Math.max(2, Math.min(100, v))); return; }
      if ("room".equals(k)) { renderer.roomDim = Math.max(0, Math.min(100, v)) / 100f; prefs.edit().putInt("room", Math.max(0, Math.min(100, v))).apply(); return; }
      if ("ipd".equals(k)) { v = Math.max(50, Math.min(75, v)); renderer.ipdMm = v; prefs.edit().putInt("ipd", v).apply(); return; }
      if ("sep".equals(k)) { v = Math.max(-20, Math.min(20, v)); renderer.sepMm = v; prefs.edit().putInt("sep", v).apply(); return; }
      if ("vsep".equals(k)) { v = Math.max(-15, Math.min(15, v)); renderer.vOffMm = v; prefs.edit().putInt("vsep", v).apply(); return; }
      if ("lsize".equals(k)) { v = Math.max(60, Math.min(120, v)); renderer.sizePct = v; prefs.edit().putInt("lsize", v).apply(); return; }
      if ("ldist".equals(k)) { v = Math.max(0, Math.min(200, v)); renderer.distPct = v; prefs.edit().putInt("ldist2", v).apply(); return; }
      if ("lfov".equals(k)) { v = Math.max(60, Math.min(120, v)); renderer.fovDeg = v; prefs.edit().putInt("lfov", v).apply(); return; }
      if ("mzoom".equals(k)) { int z = Math.max(1, Math.min(5, v)); renderer.menuZoom = z; prefs.edit().putInt("mz", z).apply(); return; }
      if ("lmode".equals(k)) { v = v == 0 ? 0 : 1; renderer.lensMode = v; prefs.edit().putInt("lmode", v).apply(); return; }
      if ("sharp".equals(k)) { v = Math.max(0, Math.min(100, v)); renderer.sharp = v / 100f; prefs.edit().putInt("sharp", v).apply(); return; }
      if ("lreset".equals(k)) { renderer.ipdMm = 64; renderer.sepMm = 0; renderer.vOffMm = 0; renderer.sizePct = 100; renderer.distPct = 100; renderer.fovDeg = 90; renderer.sharp = 0.4f; prefs.edit().putInt("ipd", 64).putInt("sep", 0).putInt("vsep", 0).putInt("lsize", 100).putInt("ldist2", 100).putInt("lfov", 90).putInt("sharp", 40).apply(); return; }
      if ("zoom".equals(k)) { int z = Math.max(1, Math.min(5, v)); renderer.zoom = z; prefs.edit().putInt("zoom", z).apply(); return; }
      if ("pOn".equals(k) || "pOff".equals(k)) {
        float on = renderer.pinchOn, off = renderer.pinchOff, f = Math.max(0.05f, Math.min(0.6f, v / 100f));
        if ("pOn".equals(k)) { on = f; if (off < on + 0.04f) off = on + 0.04f; }
        else { off = f; if (on > off - 0.04f) on = off - 0.04f; }
        renderer.pinchOn = Math.max(0.05f, on);
        renderer.pinchOff = Math.min(0.6f, off);
        prefs.edit().putFloat("pOn", renderer.pinchOn).putFloat("pOff", renderer.pinchOff).apply();
      }
    } catch (Throwable t) { }
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
    "\n" +
    "<style>\n" +
    "@font-face{font-family:'Exo 2';font-weight:300;src:url(/font/exo2-300.woff2) format('woff2')}\n" +
    "@font-face{font-family:'Exo 2';font-weight:400;src:url(/font/exo2-400.woff2) format('woff2')}\n" +
    "*{box-sizing:border-box;-webkit-tap-highlight-color:transparent;-webkit-user-select:none;user-select:none}\n" +
    "html,body{margin:0;height:100%;background:#000;color:#fff;font-family:system-ui,-apple-system,sans-serif;overflow:hidden}\n" +
    "#app{display:flex;height:100%}\n" +
    "#rail{width:168px;flex:none;padding:8px;display:flex;flex-direction:column;gap:5px;background:#151822}\n" +
    ".mi{flex:1;display:flex;align-items:center;gap:8px;padding:0 9px;border-radius:12px;font-size:14px;white-space:nowrap;background:rgba(255,255,255,.07)}\n" +
    ".mi svg{width:22px;height:22px;flex:none;fill:none;stroke:currentColor;stroke-width:1.6;stroke-linecap:round;stroke-linejoin:round}\n" +
    ".mi.on{background:rgba(255,255,255,.24)}\n" +
    ".mi:active,.ai:active,.row:active,.bt:active{background:#fff;color:#000}\n" +
    "#main{flex:1;padding:14px 16px;display:flex;flex-direction:column;min-width:0}\n" +
    "h1{font-family:'Exo 2',system-ui,sans-serif;font-size:14px;font-weight:300;letter-spacing:3px;opacity:.8;margin:0;height:22px}\n" +
    ".pg>h1,.pg>.hd{padding-bottom:9px;margin-bottom:12px;border-bottom:1px solid;border-image:linear-gradient(90deg,rgba(255,255,255,.38),rgba(255,255,255,.12) 55%,rgba(255,255,255,0)) 1}\n" +
    ".pg>h1{height:auto}\n" +
    ".pg.on{overflow-y:auto;overflow-x:hidden}\n" +
    ".pg::-webkit-scrollbar{display:none}\n" +
    ".pg>*{flex-shrink:0}\n" +
    "#p-space>#sb{flex-shrink:1}\n" +
    ".pg{display:none;flex:1;min-height:0}\n" +
    ".pg.on{display:flex;flex-direction:column}\n" +
    ".grid{display:flex;flex-direction:column;align-items:center;justify-content:center;flex:1;min-height:200px;overflow:hidden}\n" +
    ".hr{display:flex;justify-content:center;margin-top:-4px;transform:translateX(-23px)}\n" +
    ".hr.od{transform:translateX(23px)}\n" +
    ".ai{width:92px;height:74px;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:6px;font-family:'Exo 2',system-ui,sans-serif;font-size:12px;font-weight:300;letter-spacing:.6px;text-align:center}\n" +
    ".ai span{opacity:.88;max-width:90px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}\n" +
    ".ai:active{background:transparent;color:#fff;opacity:.6}\n" +
    "#p-web{position:relative}\n" +
    ".ov{position:absolute;left:0;right:0;top:0;bottom:0;background:#000;z-index:5;display:none;flex-direction:column;overflow:hidden}\n" +
    ".ov.on{display:flex}\n" +
    ".ov .lst{flex:1;min-height:0;overflow-y:auto}\n" +
    ".ov .lst::-webkit-scrollbar{display:none}\n" +
    ".sr{display:flex;align-items:center;gap:12px;padding:7px 12px;border-radius:16px;background:rgba(255,255,255,.07);margin-bottom:7px;min-height:54px;flex:none}\n" +
    ".sr .lg{width:34px;height:34px;flex:none}.sr .lg img{width:34px;height:34px}\n" +
    ".sr .t{flex:1;min-width:0}\n" +
    ".sr .t b{font-family:'Exo 2',system-ui,sans-serif;font-weight:400;font-size:16px;display:block;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}\n" +
    ".sr .t span{font-size:11px;opacity:.6;display:block;margin-top:1px;letter-spacing:.5px}\n" +
    ".sr .bt2{height:34px;min-width:34px;padding:0 12px;border-radius:17px;background:rgba(255,255,255,.14);display:flex;align-items:center;justify-content:center;font-size:18px;flex:none}\n" +
    ".sr .bt2.dn{background:#5eead4;color:#04201c}\n" +
    ".sr .bt2:active{background:#fff;color:#000}\n" +
    ".sr svg{width:18px;height:18px;fill:none;stroke:currentColor;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}\n" +
    ".sr.opt{min-height:70px}\n" +
    ".mi2{width:100%;height:56px;border-radius:28px;border:1.5px solid rgba(255,255,255,.55);background:rgba(255,255,255,.06);color:#fff;font-size:20px;padding:0 22px;outline:none;font-family:'Exo 2',system-ui,sans-serif;font-weight:300;-webkit-user-select:text;user-select:text}\n" +
    ".mi2:focus{border-color:#5eead4}\n" +
    ".lg{width:36px;height:36px;border-radius:50%;color:#fff;font-weight:300;font-size:18px;display:flex;align-items:center;justify-content:center;overflow:hidden}\n" +
    ".lg img{width:36px;height:36px;border-radius:50%;display:block}\n" +
    ".lg.fb{background:rgba(255,255,255,.16)}\n" +
    ".row{display:flex;align-items:center;gap:12px;padding:6px 12px;border-radius:14px;background:rgba(255,255,255,.07);margin-bottom:6px;min-height:52px}\n" +
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
    ".row.dis{opacity:.38;pointer-events:none}\n" +
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
    "#p-cfg .row{min-height:44px;padding:4px 12px;margin-bottom:5px}\n" +
    ".seg{display:flex;gap:6px;flex:none}\n" +
    ".sb{min-width:46px;height:34px;padding:0 10px;border-radius:10px;background:rgba(255,255,255,.12);display:flex;align-items:center;justify-content:center;font-size:14px}\n" +
    ".sb.on{background:#5eead4;color:#04201c}\n" +
    ".sb.off{opacity:.45}\n" +
    ".sb:active{background:#fff;color:#000}\n" +
    ".sl{position:relative;height:38px;flex:1.5;min-width:0;touch-action:none}\n" +
    ".sl .tr{position:absolute;left:11px;right:11px;top:15px;height:8px;border-radius:4px;background:rgba(255,255,255,.22);overflow:hidden}\n" +
    ".sl .fl{height:100%;width:0;background:#fff}\n" +
    ".sl .kn{position:absolute;top:8px;left:0;width:22px;height:22px;margin-left:0;border-radius:50%;background:#fff;box-shadow:0 1px 4px rgba(0,0,0,.5)}\n" +
    ".sl.dr .kn{background:#5eead4}\n" +
    ".sl.dr .fl{background:#5eead4}\n" +
    ".cv{min-width:46px;text-align:right;font-size:14px;opacity:.85;flex:none}\n" +
    ".vs{flex:1;display:flex;justify-content:space-around;align-items:stretch;gap:20px;padding:4px 30px 0;min-height:0}\n" +
    ".vc{display:flex;flex-direction:column;align-items:center;gap:10px;flex:1;min-height:0}\n" +
    ".vc .cv{min-width:0;text-align:center;font-family:'Exo 2',system-ui,sans-serif;font-size:17px;font-weight:300;opacity:.9;height:22px}\n" +
    ".vc .nm2{font-family:'Exo 2',system-ui,sans-serif;font-size:13px;font-weight:300;letter-spacing:1px;opacity:.85;height:18px}\n" +
    ".sl.v{flex:1;width:112px;max-width:112px;min-height:0;height:auto;border-radius:36px;background:rgba(255,255,255,.2);overflow:hidden;position:relative;touch-action:none}\n" +
    ".sl.v .fl{position:absolute;left:0;right:0;bottom:0;height:0;width:auto;background:rgba(255,255,255,.95);border-radius:0}\n" +
    ".sl.v.dr .fl{background:#fff}\n" +
    ".sl.v svg{position:absolute;left:50%;bottom:20px;width:34px;height:34px;margin-left:-17px;fill:none;stroke:#fff;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;mix-blend-mode:difference}\n" +
    ".soon{margin-top:70px;text-align:center;font-family:'Exo 2',system-ui,sans-serif;font-weight:300;font-size:22px;letter-spacing:3px;opacity:.55}\n" +
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
    "  <div class=\"pg\" id=\"p-web\"><div class=\"hd\" id=\"wh\"></div><div class=\"grid\" id=\"grid\"></div>\n" +
    "    <div class=\"ov\" id=\"wov\"><div class=\"hd\" id=\"woh\"></div><div class=\"lst\" id=\"wob\"></div></div></div>\n" +
    "  <div class=\"pg\" id=\"p-apps\"><h1>APLICATIVOS</h1><div class=\"soon\">Em breve</div></div>\n" +
    "  <div class=\"pg\" id=\"p-aju\"><h1>AJUSTES</h1><div class=\"vs\"><div class=\"vc\"><div class=\"cv\" data-v=\"vol\"></div><div class=\"sl v\" data-k=\"vol\" data-min=\"0\" data-max=\"100\"><div class=\"fl\"></div><svg viewBox=\"0 0 24 24\"><path d=\"M4 9h4l5-4v14l-5-4H4z\"/><path d=\"M16.5 9a4 4 0 0 1 0 6\"/><path d=\"M19 6.5a8 8 0 0 1 0 11\"/></svg></div><div class=\"nm2\">VOLUME</div></div><div class=\"vc\"><div class=\"cv\" data-v=\"bri\"></div><div class=\"sl v\" data-k=\"bri\" data-min=\"2\" data-max=\"100\"><div class=\"fl\"></div><svg viewBox=\"0 0 24 24\"><circle cx=\"12\" cy=\"12\" r=\"4\"/><path d=\"M12 2.5v3M12 18.5v3M2.5 12h3M18.5 12h3M5.3 5.3l2.1 2.1M16.6 16.6l2.1 2.1M18.7 5.3l-2.1 2.1M7.4 16.6l-2.1 2.1\"/></svg></div><div class=\"nm2\">BRILHO</div></div><div class=\"vc\"><div class=\"cv\" data-v=\"room\"></div><div class=\"sl v\" data-k=\"room\" data-min=\"0\" data-max=\"100\"><div class=\"fl\"></div><svg viewBox=\"0 0 24 24\"><path d=\"M20 14.5A8.5 8.5 0 0 1 9.5 4 8.5 8.5 0 1 0 20 14.5z\"/></svg></div><div class=\"nm2\">QUARTO</div></div></div></div>\n" +
    "  <div class=\"pg\" id=\"p-lente\"><div class=\"hd\"><div class=\"back\" data-go=\"cfg\">&lsaquo; Voltar</div><h1>CORRE&Ccedil;&Atilde;O DE LENTE</h1></div>\n" +
    "    <div class=\"row\"><div class=\"t\"><b>Modo de lente</b><span id=\"lms\">Cardboard: valores prontos para o VR Box.</span></div><div class=\"seg\"><div class=\"sb\" data-lm=\"0\">Cardboard</div><div class=\"sb\" data-lm=\"1\">Personalizado</div></div></div>\n" +
    "<div class=\"row lc\"><div class=\"t\"><b>Campo de vis&atilde;o</b><span>Em graus. Maior = imagem mais ampla, menos zoom.</span></div><div class=\"sl\" data-k=\"lfov\" data-min=\"60\" data-max=\"120\"><div class=\"tr\"><div class=\"fl\"></div></div><div class=\"kn\"></div></div><div class=\"cv\" data-v=\"lfov\"></div></div>\n" +
    "<div class=\"row lc\"><div class=\"t\"><b>Dist&acirc;ncia entre os olhos (IPD)</b><span>Em mm. Padr&atilde;o 64.</span></div><div class=\"sl\" data-k=\"ipd\" data-min=\"50\" data-max=\"75\"><div class=\"tr\"><div class=\"fl\"></div></div><div class=\"kn\"></div></div><div class=\"cv\" data-v=\"ipd\"></div></div>\n" +
    "<div class=\"row lc\"><div class=\"t\"><b>Separa&ccedil;&atilde;o das imagens</b><span>Em mm. Positivo afasta, negativo aproxima.</span></div><div class=\"sl\" data-k=\"sep\" data-min=\"-20\" data-max=\"20\"><div class=\"tr\"><div class=\"fl\"></div></div><div class=\"kn\"></div></div><div class=\"cv\" data-v=\"sep\"></div></div>\n" +
    "<div class=\"row lc\"><div class=\"t\"><b>Altura das imagens</b><span>Em mm. Positivo sobe a imagem.</span></div><div class=\"sl\" data-k=\"vsep\" data-min=\"-15\" data-max=\"15\"><div class=\"tr\"><div class=\"fl\"></div></div><div class=\"kn\"></div></div><div class=\"cv\" data-v=\"vsep\"></div></div>\n" +
    "<div class=\"row lc\"><div class=\"t\"><b>Tamanho da imagem</b><span>Em %. Reduz ou amplia cada olho.</span></div><div class=\"sl\" data-k=\"lsize\" data-min=\"60\" data-max=\"120\"><div class=\"tr\"><div class=\"fl\"></div></div><div class=\"kn\"></div></div><div class=\"cv\" data-v=\"lsize\"></div></div>\n" +
    "<div class=\"row lc\"><div class=\"t\"><b>Corre&ccedil;&atilde;o de distor&ccedil;&atilde;o</b><span>100% = Cardboard. Compensa o efeito da lente.</span></div><div class=\"sl\" data-k=\"ldist\" data-min=\"0\" data-max=\"200\"><div class=\"tr\"><div class=\"fl\"></div></div><div class=\"kn\"></div></div><div class=\"cv\" data-v=\"ldist\"></div></div>\n" +
    "<div class=\"row\"><div class=\"t\"><b>Nitidez do mundo</b><span>Agu\u00e7a imagens e v\u00eddeos 360 (sempre ajust\u00e1vel).</span></div><div class=\"sl\" data-k=\"sharp\" data-min=\"0\" data-max=\"100\"><div class=\"tr\"><div class=\"fl\"></div></div><div class=\"kn\"></div></div><div class=\"cv\" data-v=\"sharp\"></div></div>\n" +
    "    <div class=\"row lc\" data-act=\"set:lreset:0\"><div class=\"t\"><b>Restaurar padr&otilde;es</b><span>Valores do modo personalizado (vale s&oacute; no modo Est&eacute;reo).</span></div><div class=\"chev\">&#8634;</div></div>\n" +
    "  </div>\n" +
    "  <div class=\"pg\" id=\"p-cfg\"><h1>CONFIGURA&Ccedil;&Otilde;ES</h1>\n" +
    "    <div class=\"row\"><div class=\"t\"><b>Zoom do menu</b><span>Tamanho do menu quando ele abre (2x = padr&atilde;o).</span></div><div class=\"seg\" id=\"mseg\"><div class=\"sb\" data-m=\"1\">1x</div><div class=\"sb\" data-m=\"2\">2x</div><div class=\"sb\" data-m=\"3\">3x</div><div class=\"sb\" data-m=\"4\">4x</div><div class=\"sb\" data-m=\"5\">5x</div></div></div>\n" +
    "    <div class=\"row\"><div class=\"t\"><b>Clique</b><span>Como a m&atilde;o clica.</span></div><div class=\"seg\"><div class=\"sb on\" data-c=\"0\">Pin&ccedil;a</div><div class=\"sb off\" data-c=\"1\">Empurrar</div></div></div>\n" +
    "    <div class=\"row\"><div class=\"t\"><b>Fechar a pin&ccedil;a</b><span>Dist&acirc;ncia dos dedos para clicar.</span></div><div class=\"sl\" data-k=\"pOn\" data-min=\"6\" data-max=\"30\"><div class=\"tr\"><div class=\"fl\"></div></div><div class=\"kn\"></div></div><div class=\"cv\" data-v=\"pOn\"></div></div>\n" +
    "    <div class=\"row\"><div class=\"t\"><b>Soltar a pin&ccedil;a</b><span>Dist&acirc;ncia dos dedos para soltar.</span></div><div class=\"sl\" data-k=\"pOff\" data-min=\"10\" data-max=\"50\"><div class=\"tr\"><div class=\"fl\"></div></div><div class=\"kn\"></div></div><div class=\"cv\" data-v=\"pOff\"></div></div>\n" +
    "    <div class=\"row\" data-go=\"lente\"><div class=\"t\"><b>Corre&ccedil;&atilde;o de lente</b><span>Dist&acirc;ncia entre olhos, separa&ccedil;&atilde;o, tamanho e distor&ccedil;&atilde;o.</span></div><div class=\"chev\">&rsaquo;</div></div>\n" +
    "    <div class=\"row\" data-act=\"hybrid\"><div class=\"t\"><b>Modo h&iacute;brido</b><span>Usa o girosc&oacute;pio quando o ARCore perde o rastreio.</span></div><div class=\"sw\" id=\"swh\"><i></i></div></div>\n" +
    "  </div>\n" +
    "</div></div>\n" +
    "<div id=\"toast\"></div>\n" +
    "<script>\n" +
    "var A=window.ArMenu,cur='home';\n" +
    "function act(a){try{A.act(a)}catch(e){}}\n" +
    "var CAT=[[\"G1 Globo\", \"https://g1.globo.com/\", \"Not\u00edcias\"], [\"Folha\", \"https://www.folha.uol.com.br/\", \"Not\u00edcias\"], [\"BBC News\", \"https://www.bbc.com/news\", \"Not\u00edcias\"], [\"CNN Brasil\", \"https://www.cnnbrasil.com.br/\", \"Not\u00edcias\"], [\"Reuters\", \"https://www.reuters.com/\", \"Not\u00edcias\"], [\"ge.globo\", \"https://ge.globo.com/\", \"Esportes\"], [\"ESPN\", \"https://www.espn.com.br/\", \"Esportes\"], [\"Lance!\", \"https://www.lance.com.br/\", \"Esportes\"], [\"Sofascore\", \"https://www.sofascore.com/\", \"Esportes\"], [\"F\u00f3rmula 1\", \"https://www.formula1.com/\", \"Esportes\"], [\"IGN Brasil\", \"https://br.ign.com/\", \"Games\"], [\"GameSpot\", \"https://www.gamespot.com/\", \"Games\"], [\"Kotaku\", \"https://kotaku.com/\", \"Games\"], [\"Steam\", \"https://store.steampowered.com/\", \"Games\"], [\"Twitch\", \"https://www.twitch.tv/\", \"Games\"], [\"Instagram\", \"https://www.instagram.com/\", \"Redes sociais\"], [\"X\", \"https://x.com/\", \"Redes sociais\"], [\"Facebook\", \"https://m.facebook.com/\", \"Redes sociais\"], [\"TikTok\", \"https://www.tiktok.com/\", \"Redes sociais\"], [\"Reddit\", \"https://www.reddit.com/\", \"Redes sociais\"], [\"Discord\", \"https://discord.com/app\", \"Redes sociais\"], [\"WhatsApp\", \"https://web.whatsapp.com/\", \"Redes sociais\"], [\"LinkedIn\", \"https://www.linkedin.com/\", \"Redes sociais\"], [\"Pinterest\", \"https://www.pinterest.com/\", \"Redes sociais\"], [\"YouTube\", \"https://m.youtube.com/\", \"Streaming de v\u00eddeo\"], [\"Netflix\", \"https://www.netflix.com/\", \"Streaming de v\u00eddeo\"], [\"Prime Video\", \"https://www.primevideo.com/\", \"Streaming de v\u00eddeo\"], [\"Disney+\", \"https://www.disneyplus.com/\", \"Streaming de v\u00eddeo\"], [\"Max\", \"https://www.max.com/\", \"Streaming de v\u00eddeo\"], [\"Globoplay\", \"https://globoplay.globo.com/\", \"Streaming de v\u00eddeo\"], [\"Crunchyroll\", \"https://www.crunchyroll.com/\", \"Streaming de v\u00eddeo\"], [\"Spotify\", \"https://open.spotify.com/\", \"M\u00fasica\"], [\"YouTube Music\", \"https://music.youtube.com/\", \"M\u00fasica\"], [\"Deezer\", \"https://www.deezer.com/\", \"M\u00fasica\"], [\"SoundCloud\", \"https://soundcloud.com/\", \"M\u00fasica\"], [\"Tecnoblog\", \"https://tecnoblog.net/\", \"Tecnologia\"], [\"The Verge\", \"https://www.theverge.com/\", \"Tecnologia\"], [\"Canaltech\", \"https://canaltech.com.br/\", \"Tecnologia\"], [\"GitHub\", \"https://github.com/\", \"Tecnologia\"], [\"Wikip\u00e9dia\", \"https://pt.m.wikipedia.org/\", \"Educa\u00e7\u00e3o\"], [\"Khan Academy\", \"https://pt.khanacademy.org/\", \"Educa\u00e7\u00e3o\"], [\"Duolingo\", \"https://www.duolingo.com/\", \"Educa\u00e7\u00e3o\"], [\"Google\", \"https://www.google.com/\", \"Ferramentas\"], [\"Mapas\", \"https://www.openstreetmap.org/\", \"Ferramentas\"], [\"Tradutor\", \"https://translate.google.com/\", \"Ferramentas\"], [\"Gmail\", \"https://mail.google.com/\", \"Ferramentas\"], [\"Mercado Livre\", \"https://www.mercadolivre.com.br/\", \"Compras\"], [\"Amazon\", \"https://www.amazon.com.br/\", \"Compras\"]];\n" +
    "var SITES=[],SRAW='',WP=0,WPER=12,EV='';\n" +
    "var ICE={pen:'<svg viewBox=\"0 0 24 24\"><path d=\"M4 20h4L19 9l-4-4L4 16z\"/></svg>',chk:'<svg viewBox=\"0 0 24 24\"><path d=\"M5 12.5l4.5 4.5L19 7.5\"/></svg>'};\n" +
    "function hostOf(u){try{return new URL(u).hostname}catch(e){return String(u).replace(/^https?:\\/\\//,'').split('/')[0]}}\n" +
    "function nameOf(u){var h=hostOf(u).replace(/^(www|m|web|pt|mobile)\\./,'').split('.')[0];return h?h.charAt(0).toUpperCase()+h.slice(1):'Site';}\n" +
    "function normUrl(t){t=String(t||'').trim();if(!t)return'';if(!/^[a-z]+:\\/\\//i.test(t))t='https://'+t;return t;}\n" +
    "function favEl(u,n,cls){var lg=document.createElement('div');lg.className='lg';var im=new Image();\n" +
    "  im.onerror=function(){lg.textContent=(n||'?').charAt(0);lg.className='lg fb';im.remove();};\n" +
    "  im.src='https://www.google.com/s2/favicons?domain='+encodeURIComponent(hostOf(u))+'&sz=128';lg.appendChild(im);return lg;}\n" +
    "function loadSites(force){var r='';try{r=A.sites()||''}catch(e){}\n" +
    "  if(!force&&r===SRAW&&SITES.length)return false;SRAW=r;try{SITES=JSON.parse(r)}catch(e){SITES=[]}return true;}\n" +
    "function saveSites(){SRAW=JSON.stringify(SITES);act('sites:'+SRAW);}\n" +
    "function hasSite(u){var h=hostOf(u).replace(/^www\\./,'');return SITES.some(function(x){return hostOf(x.u).replace(/^www\\./,'')===h});}\n" +
    "function webRender(){\n" +
    "  var np=Math.max(1,Math.ceil(SITES.length/WPER));if(WP>=np)WP=np-1;\n" +
    "  var h=document.getElementById('wh');\n" +
    "  h.innerHTML='<h1>WEB</h1>'+hb('edit',ICE.pen+'<span>Editar</span>')+'<div style=\"flex:1\"></div>'+(np>1?hb('prev','&#8249;')+'<span class=\"pgn\">'+(WP+1)+'/'+np+'</span>'+hb('next','&#8250;'):'');\n" +
    "  var g=document.getElementById('grid');g.innerHTML='';\n" +
    "  SITES.slice(WP*WPER,(WP+1)*WPER).forEach(function(st,i){var d=document.createElement('div');d.className='ai';\n" +
    "    d.appendChild(favEl(st.u,st.n));var sp=document.createElement('span');sp.textContent=st.n;d.appendChild(sp);\n" +
    "    d.onclick=function(){act('open:'+st.u);};\n" +
    "    var ri=Math.floor(i/4),rows=g.children;while(rows.length<=ri){var r=document.createElement('div');r.className='hr'+(rows.length%2?' od':'');g.appendChild(r);}rows[ri].appendChild(d);});\n" +
    "}\n" +
    "function ovShow(v){EV=v;var o=document.getElementById('wov');o.className='ov'+(v?' on':'');if(v)ovRender();else{act('kb:off');webRender();}}\n" +
    "function ovRender(){var h=document.getElementById('woh'),b=document.getElementById('wob');\n" +
    "  var back=hb(EV==='menu'?'close':'ebk',IC.back+'<span>Voltar</span>');\n" +
    "  if(EV==='menu'){h.innerHTML=back+'<h1 style=\"margin-left:10px\">EDITAR</h1>';\n" +
    "    b.innerHTML='<div class=\"sr opt\" data-e=\"add\"><div class=\"t\"><b>Adicionar sites da lista</b><span>Escolha entre sites prontos por categoria.</span></div></div>'\n" +
    "      +'<div class=\"sr opt\" data-e=\"man\"><div class=\"t\"><b>Adicionar manualmente</b><span>Digite o endere&ccedil;o; nome e &iacute;cone s&atilde;o autom&aacute;ticos.</span></div></div>'\n" +
    "      +'<div class=\"sr opt\" data-e=\"del\"><div class=\"t\"><b>Deletar site</b><span>Remove sites da aba Web.</span></div></div>';\n" +
    "    b.querySelectorAll('[data-e]').forEach(function(e){e.onclick=function(){ovShow(e.getAttribute('data-e'));};});return;}\n" +
    "  if(EV==='add'){h.innerHTML=back+'<h1 style=\"margin-left:10px\">LISTA DE SITES</h1>';b.innerHTML='';\n" +
    "    CAT.forEach(function(c){var r=document.createElement('div');r.className='sr';r.appendChild(favEl(c[1],c[0]));\n" +
    "      var t=document.createElement('div');t.className='t';t.innerHTML='<b>'+esc(c[0])+'</b><span>'+esc(c[2])+'</span>';r.appendChild(t);\n" +
    "      var bt=document.createElement('div');var has=hasSite(c[1]);bt.className='bt2'+(has?' dn':'');bt.innerHTML=has?ICE.chk:IC.plus;\n" +
    "      bt.onclick=function(){if(hasSite(c[1]))return;SITES.push({n:c[0],u:c[1]});saveSites();bt.className='bt2 dn';bt.innerHTML=ICE.chk;};\n" +
    "      r.appendChild(bt);b.appendChild(r);});return;}\n" +
    "  if(EV==='man'){h.innerHTML=back+'<h1 style=\"margin-left:10px\">ADICIONAR SITE</h1>';\n" +
    "    b.innerHTML='<input id=\"murl\" class=\"mi2\" type=\"text\" inputmode=\"none\" autocomplete=\"off\" autocapitalize=\"off\" spellcheck=\"false\" placeholder=\"endere&ccedil;o do site, ex.: g1.globo.com\">'\n" +
    "      +'<div class=\"sr\" id=\"mprev\" style=\"margin-top:12px;visibility:hidden\"></div>'\n" +
    "      +'<div class=\"sr opt\" id=\"madd\" style=\"justify-content:center\"><div class=\"t\" style=\"flex:none\"><b>Adicionar</b></div></div>';\n" +
    "    var inp=document.getElementById('murl');\n" +
    "    function pv(){var u=normUrl(inp.value),p=document.getElementById('mprev');if(!u){p.style.visibility='hidden';return;}\n" +
    "      p.style.visibility='visible';p.innerHTML='';p.appendChild(favEl(u,nameOf(u)));var t=document.createElement('div');t.className='t';t.innerHTML='<b>'+esc(nameOf(u))+'</b><span>'+esc(hostOf(u))+'</span>';p.appendChild(t);}\n" +
    "    function add(){var u=normUrl(inp.value);if(!u)return;if(!hasSite(u)){SITES.push({n:nameOf(u),u:u});saveSites();}ovShow('menu');}\n" +
    "    function fk(){inp.focus();act('kb:on');}\n" +
    "    inp.onclick=fk;inp.onfocus=function(){act('kb:on');};inp.oninput=pv;\n" +
    "    inp.onkeydown=function(e){if(e.key==='Enter'){e.preventDefault();add();}};\n" +
    "    document.getElementById('madd').onclick=add;setTimeout(fk,150);return;}\n" +
    "  if(EV==='del'){h.innerHTML=back+'<h1 style=\"margin-left:10px\">DELETAR SITE</h1>';b.innerHTML='';\n" +
    "    if(!SITES.length)b.innerHTML='<div class=\"soon\" style=\"margin-top:40px;font-size:16px\">Nenhum site</div>';\n" +
    "    SITES.forEach(function(st,i){var r=document.createElement('div');r.className='sr';r.appendChild(favEl(st.u,st.n));\n" +
    "      var t=document.createElement('div');t.className='t';t.innerHTML='<b>'+esc(st.n)+'</b><span>'+esc(hostOf(st.u))+'</span>';r.appendChild(t);\n" +
    "      var bt=document.createElement('div');bt.className='bt2';bt.innerHTML=IC.trash;bt.onclick=function(){SITES.splice(i,1);saveSites();ovRender();};r.appendChild(bt);b.appendChild(r);});return;}\n" +
    "}\n" +
    "document.getElementById('app').addEventListener('click',function(ev){var c=ev.target.closest&&ev.target.closest('#wh [data-c],#woh [data-c]');if(!c)return;\n" +
    "  var k=c.getAttribute('data-c'),np=Math.max(1,Math.ceil(SITES.length/WPER));\n" +
    "  if(k==='edit')ovShow('menu');else if(k==='close')ovShow('');else if(k==='ebk')ovShow('menu');\n" +
    "  else if(k==='prev'){WP=(WP+np-1)%np;webRender();}else if(k==='next'){WP=(WP+1)%np;webRender();}});\n" +
    "setInterval(function(){if(cur==='web'&&!EV&&loadSites(false))webRender();},1500);\n" +
    "function show(n){cur=n;if(n==='web'){loadSites(true);if(EV)ovShow('');webRender();}if(n==='space'){S.sel=null;S.sig='';setTimeout(sTick,0);sRender();}\n" +
    "  ['help','space','web','apps','aju','lente','cfg'].forEach(function(k){\n" +
    "    document.getElementById('p-'+k).className='pg'+(k===n?' on':'');});\n" +
    "  if(n==='cfg'||n==='aju'||n==='lente')refresh();}\n" +
    "function refresh(){var s={};try{s=JSON.parse(A.state())}catch(e){}\n" +
    "  document.getElementById('swg').className='sw'+(s.gpu?' on':'');\n" +
    "  document.getElementById('swh').className='sw'+(s.hybrid?' on':'');\n" +
    "  document.getElementById('sws').className='sw'+(s.stereo?' on':'');\n" +
    "  ['vol','bri','room','pOn','pOff','ipd','sep','vsep','lsize','ldist','lfov','sharp'].forEach(function(k){if(typeof s[k]==='number')setSl(k,s[k]);});\n" +
    "  if(typeof s.zoom==='number')setZoomUi(s.zoom);\n" +
    "  if(typeof s.mz==='number')setMz(s.mz);\n" +
    "  if(typeof s.lmode==='number')setLm(s.lmode);}\n" +
    "/* ---------- sliders e zoom ---------- */\n" +
    "var UN={ipd:' mm',sep:' mm',vsep:' mm',lfov:'\u00b0'},SLV={},SLD=null,SLT=0;\n" +
    "function slEl(k){return document.querySelector('.sl[data-k=\"'+k+'\"]');}\n" +
    "function setSl(k,v){var e=slEl(k);if(!e||SLD===k)return;paintSl(e,k,v);}\n" +
    "function paintSl(e,k,v){var mn=+e.getAttribute('data-min'),mx=+e.getAttribute('data-max');v=Math.max(mn,Math.min(mx,v));SLV[k]=v;\n" +
    "  var f=(v-mn)/(mx-mn);\n" +
    "  if(e.classList.contains('v')){e.querySelector('.fl').style.height=(f*100)+'%';}\n" +
    "  else{var w=e.clientWidth-22;e.querySelector('.fl').style.width=(f*100)+'%';e.querySelector('.kn').style.left=(f*w)+'px';}\n" +
    "  var c=document.querySelector('[data-v=\"'+k+'\"]');if(c)c.textContent=Math.round(v)+(UN[k]||'%');}\n" +
    "function slPos(e,ev){var t=ev.touches&&ev.touches.length?ev.touches[0]:(ev.changedTouches&&ev.changedTouches.length?ev.changedTouches[0]:ev);\n" +
    "  var r=e.getBoundingClientRect(),mn=+e.getAttribute('data-min'),mx=+e.getAttribute('data-max'),f;\n" +
    "  if(e.classList.contains('v'))f=1-(t.clientY-r.top)/Math.max(1,r.height);\n" +
    "  else f=(t.clientX-r.left-11)/Math.max(1,r.width-22);\n" +
    "  f=Math.max(0,Math.min(1,f));return Math.round(mn+f*(mx-mn));}\n" +
    "function slSend(k,v,force){var n=Date.now();if(!force&&n-SLT<60)return;SLT=n;act('set:'+k+':'+v);}\n" +
    "document.querySelectorAll('.sl').forEach(function(e){var k=e.getAttribute('data-k');\n" +
    "  function mv(ev){if(SLD!==k)return;ev.preventDefault();var v=slPos(e,ev);paintSl(e,k,v);slSend(k,v,false);}\n" +
    "  function st(ev){ev.preventDefault();SLD=k;e.classList.add('dr');var v=slPos(e,ev);paintSl(e,k,v);slSend(k,v,true);}\n" +
    "  function en(ev){if(SLD!==k)return;SLD=null;e.classList.remove('dr');slSend(k,SLV[k],true);setTimeout(refresh,250);}\n" +
    "  e.addEventListener('touchstart',st,{passive:false});e.addEventListener('touchmove',mv,{passive:false});\n" +
    "  e.addEventListener('touchend',en);e.addEventListener('touchcancel',en);\n" +
    "  e.addEventListener('mousedown',function(ev){st(ev);function m(x){mv(x);}function u(x){document.removeEventListener('mousemove',m);document.removeEventListener('mouseup',u);en(x);}document.addEventListener('mousemove',m);document.addEventListener('mouseup',u);});});\n" +
    "function setLm(m){document.querySelectorAll('[data-lm]').forEach(function(b){b.className='sb'+(+b.getAttribute('data-lm')===m?' on':'');});\n" +
    "  document.querySelectorAll('.lc').forEach(function(r){r.classList.toggle('dis',m===0);});\n" +
    "  var t=document.getElementById('lms');if(t)t.textContent=m===0?'Cardboard: valores prontos para o VR Box.':'Personalizado: ajuste cada item.';}\n" +
    "document.querySelectorAll('[data-lm]').forEach(function(b){b.onclick=function(){var m=+b.getAttribute('data-lm');setLm(m);act('set:lmode:'+m);setTimeout(refresh,300);};});\n" +
    "function setMz(z){document.querySelectorAll('[data-m]').forEach(function(b){b.className='sb'+(+b.getAttribute('data-m')===z?' on':'');});}\n" +
    "document.querySelectorAll('[data-m]').forEach(function(b){b.onclick=function(){var z=+b.getAttribute('data-m');setMz(z);act('set:mzoom:'+z);};});\n" +
    "function setZoomUi(z){document.querySelectorAll('[data-z]').forEach(function(b){b.className='sb'+(+b.getAttribute('data-z')===z?' on':'');});}\n" +
    "document.querySelectorAll('[data-z]').forEach(function(b){b.onclick=function(){var z=+b.getAttribute('data-z');setZoomUi(z);act('set:zoom:'+z);};});\n" +
    "document.querySelectorAll('[data-c]').forEach(function(b){b.onclick=function(){if(b.getAttribute('data-c')==='1')toast('Empurrar: em breve');};});\n" +
    "document.querySelectorAll('[data-go]').forEach(function(e){e.onclick=function(){show(e.getAttribute('data-go'));};});\n" +
    "document.querySelectorAll('[data-act]').forEach(function(e){e.onclick=function(){\n" +
    "  var a=e.getAttribute('data-act');act(a);\n" +
    "  if(a==='gpu'||a==='hybrid'||a==='stereo'||a.indexOf('set:lreset')===0){setTimeout(refresh,350);}};});\n" +
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
    "  var n2=S.lib.length;if(!n2)S.del=false;var np2=Math.max(1,Math.ceil(n2/PER));if(S.page>=np2)S.page=np2-1;\n" +
    "  h.innerHTML='<h1>MUNDOS'+(st.active&&st.video?' <small style=\"opacity:.55;letter-spacing:0;font-size:11px;margin-left:8px\">pin&ccedil;a 1 s no v&iacute;deo = controles</small>':'')+'</h1>'+pager(n2,S.page,PER)\n" +
    "    +(st.active?hb('exit',IC.out+'<span>Sair</span>'):(n2?hb('trash',IC.trash,S.del):''));\n" +
    "  var cells=(S.del&&n2)?'':'<div class=\"tl\" data-c=\"add\">'+IC.plus+'<span>Importar</span></div>';\n" +
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
    "var w0='web';try{w0=A.page()||'web'}catch(e){}show(w0);\n" +
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
    "   +bt('rel:10000','<span>10</span>'+IC.fwd)+bt('speed','<span>'+(S.speed||1)+'&times;</span>')+bt('mute',S.muted?IC.mute:IC.vol)+bt('loop',IC.loop,S.loop)+bt('fmt','<span>'+['AUTO','2D','TB','LR'][S.lay||0]+'</span>',(S.lay||0)>0);\n" +
    "}\n" +
    "function tick(){\n" +
    "  var s;try{s=JSON.parse(A.spState())}catch(e){return}\n" +
    "  S=s;dur=s.dur||0;\n" +
    "  var g=[s.playing,s.muted,s.loop,s.speed,s.lay].join('|');\n" +
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
    String[] sf = {".jpg", ".mp4", "_t.jpg", ".txt", ".src", ".fmt"};
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
            String id = o.optString("id", ""), tp = o.optString("tipo", ""), url = o.optString("url", ""), th = o.optString("miniatura", ""), fm = o.optString("formato", "");
            if (!id.matches("[A-Za-z0-9_-]{1,60}") || !(tp.equals("imagem") || tp.equals("video")) || !storeUrlOk(url)) continue;
            String nome = o.optString("nome", id);
            JSONObject r = new JSONObject();
            r.put("id", id);
            r.put("nome", nome);
            r.put("tipo", tp);
            r.put("tamanho", o.optLong("tamanho", 0));
            r.put("miniatura", storeUrlOk(th) ? th : "");
            out.put(r);
            items.put(id, new String[]{url, tp, nome, fm});
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
    final String url = it[0], tipo = it[1], nome = it[2], formato = it.length > 3 ? it[3] : "";
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
            if (formato.length() > 0) writeText(new File(dir, id + ".fmt"), formato);
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
    try { s.compress(Bitmap.CompressFormat.JPEG, 95, fo); } finally { fo.close(); }
    Bitmap t = Bitmap.createScaledBitmap(s, 320, 160, true);
    fo = new FileOutputStream(new File(dir, id + "_t.jpg"));
    try { t.compress(Bitmap.CompressFormat.JPEG, 80, fo); } finally { fo.close(); }
    writeText(new File(dir, id + ".txt"), name);
    lastId = id;
    t.recycle();
    s.recycle();
  }

  /**
   * Layout do video 360: 0 mono (2:1), 1 top-bottom (olho esquerdo em cima), 2 lado a lado.
   * O catalogo pode dizer "formato" (mono, top-bottom, side-by-side); sem isso, decide pela proporcao do video.
   */
  int layoutOf(File mp4) {
    try {
      String n = mp4.getName();
      File ff = new File(dir, n.substring(0, n.lastIndexOf('.')) + ".fmt");
      if (ff.exists()) {
        String f = readText(ff, "").trim().toLowerCase();
        if (f.startsWith("top") || f.equals("tb") || f.equals("ou") || f.startsWith("over")) return 1;
        if (f.startsWith("side") || f.equals("sbs") || f.equals("lr") || f.startsWith("lado")) return 2;
        if (f.startsWith("mono")) return 0;
      }
      MediaMetadataRetriever mr = new MediaMetadataRetriever();
      try {
        mr.setDataSource(mp4.getAbsolutePath());
        String ws = mr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH), hs = mr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT);
        float r = 2f;
        if (ws != null && hs != null) r = Float.parseFloat(ws) / Math.max(1f, Float.parseFloat(hs));
        if (r >= 3.4f) return 2;                 // 4:1 = lado a lado
        if (r >= 0.8f && r <= 1.25f) return 1;   // 1:1 = top-bottom
        // outras proporcoes: compara as metades de um quadro; num par estereo as duas metades sao quase iguais
        Bitmap fr = mr.getFrameAtTime(2000000L, MediaMetadataRetriever.OPTION_CLOSEST_SYNC);
        if (fr == null) fr = mr.getFrameAtTime();
        if (fr != null) {
          Bitmap sm = Bitmap.createScaledBitmap(fr, 64, 64, true);
          int[] px = new int[64 * 64];
          sm.getPixels(px, 0, 64, 0, 0, 64, 64);
          double tb = 0, lr = 0;
          for (int y = 0; y < 32; y++) for (int x = 0; x < 64; x++) tb += diff(px[y * 64 + x], px[(y + 32) * 64 + x]);
          for (int y = 0; y < 64; y++) for (int x = 0; x < 32; x++) lr += diff(px[y * 64 + x], px[y * 64 + x + 32]);
          tb /= 2048.0; lr /= 2048.0;
          if (tb < 22 && tb < lr * 0.6) return 1;
          if (lr < 22 && lr < tb * 0.6) return 2;
        }
      } finally { mr.release(); }
    } catch (Throwable t) { }
    return 0;
  }

  private static double diff(int a, int b) {
    int dr = ((a >> 16) & 255) - ((b >> 16) & 255), dg = ((a >> 8) & 255) - ((b >> 8) & 255), db = (a & 255) - (b & 255);
    return (Math.abs(dr) + Math.abs(dg) + Math.abs(db)) / 3.0;
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
    if (c.equals("fmt")) { act.cycleLayout(); return; }
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
      .append(",\"lay\":").append(act.renderer.layModeNow())
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
cat > app/src/main/java/com/vr/launcher/ArMorePage.java <<'EOF'
package com.vr.launcher;

/** Pagina HTML gerada (more.html). */
final class ArMorePage {
  static final String HTML =
    "<!doctype html>\n" +
    "<html><head><meta charset=\"utf-8\">\n" +
    "<meta name=\"viewport\" content=\"width=device-width,initial-scale=1,user-scalable=no\">\n" +
    "<style>\n" +
    "@font-face{font-family:'Exo 2';font-weight:300;src:url(/font/exo2-300.woff2) format('woff2')}\n" +
    "@font-face{font-family:'Exo 2';font-weight:400;src:url(/font/exo2-400.woff2) format('woff2')}\n" +
    "*{box-sizing:border-box;-webkit-tap-highlight-color:transparent;-webkit-user-select:none;user-select:none}\n" +
    "html,body{margin:0;height:100%;background:#000;color:#fff;font-family:system-ui,-apple-system,sans-serif;overflow:hidden}\n" +
    "#main{height:100%;padding:16px 20px;display:flex;flex-direction:column;overflow-y:auto}\n" +
    "#main::-webkit-scrollbar{display:none}\n" +
    "h1{font-family:'Exo 2',system-ui,sans-serif;font-size:14px;font-weight:300;letter-spacing:3px;opacity:.8;margin:0 0 12px;padding-bottom:9px;border-bottom:1px solid;border-image:linear-gradient(90deg,rgba(255,255,255,.38),rgba(255,255,255,.12) 55%,rgba(255,255,255,0)) 1;flex:none}\n" +
    ".row{display:flex;align-items:center;gap:12px;padding:8px 14px;border-radius:16px;background:rgba(255,255,255,.07);margin-bottom:8px;min-height:62px;flex:none}\n" +
    ".row:active{background:#fff;color:#000}\n" +
    ".t{flex:1;min-width:0}\n" +
    ".t b{font-family:'Exo 2',system-ui,sans-serif;font-weight:400;font-size:18px;display:block}\n" +
    ".t span{font-size:12px;opacity:.75;display:block;margin-top:2px}\n" +
    ".sw{width:58px;height:32px;border-radius:16px;background:rgba(255,255,255,.28);position:relative;flex:none}\n" +
    ".sw i{position:absolute;left:3px;top:3px;width:26px;height:26px;border-radius:50%;background:#fff;transition:left .15s}\n" +
    ".sw.on{background:#3ddc84}\n" +
    ".sw.on i{left:29px}\n" +
    ".seg{display:flex;gap:6px;flex:none}\n" +
    ".sb{min-width:54px;height:40px;padding:0 12px;border-radius:12px;background:rgba(255,255,255,.12);display:flex;align-items:center;justify-content:center;font-family:'Exo 2',system-ui,sans-serif;font-size:16px}\n" +
    ".sb.on{background:#5eead4;color:#04201c}\n" +
    ".sb:active{background:#fff;color:#000}\n" +
    "</style></head><body>\n" +
    "<div id=\"main\">\n" +
    "<h1>OP&Ccedil;&Otilde;ES DA JANELA</h1>\n" +
    "<div class=\"row\" data-a=\"curve\"><div class=\"t\"><b>Tela curva</b><span>Curva s&oacute; as laterais desta janela.</span></div><div class=\"sw\" id=\"s-curve\"><i></i></div></div>\n" +
    "<div class=\"row\" data-a=\"fav\"><div class=\"t\"><b>Favoritar</b><span>Adiciona este site &agrave; aba Web (toque de novo para remover).</span></div><svg id=\"s-fav\" viewBox=\"0 0 24 24\" width=\"34\" height=\"34\" style=\"flex:none;fill:none;stroke:#fff;stroke-width:1.8;stroke-linejoin:round\"><path d=\"M12 20.5s-7.5-4.6-9.3-9.2C1.6 8.3 3.4 5 6.6 5c2 0 3.5 1.1 5.4 3.2C13.9 6.1 15.4 5 17.4 5c3.2 0 5 3.3 3.9 6.3-1.8 4.6-9.3 9.2-9.3 9.2z\"/></svg></div>\n" +
    "<div class=\"row\" data-a=\"desktop\"><div class=\"t\"><b>Modo computador</b><span>Sites em vers&atilde;o de PC (todas as janelas).</span></div><div class=\"sw\" id=\"s-desktop\"><i></i></div></div>\n" +
    "<div class=\"row\"><div class=\"t\"><b>Zoom do navegador</b><span>Menor = letras menores (todas as janelas).</span></div><div class=\"seg\" id=\"g-zoom\"><div class=\"sb\" data-z=\"100\">100%</div><div class=\"sb\" data-z=\"90\">90%</div><div class=\"sb\" data-z=\"80\">80%</div><div class=\"sb\" data-z=\"70\">70%</div><div class=\"sb\" data-z=\"60\">60%</div></div></div>\n" +
    "<div class=\"row\"><div class=\"t\"><b>Propor&ccedil;&atilde;o</b><span>Formato das janelas (todas).</span></div><div class=\"seg\" id=\"g-ar\"><div class=\"sb\" data-r=\"0\">16:9</div><div class=\"sb\" data-r=\"1\">21:9</div><div class=\"sb\" data-r=\"2\">32:9</div><div class=\"sb\" data-r=\"3\">9:16</div></div></div>\n" +
    "</div>\n" +
    "<script>\n" +
    "var A=window.ArMenu;\n" +
    "function act(a){try{A.act(a)}catch(e){}}\n" +
    "function refresh(){var s={};try{s=JSON.parse(A.state())}catch(e){}\n" +
    "  document.getElementById('s-curve').className='sw'+(s.curved?' on':'');\n" +
    "  var hf=document.getElementById('s-fav');hf.style.fill=s.fav?'#ff4d6d':'none';hf.style.stroke=s.fav?'#ff4d6d':'#fff';\n" +
    "  document.getElementById('s-desktop').className='sw'+(s.desktop?' on':'');\n" +
    "  document.querySelectorAll('[data-z]').forEach(function(b){b.className='sb'+(+b.getAttribute('data-z')===s.bz?' on':'')});\n" +
    "  document.querySelectorAll('[data-r]').forEach(function(b){b.className='sb'+(+b.getAttribute('data-r')===s.ar?' on':'')});}\n" +
    "document.querySelectorAll('[data-a]').forEach(function(e){e.onclick=function(){act('more:'+e.getAttribute('data-a'));setTimeout(refresh,250);};});\n" +
    "document.querySelectorAll('[data-z]').forEach(function(e){e.onclick=function(){act('more:zoom:'+e.getAttribute('data-z'));setTimeout(refresh,200);};});\n" +
    "document.querySelectorAll('[data-r]').forEach(function(e){e.onclick=function(){act('more:ar:'+e.getAttribute('data-r'));setTimeout(refresh,200);};});\n" +
    "refresh();setInterval(refresh,1000);\n" +
    "</script></body></html>\n" +
    "\n";
}
EOF
cat > app/src/main/java/com/vr/launcher/ArHelloPage.java <<'EOF'
package com.vr.launcher;

/** Pagina HTML gerada (hello.html). */
final class ArHelloPage {
  static final String HTML =
    "<!doctype html>\n" +
    "<html><head><meta charset=\"utf-8\">\n" +
    "<meta name=\"viewport\" content=\"width=device-width,initial-scale=1,user-scalable=no\">\n" +
    "<style>\n" +
    "@font-face{font-family:'Hand';font-weight:600;src:url(/font/hand.woff2) format('woff2')}\n" +
    "*{box-sizing:border-box;-webkit-user-select:none;user-select:none}\n" +
    "html,body{margin:0;height:100%;background:#000;color:#fff;overflow:hidden}\n" +
    "#w{height:100%;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:34px;opacity:0;transition:opacity .8s ease}\n" +
    "#w.on{opacity:1}\n" +
    "/* sombra em azul puro: o 3D a transforma em um escurecimento translucido atras das letras */\n" +
    "#t{font-family:'Hand',cursive;font-weight:600;font-size:68px;text-align:center;padding:0 20px;line-height:1.1;color:#fff;\n" +
    "  text-shadow:0 4px 12px rgb(0,0,255),0 2px 3px rgb(0,0,255),0 0 26px rgb(0,0,255)}\n" +
    "#t span{display:inline-block;white-space:pre;animation:smoke 1.25s cubic-bezier(.2,.7,.3,1) both,wipe .7s ease-out both}\n" +
    "@keyframes smoke{0%{opacity:0;filter:blur(18px);transform:translate(-10px,14px) scale(1.7)}\n" +
    "  45%{opacity:.55;filter:blur(8px);transform:translate(4px,-4px) scale(1.25)}\n" +
    "  100%{opacity:1;filter:blur(0);transform:none}}\n" +
    "@keyframes wipe{0%{clip-path:inset(-30% 100% -30% -10%)}100%{clip-path:inset(-30% -10% -30% -10%)}}\n" +
    "#f{width:74%;max-width:560px;height:78px;border-radius:39px;border:2.5px solid #fff;background:rgb(0,0,150);display:none;align-items:center;justify-content:center;\n" +
    "  font-family:'Hand',cursive;font-weight:600;font-size:54px;color:#fff;padding:0 28px;overflow:hidden;white-space:nowrap;\n" +
    "  box-shadow:0 0 14px rgb(0,0,255);text-shadow:0 3px 8px rgb(0,0,255)}\n" +
    "#f.on{display:flex}\n" +
    "#c{display:inline-block;width:3px;height:48px;background:#fff;margin-left:4px;animation:bl 1s steps(1) infinite}\n" +
    "#ph{opacity:.7}\n" +
    "@keyframes bl{50%{opacity:0}}\n" +
    "</style></head><body>\n" +
    "<div id=\"w\"><div id=\"t\"></div><div id=\"f\"><span id=\"v\"></span><span id=\"c\"></span></div></div>\n" +
    "<script>\n" +
    "var A=window.ArMenu,last='',lt='';\n" +
    "function setTitle(x){var t=document.getElementById('t');t.innerHTML='';\n" +
    "  for(var i=0;i<x.length;i++){var s=document.createElement('span');s.textContent=x.charAt(i);\n" +
    "    s.style.animationDelay=(i*0.075)+'s,'+(i*0.075+0.35)+'s';t.appendChild(s);}}\n" +
    "function tick(){var s={};try{s=JSON.parse(A.state())}catch(e){}\n" +
    "  var m=s.hm||0,sig=[m,s.ht,s.hb].join('|');\n" +
    "  if(sig===last)return;last=sig;\n" +
    "  if(s.ht!==lt&&m>0){lt=s.ht;setTitle(s.ht||'');}\n" +
    "  document.getElementById('f').className=m===1?'on':'';\n" +
    "  var v=document.getElementById('v');\n" +
    "  if(s.hb)v.textContent=s.hb;else v.innerHTML='<span id=\"ph\">apelido</span>';\n" +
    "  document.getElementById('w').className=(m===1||m===2)?'on':'';}\n" +
    "setInterval(tick,120);tick();\n" +
    "</script></body></html>\n" +
    "\n";
}
EOF
cat > app/src/main/java/com/vr/launcher/ArFont.java <<'EOF'
package com.vr.launcher;

import java.io.ByteArrayInputStream;
import java.io.InputStream;

/** Fonte Exo 2 (OFL), latin 300 e 400, embutida: nao precisa de internet. Gerado, nao editar. */
final class ArFont {
  private static final String[] FHAND_P = {
    "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"
  };
  private static String hand() { StringBuilder b = new StringBuilder(); for (String c : FHAND_P) b.append(c); return b.toString(); }
  private static final String F300 = "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";
  private static final String F400 = "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";
  static InputStream open(String name) {
    String b = name.contains("hand") ? hand() : name.contains("300") ? F300 : name.contains("400") ? F400 : null;
    if (b == null) return null;
    return new ByteArrayInputStream(android.util.Base64.decode(b, android.util.Base64.DEFAULT));
  }
}
EOF
