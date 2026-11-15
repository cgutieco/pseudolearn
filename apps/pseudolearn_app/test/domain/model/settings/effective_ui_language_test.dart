import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/settings/effective_ui_language.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';

void main() {
  group('Effective UI Language Resolution', () {
    test('resolves system setting using device locale code', () {
      expect(
        resolveEffectiveLanguage(
          setting: UiLanguageId.system,
          systemLanguageCode: 'en',
        ),
        UiLanguageId.english,
      );
      expect(
        resolveEffectiveLanguage(
          setting: UiLanguageId.system,
          systemLanguageCode: 'es',
        ),
        UiLanguageId.spanish,
      );
    });

    test('falls back to spanish when system locale is unknown, null or empty', () {
      expect(
        resolveEffectiveLanguage(
          setting: UiLanguageId.system,
          systemLanguageCode: 'fr',
        ),
        UiLanguageId.spanish,
      );
      expect(
        resolveEffectiveLanguage(
          setting: UiLanguageId.system,
          systemLanguageCode: 'de',
        ),
        UiLanguageId.spanish,
      );
      expect(
        resolveEffectiveLanguage(
          setting: UiLanguageId.system,
          systemLanguageCode: null,
        ),
        UiLanguageId.spanish,
      );
      expect(
        resolveEffectiveLanguage(
          setting: UiLanguageId.system,
          systemLanguageCode: '',
        ),
        UiLanguageId.spanish,
      );
    });

    test('respects explicit user setting regardless of device locale', () {
      expect(
        resolveEffectiveLanguage(
          setting: UiLanguageId.spanish,
          systemLanguageCode: 'en',
        ),
        UiLanguageId.spanish,
      );
      expect(
        resolveEffectiveLanguage(
          setting: UiLanguageId.english,
          systemLanguageCode: 'es',
        ),
        UiLanguageId.english,
      );
    });
  });
}
