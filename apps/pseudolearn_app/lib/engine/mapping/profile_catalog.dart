import 'package:pseudolearn_core/pseudolearn_core.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/settings/ui_language_id.dart';

final class ProfileCatalog {
  const ProfileCatalog._();

  static LanguageProfile toLanguageProfile(SyntaxProfileId profileId) {
    return switch (profileId) {
      SyntaxProfileId.classicSpanish => const ClassicSpanishProfile.flexible(),
      SyntaxProfileId.english => const EnglishProfile.flexible(),
    };
  }

  static DiagnosticLocale toDiagnosticLocale(UiLanguageId languageId) {
    return switch (languageId) {
      UiLanguageId.spanish => DiagnosticLocale.es,
      UiLanguageId.english => DiagnosticLocale.en,
      UiLanguageId.system => DiagnosticLocale.es,
    };
  }
}
