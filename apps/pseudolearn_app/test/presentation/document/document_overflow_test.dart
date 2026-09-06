import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pseudolearn_app/composition/cubit_scope.dart';
import 'package:pseudolearn_app/domain/model/documents/document.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_case.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_kind.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_level.dart';
import 'package:pseudolearn_app/domain/model/knowledge/expected_value_kind.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import '../../fakes/fake_knowledge_repository.dart';
import '../../fakes/in_memory_document_repository.dart';
import '../../fakes/pump_app.dart';
import '../../fakes/test_dependencies.dart';

const String _factorialSource = 'Proceso Factorial\n'
    '\tDefinir n Como Entero;\n'
    '\tDefinir f Como Entero;\n'
    '\tDefinir i Como Entero;\n'
    '\tn <- 5;\n'
    '\tf <- 1;\n'
    '\tPara i <- 1 Hasta n Con Paso 1 Hacer\n'
    '\t\tf <- f * i;\n'
    '\tFinPara\n'
    '\tEscribir "Factorial: ", f;\n'
    'FinProceso\n';

const List<double> _compactWidths = <double>[360, 375, 390, 430, 599];

void main() {
  for (final width in _compactWidths) {
    testWidgets(
        '${width.toInt()} px shows an executed document without overflowing',
        (tester) async {
      final repo = InMemoryDocumentRepository();
      final now = DateTime(2026, 8, 16, 12, 0);
      repo.documents['doc-1'] = Document(
        id: 'doc-1',
        title: 'Cálculo de factorial',
        content: _factorialSource,
        profileId: SyntaxProfileId.classicSpanish,
        revision: 1,
        createdAt: now,
        updatedAt: now,
      );

      final errors = await collectLayoutErrors(() async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1.0;
        tester.platformDispatcher.localesTestValue = <Locale>[
          const Locale('es')
        ];
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearLocalesTestValue);

        await tester.pumpWidget(
            CubitScope(dependencies: buildTestDependencies(repository: repo)));
        await tester.pumpAndSettle();

        final context = tester.element(find.byType(Navigator).first);
        GoRouter.of(context).go('/biblioteca/documento/doc-1');
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.play_arrow).first);
        await tester.pumpAndSettle();
      });

      expect(
        errors.map((e) => e.exception.toString()).toList(),
        isEmpty,
        reason: 'Layout errors at ${width.toInt()} px',
      );
    });
  }

  testWidgets(
      '360 px shows document with expanded exercise strip and output panel without overflowing',
      (tester) async {
    final repo = InMemoryDocumentRepository();
    final now = DateTime(2026, 8, 16, 12, 0);
    repo.documents['doc-exercise'] = Document(
      id: 'doc-exercise',
      title: 'Ejercicio Suma',
      content: _factorialSource,
      profileId: SyntaxProfileId.classicSpanish,
      revision: 1,
      createdAt: now,
      updatedAt: now,
      exerciseId: 'CON-B1-E1',
    );

    final errors = await collectLayoutErrors(() async {
      tester.view.physicalSize = const Size(360, 844);
      tester.view.devicePixelRatio = 1.0;
      tester.platformDispatcher.localesTestValue = <Locale>[const Locale('es')];
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await tester.pumpWidget(
          CubitScope(dependencies: buildTestDependencies(repository: repo)));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(Navigator).first);
      GoRouter.of(context).go('/biblioteca/documento/doc-exercise');
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.play_arrow).first);
      await tester.pumpAndSettle();
    });

    expect(
      errors.map((e) => e.exception.toString()).toList(),
      isEmpty,
      reason: 'Layout errors with exercise strip at 360 px',
    );
  });

  testWidgets(
      '402 px shows document with exercise strip and keyboard open without overflowing',
      (tester) async {
    final repo = InMemoryDocumentRepository();
    final now = DateTime(2026, 8, 16, 12, 0);
    repo.documents['doc-exercise'] = Document(
      id: 'doc-exercise',
      title: 'Segundos en un intervalo de minutos',
      content: _factorialSource,
      profileId: SyntaxProfileId.classicSpanish,
      revision: 1,
      createdAt: now,
      updatedAt: now,
      exerciseId: 'CON-A2-E1',
    );

    final knowledgeRepo = FakeKnowledgeRepository(
      exercisesByPath: {
        'CON-A2-E1': const Exercise(
          id: 'CON-A2-E1',
          title: 'Segundos en un intervalo de minutos',
          statement:
              'Lee una cantidad de minutos y escribe cuántos segundos son.',
          level: ExerciseLevel.reproduce,
          kind: ExerciseKind.create,
          moduleId: 'CON-A2',
          visibleCases: [
            ExerciseCase(
              inputs: ['2'],
              expectedOutputs: ['120'],
              expectedValueKind: ExpectedValueKind.numeric,
            ),
            ExerciseCase(
              inputs: ['5'],
              expectedOutputs: ['300'],
              expectedValueKind: ExpectedValueKind.numeric,
            ),
          ],
          hiddenCases: [],
          assertions: [],
        ),
      },
    );

    final errors = await collectLayoutErrors(() async {
      tester.view.physicalSize = const Size(402, 874);
      tester.view.devicePixelRatio = 1.0;
      tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
      tester.view.viewInsets = const FakeViewPadding(bottom: 336);
      tester.platformDispatcher.localesTestValue = <Locale>[const Locale('es')];
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await tester.pumpWidget(CubitScope(
        dependencies: buildTestDependencies(
          repository: repo,
          knowledgeRepository: knowledgeRepo,
        ),
      ));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(Navigator).first);
      GoRouter.of(context).go('/biblioteca/documento/doc-exercise');
      await tester.pumpAndSettle();
    });

    expect(
      errors.map((e) => e.exception.toString()).toList(),
      isEmpty,
      reason: 'Layout errors with keyboard open at 402 px',
    );
  });

  testWidgets(
      '360x640 px shows document with exercise strip and keyboard open without overflowing',
      (tester) async {
    final repo = InMemoryDocumentRepository();
    final now = DateTime(2026, 8, 16, 12, 0);
    repo.documents['doc-exercise'] = Document(
      id: 'doc-exercise',
      title: 'Segundos en un intervalo de minutos',
      content: _factorialSource,
      profileId: SyntaxProfileId.classicSpanish,
      revision: 1,
      createdAt: now,
      updatedAt: now,
      exerciseId: 'CON-A2-E1',
    );

    final knowledgeRepo = FakeKnowledgeRepository(
      exercisesByPath: {
        'CON-A2-E1': const Exercise(
          id: 'CON-A2-E1',
          title: 'Segundos en un intervalo de minutos',
          statement:
              'Lee una cantidad de minutos y escribe cuántos segundos son.',
          level: ExerciseLevel.reproduce,
          kind: ExerciseKind.create,
          moduleId: 'CON-A2',
          visibleCases: [
            ExerciseCase(
              inputs: ['2'],
              expectedOutputs: ['120'],
              expectedValueKind: ExpectedValueKind.numeric,
            ),
            ExerciseCase(
              inputs: ['5'],
              expectedOutputs: ['300'],
              expectedValueKind: ExpectedValueKind.numeric,
            ),
          ],
          hiddenCases: [],
          assertions: [],
        ),
      },
    );

    final errors = await collectLayoutErrors(() async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      tester.view.padding = const FakeViewPadding(top: 24, bottom: 0);
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      tester.platformDispatcher.localesTestValue = <Locale>[const Locale('es')];
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await tester.pumpWidget(CubitScope(
        dependencies: buildTestDependencies(
          repository: repo,
          knowledgeRepository: knowledgeRepo,
        ),
      ));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(Navigator).first);
      GoRouter.of(context).go('/biblioteca/documento/doc-exercise');
      await tester.pumpAndSettle();
    });

    expect(
      errors.map((e) => e.exception.toString()).toList(),
      isEmpty,
      reason: 'Layout errors with keyboard open at 360x640 px',
    );
  });
}
