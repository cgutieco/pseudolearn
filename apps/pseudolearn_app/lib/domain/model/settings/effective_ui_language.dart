import 'ui_language_id.dart';

UiLanguageId resolveEffectiveLanguage({
  required UiLanguageId setting,
  String? systemLanguageCode,
}) {
  final code = setting.resolveLocaleCode(systemLanguageCode);
  return code == 'en' ? UiLanguageId.english : UiLanguageId.spanish;
}
