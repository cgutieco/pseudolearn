import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/route/route_kinds.dart';
import 'package:pseudolearn_app/presentation/route/blocks/practice_view.dart';
import 'package:pseudolearn_app/presentation/route/lesson_scope.dart';
import '../../../fakes/route_fixtures.dart';
import '../route_widget_support.dart';

LessonScope _scopeWith(List<bool> required) => LessonScope(
  edition: routeTestEdition,
  onOpenLink: (_) {},
  onOpenExercise: (_) {},
  exercises: [
    for (final (index, isRequired) in required.indexed)
      exerciseEntry('ejercicio-$index', required: isRequired, kind: RouteExerciseKind.solve),
  ],
);

void main() {
  testWidgets('explains that the required exercises complete the lesson', (tester) async {
    await tester.pumpWidget(routeTestApp(PracticeView(ids: const ['ejercicio-0', 'ejercicio-1'], scope: _scopeWith([true, false]))));
    await tester.pumpAndSettle();

    expect(find.textContaining('para completar esta lección'), findsOneWidget);
    expect(find.textContaining('Obligatorio'), findsWidgets);
  });

  testWidgets('a practice without required exercises shows no completion notice', (tester) async {
    await tester.pumpWidget(routeTestApp(PracticeView(ids: const ['ejercicio-0'], scope: _scopeWith([false]))));
    await tester.pumpAndSettle();

    expect(find.textContaining('para completar esta lección'), findsNothing);
  });

  testWidgets('an empty practice renders neither notice nor tiles', (tester) async {
    await tester.pumpWidget(routeTestApp(PracticeView(ids: const [], scope: _scopeWith([]))));
    await tester.pumpAndSettle();

    expect(find.byType(PracticeRequiredHint), findsNothing);
    expect(find.byType(PracticeTile), findsNothing);
  });
}
