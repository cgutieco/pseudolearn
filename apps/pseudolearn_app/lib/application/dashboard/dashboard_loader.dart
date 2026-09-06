import '../../domain/model/documents/document.dart';
import '../../domain/model/knowledge/ast_construct.dart';
import '../../domain/model/knowledge/content_load_result.dart';
import '../../domain/model/knowledge/knowledge_entry.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/clock.dart';
import '../../domain/ports/document_repository.dart';
import '../../domain/ports/knowledge_repository.dart';
import '../../domain/ports/program_construct_reader.dart';
import '../../domain/ports/progress_history.dart';
import '../../domain/ports/sync_queue.dart';
import 'dashboard_inputs.dart';

final class DashboardLoader {
  final DocumentRepository _documents;
  final KnowledgeRepository _knowledge;
  final ProgressHistory _progressHistory;
  final SyncQueue _syncQueue;
  final ProgramConstructReader _constructReader;
  final Clock _clock;

  const DashboardLoader({
    required DocumentRepository documents,
    required KnowledgeRepository knowledge,
    required ProgressHistory progressHistory,
    required SyncQueue syncQueue,
    required ProgramConstructReader constructReader,
    required Clock clock,
  })  : _documents = documents,
        _knowledge = knowledge,
        _progressHistory = progressHistory,
        _syncQueue = syncQueue,
        _constructReader = constructReader,
        _clock = clock;

  Future<ContentLoadResult<DashboardInputs>> load(UiLanguageId language) async {
    final entriesResult = await _knowledge.getEntries(language);
    if (entriesResult is ContentLoadFailed<List<KnowledgeEntry>>) {
      return ContentLoadFailed(
        failure: entriesResult.failure,
        detail: entriesResult.detail,
      );
    }

    final documents = await _documents.listDocuments();
    return ContentLoaded(DashboardInputs(
      documents: documents,
      constructsByDocument: await _readConstructs(documents),
      entries: (entriesResult as ContentLoaded<List<KnowledgeEntry>>).value,
      progress: await _progressHistory.readEntries(),
      pending: await _syncQueue.pendingEntries(),
      now: _clock.now(),
    ));
  }

  Future<Map<String, Set<AstConstruct>>> _readConstructs(
    List<DocumentSummary> summaries,
  ) async {
    final constructs = <String, Set<AstConstruct>>{};
    for (final summary in summaries) {
      final document = await _documents.loadDocument(summary.id);
      if (document == null) continue;
      constructs[document.id] = _constructReader.constructsOf(
        sourceCode: document.content,
        profileId: document.profileId,
      );
    }
    return constructs;
  }
}
