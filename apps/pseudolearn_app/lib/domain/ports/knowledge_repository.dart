import '../model/knowledge/content_block.dart';
import '../model/knowledge/content_load_result.dart';
import '../model/knowledge/exercise.dart';
import '../model/knowledge/knowledge_entry.dart';
import '../model/knowledge/learning_module.dart';
import '../model/profiles/syntax_profile_id.dart';
import '../model/settings/ui_language_id.dart';

abstract interface class KnowledgeRepository {
  Future<ContentLoadResult<List<KnowledgeEntry>>> getEntries(
    UiLanguageId language,
  );

  Future<ContentLoadResult<List<ContentBlock>>> getDocumentBlocks({
    required String path,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  });

  Future<ContentLoadResult<LearningModule>> getModule({
    required KnowledgeEntry entry,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  });

  Future<ContentLoadResult<Exercise>> getExercise(String path);

  Future<String> getRawContent(String path);
}
