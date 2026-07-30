import 'package:flutter_test/flutter_test.dart';

import 'package:noinsta/utils/helpers.dart';

void main() {
  group('mimeTypeForFileName', () {
    test('returns image/png for .png files', () {
      expect(mimeTypeForFileName('photo.png'), 'image/png');
      expect(mimeTypeForFileName('PHOTO.PNG'), 'image/png');
    });

    test('returns image/jpeg for .jpg and .jpeg files', () {
      expect(mimeTypeForFileName('photo.jpg'), 'image/jpeg');
      expect(mimeTypeForFileName('photo.jpeg'), 'image/jpeg');
      expect(mimeTypeForFileName('PHOTO.JPG'), 'image/jpeg');
    });

    test('returns image/gif for .gif files', () {
      expect(mimeTypeForFileName('anim.gif'), 'image/gif');
    });

    test('returns image/webp for .webp files', () {
      expect(mimeTypeForFileName('img.webp'), 'image/webp');
    });

    test('returns audio/mp4 for .m4a files', () {
      expect(mimeTypeForFileName('voice.m4a'), 'audio/mp4');
    });

    test('returns audio/mpeg for .mp3 files', () {
      expect(mimeTypeForFileName('song.mp3'), 'audio/mpeg');
    });

    test('returns audio/wav for .wav files', () {
      expect(mimeTypeForFileName('sound.wav'), 'audio/wav');
    });

    test('returns audio/ogg for .ogg files', () {
      expect(mimeTypeForFileName('sound.ogg'), 'audio/ogg');
    });

    test('defaults to image/jpeg for unknown extensions', () {
      expect(mimeTypeForFileName('file.bin'), 'image/jpeg');
      expect(mimeTypeForFileName('file'), 'image/jpeg');
    });
  });

  group('Constants', () {
    test('initialUrl targets Instagram DM inbox', () {
      expect(instaliteInitialUrl, contains('instagram.com'));
      expect(instaliteInitialUrl, contains('direct/inbox'));
    });

    test('userAgent contains Chrome and Android identifiers', () {
      expect(instaliteUserAgent, contains('Chrome'));
      expect(instaliteUserAgent, contains('Android'));
    });
  });
}
