import '../../domain/model/documents/document.dart';
import '../../domain/model/knowledge/ast_construct.dart';
import '../../domain/model/knowledge/content_load_failure.dart';
import '../../domain/model/knowledge/content_load_result.dart';
import '../../domain/model/profiles/syntax_profile_for_language.dart';
import '../../domain/model/reference/reference_edition.dart';
import '../../domain/model/reference/reference_index.dart';
import '../../domain/model/route/route_toc.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/clock.dart';
import '../../domain/ports/document_repository.dart';
import '../../domain/ports/reference_repository.dart';
import '../../domain/ports/route_repository.dart';
import '../../domain/ports/program_construct_reader.dart';
import '../../domain/ports/progress_history.dart';
import '../../domain/ports/sync_queue.dart';
import 'dashboard_inputs.dart';

final class DashboardLoader {
  final DocumentRepository _documents;
  final RouteRepository _route;
  final ReferenceRepository _reference;
  final ProgressHistory _progressHistory;
  final SyncQueue _syncQueue;
  final ProgramConstructReader _constructReader;
  final Clock _clock;

  const DashboardLoader({
    required this._documents,
    required this._route,
    required this._reference,
    required this._progressHistory,
    required this._syncQueue,
    required this._constructReader,
    required this._clock,
  });

  Future<ContentLoadResult<DashboardInputs>> load(UiLanguageId language) async {
    final edition = ReferenceEdition(
      language: language,
      profile: syntaxProfileForLanguage(language),
    );
    final toc = await _route.loadToc(edition);
    if (toc is! ContentLoaded<RouteToc>) {
      return const ContentLoadFailed(
        failure: ContentLoadFailure.malformedRoute,
        detail: 'route',
      );
    }
    final index = await _reference.loadIndex(edition);
    final documents = await _documents.listDocuments();
    return ContentLoaded(DashboardInputs(
      documents: documents,
      constructsByDocument: await _readConstructs(documents),
      toc: toc.value,
      specificationSections:
          index is ContentLoaded<ReferenceIndex> ? index.value.sections : const [],
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
