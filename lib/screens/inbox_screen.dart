import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../utils/helpers.dart';

const _kInitialUrl = instaliteInitialUrl;
const _kPhotoChannel = 'InstalitePhotoPicker';
const _kAudioChannel = 'InstaliteAudioRecorder';

const _kUserAgent = instaliteUserAgent;

const _kOnPageLoadJs = r'''
(function() {
  // ---------- photo picker monkeypatch ----------
  if (!window.__instalite_patched__) {
    window.__instalite_patched__ = true;
    var _origClick = HTMLInputElement.prototype.click;
    HTMLInputElement.prototype.click = function() {
      if (this.type === 'file' && this.accept && this.accept.indexOf('image') !== -1) {
        InstalitePhotoPicker.postMessage('pick');
        return;
      }
      if (this.type === 'file' && window.location.pathname.indexOf('/direct/') === 0) {
        InstalitePhotoPicker.postMessage('pick');
        return;
      }
      _origClick.call(this);
    };
  }

  // ---------- audio / mic monkeypatch ----------
  if (!window.__instalite_mic_patched__) {
    window.__instalite_mic_patched__ = true;
    var _origGetUserMedia = navigator.mediaDevices.getUserMedia.bind(navigator.mediaDevices);
    navigator.mediaDevices.getUserMedia = function(constraints) {
      if (constraints && constraints.audio && !constraints.video &&
          window.location.pathname.indexOf('/direct/') === 0) {
        InstaliteAudioRecorder.postMessage('start');
        return new Promise(function() {});
      }
      return _origGetUserMedia(constraints);
    };
  }

  // ---------- feed / reels blocker ----------
  var _profilePath = null;

  function getProfilePath() {
    try {
      var scripts = document.querySelectorAll('script[type="application/json"]');
      for (var i = 0; i < scripts.length; i++) {
        var m = scripts[i].textContent.match(/"username"\s*:\s*"([^"]+)"/);
        if (m) return '/' + m[1] + '/';
      }
    } catch(_) {}
    var all = document.querySelectorAll('a[href^="/"]');
    for (var j = 0; j < all.length; j++) {
      var h = all[j].getAttribute('href');
      if (!h || h.length < 2) continue;
      if (h === '/' || h === '/explore/' || h === '/reels/' || h === '/direct/inbox/') continue;
      if (h.indexOf('/explore') === 0 || h.indexOf('/reels') === 0 ||
          h.indexOf('/direct') === 0  || h.indexOf('/accounts') === 0 ||
          h.indexOf('/p/') === 0       || h.indexOf('/stories') === 0) continue;
      return h.endsWith('/') ? h : h + '/';
    }
    return '/direct/inbox/';
  }

  function isBlockedPath() {
    var p = window.location.pathname;
    return p === '/' || p.indexOf('/reels') === 0;
  }

  function blockAndRedirect() {
    if (!isBlockedPath()) return;
    if (!_profilePath) _profilePath = getProfilePath();
    window.location.replace(_profilePath);
  }

  // ---------- hide Home & Reels ----------

  function injectHideCSS() {
    if (document.getElementById('__instalite_hide_css__')) return;
    var s = document.createElement('style');
    s.id = '__instalite_hide_css__';
    s.textContent =
      'a[href="/"]{display:none!important}' +
      'a[href^="/reels/"]{display:none!important}' +
      '[data-visualcompletion="ignore-dynamic"]>*:has(a[href="/"]){display:none!important}' +
      '[data-visualcompletion="ignore-dynamic"]>*:has(a[href^="/reels/"]){display:none!important}' +
      'nav[role="navigation"]>*:has(a[href="/"]){display:none!important}' +
      'nav[role="navigation"]>*:has(a[href^="/reels/"]){display:none!important}';
    (document.head || document.documentElement).appendChild(s);
  }

  function hideHomeAndReels() {
    var nav = document.querySelector('[data-visualcompletion="ignore-dynamic"]') ||
              document.querySelector('nav[role="navigation"]') ||
              document.querySelector('div[role="tablist"]');
    if (!nav) return;
    var children = nav.children;
    for (var i = 0; i < children.length; i++) {
      var child = children[i];
      if (child.querySelector && child.querySelector('a[href="/"], a[href^="/reels/"]')) {
        child.style.display = 'none';
      }
    }
  }

  function startNavObserver() {
    if (window.__instalite_nav_observer__) {
      window.__instalite_nav_observer__.disconnect();
    }
    var nav = document.querySelector('[data-visualcompletion="ignore-dynamic"]') ||
              document.querySelector('nav[role="navigation"]') ||
              document.querySelector('div[role="tablist"]');
    if (!nav) return;
    window.__instalite_nav_observer__ = new MutationObserver(function() {
      hideHomeAndReels();
      requestAnimationFrame(hideHomeAndReels);
    });
    window.__instalite_nav_observer__.observe(nav, {
      childList: true,
      subtree: true,
    });
  }

  injectHideCSS();
  hideHomeAndReels();
  startNavObserver();

  // Monkeypatch history.pushState (React Router uses this).
  if (!window.__instalite_history_patched__) {
    window.__instalite_history_patched__ = true;

    var _origPush = history.pushState;
    history.pushState = function() {
      _origPush.apply(this, arguments);
      blockAndRedirect();
      hideHomeAndReels();
      startNavObserver();
    };

    var _origReplace = history.replaceState;
    history.replaceState = function() {
      _origReplace.apply(this, arguments);
      blockAndRedirect();
      hideHomeAndReels();
      startNavObserver();
    };

    window.addEventListener('popstate', function() {
      blockAndRedirect();
      hideHomeAndReels();
      startNavObserver();
    });
  }

  blockAndRedirect();
  hideHomeAndReels();
})();
''';

