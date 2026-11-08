import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pseudolearn_app/composition/cubit_scope.dart';
import 'package:pseudolearn_app/domain/model/exercises/exercise_reference.dart';
import '../../fakes/fake_identifier_generator.dart';
import '../../fakes/in_memory_document_repository.dart';
import '../../fakes/in_memory_user_exercise_repository.dart';
import '../../fakes/test_dependencies.dart';
import '../../fakes/user_exercise_fixtures.dart';

Future<void> _go(WidgetTester tester, String location) async {
  GoRouter.of(tester.element(find.byType(Navigator).first)).go(location);
  await tester.pumpAndSettle();
}

Future<void> _type(WidgetTester tester, String name, String text) async {
  final field = find.byKey(ValueKey('user-exercise-field:$name'));
  await tester.ensureVisible(field);
  await tester.enterText(find.descendant(of: field, matching: find.byType(TextField)), text);
}

void main() {
  testWidgets('the library lists user exercises and solving opens an attempt', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final exercises = InMemoryUserExerciseRepository()..exercises['ux-1'] = sumExercise();
    final documents = InMemoryDocumentRepository();
    await tester.pumpWidget(CubitScope(
      dependencies: buildTestDependencies(
        repository: documents,
        userExerciseRepository: exercises,
        identifiers: FakeIdentifierGenerator(['attempt-1']),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('feature:user-exercises')), findsOneWidget);
    expect(find.text(sumDraft().title), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('user-exercise-solve:ux-1')));
    await tester.pumpAndSettle();
    final attempt = documents.documents['attempt-1']!;
    expect(ExerciseReference.parse(attempt.exerciseId!), const ExerciseReference.user('ux-1'));
  });

  testWidgets('an invalid draft is not published and the problem is shown', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final exercises = InMemoryUserExerciseRepository();
    await tester.pumpWidget(CubitScope(
      dependencies: buildTestDependencies(userExerciseRepository: exercises),
    ));
    await tester.pumpAndSettle();
    await _go(tester, '/biblioteca/ejercicio/nuevo');
    expect(find.byKey(const ValueKey('feature:user-exercise-editor')), findsOneWidget);
    await _type(tester, 'title', 'Suma');
    await _type(tester, 'statement', 'Suma dos enteros');
    await _type(tester, 'visibleCases', '2; 3 => 5');
    await tester.ensureVisible(find.byKey(const ValueKey('user-exercise-publish')));
    await tester.tap(find.byKey(const ValueKey('user-exercise-publish')));
    await tester.pumpAndSettle();
    expect(find.textContaining('reference solution'), findsOneWidget);
    expect(exercises.exercises, isEmpty);
  });

  testWidgets('a malformed case line is reported before validating', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(CubitScope(dependencies: buildTestDependencies()));
    await tester.pumpAndSettle();
    await _go(tester, '/biblioteca/ejercicio/nuevo');
    await _type(tester, 'visibleCases', '2; 3');
    await tester.ensureVisible(find.byKey(const ValueKey('user-exercise-publish')));
    await tester.tap(find.byKey(const ValueKey('user-exercise-publish')));
    await tester.pumpAndSettle();
    expect(find.textContaining('case format'), findsOneWidget);
  });

  testWidgets('a valid draft is published and listed', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final exercises = InMemoryUserExerciseRepository();
    await tester.pumpWidget(CubitScope(
      dependencies: buildTestDependencies(
        userExerciseRepository: exercises,
        identifiers: FakeIdentifierGenerator(['ux-new']),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('feature:user-exercise-create')));
    await tester.pumpAndSettle();
    await _type(tester, 'title', 'Suma');
    await _type(tester, 'statement', 'Suma dos enteros');
    await _type(tester, 'visibleCases', '2; 3 => 5');
    await _type(tester, 'solution', sumSolution);
    await tester.ensureVisible(find.byKey(const ValueKey('user-exercise-publish')));
    await tester.tap(find.byKey(const ValueKey('user-exercise-publish')));
    await tester.pumpAndSettle();
    expect(exercises.exercises.keys, ['ux-new']);
    expect(find.text('Suma'), findsWidgets);
  });
}
