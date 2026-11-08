import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/route/route_index_cubit.dart';
import 'package:pseudolearn_app/application/route/route_index_state.dart';
import 'package:pseudolearn_app/application/route/route_progress.dart';
import 'package:pseudolearn_app/domain/model/dashboard/coverage_count.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_edition.dart';
import 'package:pseudolearn_app/domain/model/route/route_kinds.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import '../../fakes/fake_route_repository.dart';
import '../../fakes/in_memory_local_progress_store.dart';
import '../../fakes/route_fixtures.dart';

const ReferenceEdition _edition = ReferenceEdition(
  language: UiLanguageId.spanish,
  profile: SyntaxProfileId.classicSpanish,
);

void main() {
  test('loads the parts and the progress of every lesson', () async {
    final store = InMemoryLocalProgressStore();
    await store.markModuleVisited(routeLessonProgressId('inicio.primero'));
    final cubit = RouteIndexCubit(repository: FakeRouteRepository(toc: sampleToc), progressStore: store);

    await cubit.load(_edition);

    expect(cubit.state.status, RouteIndexStatus.success);
    expect(cubit.state.toc.parts.length, 2);
    expect(cubit.state.progressOf('inicio.primero'), LessonProgress.visited);
    expect(cubit.state.progressOf('imperativo.segundo'), LessonProgress.notStarted);
    expect(cubit.state.nextLessonId, 'inicio.primero');
  });

  test('carries the solved required exercises of every lesson', () async {
    final store = InMemoryLocalProgressStore();
    await store.markExerciseCompleted(routeExerciseProgressId('inicio.primero.a'));
    final cubit = RouteIndexCubit(repository: FakeRouteRepository(toc: sampleToc), progressStore: store);

    await cubit.load(_edition);

    expect(cubit.state.requiredOf('inicio.primero'), const CoverageCount(done: 1, total: 2));
    expect(cubit.state.requiredOf('imperativo.segundo'), const CoverageCount(done: 0, total: 1));
    expect(cubit.state.requiredOf('unknown'), const CoverageCount.empty());
  });

  test('a missing bundle is an error state', () async {
    final cubit = RouteIndexCubit(
      repository: FakeRouteRepository(failToc: true),
      progressStore: InMemoryLocalProgressStore(),
    );

    await cubit.load(_edition);

    expect(cubit.state.status, RouteIndexStatus.error);
    expect(cubit.state.toc.lessons, isEmpty);
  });

  test('refresh reloads the last edition and does nothing before a load', () async {
    final repository = FakeRouteRepository(toc: sampleToc);
    final cubit = RouteIndexCubit(repository: repository, progressStore: InMemoryLocalProgressStore());

    await cubit.refresh();
    expect(repository.requestedEditions, isEmpty);

    await cubit.load(_edition);
    await cubit.refresh();
    expect(repository.requestedEditions.length, 2);
  });
}
