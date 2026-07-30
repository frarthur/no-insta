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

/// Mobile user-agent so Instagram serves the mobile-optimized UI.
const instaliteUserAgent =
    'Mozilla/5.0 (Linux; Android 14; Pixel 8) '
    'AppleWebKit/537.36 (KHTML, like Gecko) '
    'Chrome/120.0.0.0 Mobile Safari/537.36';
