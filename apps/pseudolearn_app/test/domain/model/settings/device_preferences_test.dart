import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/settings/device_preferences.dart';

void main() {
  group('DevicePreferences', () {
    test('defaults have expected initial values', () {
      const prefs = DevicePreferences.defaults();
      expect(prefs.editorFontSize, equals(14.0));
      expect(prefs.showLineNumbers, isTrue);
      expect(prefs.showIndentGuides, isTrue);
      expect(prefs.hasSeenOnboarding, isFalse);
    });

    test('copyWith updates selected fields correctly', () {
      const initial = DevicePreferences.defaults();
      final updated = initial.copyWith(
        editorFontSize: 18.0,
        hasSeenOnboarding: true,
      );
      expect(updated.editorFontSize, equals(18.0));
      expect(updated.showLineNumbers, isTrue);
      expect(updated.showIndentGuides, isTrue);
      expect(updated.hasSeenOnboarding, isTrue);
    });

    test('serializes and deserializes cleanly via JSON', () {
      const original = DevicePreferences(
        editorFontSize: 16.5,
        showLineNumbers: false,
        showIndentGuides: false,
        hasSeenOnboarding: true,
      );
      final json = original.toJson();
      final restored = DevicePreferences.fromJson(json);

      expect(restored, equals(original));
      expect(restored.hashCode, equals(original.hashCode));
    });

    test('fromJson falls back to defaults for missing fields', () {
      final restored = DevicePreferences.fromJson(const {});
      expect(restored.editorFontSize, equals(14.0));
      expect(restored.showLineNumbers, isTrue);
      expect(restored.showIndentGuides, isTrue);
      expect(restored.hasSeenOnboarding, isFalse);
    });

    test('equality compares structural field values', () {
      const a = DevicePreferences(
        editorFontSize: 14.0,
        showLineNumbers: true,
        showIndentGuides: true,
        hasSeenOnboarding: false,
      );
      const b = DevicePreferences(
        editorFontSize: 14.0,
        showLineNumbers: true,
        showIndentGuides: true,
        hasSeenOnboarding: false,
      );
      const c = DevicePreferences(
        editorFontSize: 16.0,
        showLineNumbers: true,
        showIndentGuides: true,
        hasSeenOnboarding: false,
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}
