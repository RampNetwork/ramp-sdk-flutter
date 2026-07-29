import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ramp_flutter/src/android_file_selector.dart';

void main() {
  group('fileTypeForAcceptTypes', () {
    test('defaults to any when empty', () {
      expect(fileTypeForAcceptTypes(const []), FileType.any);
    });

    test('maps image and video mime families', () {
      expect(fileTypeForAcceptTypes(const ['image/png', 'image/jpeg']), FileType.image);
      expect(fileTypeForAcceptTypes(const ['video/mp4']), FileType.video);
    });

    test('maps extension and pdf accepts to custom', () {
      expect(fileTypeForAcceptTypes(const ['.pdf', 'application/pdf']), FileType.custom);
      expect(fileTypeForAcceptTypes(const ['.png', '.jpg']), FileType.custom);
    });

    test('falls back to any for mixed or unknown accepts', () {
      expect(fileTypeForAcceptTypes(const ['image/png', 'application/pdf']), FileType.any);
      expect(fileTypeForAcceptTypes(const ['application/json']), FileType.any);
    });
  });

  group('extensionsForAcceptTypes', () {
    test('extracts dotted extensions and pdf', () {
      expect(extensionsForAcceptTypes(const ['.PNG', 'application/pdf', ' .jpg ']), ['png', 'pdf', 'jpg']);
    });

    test('returns null when nothing maps to an extension', () {
      expect(extensionsForAcceptTypes(const ['image/png', 'video/mp4']), isNull);
      expect(extensionsForAcceptTypes(const []), isNull);
    });
  });
}
