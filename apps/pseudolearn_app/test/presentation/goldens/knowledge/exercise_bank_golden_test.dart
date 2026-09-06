import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/knowledge/bank/exercise_bank_state.dart';
import 'package:pseudolearn_app/domain/model/knowledge/ast_construct.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_kind.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_level.dart';
import 'package:pseudolearn_app/domain/model/knowledge/structural_assertion.dart';
import 'package:pseudolearn_app/presentation/knowledge/components/exercise_bank/exercise_bank_section.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

const _exercise1 = Exercise(
  id: 'CON-B1-E1',
  title: 'Suma de dos números',
  statement: 'Calcula la suma de dos números enteros leídos por teclado.',
  level: ExerciseLevel.reproduce,
  kind: ExerciseKind.create,
  moduleId: 'CON-B1',
  visibleCases: [],
  hiddenCases: [],
);

const _exercise2 = Exercise(
  id: 'CON-B4-E1',
  title: 'Tabla de multiplicar',
  statement: 'Usa un bucle contado para imprimir la tabla de un número dado.',
  level: ExerciseLevel.compose,
  kind: ExerciseKind.complete,
  moduleId: 'CON-B4',
  visibleCases: [],
  hiddenCases: [],
  assertions: [
    ContainsConstructAssertion(
      requirement: 'Usa bucle Para',
      construct: AstConstruct.countedLoop,
    ),
  ],
);

const _exercise3 = Exercise(
  id: 'CON-GEN-E1',
  title: 'Simulador bancario',
  statement: 'Diseña un sistema completo de cuentas y transacciones concurrentes.',
  level: ExerciseLevel.design,
  kind: ExerciseKind.modify,
  visibleCases: [],
  hiddenCases: [],
  assertions: [
    ContainsConstructAssertion(
      requirement: 'Usa clases',
      construct: AstConstruct.classDeclaration,
    ),
  ],
);

const _populatedState = ExerciseBankState(
  status: ExerciseBankStatus.success,
  allExercises: [_exercise1, _exercise2, _exercise3],
  filteredExercises: [_exercise1, _exercise2, _exercise3],
  completedExerciseIds: {'CON-B1-E1'},
  availableModuleIds: ['CON-B1', 'CON-B4'],
  availableConstructs: [AstConstruct.countedLoop, AstConstruct.classDeclaration],
);

const _emptyFilterState = ExerciseBankState(
  status: ExerciseBankStatus.success,
  allExercises: [_exercise1, _exercise2, _exercise3],
  filteredExercises: [],
  selectedLevel: ExerciseLevel.design,
  selectedModuleId: 'CON-B1',
  availableModuleIds: ['CON-B1', 'CON-B4'],
  availableConstructs: [AstConstruct.countedLoop, AstConstruct.classDeclaration],
);

Future<void> _pumpExerciseBankView(
  WidgetTester tester, {
  required Size size,
  required ThemeData theme,
  required ExerciseBankState state,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      locale: const Locale('es'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => DesignCanvas(child: child ?? const SizedBox.shrink()),
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ExerciseBankSection(
            state: state,
            onLevelSelected: (_) {},
            onModuleSelected: (_) {},
            onConstructSelected: (_) {},
            onClearFilters: () {},
            onOpenExercise: (_) {},
            onRetry: () {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('ExerciseBankSection Goldens (CON-F14) — three widths and two themes', () {
    final widths = <String, double>{
      'compact': 360,
      'medium': 600,
      'expanded': 960,
    };

    for (final entry in widths.entries) {
      testWidgets('${entry.key} · light', (tester) async {
        await _pumpExerciseBankView(
          tester,
          size: Size(entry.value, 800),
          theme: AppTheme.light(),
          state: _populatedState,
        );
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('exercise_bank_${entry.key}_light.png'),
        );
      });

      testWidgets('${entry.key} · dark', (tester) async {
        await _pumpExerciseBankView(
          tester,
          size: Size(entry.value, 800),
          theme: AppTheme.dark(),
          state: _populatedState,
        );
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('exercise_bank_${entry.key}_dark.png'),
        );
      });
    }
  });

  group('ExerciseBankSection Goldens (CON-F14) — empty filter result', () {
    testWidgets('empty filter · medium · light', (tester) async {
      await _pumpExerciseBankView(
        tester,
        size: const Size(600, 800),
        theme: AppTheme.light(),
        state: _emptyFilterState,
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('exercise_bank_empty_filter_medium_light.png'),
      );
    });

    testWidgets('empty filter · medium · dark', (tester) async {
      await _pumpExerciseBankView(
        tester,
        size: const Size(600, 800),
        theme: AppTheme.dark(),
        state: _emptyFilterState,
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('exercise_bank_empty_filter_medium_dark.png'),
      );
    });
  });
}
