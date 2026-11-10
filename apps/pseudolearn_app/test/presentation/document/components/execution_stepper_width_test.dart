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

const ExecutionState _pausedInsideBlock = ExecutionState(
  status: ExecutionStatus.pausedAtStatement,
  currentStep: ExecutionStep(
    stepNumber: 12,
    focus: ExecutionFocus(
      nodeId: ProgramNodeId(3),
      range: _range,
      kind: ExecutionFocusKind.decision,
    ),
    focusRevision: 12,
    taskContexts: [],
    blockPosition: BlockPosition(depth: 2, enclosingNodeId: ProgramNodeId(1)),
    scopeName: 'Principal',
    scopeDepth: 1,
  ),
  outputLines: [],
  runId: 1,
  statementNumber: 12,
);

final class _Fit {
  final double window;
  final double stepper;
  final String locale;

  const _Fit(this.window, this.stepper, this.locale);

  @override
  String toString() =>
      '${stepper.toInt()} pt of stepper in a ${window.toInt()} pt window ($locale)';
}

const List<_Fit> _edges = <_Fit>[
  _Fit(443, 443, 'es'),

  _Fit(600, 503, 'es'),
  _Fit(600, 503, 'en'),
  _Fit(600, 400, 'es'),
  _Fit(600, 600, 'es'),
  _Fit(960, 863, 'es'),
  _Fit(960, 863, 'en'),
  _Fit(1032, 935, 'es'),
  _Fit(1280, 1183, 'es'),
];

Future<void> _pumpAt(WidgetTester tester, _Fit fit) async {
  tester.view.physicalSize = Size(fit.window, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      locale: Locale(fit.locale),
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
            alignment: Alignment.bottomRight,
            child: SizedBox(
              width: fit.stepper,
              child: ExecutionStepper(
                state: _pausedInsideBlock,
                isExecutable: true,
                onPace: (_) {},
                onTaskStep: (_) {},
                onStop: () {},
                onOpenOptions: () {},
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

double _commandScale(WidgetTester tester) {
  final box = tester.renderObject<RenderBox>(find.byType(FittedBox));
  final child = tester.renderObject<RenderBox>(
    find.descendant(of: find.byType(FittedBox), matching: find.byType(Row)).first,
  );
  return box.size.width / child.size.width;
}

void main() {
  testWidgets('keeps the commands at full size wherever they fit', (
    tester,
  ) async {
    await _pumpAt(tester, const _Fit(1280, 1183, 'es'));
    expect(_commandScale(tester), 1);
    await _pumpAt(tester, const _Fit(443, 443, 'es'));
    expect(_commandScale(tester), 1);
  });

  testWidgets('shrinks the commands just enough at the narrow edge of a class', (
    tester,
  ) async {
    await _pumpAt(tester, const _Fit(960, 863, 'es'));
    expect(_commandScale(tester), inExclusiveRange(0.9, 1));
  });

  for (final fit in _edges) {
    testWidgets('every command fits in $fit', (tester) async {
      await _pumpAt(tester, fit);

      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.stop), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz), findsOneWidget);
      final stepperRight = tester.getTopRight(find.byType(ExecutionStepper)).dx;
      final stopRight = tester.getTopRight(find.byIcon(Icons.stop)).dx;
      expect(stopRight, lessThanOrEqualTo(stepperRight));
    });
  }
}
