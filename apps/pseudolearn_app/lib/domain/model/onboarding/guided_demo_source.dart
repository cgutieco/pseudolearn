import '../profiles/syntax_profile_id.dart';
import '../settings/ui_language_id.dart';

final class GuidedDemoSource {
  final String code;
  final SyntaxProfileId profileId;
  final UiLanguageId languageId;

  const GuidedDemoSource({
    required this.code,
    required this.profileId,
    required this.languageId,
  });

  bool get isRunnable => code.trim().isNotEmpty;
}
