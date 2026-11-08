import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pseudolearn_app/composition/cubit_scope.dart';
import 'package:pseudolearn_app/domain/model/exercises/exercise_reference.dart';
import 'package:pseudolearn_app/presentation/components/button/app_button.dart';
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

Future<void> _openExercisesTab(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('feature:user-exercises')));
  await tester.pumpAndSettle();
}

Future<InMemoryUserExerciseRepository> _pumpLibrary(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1200, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final exercises = InMemoryUserExerciseRepository()..exercises['ux-1'] = sumExercise();
  await tester.pumpWidget(CubitScope(
    dependencies: buildTestDependencies(userExerciseRepository: exercises),
  ));
  await tester.pumpAndSettle();
  await _openExercisesTab(tester);
  return exercises;
}

Future<void> _openMenu(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('user-exercise-menu:ux-1')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the exercise card summarises the statement, cases and hints', (tester) async {
    await _pumpLibrary(tester);
    final card = find.byKey(const ValueKey('user-exercise:ux-1'));
    expect(find.descendant(of: card, matching: find.text(sumDraft().statement)), findsOneWidget);
    expect(find.descendant(of: card, matching: find.text('2 test cases')), findsOneWidget);
    expect(find.descendant(of: card, matching: find.text('2 hints')), findsOneWidget);
    expect(find.descendant(of: card, matching: find.text('Edit')), findsNothing);
    expect(find.descendant(of: card, matching: find.text('Delete')), findsNothing);
  });

  testWidgets('the options menu opens the editor for the exercise', (tester) async {
    await _pumpLibrary(tester);
    await _openMenu(tester);
    await tester.tap(find.byKey(const ValueKey('user-exercise-edit')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('feature:user-exercise-editor')), findsOneWidget);
    expect(find.text('Edit exercise'), findsOneWidget);
  });

  testWidgets('deleting from the options menu asks first and removes on confirmation', (tester) async {
    final exercises = await _pumpLibrary(tester);
    await _openMenu(tester);
    await tester.tap(find.byKey(const ValueKey('user-exercise-delete')));
    await tester.pumpAndSettle();
    expect(find.text('Delete the exercise?'), findsOneWidget);
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    expect(exercises.exercises, isEmpty);
    expect(find.byKey(const ValueKey('user-exercise:ux-1')), findsNothing);
  });

  testWidgets('cancelling the delete keeps the exercise', (tester) async {
    final exercises = await _pumpLibrary(tester);
    await _openMenu(tester);
    await tester.tap(find.byKey(const ValueKey('user-exercise-delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(exercises.exercises.keys, ['ux-1']);
  });

  testWidgets('the editor marks which fields are required and explains each one', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(CubitScope(dependencies: buildTestDependencies()));
    await tester.pumpAndSettle();
    await _go(tester, '/biblioteca/ejercicio/nuevo');
    expect(find.byKey(const ValueKey('user-exercise-required'), skipOffstage: false), findsNWidgets(4));
    expect(find.byKey(const ValueKey('user-exercise-optional'), skipOffstage: false), findsNWidgets(6));
    expect(find.bySemanticsLabel('Title, required'), findsOneWidget);
    expect(find.bySemanticsLabel('Story, optional'), findsOneWidget);
    expect(find.text('E.g.: Even or odd?'), findsOneWidget);
    expect(find.text('A short name to recognise it in your list.'), findsOneWidget);
  });

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
    expect(find.text(sumDraft().title), findsNothing);
    await _openExercisesTab(tester);
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
    await _openExercisesTab(tester);
    await tester.tap(find.byKey(const ValueKey('user-exercise-create')));
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

  testWidgets('with no exercises the tab offers to create the first one', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(CubitScope(dependencies: buildTestDependencies()));
    await tester.pumpAndSettle();
    await _openExercisesTab(tester);
    expect(find.text('No exercises yet'), findsOneWidget);
    await tester.tap(find.widgetWithText(AppButton, 'New exercise'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('feature:user-exercise-editor')), findsOneWidget);
  });
}
