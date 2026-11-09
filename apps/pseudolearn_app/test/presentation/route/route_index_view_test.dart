import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/route/route_index_state.dart';
import 'package:pseudolearn_app/application/route/route_progress.dart';
import 'package:pseudolearn_app/domain/model/dashboard/coverage_count.dart';
import 'package:pseudolearn_app/presentation/route/route_index_view.dart';
import '../../fakes/route_fixtures.dart';
import 'route_widget_support.dart';

void main() {
  testWidgets('lists parts and lessons with their progress', (tester) async {
    final opened = <String>[];
    await tester.pumpWidget(routeTestApp(RouteIndexView(
        state: RouteIndexState(
          status: RouteIndexStatus.success,
          toc: sampleToc,
          lessonProgress: const {'inicio.primero': LessonProgress.completed},
          nextLessonId: 'imperativo.segundo',
        ),
        onOpenLesson: opened.add,
        onRetry: () {},
      )));
    await tester.pumpAndSettle();

    expect(find.text('0 · Empezar de cero'), findsOneWidget);
    expect(find.textContaining('Completada'), findsOneWidget);
    expect(find.textContaining('Sigue esta'), findsOneWidget);
    await tester.tap(find.text('imperativo.segundo · Lección imperativo.segundo'));
    expect(opened, ['imperativo.segundo']);
  });

  testWidgets('an unfinished lesson shows its required exercises and a completed one does not', (tester) async {
    await tester.pumpWidget(routeTestApp(RouteIndexView(
        state: RouteIndexState(
          status: RouteIndexStatus.success,
          toc: sampleToc,
          lessonProgress: const {
            'inicio.primero': LessonProgress.completed,
            'imperativo.segundo': LessonProgress.visited,
          },
          requiredExercises: const {
            'inicio.primero': CoverageCount(done: 2, total: 2),
            'imperativo.segundo': CoverageCount(done: 0, total: 1),
          },
          nextLessonId: 'imperativo.segundo',
        ),
        onOpenLesson: (_) {},
        onRetry: () {},
      )));
    await tester.pumpAndSettle();

    expect(find.textContaining('En curso · Obligatorios resueltos: 0 de 1'), findsOneWidget);
    expect(find.textContaining('Obligatorios resueltos: 2 de 2'), findsNothing);
  });

  testWidgets('a lesson without required exercises shows no requirement', (tester) async {
    await tester.pumpWidget(routeTestApp(RouteIndexView(
        state: RouteIndexState(status: RouteIndexStatus.success, toc: sampleToc),
        onOpenLesson: (_) {},
        onRetry: () {},
      )));
    await tester.pumpAndSettle();

    expect(find.textContaining('Obligatorios resueltos'), findsNothing);
  });

  testWidgets('states the rule that completes a lesson above the parts', (tester) async {
    await tester.pumpWidget(routeTestApp(RouteIndexView(
        state: RouteIndexState(status: RouteIndexStatus.success, toc: sampleToc),
        onOpenLesson: (_) {},
        onRetry: () {},
      )));
    await tester.pumpAndSettle();

    expect(find.textContaining('Una lección se completa cuando resuelves todos sus ejercicios obligatorios'), findsOneWidget);
  });

  testWidgets('the completion rule is not shown while the route fails to load', (tester) async {
    await tester.pumpWidget(routeTestApp(RouteIndexView(
      state: const RouteIndexState(status: RouteIndexStatus.error),
      onOpenLesson: (_) {},
      onRetry: () {},
    )));
    await tester.pumpAndSettle();

    expect(find.textContaining('Una lección se completa'), findsNothing);
  });

  testWidgets('an error offers a retry', (tester) async {
    var retried = false;
    await tester.pumpWidget(routeTestApp(RouteIndexView(
      state: const RouteIndexState(status: RouteIndexStatus.error),
      onOpenLesson: (_) {},
      onRetry: () => retried = true,
    )));
    await tester.pumpAndSettle();

    expect(find.text('No se pudo cargar la ruta'), findsOneWidget);
    await tester.tap(find.text('Reintentar'));
    expect(retried, isTrue);
  });
}
