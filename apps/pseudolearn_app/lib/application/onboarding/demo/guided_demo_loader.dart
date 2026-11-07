import '../../../domain/model/onboarding/guided_demo_source.dart';
import '../../../domain/model/profiles/syntax_profile_id.dart';
import '../../../domain/model/settings/ui_language_id.dart';
import '../../../domain/ports/demo_program_source.dart';

const String _spanishDemoPath = 'guided_demo_es.pseudo';
const String _englishDemoPath = 'guided_demo_en.pseudo';

final class GuidedDemoLoader {
  final DemoProgramSource _source;

  const GuidedDemoLoader({required DemoProgramSource source}) : _source = source;

  Future<GuidedDemoSource?> load(UiLanguageId languageId) async {
    final isEnglish = languageId == UiLanguageId.english;
    try {
      final code = await _source.load(
        isEnglish ? _englishDemoPath : _spanishDemoPath,
      );
      final source = GuidedDemoSource(
        code: code,
        profileId:
            isEnglish ? SyntaxProfileId.english : SyntaxProfileId.classicSpanish,
        languageId: languageId,
      );
      return source.isRunnable ? source : null;
    } catch (_) {
      return null;
    }
  }
}
