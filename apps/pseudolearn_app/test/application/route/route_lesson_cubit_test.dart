import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/route/route_lesson_cubit.dart';
import 'package:pseudolearn_app/application/route/route_lesson_state.dart';
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
  test('loads the lesson, its exercises and marks it as visited', () async {
    final store = InMemoryLocalProgressStore();
    await store.markExerciseCompleted(routeExerciseProgressId('inicio.primero.a'));
    final cubit = RouteLessonCubit(
      repository: FakeRouteRepository(
        toc: sampleToc,
        lessons: {'inicio.primero': sampleLesson('inicio.primero')},
      ),
      progressStore: store,
    );

    await cubit.load(_edition, 'inicio.primero');

    expect(cubit.state.status, RouteLessonStatus.success);
    expect(cubit.state.exercises.length, 3);
    expect(cubit.state.completedExerciseIds, {'inicio.primero.a'});
    expect(cubit.state.exercise('inicio.primero.b')?.kind, RouteExerciseKind.predict);
    expect(cubit.state.exercise('nada'), isNull);
    expect(await store.isModuleVisited(routeLessonProgressId('inicio.primero')), isTrue);
  });

  test('an unknown lesson is not found and is not marked', () async {
    final store = InMemoryLocalProgressStore();
    final cubit = RouteLessonCubit(repository: FakeRouteRepository(), progressStore: store);

    await cubit.load(_edition, 'nada');

    expect(cubit.state.status, RouteLessonStatus.notFound);
    expect(await store.isModuleVisited(routeLessonProgressId('nada')), isFalse);
  });

  test('a lesson without index entry still opens with no exercises', () async {
    final cubit = RouteLessonCubit(
      repository: FakeRouteRepository(lessons: {'x': sampleLesson('x')}, failToc: true),
      progressStore: InMemoryLocalProgressStore(),
    );

    await cubit.load(_edition, 'x');

    expect(cubit.state.status, RouteLessonStatus.success);
    expect(cubit.state.exercises, isEmpty);
  });
}
