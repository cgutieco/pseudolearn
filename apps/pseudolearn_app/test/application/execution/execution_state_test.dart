import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/execution/execution_state.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/domain/model/analysis/source_range.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_focus.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_step.dart';

const _focus = ExecutionFocus(
  nodeId: ProgramNodeId(4),
  range: SourceRange(
    startOffset: 0,
    endOffset: 4,
    startLine: 3,
    startColumn: 1,
    endLine: 3,
    endColumn: 5,
  ),
  kind: ExecutionFocusKind.statement,
);

ExecutionState _state(ExecutionStatus status, {required bool isContinuous}) =>
    ExecutionState(
      status: status,
      currentStep: const ExecutionStep(
        stepNumber: 3,
        focus: _focus,
        focusRevision: 3,
        scopeName: 'global',
        scopeDepth: 1,
      ),
      outputLines: const [],
      isContinuous: isContinuous,
    );

void main() {
  group('ExecutionState.followedFocus', () {
    test('a continuous run hides the focus while it runs', () {
      final state = _state(ExecutionStatus.running, isContinuous: true);

      expect(state.isContinuousRun, isTrue);
      expect(state.followedFocus, isNull);
    });

    test('a continuous run hides the focus while a host effect is pending', () {
      final state = _state(
        ExecutionStatus.pausedAwaitingEffect,
        isContinuous: true,
      );

      expect(state.followedFocus, isNull);
    });

    test('a continuous run shows the statement that asks for input', () {
      final state = _state(
        ExecutionStatus.pausedAwaitingInput,
        isContinuous: true,
      );

      expect(state.followedFocus, _focus);
    });

    test('a stepping run always shows its focus', () {
      final state = _state(ExecutionStatus.running, isContinuous: false);

      expect(state.isContinuousRun, isFalse);
      expect(state.followedFocus, _focus);
    });

    test('a finished continuous run is no longer a continuous run', () {
      final state = _state(
        ExecutionStatus.finishedSuccess,
        isContinuous: true,
      );

      expect(state.isContinuousRun, isFalse);
      expect(state.followedFocus, _focus);
    });

    test('showing the tasks hides the trace', () {
      final state = _state(ExecutionStatus.running, isContinuous: true)
          .applyViewAction(ExecutionViewAction.showTrace)
          .applyViewAction(ExecutionViewAction.showTasks);

      expect(state.isTasksVisible, isTrue);
      expect(state.isTraceVisible, isFalse);
    });

    test('another tab hides both the trace and the tasks', () {
      final state = _state(ExecutionStatus.running, isContinuous: true)
          .applyViewAction(ExecutionViewAction.showTasks)
          .applyViewAction(ExecutionViewAction.showOtherTab);

      expect(state.isTasksVisible, isFalse);
      expect(state.isTraceVisible, isFalse);
    });

    test('switching the trace keeps the continuous flag', () {
      final state = _state(ExecutionStatus.running, isContinuous: true);

      final shown = state.applyViewAction(ExecutionViewAction.showTrace);

      expect(shown.isTraceVisible, isTrue);
      expect(shown.isContinuous, isTrue);
    });
  });
}
