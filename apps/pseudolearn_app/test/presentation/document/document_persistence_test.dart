import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pseudolearn_app/application/editor/editor_cubit.dart';
import 'package:pseudolearn_app/application/knowledge/session/exercise_session_cubit.dart';
import 'package:pseudolearn_app/application/knowledge/session/exercise_session_state.dart';
import 'package:pseudolearn_app/composition/cubit_scope.dart';
import 'package:pseudolearn_app/domain/model/documents/document.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_case.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_kind.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_level.dart';
import 'package:pseudolearn_app/domain/model/knowledge/expected_value_kind.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry_type.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import '../../fakes/fake_knowledge_repository.dart';
import '../../fakes/in_memory_document_repository.dart';
import '../../fakes/in_memory_local_progress_store.dart';
import '../../fakes/test_dependencies.dart';

void main() {
  testWidgets('saves dirty document when navigating back via header back button', (tester) async {
    final repo = InMemoryDocumentRepository();
    final now = DateTime(2026, 8, 16, 12, 0);
    repo.documents['doc-1'] = Document(
      id: 'doc-1',
      title: 'Mi Algoritmo',
      content: 'Algoritmo Inicial\nFinAlgoritmo',
      profileId: SyntaxProfileId.classicSpanish,
      revision: 1,
      createdAt: now,
      updatedAt: now,
    );

    final deps = buildTestDependencies(repository: repo);
    await tester.pumpWidget(CubitScope(dependencies: deps));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(Navigator).first);
    GoRouter.of(context).go('/biblioteca/documento/doc-1');
    await tester.pumpAndSettle();

    final editorCubit = tester.element(find.byType(Navigator).first).read<EditorCubit>();
    editorCubit.updateSourceCode('Algoritmo Modificado\n  Escribir 10\nFinAlgoritmo');
    await tester.pump();
    expect(editorCubit.state.isDirty, isTrue);

    await tester.tap(find.byIcon(Icons.arrow_back).first);
    await tester.pumpAndSettle();

    final saved = await repo.loadDocument('doc-1');
    expect(saved?.content, contains('Algoritmo Modificado'));
    expect(saved?.revision, equals(2));
  });

  testWidgets('saves dirty document and auto-checks exercise when tapping Run to end', (tester) async {
    final repo = InMemoryDocumentRepository();
    final progressStore = InMemoryLocalProgressStore();
    final now = DateTime(2026, 8, 16, 12, 0);

    const exercise = Exercise(
      id: 'EX-TEST-1',
      title: 'Escribir Saludo',
      statement: 'Escribe Hola',
      level: ExerciseLevel.reproduce,
      kind: ExerciseKind.complete,
      visibleCases: [
        ExerciseCase(inputs: [], expectedOutputs: ['Hola'], expectedValueKind: ExpectedValueKind.text),
      ],
      hiddenCases: [],
    );

    const exerciseEntry = KnowledgeEntry(
      id: 'EX-TEST-1',
      type: KnowledgeEntryType.exercise,
      title: 'Escribir Saludo',
      summary: 'Escribe Hola',
      path: 'exercises/EX-TEST-1_es.json',
    );

    final knowledgeRepo = FakeKnowledgeRepository(
      entries: [exerciseEntry],
      exercisesByPath: {
        'exercises/EX-TEST-1_es.json': exercise,
      },
    );

    repo.documents['doc-ex'] = Document(
      id: 'doc-ex',
      title: 'Ejercicio Hola',
      content: 'Algoritmo Saludo\n  Escribir "Hola"\nFinAlgoritmo\n',
      profileId: SyntaxProfileId.classicSpanish,
      revision: 1,
      createdAt: now,
      updatedAt: now,
      exerciseId: 'EX-TEST-1',
    );

    final deps = buildTestDependencies(
      repository: repo,
      localProgressStore: progressStore,
      knowledgeRepository: knowledgeRepo,
    );

    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(CubitScope(dependencies: deps));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(Navigator).first);
    GoRouter.of(context).go('/biblioteca/documento/doc-ex');
    await tester.pumpAndSettle();

    final editorCubit = tester.element(find.byType(Navigator).first).read<EditorCubit>();
    editorCubit.updateSourceCode('Algoritmo Saludo\n  Escribir "Hola"\nFinAlgoritmo\n');
    await tester.pumpAndSettle();

    final sessionCubit = tester.element(find.byType(Navigator).first).read<ExerciseSessionCubit>();
    expect(sessionCubit.state.exercise, isNotNull);
    expect(editorCubit.state.report.isExecutable, isTrue);

    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pumpAndSettle();

    expect(sessionCubit.state.status, equals(ExerciseSessionStatus.success));
    final isCompleted = await progressStore.isExerciseCompleted('EX-TEST-1');
    expect(isCompleted, isTrue);

    final saved = await repo.loadDocument('doc-ex');
    expect(saved?.content, contains('Algoritmo Saludo'));
  });
}
