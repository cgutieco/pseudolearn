import '../../../domain/model/onboarding/guided_demo_source.dart';
import '../../../domain/model/profiles/syntax_profile_id.dart';
import '../../../domain/model/settings/ui_language_id.dart';
import '../../../domain/ports/knowledge_repository.dart';

const String _spanishDemoPath = 'examples/guided_demo_es.pseudo';
const String _englishDemoPath = 'examples/guided_demo_en.pseudo';

final class GuidedDemoLoader {
  final KnowledgeRepository _repository;

  const GuidedDemoLoader({required KnowledgeRepository repository})
      : _repository = repository;

  Future<GuidedDemoSource?> load(UiLanguageId languageId) async {
    final isEnglish = languageId == UiLanguageId.english;
    try {
      final code = await _repository.getRawContent(
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
