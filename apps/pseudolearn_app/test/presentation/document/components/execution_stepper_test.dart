import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/execution/execution_state.dart';
import 'package:pseudolearn_app/application/execution/step_pace.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/domain/model/analysis/source_range.dart';
import 'package:pseudolearn_app/domain/model/execution/block_position.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_focus.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_step.dart';
import 'package:pseudolearn_app/presentation/document/components/execution_stepper.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

const _range = SourceRange(
  startOffset: 0,
  endOffset: 4,
  startLine: 8,
  startColumn: 1,
  endLine: 8,
  endColumn: 5,
);

ExecutionState _paused({
  required ExecutionFocusKind kind,
  int depth = 1,
  ProgramNodeId? enclosingNodeId,
}) {
  return ExecutionState(
    status: ExecutionStatus.pausedAtStatement,
    currentStep: ExecutionStep(
      stepNumber: 12,
      focus: ExecutionFocus(
        nodeId: const ProgramNodeId(3),
        range: _range,
        kind: kind,
      ),
      focusRevision: 12,
      blockPosition: BlockPosition(depth: depth, enclosingNodeId: enclosingNodeId),
      scopeName: 'Principal',
      scopeDepth: 1,
    ),
    outputLines: const [],
    runId: 1,
    statementNumber: 12,
  );
}

Widget _wrap({required Widget child, Size size = const Size(1280, 900)}) {
  return MediaQuery(
    data: MediaQueryData(size: size),
    child: MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('es'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: DesignCanvas(child: child)),
    ),
  );
}

Future<void> _pumpStepper(
  WidgetTester tester, {
  required ExecutionState state,
  void Function(StepPace)? onPace,
}) async {
  tester.view.physicalSize = const Size(1280, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(_wrap(
    child: ExecutionStepper(
      state: state,
      isExecutable: true,
      onPace: onPace ?? (_) {},
      onStop: () {},
    ),
  ));
  await tester.pumpAndSettle();
}

VoidCallback? _pressOf(WidgetTester tester, String label) {
  final button = tester.widget<InkWell>(
    find.ancestor(of: find.text(label), matching: find.byType(InkWell)).first,
  );
  return button.onTap;
}

void main() {
  group('ExecutionStepper', () {
    testWidgets('with no execution it offers only starting one', (tester) async {
      await _pumpStepper(tester, state: const ExecutionState.initial());

      expect(find.text('Paso a paso'), findsOneWidget);
      expect(find.text('Ejecutar'), findsOneWidget);
      expect(find.text('Saltar bloque'), findsNothing);
      expect(find.text('Sin ejecución'), findsOneWidget);
    });

    testWidgets('a paused session replaces the bar with the debugging commands',
        (tester) async {
      await _pumpStepper(tester, state: _paused(kind: ExecutionFocusKind.statement));

      expect(find.text('Paso a paso'), findsNothing);
      expect(find.text('Paso'), findsOneWidget);
      expect(find.text('Saltar bloque'), findsOneWidget);
      expect(find.text('Salir del bloque'), findsOneWidget);
      expect(find.text('Continuar'), findsOneWidget);
      expect(find.text('Pausado en la línea 8'), findsOneWidget);
      expect(find.text('Sentencia 12'), findsOneWidget);
    });

    testWidgets('skipping a block is offered only on a block header', (tester) async {
      await _pumpStepper(tester, state: _paused(kind: ExecutionFocusKind.statement));
      expect(_pressOf(tester, 'Saltar bloque'), isNull);

      await _pumpStepper(tester, state: _paused(kind: ExecutionFocusKind.decision));
      expect(_pressOf(tester, 'Saltar bloque'), isNotNull);
    });

    testWidgets('leaving a block is offered only inside one', (tester) async {
      await _pumpStepper(tester, state: _paused(kind: ExecutionFocusKind.statement));
      expect(_pressOf(tester, 'Salir del bloque'), isNull);

      await _pumpStepper(
        tester,
        state: _paused(
          kind: ExecutionFocusKind.statement,
          depth: 2,
          enclosingNodeId: const ProgramNodeId(9),
        ),
      );
      expect(_pressOf(tester, 'Salir del bloque'), isNotNull);
    });

    testWidgets('each command reports its own pace', (tester) async {
      final paces = <StepPace>[];
      await _pumpStepper(
        tester,
        state: _paused(
          kind: ExecutionFocusKind.decision,
          depth: 2,
          enclosingNodeId: const ProgramNodeId(9),
        ),
        onPace: paces.add,
      );

      await tester.tap(find.text('Paso'));
      await tester.tap(find.text('Saltar bloque'));
      await tester.tap(find.text('Salir del bloque'));
      await tester.tap(find.text('Continuar'));

      expect(paces, [
        StepPace.nextStatement,
        StepPace.overBlock,
        StepPace.outOfBlock,
        StepPace.toEnd,
      ]);
    });
  });
}
