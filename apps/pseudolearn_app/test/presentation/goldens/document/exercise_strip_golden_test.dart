import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/knowledge/session/exercise_session_state.dart';
import 'package:pseudolearn_app/domain/model/knowledge/expected_value_kind.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_case.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_check_outcome.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_check_result.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_kind.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_level.dart';
import 'package:pseudolearn_app/presentation/document/components/exercise_strip.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

const _sampleExercise = Exercise(
  id: 'CON-B1-E1',
  title: 'Suma de dos números',
  statement: 'Escribe un programa que lea dos números enteros por teclado y escriba su suma.',
  level: ExerciseLevel.reproduce,
  kind: ExerciseKind.create,
  moduleId: 'CON-B1',
  visibleCases: [
    ExerciseCase(
      inputs: ['2', '3'],
      expectedOutputs: ['5'],
      expectedValueKind: ExpectedValueKind.numeric,
    ),
    ExerciseCase(
      inputs: ['10', '20'],
      expectedOutputs: ['30'],
      expectedValueKind: ExpectedValueKind.numeric,
    ),
  ],
  hiddenCases: [
    ExerciseCase(
      inputs: ['-5', '5'],
      expectedOutputs: ['0'],
      expectedValueKind: ExpectedValueKind.numeric,
    ),
  ],
);

const _readyState = ExerciseSessionState(
  status: ExerciseSessionStatus.ready,
  exercise: _sampleExercise,
  isCompleted: false,
);

const _solvedState = ExerciseSessionState(
  status: ExerciseSessionStatus.success,
  exercise: _sampleExercise,
  isCompleted: true,
  lastResult: ExerciseCheckResult(
    outcome: ExerciseCheckOutcome.allCasesPassed,
    passedCases: 3,
    totalCases: 3,
  ),
);

Future<void> _pumpExerciseStrip(
  WidgetTester tester, {
  required Size size,
  required ThemeData theme,
  required ExerciseSessionState state,
  required bool isExpanded,
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
        body: SingleChildScrollView(
          child: ExerciseStrip(
            exerciseId: 'CON-B1-E1',
            sessionState: state,
            isExpanded: isExpanded,
            onToggleExpand: () {},
            onCheck: () {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('ExerciseStrip Goldens (CON-F15) — expanded strip across three widths and two themes', () {
    final widths = <String, double>{
      'compact': 360,
      'medium': 600,
      'expanded': 960,
    };

    for (final entry in widths.entries) {
      testWidgets('${entry.key} · light', (tester) async {
        await _pumpExerciseStrip(
          tester,
          size: Size(entry.value, 400),
          theme: AppTheme.light(),
          state: _readyState,
          isExpanded: true,
        );
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('exercise_strip_expanded_${entry.key}_light.png'),
        );
      });

      testWidgets('${entry.key} · dark', (tester) async {
        await _pumpExerciseStrip(
          tester,
          size: Size(entry.value, 400),
          theme: AppTheme.dark(),
          state: _readyState,
          isExpanded: true,
        );
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('exercise_strip_expanded_${entry.key}_dark.png'),
        );
      });
    }
  });

  group('ExerciseStrip Goldens (CON-F15) — collapsed strip', () {
    testWidgets('collapsed · medium · light', (tester) async {
      await _pumpExerciseStrip(
        tester,
        size: const Size(600, 200),
        theme: AppTheme.light(),
        state: _readyState,
        isExpanded: false,
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('exercise_strip_collapsed_medium_light.png'),
      );
    });

    testWidgets('collapsed · medium · dark', (tester) async {
      await _pumpExerciseStrip(
        tester,
        size: const Size(600, 200),
        theme: AppTheme.dark(),
        state: _readyState,
        isExpanded: false,
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('exercise_strip_collapsed_medium_dark.png'),
      );
    });
  });

  group('ExerciseStrip Goldens (CON-F15) — solved state with check result feedback', () {
    testWidgets('solved · medium · light', (tester) async {
      await _pumpExerciseStrip(
        tester,
        size: const Size(600, 400),
        theme: AppTheme.light(),
        state: _solvedState,
        isExpanded: true,
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('exercise_strip_solved_medium_light.png'),
      );
    });

    testWidgets('solved · medium · dark', (tester) async {
      await _pumpExerciseStrip(
        tester,
        size: const Size(600, 400),
        theme: AppTheme.dark(),
        state: _solvedState,
        isExpanded: true,
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('exercise_strip_solved_medium_dark.png'),
      );
    });
  });
}
