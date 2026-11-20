import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/settings/ui_language_id.dart';

final class CompanionSource {
  final String sourceCode;
  final SyntaxProfileId profileId;
  final UiLanguageId languageId;

  const CompanionSource({
    required this.sourceCode,
    required this.profileId,
    required this.languageId,
  });
}
