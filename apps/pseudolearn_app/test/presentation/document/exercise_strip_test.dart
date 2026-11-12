import 'package:cupertino_ui/cupertino_ui.dart' show GlobalCupertinoLocalizations;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart' show GlobalWidgetsLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/route/session/exercise_session_state.dart';
import 'package:pseudolearn_app/domain/model/knowledge/expected_value_kind.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_case.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_case_failure.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_check_outcome.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_check_result.dart';
import 'package:pseudolearn_app/domain/model/route/route_kinds.dart';
import 'package:pseudolearn_app/presentation/components/button/app_icon_button.dart';
import 'package:pseudolearn_app/presentation/document/components/exercise_strip.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('es'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, c) =>
          DesignCanvas(child: c ?? const SizedBox.shrink()),
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );
  }

  const sampleExercise = Exercise(
    id: 'CON-B1-E1',
    title: 'Suma de dos números',
    statement: 'Escribe un programa que lea dos números y escriba su suma.',
    level: RouteLevel.seed,
    kind: RouteExerciseKind.solve,
    lessonId: 'CON-B1',
    visibleCases: [
      ExerciseCase(
        inputs: ['2', '3'],
        expectedOutputs: ['5'],
        expectedValueKind: ExpectedValueKind.numeric,
      ),
    ],
    hiddenCases: [
      ExerciseCase(
        inputs: ['-1', '1'],
        expectedOutputs: ['0'],
        expectedValueKind: ExpectedValueKind.numeric,
      ),
    ],
  );

  group('ExerciseStrip Component Tests', () {
    testWidgets(
        'Renders ready state with statement and visible cases, without a check button',
        (tester) async {
      const sessionState = ExerciseSessionState(
        status: ExerciseSessionStatus.ready,
        exercise: sampleExercise,
        isCompleted: false,
      );

      await tester.pumpWidget(
        buildTestWidget(
          ExerciseStrip(
            exerciseId: 'CON-B1-E1',
            sessionState: sessionState,
            isExpanded: true,
            onToggleExpand: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ejercicio: Suma de dos números'), findsOneWidget);
      expect(find.text('Semilla'), findsOneWidget);
      expect(find.text('Resolver'), findsOneWidget);
      expect(
          find.text(
              'Escribe un programa que lea dos números y escriba su suma.'),
          findsOneWidget);
      expect(find.text('Casos de prueba visibles:'), findsOneWidget);
      expect(find.text('Entrada: 2, 3'), findsOneWidget);
      expect(find.text('Salida esperada: 5'), findsOneWidget);
      expect(find.text('Comprobar'), findsNothing);
    });

    testWidgets('Checking does not add any progress text to the strip',
        (tester) async {
      const sessionState = ExerciseSessionState(
        status: ExerciseSessionStatus.checking,
        exercise: sampleExercise,
      );

      await tester.pumpWidget(
        buildTestWidget(
          ExerciseStrip(
            exerciseId: 'CON-B1-E1',
            sessionState: sessionState,
            isExpanded: true,
            onToggleExpand: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Comprobando...'), findsNothing);
      expect(find.text('Ejercicio: Suma de dos números'), findsOneWidget);
    });

    testWidgets(
        'Renders success outcome (allCasesPassed) without percentages or grades',
        (tester) async {
      const sessionState = ExerciseSessionState(
        status: ExerciseSessionStatus.success,
        exercise: sampleExercise,
        isCompleted: true,
        lastResult: ExerciseCheckResult(
          outcome: ExerciseCheckOutcome.allCasesPassed,
          passedCases: 2,
          totalCases: 2,
        ),
      );

      await tester.pumpWidget(
        buildTestWidget(
          ExerciseStrip(
            exerciseId: 'CON-B1-E1',
            sessionState: sessionState,
            isExpanded: true,
            onToggleExpand: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2/2'), findsOneWidget);
      expect(find.bySemanticsLabel('Cumple 2 de 2 casos'), findsOneWidget);
      expect(find.text('Cumple 2 de 2 casos'), findsNothing);
      expect(find.text('Superado'), findsNothing);

      expect(find.textContaining('%'), findsNothing);
      expect(find.textContaining('Aprobado'), findsNothing);
      expect(find.textContaining('Nota'), findsNothing);
    });

    testWidgets('Renders caseFailed and reveals first failed hidden case',
        (tester) async {
      const failure = ExerciseCaseFailure(
        caseIndex: 1,
        isHidden: true,
        inputs: ['-1', '1'],
        expectedOutputs: ['0'],
        actualOutputs: ['-1'],
      );

      const sessionState = ExerciseSessionState(
        status: ExerciseSessionStatus.success,
        exercise: sampleExercise,
        isCompleted: false,
        lastResult: ExerciseCheckResult(
          outcome: ExerciseCheckOutcome.caseFailed,
          passedCases: 1,
          totalCases: 2,
          firstFailure: failure,
        ),
        revealedHiddenFailure: failure,
      );

      await tester.pumpWidget(
        buildTestWidget(
          ExerciseStrip(
            exerciseId: 'CON-B1-E1',
            sessionState: sessionState,
            isExpanded: true,
            onToggleExpand: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1/2'), findsOneWidget);
      expect(find.text('Cumple 1 de 2 casos'), findsOneWidget);
      expect(find.text('Primer caso oculto fallido:'), findsOneWidget);
      expect(find.text('Entrada: -1, 1'), findsOneWidget);
      expect(find.text('Salida esperada: 0'), findsOneWidget);
      expect(find.text('Salida obtenida: -1'), findsOneWidget);
    });

    testWidgets('Renders anomalous outcomes with distinct pedagogical messages',
        (tester) async {
      for (final (outcome, message) in [
        (
          ExerciseCheckOutcome.programDidNotParse,
          'El programa contiene errores de sintaxis y no puede comprobarse.',
        ),
        (
          ExerciseCheckOutcome.programHalted,
          'La ejecución se detuvo de forma anómala.',
        ),
        (
          ExerciseCheckOutcome.stepLimitReached,
          'Se agotó el límite de pasos (posible bucle infinito).',
        ),
        (
          ExerciseCheckOutcome.inputScriptExhausted,
          'El programa solicitó más entradas de las previstas.',
        ),
      ]) {
        final sessionState = ExerciseSessionState(
          status: ExerciseSessionStatus.success,
          exercise: sampleExercise,
          lastResult: ExerciseCheckResult(
            outcome: outcome,
            passedCases: 0,
            totalCases: 2,
          ),
        );

        await tester.pumpWidget(
          buildTestWidget(
            ExerciseStrip(
              exerciseId: 'CON-B1-E1',
              sessionState: sessionState,
              isExpanded: true,
              onToggleExpand: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(message), findsOneWidget);
      }
    });

    testWidgets('Renders warning notice when exercise is not found in catalog',
        (tester) async {
      const sessionState = ExerciseSessionState(
        status: ExerciseSessionStatus.exerciseNotFound,
        exercise: null,
      );

      await tester.pumpWidget(
        buildTestWidget(
          ExerciseStrip(
            exerciseId: 'UNKNOWN-E99',
            sessionState: sessionState,
            isExpanded: true,
            onToggleExpand: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ejercicio: Ejercicio no disponible'), findsOneWidget);
      expect(
        find.text(
            'El ejercicio vinculado (UNKNOWN-E99) no existe en el catálogo. Puedes editar y ejecutar este documento con normalidad.'),
        findsOneWidget,
      );
    });

    testWidgets('Toggles collapsed / expanded body', (tester) async {
      var toggled = false;

      const sessionState = ExerciseSessionState(
        status: ExerciseSessionStatus.ready,
        exercise: sampleExercise,
      );

      await tester.pumpWidget(
        buildTestWidget(
          ExerciseStrip(
            exerciseId: 'CON-B1-E1',
            sessionState: sessionState,
            isExpanded: false,
            onToggleExpand: () => toggled = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ejercicio: Suma de dos números'), findsOneWidget);

      expect(
          find.text(
              'Escribe un programa que lea dos números y escriba su suma.'),
          findsNothing);

      await tester.tap(find.byType(AppIconButton));
      await tester.pump();
      expect(toggled, isTrue);
    });

    testWidgets('A completed exercise without a fresh check shows Superado',
        (tester) async {
      const sessionState = ExerciseSessionState(
        status: ExerciseSessionStatus.ready,
        exercise: sampleExercise,
        isCompleted: true,
      );

      await tester.pumpWidget(
        buildTestWidget(
          ExerciseStrip(
            exerciseId: 'CON-B1-E1',
            sessionState: sessionState,
            isExpanded: false,
            onToggleExpand: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Superado'), findsOneWidget);
      expect(find.text('Resolver'), findsNothing);
    });

    testWidgets('A collapsed strip still shows the latest case ratio',
        (tester) async {
      const sessionState = ExerciseSessionState(
        status: ExerciseSessionStatus.success,
        exercise: sampleExercise,
        lastResult: ExerciseCheckResult(
          outcome: ExerciseCheckOutcome.caseFailed,
          passedCases: 0,
          totalCases: 2,
        ),
      );

      await tester.pumpWidget(
        buildTestWidget(
          ExerciseStrip(
            exerciseId: 'CON-B1-E1',
            sessionState: sessionState,
            isExpanded: false,
            onToggleExpand: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('0/2'), findsOneWidget);
      expect(find.text('Cumple 0 de 2 casos'), findsNothing);
    });
  });
}
