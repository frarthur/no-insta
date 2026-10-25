import 'package:flutter/foundation.dart';

/// Returns a MIME type string for the given file name based on its extension.
String mimeTypeForFileName(String name) {
  final lower = name.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.gif')) return 'image/gif';
  if (lower.endsWith('.webp')) return 'image/webp';
  if (lower.endsWith('.m4a')) return 'audio/mp4';
  if (lower.endsWith('.mp3')) return 'audio/mpeg';
  if (lower.endsWith('.wav')) return 'audio/wav';
  if (lower.endsWith('.ogg')) return 'audio/ogg';
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
  return 'image/jpeg';
}

/// Instagram DM inbox URL loaded on startup.
const instaliteInitialUrl = 'https://www.instagram.com/direct/inbox/';

/// Android mobile user-agent so Instagram serves the mobile-optimized UI.
const instaliteUserAgent =
    'Mozilla/5.0 (Linux; Android 14; Pixel 8) '
    'AppleWebKit/537.36 (KHTML, like Gecko) '
    'Chrome/120.0.0.0 Mobile Safari/537.36';

/// iOS Safari user-agent.
///
/// WKWebView runs on WebKit, not Blink: announcing an Android Chrome UA makes
/// Instagram serve markup that relies on Chrome-only behaviour (and trips its
/// "unsupported browser" heuristics), so iOS gets its own UA.
const instaliteUserAgentIos =
    'Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) '
    'AppleWebKit/605.1.15 (KHTML, like Gecko) '
    'Version/17.5 Mobile/15E148 Safari/604.1';

/// Returns the user-agent matching [platform].
String instaliteUserAgentFor(TargetPlatform platform) =>
    platform == TargetPlatform.iOS ? instaliteUserAgentIos : instaliteUserAgent;
