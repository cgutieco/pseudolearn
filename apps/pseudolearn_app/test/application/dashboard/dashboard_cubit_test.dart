import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/dashboard/dashboard_cubit.dart';
import 'package:pseudolearn_app/application/dashboard/dashboard_loader.dart';
import 'package:pseudolearn_app/application/dashboard/dashboard_state.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_load_result.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_edition.dart';
import 'package:pseudolearn_app/domain/model/route/route_kinds.dart';
import 'package:pseudolearn_app/domain/model/route/route_toc.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import '../../fakes/fake_clock.dart';
import '../../fakes/fake_program_construct_reader.dart';
import '../../fakes/fake_reference_repository.dart';
import '../../fakes/fake_route_repository.dart';
import '../../fakes/fake_sync_queue.dart';
import '../../fakes/in_memory_document_repository.dart';
import '../../fakes/in_memory_progress_history.dart';
import '../../fakes/route_fixtures.dart';
import 'dashboard_fixtures.dart';

final class _ThrowingRouteRepository extends FakeRouteRepository {
  @override
  Future<ContentLoadResult<RouteToc>> loadToc(ReferenceEdition edition) =>
      throw StateError('broken bundle');
}

DashboardCubit _cubitWith(FakeRouteRepository route) {
  return DashboardCubit(
    loader: DashboardLoader(
      documents: InMemoryDocumentRepository(),
      route: route,
      reference: FakeReferenceRepository(index: sampleIndex()),
      progressHistory: InMemoryProgressHistory(
        entries: [
          visitedEntry(routeLessonProgressId('inicio.primero'), at: DateTime(2026, 9, 1)),
          completedEntry(routeExerciseProgressId('inicio.primero.a'), at: DateTime(2026, 9, 1)),
          completedEntry(routeExerciseProgressId('inicio.primero.b'), at: DateTime(2026, 9, 1)),
        ],
      ),
      syncQueue: FakeSyncQueue(),
      constructReader: FakeProgramConstructReader(),
      clock: FakeClock(DateTime(2026, 9, 2, 12)),
    ),
  );
}

void main() {
  group('DashboardCubit', () {
    test('starts in its initial state without reading anything', () {
      final cubit = _cubitWith(FakeRouteRepository());

      expect(cubit.state.status, DashboardStatus.initial);
      expect(cubit.state.library.total, 0);
    });

    test('publishes a success state built from local data alone', () async {
      final cubit = _cubitWith(FakeRouteRepository(toc: sampleToc));

      await cubit.load(UiLanguageId.spanish);

      expect(cubit.state.status, DashboardStatus.success);
      expect(cubit.state.route.first.lessons.done, 1);
      expect(cubit.state.nextLesson?.id, 'imperativo.segundo');
    });

    test('a missing route bundle becomes an error state', () async {
      final cubit = _cubitWith(FakeRouteRepository(failToc: true));

      await cubit.load(UiLanguageId.spanish);

      expect(cubit.state.status, DashboardStatus.error);
      expect(cubit.state.errorMessage, 'route');
    });

    test('an exception from the ports never escapes the cubit', () async {
      final cubit = _cubitWith(_ThrowingRouteRepository());

      await cubit.load(UiLanguageId.spanish);

      expect(cubit.state.status, DashboardStatus.error);
      expect(cubit.state.errorMessage, isNotNull);
    });

    test('loading twice replaces the state instead of accumulating', () async {
      final cubit = _cubitWith(FakeRouteRepository(toc: sampleToc));

      await cubit.load(UiLanguageId.spanish);
      await cubit.load(UiLanguageId.spanish);

      expect(cubit.state.route.first.lessons.done, 1);
      expect(cubit.state.route.first.lessons.total, 1);
    });
  });
}
