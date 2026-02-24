// Compiles a dart2wasm-generated main module from `source` which can then
// instantiatable via the `instantiate` method.
//
// `source` needs to be a `Response` object (or promise thereof) e.g. created
// via the `fetch()` JS API.
export async function compileStreaming(source) {
  const builtins = {builtins: ['js-string']};
  return new CompiledApp(
      await WebAssembly.compileStreaming(source, builtins), builtins);
}

// Compiles a dart2wasm-generated wasm modules from `bytes` which is then
// instantiatable via the `instantiate` method.
export async function compile(bytes) {
  const builtins = {builtins: ['js-string']};
  return new CompiledApp(await WebAssembly.compile(bytes, builtins), builtins);
}

// DEPRECATED: Please use `compile` or `compileStreaming` to get a compiled app,
// use `instantiate` method to get an instantiated app and then call
// `invokeMain` to invoke the main function.
export async function instantiate(modulePromise, importObjectPromise) {
  var moduleOrCompiledApp = await modulePromise;
  if (!(moduleOrCompiledApp instanceof CompiledApp)) {
    moduleOrCompiledApp = new CompiledApp(moduleOrCompiledApp);
  }
  const instantiatedApp = await moduleOrCompiledApp.instantiate(await importObjectPromise);
  return instantiatedApp.instantiatedModule;
}

// DEPRECATED: Please use `compile` or `compileStreaming` to get a compiled app,
// use `instantiate` method to get an instantiated app and then call
// `invokeMain` to invoke the main function.
export const invoke = (moduleInstance, ...args) => {
  moduleInstance.exports.$invokeMain(args);
}

class CompiledApp {
  constructor(module, builtins) {
    this.module = module;
    this.builtins = builtins;
  }

