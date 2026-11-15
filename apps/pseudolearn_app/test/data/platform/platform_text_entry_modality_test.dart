import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/platform/platform_text_entry_modality.dart';

void main() {
  group('PlatformTextEntryModality', () {
    tearDown(() => debugDefaultTargetPlatformOverride = null);

    test('iOS types on screen', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      expect(const PlatformTextEntryModality().hasOnscreenTextEntry, isTrue);
    });

    test('macOS types on a physical keyboard', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

      expect(const PlatformTextEntryModality().hasOnscreenTextEntry, isFalse);
    });

    test('a platform this project does not ship yet is treated as physical', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;

      expect(const PlatformTextEntryModality().hasOnscreenTextEntry, isFalse);
    });
  });
}
