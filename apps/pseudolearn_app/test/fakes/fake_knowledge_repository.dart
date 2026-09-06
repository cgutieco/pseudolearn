import 'package:pseudolearn_app/domain/model/knowledge/content_block.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_load_failure.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_load_result.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry.dart';
import 'package:pseudolearn_app/domain/model/knowledge/learning_module.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/domain/ports/knowledge_repository.dart';

base class FakeKnowledgeRepository implements KnowledgeRepository {
  List<KnowledgeEntry> entries;
  Map<String, List<ContentBlock>> blocksByPath;
  Map<String, String> rawContentByPath;
  Map<String, Exercise> exercisesByPath;
  Map<String, LearningModule> modulesByEntryId;
  bool shouldThrow;

  FakeKnowledgeRepository({
    this.entries = const [],
    this.blocksByPath = const {},
    this.rawContentByPath = const {},
    this.exercisesByPath = const {},
    this.modulesByEntryId = const {},
    this.shouldThrow = false,
  });

  @override
  Future<ContentLoadResult<List<KnowledgeEntry>>> getEntries(
    UiLanguageId language,
  ) async {
    if (shouldThrow) throw Exception('Repository error');
    return ContentLoaded(entries);
  }

  @override
  Future<ContentLoadResult<List<ContentBlock>>> getDocumentBlocks({
    required String path,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) async {
    if (shouldThrow) throw Exception('Failed to load blocks');
    final blocks = blocksByPath[path];
    if (blocks == null) {
      return ContentLoadFailed(
        failure: ContentLoadFailure.assetMissing,
        detail: path,
      );
    }
    return ContentLoaded(blocks);
  }

  @override
  Future<ContentLoadResult<LearningModule>> getModule({
    required KnowledgeEntry entry,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) async {
    if (shouldThrow) throw Exception('Failed to load module');
    final module = modulesByEntryId[entry.id];
    if (module == null) {
      return ContentLoadFailed(
        failure: ContentLoadFailure.assetMissing,
        detail: entry.id,
      );
    }
    return ContentLoaded(module);
  }

  @override
  Future<ContentLoadResult<Exercise>> getExercise(String path) async {
    if (shouldThrow) throw Exception('Failed to load exercise');
    final exercise = exercisesByPath[path];
    if (exercise == null) {
      return ContentLoadFailed(
        failure: ContentLoadFailure.assetMissing,
        detail: path,
      );
    }
    return ContentLoaded(exercise);
  }

  @override
  Future<String> getRawContent(String path) async {
    if (shouldThrow) throw Exception('Failed to load raw content');
    return rawContentByPath[path] ?? '';
  }
}

final class FailingKnowledgeRepository extends FakeKnowledgeRepository {
  @override
  Future<ContentLoadResult<List<KnowledgeEntry>>> getEntries(
    UiLanguageId language,
  ) async {
    return const ContentLoadFailed(
      failure: ContentLoadFailure.malformedManifest,
      detail: 'manifest_es.json',
    );
  }
}