  // The second argument is an options object containing:
  // `loadDeferredWasm` is a JS function that takes a module name matching a
  //   wasm file produced by the dart2wasm compiler and returns the bytes to
  //   load the module. These bytes can be in either a format supported by
  //   `WebAssembly.compile` or `WebAssembly.compileStreaming`.
  // `loadDynamicModule` is a JS function that takes two string names matching,
  //   in order, a wasm file produced by the dart2wasm compiler during dynamic
  //   module compilation and a corresponding js file produced by the same
  //   compilation. It should return a JS Array containing 2 elements. The first
  //   should be the bytes for the wasm module in a format supported by
  //   `WebAssembly.compile` or `WebAssembly.compileStreaming`. The second
  //   should be the result of using the JS 'import' API on the js file path.
  async instantiate(additionalImports, {loadDeferredWasm, loadDynamicModule} = {}) {
    let dartInstance;

    // Prints to the console
    function printToConsole(value) {
      if (typeof dartPrint == "function") {
        dartPrint(value);
        return;
      }
      if (typeof console == "object" && typeof console.log != "undefined") {
        console.log(value);
        return;
      }
      if (typeof print == "function") {
        print(value);
        return;
      }

      throw "Unable to print message: " + value;
    }

    // A special symbol attached to functions that wrap Dart functions.
    const jsWrappedDartFunctionSymbol = Symbol("JSWrappedDartFunction");

    function finalizeWrapper(dartFunction, wrapped) {
      wrapped.dartFunction = dartFunction;
      wrapped[jsWrappedDartFunctionSymbol] = true;
      return wrapped;
    }

    // Imports
    const dart2wasm = {
            _3: (o, t) => typeof o === t,
      _4: (o, c) => o instanceof c,
      _5: o => Object.keys(o),
      _8: (o, a) => o + a,
      _36: x0 => new Array(x0),
      _38: x0 => x0.length,
      _40: (x0,x1) => x0[x1],
      _41: (x0,x1,x2) => { x0[x1] = x2 },
      _43: x0 => new Promise(x0),
      _45: (x0,x1,x2) => new DataView(x0,x1,x2),
      _47: x0 => new Int8Array(x0),
      _48: (x0,x1,x2) => new Uint8Array(x0,x1,x2),
      _49: x0 => new Uint8Array(x0),
      _51: x0 => new Uint8ClampedArray(x0),
      _53: x0 => new Int16Array(x0),
      _55: x0 => new Uint16Array(x0),
      _57: x0 => new Int32Array(x0),
      _59: x0 => new Uint32Array(x0),
      _61: x0 => new Float32Array(x0),
      _63: x0 => new Float64Array(x0),
      _65: (x0,x1,x2) => x0.call(x1,x2),
      _67: (x0,x1) => x0.call(x1),
      _70: (decoder, codeUnits) => decoder.decode(codeUnits),
      _71: () => new TextDecoder("utf-8", {fatal: true}),
      _72: () => new TextDecoder("utf-8", {fatal: false}),
      _73: (s) => +s,
      _74: x0 => new Uint8Array(x0),
      _75: (x0,x1,x2) => x0.set(x1,x2),
      _76: (x0,x1) => x0.transferFromImageBitmap(x1),
      _78: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._78(f,arguments.length,x0) }),
      _79: x0 => new window.FinalizationRegistry(x0),
      _80: (x0,x1,x2,x3) => x0.register(x1,x2,x3),
      _81: (x0,x1) => x0.unregister(x1),
      _82: (x0,x1,x2) => x0.slice(x1,x2),
      _83: (x0,x1) => x0.decode(x1),
      _84: (x0,x1) => x0.segment(x1),
      _85: () => new TextDecoder(),
      _87: x0 => x0.buffer,
      _88: x0 => x0.wasmMemory,
      _89: () => globalThis.window._flutter_skwasmInstance,
      _90: x0 => x0.rasterStartMilliseconds,
      _91: x0 => x0.rasterEndMilliseconds,
      _92: x0 => x0.imageBitmaps,
      _196: x0 => x0.stopPropagation(),
      _197: x0 => x0.preventDefault(),
      _199: x0 => x0.remove(),
      _200: (x0,x1) => x0.append(x1),
      _201: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      _246: x0 => x0.unlock(),
      _247: x0 => x0.getReader(),
      _248: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _249: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      _250: (x0,x1) => x0.item(x1),
      _251: x0 => x0.next(),
      _252: x0 => x0.now(),
      _253: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._253(f,arguments.length,x0) }),
      _254: (x0,x1) => x0.addListener(x1),
      _255: (x0,x1) => x0.removeListener(x1),
      _256: (x0,x1) => x0.matchMedia(x1),
      _257: (x0,x1) => x0.revokeObjectURL(x1),
      _258: x0 => x0.close(),
      _259: (x0,x1,x2,x3,x4) => ({type: x0,data: x1,premultiplyAlpha: x2,colorSpaceConversion: x3,preferAnimation: x4}),
      _260: x0 => new window.ImageDecoder(x0),
      _261: x0 => ({frameIndex: x0}),
      _262: (x0,x1) => x0.decode(x1),
      _263: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._263(f,arguments.length,x0) }),
      _264: (x0,x1) => x0.getModifierState(x1),
      _265: (x0,x1) => x0.removeProperty(x1),
      _266: (x0,x1) => x0.prepend(x1),
      _267: x0 => new Intl.Locale(x0),
      _268: x0 => x0.disconnect(),
      _269: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._269(f,arguments.length,x0) }),
      _270: (x0,x1) => x0.getAttribute(x1),
      _271: (x0,x1) => x0.contains(x1),
      _272: (x0,x1) => x0.querySelector(x1),
      _273: x0 => x0.blur(),
      _274: x0 => x0.hasFocus(),
      _275: (x0,x1,x2) => x0.insertBefore(x1,x2),
      _276: (x0,x1) => x0.hasAttribute(x1),
      _277: (x0,x1) => x0.getModifierState(x1),
      _278: (x0,x1) => x0.createTextNode(x1),
      _279: (x0,x1) => x0.appendChild(x1),
      _280: (x0,x1) => x0.removeAttribute(x1),
      _281: x0 => x0.getBoundingClientRect(),
      _282: (x0,x1) => x0.observe(x1),
      _283: x0 => x0.disconnect(),
      _284: (x0,x1) => x0.closest(x1),
      _707: () => globalThis.window.flutterConfiguration,
      _709: x0 => x0.assetBase,
      _714: x0 => x0.canvasKitMaximumSurfaces,
      _715: x0 => x0.debugShowSemanticsNodes,
      _716: x0 => x0.hostElement,
      _717: x0 => x0.multiViewEnabled,
      _718: x0 => x0.nonce,
      _720: x0 => x0.fontFallbackBaseUrl,
      _730: x0 => x0.console,
      _731: x0 => x0.devicePixelRatio,
      _732: x0 => x0.document,
      _733: x0 => x0.history,
      _734: x0 => x0.innerHeight,
      _735: x0 => x0.innerWidth,
      _736: x0 => x0.location,
      _737: x0 => x0.navigator,
      _738: x0 => x0.visualViewport,
      _739: x0 => x0.performance,
      _741: x0 => x0.URL,
      _743: (x0,x1) => x0.getComputedStyle(x1),
      _744: x0 => x0.screen,
      _745: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._745(f,arguments.length,x0) }),
      _746: (x0,x1) => x0.requestAnimationFrame(x1),
      _751: (x0,x1) => x0.warn(x1),
      _753: (x0,x1) => x0.debug(x1),
      _754: x0 => globalThis.parseFloat(x0),
      _755: () => globalThis.window,
      _756: () => globalThis.Intl,
      _757: () => globalThis.Symbol,
      _758: (x0,x1,x2,x3,x4) => globalThis.createImageBitmap(x0,x1,x2,x3,x4),
      _760: x0 => x0.clipboard,
      _761: x0 => x0.maxTouchPoints,
      _762: x0 => x0.vendor,
      _763: x0 => x0.language,
      _764: x0 => x0.platform,
      _765: x0 => x0.userAgent,
      _766: (x0,x1) => x0.vibrate(x1),
      _767: x0 => x0.languages,
      _768: x0 => x0.documentElement,
      _769: (x0,x1) => x0.querySelector(x1),
      _772: (x0,x1) => x0.createElement(x1),
      _775: (x0,x1) => x0.createEvent(x1),
      _776: x0 => x0.activeElement,
      _779: x0 => x0.head,
      _780: x0 => x0.body,
      _782: (x0,x1) => { x0.title = x1 },
      _785: x0 => x0.visibilityState,
      _786: () => globalThis.document,
      _787: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._787(f,arguments.length,x0) }),
      _788: (x0,x1) => x0.dispatchEvent(x1),
      _796: x0 => x0.target,
      _798: x0 => x0.timeStamp,
      _799: x0 => x0.type,
      _801: (x0,x1,x2,x3) => x0.initEvent(x1,x2,x3),
      _807: x0 => x0.baseURI,
      _808: x0 => x0.firstChild,
      _812: x0 => x0.parentElement,
      _814: (x0,x1) => { x0.textContent = x1 },
      _815: x0 => x0.parentNode,
      _816: x0 => x0.nextSibling,
      _817: (x0,x1) => x0.removeChild(x1),
      _818: x0 => x0.isConnected,
      _826: x0 => x0.clientHeight,
      _827: x0 => x0.clientWidth,
      _828: x0 => x0.offsetHeight,
      _829: x0 => x0.offsetWidth,
      _830: x0 => x0.id,
      _831: (x0,x1) => { x0.id = x1 },
      _834: (x0,x1) => { x0.spellcheck = x1 },
      _835: x0 => x0.tagName,
      _836: x0 => x0.style,
      _838: (x0,x1) => x0.querySelectorAll(x1),
      _839: (x0,x1,x2) => x0.setAttribute(x1,x2),
      _840: (x0,x1) => { x0.tabIndex = x1 },
      _841: x0 => x0.tabIndex,
      _842: (x0,x1) => x0.focus(x1),
      _843: x0 => x0.scrollTop,
      _844: (x0,x1) => { x0.scrollTop = x1 },
      _845: x0 => x0.scrollLeft,
      _846: (x0,x1) => { x0.scrollLeft = x1 },
      _847: x0 => x0.classList,
      _849: (x0,x1) => { x0.className = x1 },
      _851: (x0,x1) => x0.getElementsByClassName(x1),
      _852: x0 => x0.click(),
      _853: (x0,x1) => x0.attachShadow(x1),
      _856: x0 => x0.computedStyleMap(),
      _857: (x0,x1) => x0.get(x1),
      _863: (x0,x1) => x0.getPropertyValue(x1),
      _864: (x0,x1,x2,x3) => x0.setProperty(x1,x2,x3),
      _865: x0 => x0.offsetLeft,
      _866: x0 => x0.offsetTop,
      _867: x0 => x0.offsetParent,
      _869: (x0,x1) => { x0.name = x1 },
      _870: x0 => x0.content,
      _871: (x0,x1) => { x0.content = x1 },
      _875: (x0,x1) => { x0.src = x1 },
      _876: x0 => x0.naturalWidth,
      _877: x0 => x0.naturalHeight,
      _881: (x0,x1) => { x0.crossOrigin = x1 },
      _883: (x0,x1) => { x0.decoding = x1 },
      _884: x0 => x0.decode(),
      _889: (x0,x1) => { x0.nonce = x1 },
      _894: (x0,x1) => { x0.width = x1 },
      _896: (x0,x1) => { x0.height = x1 },
      _899: (x0,x1) => x0.getContext(x1),
      _960: x0 => x0.width,
      _961: x0 => x0.height,
      _963: (x0,x1) => x0.fetch(x1),
      _964: x0 => x0.status,
      _966: x0 => x0.body,
      _967: x0 => x0.arrayBuffer(),
      _970: x0 => x0.read(),
      _971: x0 => x0.value,
      _972: x0 => x0.done,
      _979: x0 => x0.name,
      _980: x0 => x0.x,
      _981: x0 => x0.y,
      _984: x0 => x0.top,
      _985: x0 => x0.right,
      _986: x0 => x0.bottom,
      _987: x0 => x0.left,
      _997: x0 => x0.height,
      _998: x0 => x0.width,
      _999: x0 => x0.scale,
      _1000: (x0,x1) => { x0.value = x1 },
      _1003: (x0,x1) => { x0.placeholder = x1 },
      _1005: (x0,x1) => { x0.name = x1 },
      _1006: x0 => x0.selectionDirection,
      _1007: x0 => x0.selectionStart,
      _1008: x0 => x0.selectionEnd,
      _1011: x0 => x0.value,
      _1013: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      _1014: x0 => x0.readText(),
      _1015: (x0,x1) => x0.writeText(x1),
      _1017: x0 => x0.altKey,
      _1018: x0 => x0.code,
      _1019: x0 => x0.ctrlKey,
      _1020: x0 => x0.key,
      _1021: x0 => x0.keyCode,
      _1022: x0 => x0.location,
      _1023: x0 => x0.metaKey,
      _1024: x0 => x0.repeat,
      _1025: x0 => x0.shiftKey,
      _1026: x0 => x0.isComposing,
      _1028: x0 => x0.state,
      _1029: (x0,x1) => x0.go(x1),
      _1031: (x0,x1,x2,x3) => x0.pushState(x1,x2,x3),
      _1032: (x0,x1,x2,x3) => x0.replaceState(x1,x2,x3),
      _1033: x0 => x0.pathname,
      _1034: x0 => x0.search,
      _1035: x0 => x0.hash,
      _1039: x0 => x0.state,
      _1042: (x0,x1) => x0.createObjectURL(x1),
      _1044: x0 => new Blob(x0),
      _1046: x0 => new MutationObserver(x0),
      _1047: (x0,x1,x2) => x0.observe(x1,x2),
      _1048: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1048(f,arguments.length,x0,x1) }),
      _1051: x0 => x0.attributeName,
      _1052: x0 => x0.type,
      _1053: x0 => x0.matches,
      _1054: x0 => x0.matches,
      _1058: x0 => x0.relatedTarget,
      _1060: x0 => x0.clientX,
      _1061: x0 => x0.clientY,
      _1062: x0 => x0.offsetX,
      _1063: x0 => x0.offsetY,
      _1066: x0 => x0.button,
      _1067: x0 => x0.buttons,
      _1068: x0 => x0.ctrlKey,
      _1072: x0 => x0.pointerId,
      _1073: x0 => x0.pointerType,
      _1074: x0 => x0.pressure,
      _1075: x0 => x0.tiltX,
      _1076: x0 => x0.tiltY,
      _1077: x0 => x0.getCoalescedEvents(),
      _1080: x0 => x0.deltaX,
      _1081: x0 => x0.deltaY,
      _1082: x0 => x0.wheelDeltaX,
      _1083: x0 => x0.wheelDeltaY,
      _1084: x0 => x0.deltaMode,
      _1091: x0 => x0.changedTouches,
      _1094: x0 => x0.clientX,
      _1095: x0 => x0.clientY,
      _1098: x0 => x0.data,
      _1101: (x0,x1) => { x0.disabled = x1 },
      _1103: (x0,x1) => { x0.type = x1 },
      _1104: (x0,x1) => { x0.max = x1 },
      _1105: (x0,x1) => { x0.min = x1 },
      _1106: x0 => x0.value,
      _1107: (x0,x1) => { x0.value = x1 },
      _1108: x0 => x0.disabled,
      _1109: (x0,x1) => { x0.disabled = x1 },
      _1111: (x0,x1) => { x0.placeholder = x1 },
      _1112: (x0,x1) => { x0.name = x1 },
      _1115: (x0,x1) => { x0.autocomplete = x1 },
      _1116: x0 => x0.selectionDirection,
      _1117: x0 => x0.selectionStart,
      _1119: x0 => x0.selectionEnd,
      _1122: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      _1123: (x0,x1) => x0.add(x1),
      _1126: (x0,x1) => { x0.noValidate = x1 },
      _1127: (x0,x1) => { x0.method = x1 },
      _1128: (x0,x1) => { x0.action = x1 },
      _1154: x0 => x0.orientation,
      _1155: x0 => x0.width,
      _1156: x0 => x0.height,
      _1157: (x0,x1) => x0.lock(x1),
      _1176: x0 => new ResizeObserver(x0),
      _1179: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1179(f,arguments.length,x0,x1) }),
      _1187: x0 => x0.length,
      _1188: x0 => x0.iterator,
      _1189: x0 => x0.Segmenter,
      _1190: x0 => x0.v8BreakIterator,
      _1191: (x0,x1) => new Intl.Segmenter(x0,x1),
      _1194: x0 => x0.language,
      _1195: x0 => x0.script,
      _1196: x0 => x0.region,
      _1214: x0 => x0.done,
      _1215: x0 => x0.value,
      _1216: x0 => x0.index,
      _1220: (x0,x1) => new Intl.v8BreakIterator(x0,x1),
      _1221: (x0,x1) => x0.adoptText(x1),
      _1222: x0 => x0.first(),
      _1223: x0 => x0.next(),
      _1224: x0 => x0.current(),
      _1238: x0 => x0.hostElement,
      _1239: x0 => x0.viewConstraints,
      _1242: x0 => x0.maxHeight,
      _1243: x0 => x0.maxWidth,
      _1244: x0 => x0.minHeight,
      _1245: x0 => x0.minWidth,
      _1246: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1246(f,arguments.length,x0) }),
      _1247: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1247(f,arguments.length,x0) }),
      _1248: (x0,x1) => ({addView: x0,removeView: x1}),
      _1251: x0 => x0.loader,
      _1252: () => globalThis._flutter,
      _1253: (x0,x1) => x0.didCreateEngineInitializer(x1),
      _1254: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1254(f,arguments.length,x0) }),
      _1255: f => finalizeWrapper(f, function() { return dartInstance.exports._1255(f,arguments.length) }),
      _1256: (x0,x1) => ({initializeEngine: x0,autoStart: x1}),
      _1259: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1259(f,arguments.length,x0) }),
      _1260: x0 => ({runApp: x0}),
      _1262: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1262(f,arguments.length,x0,x1) }),
      _1263: x0 => x0.length,
      _1264: () => globalThis.window.ImageDecoder,
      _1265: x0 => x0.tracks,
      _1267: x0 => x0.completed,
      _1269: x0 => x0.image,
      _1275: x0 => x0.displayWidth,
      _1276: x0 => x0.displayHeight,
      _1277: x0 => x0.duration,
      _1280: x0 => x0.ready,
      _1281: x0 => x0.selectedTrack,
      _1282: x0 => x0.repetitionCount,
      _1283: x0 => x0.frameCount,
      _1328: (x0,x1) => x0.createElement(x1),
      _1329: (x0,x1) => x0.querySelector(x1),
      _1330: (x0,x1) => x0.appendChild(x1),
      _1331: x0 => ({type: x0}),
      _1332: (x0,x1) => new Blob(x0,x1),
      _1333: x0 => globalThis.URL.createObjectURL(x0),
      _1335: (x0,x1,x2,x3) => x0.sendCommand(x1,x2,x3),
      _1336: () => globalThis.PdfiumWasmCommunicator,
      _1338: x0 => { globalThis.pdfiumWasmWorkerUrl = x0 },
      _1340: x0 => x0.preventDefault(),
      _1341: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1341(f,arguments.length,x0) }),
      _1342: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _1348: (x0,x1) => x0.createElement(x1),
      _1354: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _1366: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1366(f,arguments.length,x0) }),
      _1367: (x0,x1) => x0.removeChild(x1),
      _1368: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1368(f,arguments.length,x0) }),
      _1369: () => new Map(),
      _1370: (x0,x1,x2) => x0.set(x1,x2),
      _1371: (x0,x1,x2,x3) => x0.call(x1,x2,x3),
      _1372: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1372(f,arguments.length,x0,x1) }),
      _1373: (x0,x1) => new ZXing.BrowserMultiFormatReader(x0,x1),
      _1375: x0 => x0.play(),
      _1376: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1376(f,arguments.length,x0) }),
      _1377: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1377(f,arguments.length,x0) }),
      _1378: (x0,x1) => x0.append(x1),
      _1379: x0 => x0.getVideoTracks(),
      _1380: x0 => x0.getSupportedConstraints(),
      _1381: x0 => ({video: x0}),
      _1382: x0 => ({facingMode: x0}),
      _1383: (x0,x1) => x0.getUserMedia(x1),
      _1384: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      _1385: (x0,x1,x2,x3) => x0.removeEventListener(x1,x2,x3),
      _1386: (x0,x1,x2) => x0.setAttribute(x1,x2),
      _1392: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      _1402: x0 => x0.click(),
      _1403: x0 => x0.remove(),
      _1411: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1411(f,arguments.length,x0) }),
      _1412: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1412(f,arguments.length,x0) }),
      _1413: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1413(f,arguments.length,x0) }),
      _1414: (x0,x1) => x0.replaceChildren(x1),
      _1415: x0 => x0.decode(),
      _1416: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      _1417: (x0,x1,x2) => x0.setRequestHeader(x1,x2),
      _1418: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1418(f,arguments.length,x0) }),
      _1419: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1419(f,arguments.length,x0) }),
      _1420: x0 => x0.send(),
      _1421: () => new XMLHttpRequest(),
      _1438: (x0,x1) => x0.getItem(x1),
      _1440: (x0,x1,x2) => x0.setItem(x1,x2),
      _1441: (x0,x1) => x0.item(x1),
      _1442: () => new FileReader(),
      _1444: (x0,x1) => x0.readAsArrayBuffer(x1),
      _1445: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1445(f,arguments.length,x0) }),
      _1446: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      _1447: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1447(f,arguments.length,x0) }),
      _1448: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1448(f,arguments.length,x0) }),
      _1449: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1449(f,arguments.length,x0) }),
      _1450: x0 => new Blob(x0),
      _1452: () => globalThis.removeSplashFromWeb(),
      _1469: x0 => globalThis.URL.revokeObjectURL(x0),
      _1481: x0 => x0.barcodeFormat,
      _1482: x0 => x0.text,
      _1483: x0 => x0.rawBytes,
      _1484: x0 => x0.resultPoints,
      _1486: Date.now,
      _1488: s => new Date(s * 1000).getTimezoneOffset() * 60,
      _1489: s => {
        if (!/^\s*[+-]?(?:Infinity|NaN|(?:\.\d+|\d+(?:\.\d*)?)(?:[eE][+-]?\d+)?)\s*$/.test(s)) {
          return NaN;
        }
        return parseFloat(s);
      },
      _1490: () => {
        let stackString = new Error().stack.toString();
        let frames = stackString.split('\n');
        let drop = 2;
        if (frames[0] === 'Error') {
            drop += 1;
        }
        return frames.slice(drop).join('\n');
      },
      _1491: () => typeof dartUseDateNowForTicks !== "undefined",
      _1492: () => 1000 * performance.now(),
      _1493: () => Date.now(),
      _1494: () => {
        // On browsers return `globalThis.location.href`
        if (globalThis.location != null) {
          return globalThis.location.href;
        }
        return null;
      },
      _1495: () => {
        return typeof process != "undefined" &&
               Object.prototype.toString.call(process) == "[object process]" &&
               process.platform == "win32"
      },
      _1496: () => new WeakMap(),
      _1497: (map, o) => map.get(o),
      _1498: (map, o, v) => map.set(o, v),
      _1499: x0 => new WeakRef(x0),
      _1500: x0 => x0.deref(),
      _1501: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1501(f,arguments.length,x0) }),
      _1502: x0 => new FinalizationRegistry(x0),
      _1507: () => globalThis.WeakRef,
      _1508: () => globalThis.FinalizationRegistry,
      _1510: x0 => x0.call(),
      _1511: s => JSON.stringify(s),
      _1512: s => printToConsole(s),
      _1513: (o, p, r) => o.replaceAll(p, () => r),
      _1514: (o, p, r) => o.replace(p, () => r),
      _1515: Function.prototype.call.bind(String.prototype.toLowerCase),
      _1516: s => s.toUpperCase(),
      _1517: s => s.trim(),
      _1518: s => s.trimLeft(),
      _1519: s => s.trimRight(),
      _1520: (string, times) => string.repeat(times),
      _1521: Function.prototype.call.bind(String.prototype.indexOf),
      _1522: (s, p, i) => s.lastIndexOf(p, i),
      _1523: (string, token) => string.split(token),
      _1524: Object.is,
      _1525: o => o instanceof Array,
      _1526: (a, i) => a.push(i),
      _1529: (a, l) => a.length = l,
      _1530: a => a.pop(),
      _1531: (a, i) => a.splice(i, 1),
      _1532: (a, s) => a.join(s),
      _1533: (a, s, e) => a.slice(s, e),
      _1535: (a, b) => a == b ? 0 : (a > b ? 1 : -1),
      _1536: a => a.length,
      _1537: (a, l) => a.length = l,
      _1538: (a, i) => a[i],
      _1539: (a, i, v) => a[i] = v,
      _1541: o => {
        if (o instanceof ArrayBuffer) return 0;
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
          return 1;
        }
        return 2;
      },
      _1542: (o, offsetInBytes, lengthInBytes) => {
        var dst = new ArrayBuffer(lengthInBytes);
        new Uint8Array(dst).set(new Uint8Array(o, offsetInBytes, lengthInBytes));
        return new DataView(dst);
      },
      _1544: o => o instanceof Uint8Array,
      _1545: (o, start, length) => new Uint8Array(o.buffer, o.byteOffset + start, length),
      _1546: o => o instanceof Int8Array,
      _1547: (o, start, length) => new Int8Array(o.buffer, o.byteOffset + start, length),
      _1548: o => o instanceof Uint8ClampedArray,
      _1549: (o, start, length) => new Uint8ClampedArray(o.buffer, o.byteOffset + start, length),
      _1550: o => o instanceof Uint16Array,
      _1551: (o, start, length) => new Uint16Array(o.buffer, o.byteOffset + start, length),
      _1552: o => o instanceof Int16Array,
      _1553: (o, start, length) => new Int16Array(o.buffer, o.byteOffset + start, length),
      _1554: o => o instanceof Uint32Array,
      _1555: (o, start, length) => new Uint32Array(o.buffer, o.byteOffset + start, length),
      _1556: o => o instanceof Int32Array,
      _1557: (o, start, length) => new Int32Array(o.buffer, o.byteOffset + start, length),
      _1559: (o, start, length) => new BigInt64Array(o.buffer, o.byteOffset + start, length),
      _1560: o => o instanceof Float32Array,
      _1561: (o, start, length) => new Float32Array(o.buffer, o.byteOffset + start, length),
      _1562: o => o instanceof Float64Array,
      _1563: (o, start, length) => new Float64Array(o.buffer, o.byteOffset + start, length),
      _1564: (t, s) => t.set(s),
      _1565: l => new DataView(new ArrayBuffer(l)),
      _1566: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
      _1567: o => o.byteLength,
      _1568: o => o.buffer,
      _1569: o => o.byteOffset,
      _1570: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
      _1571: (b, o) => new DataView(b, o),
      _1572: (b, o, l) => new DataView(b, o, l),
      _1573: Function.prototype.call.bind(DataView.prototype.getUint8),
      _1574: Function.prototype.call.bind(DataView.prototype.setUint8),
      _1575: Function.prototype.call.bind(DataView.prototype.getInt8),
      _1576: Function.prototype.call.bind(DataView.prototype.setInt8),
      _1577: Function.prototype.call.bind(DataView.prototype.getUint16),
      _1578: Function.prototype.call.bind(DataView.prototype.setUint16),
      _1579: Function.prototype.call.bind(DataView.prototype.getInt16),
      _1580: Function.prototype.call.bind(DataView.prototype.setInt16),
      _1581: Function.prototype.call.bind(DataView.prototype.getUint32),
      _1582: Function.prototype.call.bind(DataView.prototype.setUint32),
      _1583: Function.prototype.call.bind(DataView.prototype.getInt32),
      _1584: Function.prototype.call.bind(DataView.prototype.setInt32),
      _1587: Function.prototype.call.bind(DataView.prototype.getBigInt64),
      _1588: Function.prototype.call.bind(DataView.prototype.setBigInt64),
      _1589: Function.prototype.call.bind(DataView.prototype.getFloat32),
      _1590: Function.prototype.call.bind(DataView.prototype.setFloat32),
      _1591: Function.prototype.call.bind(DataView.prototype.getFloat64),
      _1592: Function.prototype.call.bind(DataView.prototype.setFloat64),
      _1605: (ms, c) =>
      setTimeout(() => dartInstance.exports.$invokeCallback(c),ms),
      _1606: (handle) => clearTimeout(handle),
      _1607: (ms, c) =>
      setInterval(() => dartInstance.exports.$invokeCallback(c), ms),
      _1608: (handle) => clearInterval(handle),
      _1609: (c) =>
      queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
      _1610: () => Date.now(),
      _1611: (s, m) => {
        try {
          return new RegExp(s, m);
        } catch (e) {
          return String(e);
        }
      },
      _1612: (x0,x1) => x0.exec(x1),
      _1613: (x0,x1) => x0.test(x1),
      _1614: x0 => x0.pop(),
      _1616: o => o === undefined,
      _1618: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
      _1620: o => {
        const proto = Object.getPrototypeOf(o);
        return proto === Object.prototype || proto === null;
      },
      _1621: o => o instanceof RegExp,
      _1622: (l, r) => l === r,
      _1623: o => o,
      _1624: o => o,
      _1625: o => o,
      _1626: b => !!b,
      _1627: o => o.length,
      _1629: (o, i) => o[i],
      _1630: f => f.dartFunction,
      _1631: () => ({}),
      _1632: () => [],
      _1634: () => globalThis,
      _1635: (constructor, args) => {
        const factoryFunction = constructor.bind.apply(
            constructor, [null, ...args]);
        return new factoryFunction();
      },
      _1636: (o, p) => p in o,
      _1637: (o, p) => o[p],
      _1638: (o, p, v) => o[p] = v,
      _1639: (o, m, a) => o[m].apply(o, a),
      _1641: o => String(o),
      _1642: (p, s, f) => p.then(s, (e) => f(e, e === undefined)),
      _1643: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1643(f,arguments.length,x0) }),
      _1644: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1644(f,arguments.length,x0,x1) }),
      _1645: o => {
        if (o === undefined) return 1;
        var type = typeof o;
        if (type === 'boolean') return 2;
        if (type === 'number') return 3;
        if (type === 'string') return 4;
        if (o instanceof Array) return 5;
        if (ArrayBuffer.isView(o)) {
          if (o instanceof Int8Array) return 6;
          if (o instanceof Uint8Array) return 7;
          if (o instanceof Uint8ClampedArray) return 8;
          if (o instanceof Int16Array) return 9;
          if (o instanceof Uint16Array) return 10;
          if (o instanceof Int32Array) return 11;
          if (o instanceof Uint32Array) return 12;
          if (o instanceof Float32Array) return 13;
          if (o instanceof Float64Array) return 14;
          if (o instanceof DataView) return 15;
        }
        if (o instanceof ArrayBuffer) return 16;
        // Feature check for `SharedArrayBuffer` before doing a type-check.
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
            return 17;
        }
        if (o instanceof Promise) return 18;
        return 19;
      },
      _1646: o => [o],
      _1647: (o0, o1) => [o0, o1],
      _1648: (o0, o1, o2) => [o0, o1, o2],
      _1649: (o0, o1, o2, o3) => [o0, o1, o2, o3],
      _1650: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI8ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _1651: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI8ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _1654: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _1655: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _1656: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _1657: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _1658: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF64ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _1659: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF64ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _1660: x0 => new ArrayBuffer(x0),
      _1661: s => {
        if (/[[\]{}()*+?.\\^$|]/.test(s)) {
            s = s.replace(/[[\]{}()*+?.\\^$|]/g, '\\$&');
        }
        return s;
      },
      _1663: x0 => x0.index,
      _1664: x0 => x0.groups,
      _1665: x0 => x0.flags,
      _1666: x0 => x0.multiline,
      _1667: x0 => x0.ignoreCase,
      _1668: x0 => x0.unicode,
      _1669: x0 => x0.dotAll,
      _1670: (x0,x1) => { x0.lastIndex = x1 },
      _1671: (o, p) => p in o,
      _1672: (o, p) => o[p],
      _1673: (o, p, v) => o[p] = v,
      _1675: x0 => x0.exports,
      _1676: (x0,x1) => globalThis.WebAssembly.instantiateStreaming(x0,x1),
      _1677: x0 => x0.instance,
      _1680: x0 => x0.buffer,
      _1683: x0 => x0.arrayBuffer(),
      _1685: x0 => x0.sqlite3_initialize(),
      _1688: (x0,x1) => x0.sqlite3_close_v2(x1),
      _1703: (x0,x1) => x0.sqlite3_finalize(x1),
      _1739: (x0,x1) => x0.sqlite3session_delete(x1),
      _1743: (x0,x1) => x0.sqlite3changeset_finalize(x1),
      _1754: (x0,x1) => x0.dart_sqlite3_malloc(x1),
      _1758: (x0,x1,x2,x3) => x0.dart_sqlite3_register_vfs(x1,x2,x3),
      _1769: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1769(f,arguments.length,x0) }),
      _1770: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1770(f,arguments.length,x0,x1) }),
      _1771: f => finalizeWrapper(f, function(x0,x1,x2,x3,x4) { return dartInstance.exports._1771(f,arguments.length,x0,x1,x2,x3,x4) }),
      _1772: f => finalizeWrapper(f, function(x0,x1,x2) { return dartInstance.exports._1772(f,arguments.length,x0,x1,x2) }),
      _1773: f => finalizeWrapper(f, function(x0,x1,x2,x3) { return dartInstance.exports._1773(f,arguments.length,x0,x1,x2,x3) }),
      _1774: f => finalizeWrapper(f, function(x0,x1,x2,x3) { return dartInstance.exports._1774(f,arguments.length,x0,x1,x2,x3) }),
      _1775: f => finalizeWrapper(f, function(x0,x1,x2) { return dartInstance.exports._1775(f,arguments.length,x0,x1,x2) }),
      _1776: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1776(f,arguments.length,x0,x1) }),
      _1777: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1777(f,arguments.length,x0,x1) }),
      _1778: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1778(f,arguments.length,x0) }),
      _1779: f => finalizeWrapper(f, function(x0,x1,x2,x3) { return dartInstance.exports._1779(f,arguments.length,x0,x1,x2,x3) }),
      _1780: f => finalizeWrapper(f, function(x0,x1,x2,x3) { return dartInstance.exports._1780(f,arguments.length,x0,x1,x2,x3) }),
      _1781: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1781(f,arguments.length,x0,x1) }),
      _1782: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1782(f,arguments.length,x0,x1) }),
      _1783: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1783(f,arguments.length,x0,x1) }),
      _1784: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1784(f,arguments.length,x0,x1) }),
      _1785: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1785(f,arguments.length,x0,x1) }),
      _1786: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1786(f,arguments.length,x0,x1) }),
      _1787: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1787(f,arguments.length,x0) }),
      _1788: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1788(f,arguments.length,x0) }),
      _1789: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1789(f,arguments.length,x0) }),
      _1790: f => finalizeWrapper(f, function(x0,x1,x2,x3,x4) { return dartInstance.exports._1790(f,arguments.length,x0,x1,x2,x3,x4) }),
      _1791: f => finalizeWrapper(f, function(x0,x1,x2,x3) { return dartInstance.exports._1791(f,arguments.length,x0,x1,x2,x3) }),
      _1792: f => finalizeWrapper(f, function(x0,x1,x2,x3) { return dartInstance.exports._1792(f,arguments.length,x0,x1,x2,x3) }),
      _1793: f => finalizeWrapper(f, function(x0,x1,x2,x3) { return dartInstance.exports._1793(f,arguments.length,x0,x1,x2,x3) }),
      _1794: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1794(f,arguments.length,x0,x1) }),
      _1795: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1795(f,arguments.length,x0,x1) }),
      _1796: f => finalizeWrapper(f, function(x0,x1,x2,x3,x4) { return dartInstance.exports._1796(f,arguments.length,x0,x1,x2,x3,x4) }),
      _1797: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1797(f,arguments.length,x0,x1) }),
      _1798: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1798(f,arguments.length,x0,x1) }),
      _1799: f => finalizeWrapper(f, function(x0,x1,x2) { return dartInstance.exports._1799(f,arguments.length,x0,x1,x2) }),
      _1803: x0 => new URL(x0),
      _1804: (x0,x1) => new URL(x0,x1),
      _1805: (x0,x1) => globalThis.fetch(x0,x1),
      _1806: (x0,x1,x2) => x0.postMessage(x1,x2),
      _1808: (x0,x1) => x0.error(x1),
      _1809: (x0,x1) => new SharedWorker(x0,x1),
      _1810: x0 => new Worker(x0),
      _1811: () => new MessageChannel(),
      _1812: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1812(f,arguments.length,x0) }),
      _1813: (x0,x1,x2) => x0.postMessage(x1,x2),
      _1814: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1814(f,arguments.length,x0) }),
      _1815: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1815(f,arguments.length,x0) }),
      _1828: (x0,x1) => globalThis.IDBKeyRange.bound(x0,x1),
      _1829: (x0,x1,x2) => x0.open(x1,x2),
      _1830: x0 => ({autoIncrement: x0}),
      _1831: (x0,x1,x2) => x0.createObjectStore(x1,x2),
      _1832: x0 => ({unique: x0}),
      _1833: (x0,x1,x2,x3) => x0.createIndex(x1,x2,x3),
      _1834: (x0,x1) => x0.createObjectStore(x1),
      _1835: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1835(f,arguments.length,x0) }),
      _1837: (x0,x1,x2) => x0.transaction(x1,x2),
      _1838: (x0,x1) => x0.objectStore(x1),
      _1840: (x0,x1) => x0.index(x1),
      _1841: x0 => x0.openKeyCursor(),
      _1842: (x0,x1) => x0.getKey(x1),
      _1843: (x0,x1) => ({name: x0,length: x1}),
      _1844: (x0,x1) => x0.put(x1),
      _1845: (x0,x1) => x0.get(x1),
      _1846: (x0,x1) => x0.openCursor(x1),
      _1847: x0 => globalThis.IDBKeyRange.only(x0),
      _1848: (x0,x1,x2) => x0.put(x1,x2),
      _1849: (x0,x1) => x0.update(x1),
      _1850: (x0,x1) => x0.delete(x1),
      _1853: x0 => x0.name,
      _1854: x0 => x0.length,
      _1859: x0 => x0.continue(),
      _1860: () => globalThis.indexedDB,
      _1873: x0 => globalThis.BigInt(x0),
      _1874: x0 => globalThis.Number(x0),
      _1893: x0 => globalThis.Object.keys(x0),
      _1894: x0 => x0.length,
      _1895: () => new XMLHttpRequest(),
      _1896: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      _1900: x0 => x0.send(),
      _1902: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1902(f,arguments.length,x0) }),
      _1903: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1903(f,arguments.length,x0) }),
      _1908: (x0,x1) => x0.log(x1),
      _1911: () => new AbortController(),
      _1912: x0 => x0.abort(),
      _1913: (x0,x1,x2,x3,x4,x5) => ({method: x0,headers: x1,body: x2,credentials: x3,redirect: x4,signal: x5}),
      _1914: (x0,x1) => globalThis.fetch(x0,x1),
      _1915: (x0,x1) => x0.get(x1),
      _1916: f => finalizeWrapper(f, function(x0,x1,x2) { return dartInstance.exports._1916(f,arguments.length,x0,x1,x2) }),
      _1917: (x0,x1) => x0.forEach(x1),
      _1918: x0 => x0.getReader(),
      _1919: x0 => x0.cancel(),
      _1920: x0 => x0.read(),
      _1921: x0 => x0.attachStreamToVideo,
      _1923: x0 => x0.decodeContinuously,
      _1927: x0 => x0.reset,
      _1929: x0 => x0.stopContinuousDecode,
      _1931: x0 => x0.stream,
      _1932: x0 => x0.videoElement,
      _1933: (x0,x1) => x0.key(x1),
      _1935: x0 => x0.facingMode,
      _1936: x0 => x0.getSettings(),
      _1937: (x0,x1) => ({width: x0,height: x1}),
      _1938: (x0,x1,x2) => ({width: x0,height: x1,facingMode: x2}),
      _1939: x0 => x0.random(),
      _1940: (x0,x1) => x0.getRandomValues(x1),
      _1941: () => globalThis.crypto,
      _1942: () => globalThis.Math,
      _1951: Function.prototype.call.bind(Number.prototype.toString),
      _1952: Function.prototype.call.bind(BigInt.prototype.toString),
      _1953: Function.prototype.call.bind(Number.prototype.toString),
      _1954: (d, digits) => d.toFixed(digits),
      _1958: () => globalThis.document,
      _1979: (x0,x1) => { x0.src = x1 },
      _1980: x0 => x0.naturalWidth,
      _1981: x0 => x0.naturalHeight,
      _1997: x0 => x0.status,
      _1998: (x0,x1) => { x0.responseType = x1 },
      _2000: x0 => x0.response,
      _2001: x0 => x0.x,
      _2002: x0 => x0.y,
      _2051: (x0,x1) => { x0.responseType = x1 },
      _2052: x0 => x0.response,
      _2099: (x0,x1) => { x0.lang = x1 },
      _2112: (x0,x1) => { x0.draggable = x1 },
      _2128: x0 => x0.style,
      _2141: (x0,x1) => { x0.oncancel = x1 },
      _2147: (x0,x1) => { x0.onchange = x1 },
      _2187: (x0,x1) => { x0.onerror = x1 },
      _2203: (x0,x1) => { x0.onload = x1 },
      _2227: (x0,x1) => { x0.onpause = x1 },
      _2229: (x0,x1) => { x0.onplay = x1 },
      _2381: x0 => x0.content,
      _2700: x0 => x0.videoWidth,
      _2701: x0 => x0.videoHeight,
      _2749: x0 => x0.paused,
      _2764: (x0,x1) => { x0.controls = x1 },
      _3055: (x0,x1) => { x0.accept = x1 },
      _3069: x0 => x0.files,
      _3095: (x0,x1) => { x0.multiple = x1 },
      _3113: (x0,x1) => { x0.type = x1 },
      _3363: (x0,x1) => { x0.src = x1 },
      _3365: (x0,x1) => { x0.type = x1 },
      _3369: (x0,x1) => { x0.async = x1 },
      _3371: (x0,x1) => { x0.defer = x1 },
      _3373: (x0,x1) => { x0.crossOrigin = x1 },
      _3383: (x0,x1) => { x0.charset = x1 },
      _3831: () => globalThis.window,
      _3871: x0 => x0.document,
      _3874: x0 => x0.location,
      _3893: x0 => x0.navigator,
      _4157: x0 => x0.localStorage,
      _4165: x0 => x0.href,
      _4264: x0 => x0.mediaDevices,
      _4280: x0 => x0.userAgent,
      _4281: x0 => x0.vendor,
      _4331: x0 => x0.data,
      _4361: x0 => x0.port1,
      _4362: x0 => x0.port2,
      _4366: (x0,x1) => { x0.onmessage = x1 },
      _4441: (x0,x1) => { x0.onerror = x1 },
      _4449: x0 => x0.port,
      _4451: (x0,x1) => { x0.onerror = x1 },
      _4484: x0 => x0.length,
      _6388: x0 => x0.type,
      _6389: x0 => x0.target,
      _6429: x0 => x0.signal,
      _6484: x0 => x0.baseURI,
      _6490: x0 => x0.firstChild,
      _6501: () => globalThis.document,
      _6583: x0 => x0.body,
      _6585: x0 => x0.head,
      _6914: (x0,x1) => { x0.id = x1 },
      _6941: x0 => x0.children,
      _8260: x0 => x0.value,
      _8262: x0 => x0.done,
      _8426: x0 => x0.size,
      _8427: x0 => x0.type,
      _8433: x0 => x0.name,
      _8434: x0 => x0.lastModified,
      _8439: x0 => x0.length,
      _8444: x0 => x0.result,
      _8940: x0 => x0.url,
      _8942: x0 => x0.status,
      _8944: x0 => x0.statusText,
      _8945: x0 => x0.headers,
      _8946: x0 => x0.body,
      _9747: x0 => x0.label,
      _9769: x0 => x0.facingMode,
      _9983: x0 => x0.width,
      _9985: x0 => x0.height,
      _9991: x0 => x0.facingMode,
      _10397: x0 => x0.result,
      _10398: x0 => x0.error,
      _10409: (x0,x1) => { x0.onupgradeneeded = x1 },
      _10411: x0 => x0.oldVersion,
      _10490: x0 => x0.key,
      _10491: x0 => x0.primaryKey,
      _10493: x0 => x0.value,
      _11332: (x0,x1) => { x0.display = x1 },
      _11496: (x0,x1) => { x0.height = x1 },
      _11690: (x0,x1) => { x0.objectFit = x1 },
      _11820: (x0,x1) => { x0.pointerEvents = x1 },
      _12118: (x0,x1) => { x0.transform = x1 },
      _12122: (x0,x1) => { x0.transformOrigin = x1 },
      _12186: (x0,x1) => { x0.width = x1 },
      _12554: x0 => x0.name,
      _13271: () => globalThis.console,
      _13294: () => globalThis.window.flutterGemmaOPFS,
      _13297: x0 => x0.message,

    };

    const baseImports = {
      dart2wasm: dart2wasm,
      Math: Math,
      Date: Date,
      Object: Object,
      Array: Array,
      Reflect: Reflect,
      S: new Proxy({}, { get(_, prop) { return prop; } }),

    };

    const jsStringPolyfill = {
      "charCodeAt": (s, i) => s.charCodeAt(i),
      "compare": (s1, s2) => {
        if (s1 < s2) return -1;
        if (s1 > s2) return 1;
        return 0;
      },
      "concat": (s1, s2) => s1 + s2,
      "equals": (s1, s2) => s1 === s2,
      "fromCharCode": (i) => String.fromCharCode(i),
      "length": (s) => s.length,
      "substring": (s, a, b) => s.substring(a, b),
      "fromCharCodeArray": (a, start, end) => {
        if (end <= start) return '';

        const read = dartInstance.exports.$wasmI16ArrayGet;
        let result = '';
        let index = start;
        const chunkLength = Math.min(end - index, 500);
        let array = new Array(chunkLength);
        while (index < end) {
          const newChunkLength = Math.min(end - index, 500);
          for (let i = 0; i < newChunkLength; i++) {
            array[i] = read(a, index++);
          }
          if (newChunkLength < chunkLength) {
            array = array.slice(0, newChunkLength);
          }
          result += String.fromCharCode(...array);
        }
        return result;
      },
      "intoCharCodeArray": (s, a, start) => {
        if (s === '') return 0;

        const write = dartInstance.exports.$wasmI16ArraySet;
        for (var i = 0; i < s.length; ++i) {
          write(a, start++, s.charCodeAt(i));
        }
        return s.length;
      },
      "test": (s) => typeof s == "string",
    };


    

    dartInstance = await WebAssembly.instantiate(this.module, {
      ...baseImports,
      ...additionalImports,
      
      "wasm:js-string": jsStringPolyfill,
    });

    return new InstantiatedApp(this, dartInstance);
  }
}

class InstantiatedApp {
  constructor(compiledApp, instantiatedModule) {
    this.compiledApp = compiledApp;
    this.instantiatedModule = instantiatedModule;
  }

  // Call the main function with the given arguments.
  invokeMain(...args) {
    this.instantiatedModule.exports.$invokeMain(args);
  }
}