String _injectFileJs(String base64, String mimeType, String fileName) {
  return '''
(function() {
  var inputs = document.querySelectorAll('input[type="file"]');
  var target = null;
  for (var i = 0; i < inputs.length; i++) {
    var a = inputs[i].getAttribute('accept') || '';
    if (a.indexOf('image') !== -1 || a.indexOf('audio') !== -1 || a === '') {
      target = inputs[i];
      if (a !== '') break;
    }
  }
  if (!target && inputs.length > 0) target = inputs[0];
  if (!target) return;

  var raw = Uint8Array.from(atob('$base64'), function(c) { return c.charCodeAt(0); });
  var blob = new Blob([raw], { type: '$mimeType' });
  var file = new File([blob], '$fileName', { type: '$mimeType' });
  var dt = new DataTransfer();
  dt.items.add(file);
  target.files = dt.files;
  target.dispatchEvent(new Event('change', { bubbles: true }));
})();
''';
}

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  late final WebViewController _controller;
  final ImagePicker _picker = ImagePicker();
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _isMicIntercepted = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(_kUserAgent)
      ..addJavaScriptChannel(
        _kPhotoChannel,
        onMessageReceived: (_) => _pickAndSendPhoto(),
      )
      ..addJavaScriptChannel(
        _kAudioChannel,
        onMessageReceived: (msg) {
          if (msg.message == 'start') _startRecordingFromMic();
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => debugPrint('Instalite | loading: $url'),
          onPageFinished: _onPageFinished,
          onWebResourceError: (error) =>
              debugPrint('Instalite | error ${error.errorCode}: ${error.description}'),
          onNavigationRequest: _onNavigationRequest,
        ),
      )
      ..loadRequest(Uri.parse(_kInitialUrl));
  }

  void _onPageFinished(String url) async {
    debugPrint('Instalite | loaded: $url');
    await _controller.runJavaScript(_kOnPageLoadJs);
  }

  Future<NavigationDecision> _onNavigationRequest(
    NavigationRequest request,
  ) async {
    final uri = Uri.parse(request.url);
    if (!uri.host.contains('instagram.com')) return NavigationDecision.navigate;
    if (uri.path == '/' || uri.path.startsWith('/reels')) {
      debugPrint('Instalite | native blocked: ${request.url}');
      _controller.loadRequest(Uri.parse(_kInitialUrl));
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }

  // --- Photo ---

  Future<void> _pickAndSendPhoto() async {
    final xfile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (xfile == null) return;
    await _injectPickedFile(xfile);
  }

  Future<void> _injectPickedFile(XFile xfile) async {
    final bytes = await xfile.readAsBytes();
    final base64 = base64Encode(bytes);
    final mime = mimeTypeForFileName(xfile.name);
    await _controller.runJavaScript(_injectFileJs(base64, mime, xfile.name));
  }

  // --- Audio ---

  Future<void> _startRecordingFromMic() async {
    if (!mounted) return;
    setState(() => _isMicIntercepted = true);
    await _startRecording();
  }

  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) return;
    setState(() => _isRecording = true);
    final tmpDir = Directory.systemTemp.path;
    final fp = '$tmpDir/instalite_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(const RecordConfig(
      encoder: AudioEncoder.aacLc,
      sampleRate: 44100,
    ), path: fp);
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    final path = await _recorder.stop();
    setState(() {
      _isRecording = false;
      _isMicIntercepted = false;
    });
    if (path == null) return;
    final file = XFile(path, mimeType: 'audio/mp4', name: 'voice_note.m4a');
    await _injectPickedFile(file);
  }

  // --- Helpers ---

  Future<void> _handleBackPress() async {
    final canGoBack = await _controller.canGoBack();
    if (canGoBack) {
      _controller.goBack();
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBackPress();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            SafeArea(child: WebViewWidget(controller: _controller)),
            if (_isRecording || _isMicIntercepted) _buildRecordingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingOverlay() {
    return Positioned.fill(
      child: Center(
        child: GestureDetector(
          onTap: _stopRecording,
          child: Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xCCFF0000),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.stop, color: Colors.white, size: 40),
          ),
        ),
      ),
    );
  }
}
