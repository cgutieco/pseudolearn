import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/dashboard/dashboard_cubit.dart';
import 'package:pseudolearn_app/application/dashboard/dashboard_loader.dart';
import 'package:pseudolearn_app/application/dashboard/dashboard_state.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_load_failure.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_load_result.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry.dart';
import 'package:pseudolearn_app/domain/model/knowledge/learning_track.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import '../../fakes/fake_clock.dart';
import '../../fakes/fake_knowledge_repository.dart';
import '../../fakes/fake_program_construct_reader.dart';
import '../../fakes/fake_sync_queue.dart';
import '../../fakes/in_memory_document_repository.dart';
import '../../fakes/in_memory_progress_history.dart';
import 'dashboard_fixtures.dart';

final class _BrokenManifestRepository extends FakeKnowledgeRepository {
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

DashboardCubit _cubitWith(FakeKnowledgeRepository knowledge) {
  return DashboardCubit(
    loader: DashboardLoader(
      documents: InMemoryDocumentRepository(),
      knowledge: knowledge,
      progressHistory: InMemoryProgressHistory(
        entries: [visitedEntry('CON-A1', at: DateTime(2026, 9, 1))],
      ),
      syncQueue: FakeSyncQueue(),
      constructReader: FakeProgramConstructReader(),
      clock: FakeClock(DateTime(2026, 9, 2, 12)),
    ),
  );
}

void main() {
  group('DashboardCubit (PANT-06-F5)', () {
    test('starts in its initial state without reading anything', () {
      final cubit = _cubitWith(FakeKnowledgeRepository());

      expect(cubit.state.status, DashboardStatus.initial);
      expect(cubit.state.library.total, 0);
    });

    test('publishes a success state built from local data alone', () async {
      final cubit = _cubitWith(FakeKnowledgeRepository(entries: [
        moduleEntry('CON-A1', track: LearningTrack.foundations, order: 1),
        moduleEntry('CON-A2', track: LearningTrack.foundations, order: 2),
      ]));

      await cubit.load(UiLanguageId.spanish);

      expect(cubit.state.status, DashboardStatus.success);
      expect(cubit.state.route.first.modules.done, 1);
      expect(cubit.state.nextModule?.id, 'CON-A2');
    });

    test('a malformed manifest becomes an error state, not an exception', () async {
      final cubit = _cubitWith(_BrokenManifestRepository());

      await cubit.load(UiLanguageId.spanish);

      expect(cubit.state.status, DashboardStatus.error);
      expect(cubit.state.errorMessage, 'manifest_es.json');
    });

    test('an exception from the ports never escapes the cubit', () async {
      final cubit = _cubitWith(FakeKnowledgeRepository(shouldThrow: true));

      await cubit.load(UiLanguageId.spanish);

      expect(cubit.state.status, DashboardStatus.error);
      expect(cubit.state.errorMessage, isNotNull);
    });

    test('loading twice replaces the state instead of accumulating', () async {
      final cubit = _cubitWith(FakeKnowledgeRepository(entries: [
        moduleEntry('CON-A1', track: LearningTrack.foundations, order: 1),
      ]));

      await cubit.load(UiLanguageId.spanish);
      await cubit.load(UiLanguageId.spanish);

      expect(cubit.state.route.first.modules.done, 1);
      expect(cubit.state.route.first.modules.total, 1);
    });
  });
}
