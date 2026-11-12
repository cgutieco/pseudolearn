import '../profiles/syntax_profile_id.dart';
import '../settings/ui_language_id.dart';

final class ReferenceEdition {
  final UiLanguageId language;
  final SyntaxProfileId profile;

  const ReferenceEdition({required this.language, required this.profile});

  String get directory {
    final languageCode = language == UiLanguageId.english ? 'en' : 'es';
    final profileCode = profile == SyntaxProfileId.english ? 'en' : 'es';
    return '$languageCode/$profileCode';
  }

  @override
  bool operator ==(Object other) =>
      other is ReferenceEdition &&
      other.language == language &&
      other.profile == profile;

  @override
  int get hashCode => Object.hash(language, profile);
}
