import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/route/route_index_state.dart';
import 'package:pseudolearn_app/application/route/route_progress.dart';
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
