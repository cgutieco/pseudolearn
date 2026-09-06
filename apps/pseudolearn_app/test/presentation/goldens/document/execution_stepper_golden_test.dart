import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/execution/execution_state.dart';
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

ExecutionState _pausedInsideLoop() => const ExecutionState(
      status: ExecutionStatus.pausedAtStatement,
      currentStep: ExecutionStep(
        stepNumber: 12,
        focus: ExecutionFocus(
          nodeId: ProgramNodeId(3),
          range: _range,
          kind: ExecutionFocusKind.decision,
        ),
        focusRevision: 12,
        blockPosition: BlockPosition(depth: 2, enclosingNodeId: ProgramNodeId(9)),
        scopeName: 'Principal',
        scopeDepth: 1,
      ),
      outputLines: [],
      runId: 1,
      statementNumber: 12,
    );

Future<void> _pump(
  WidgetTester tester, {
  required Size size,
  required ThemeData theme,
  required ExecutionState state,
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
      home: Scaffold(
        body: DesignCanvas(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ExecutionStepper(
              state: state,
              isExecutable: true,
              onPace: (_) {},
              onStop: () {},
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('execution stepper goldens', () {
    testWidgets('idle · expanded · light', (tester) async {
      await _pump(
        tester,
        size: const Size(1280, 220),
        theme: AppTheme.light(),
        state: const ExecutionState.initial(),
      );
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('stepper_idle_expanded_light.png'));
    });

    testWidgets('debugging · expanded · light', (tester) async {
      await _pump(
        tester,
        size: const Size(1280, 220),
        theme: AppTheme.light(),
        state: _pausedInsideLoop(),
      );
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('stepper_debug_expanded_light.png'));
    });

    testWidgets('debugging · medium · dark', (tester) async {
      await _pump(
        tester,
        size: const Size(760, 220),
        theme: AppTheme.dark(),
        state: _pausedInsideLoop(),
      );
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('stepper_debug_medium_dark.png'));
    });

    testWidgets('debugging · compact · light', (tester) async {
      await _pump(
        tester,
        size: const Size(420, 220),
        theme: AppTheme.light(),
        state: _pausedInsideLoop(),
      );
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('stepper_debug_compact_light.png'));
    });
  });
}
