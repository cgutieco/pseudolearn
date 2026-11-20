import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/execution/execution_state.dart';
import 'package:pseudolearn_app/application/execution/execution_step_projection.dart';
import 'package:pseudolearn_app/domain/model/execution/effect_tape.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_projection.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_step.dart';
import 'package:pseudolearn_app/domain/model/execution/output_line.dart';
import 'package:pseudolearn_app/domain/model/execution/replay_rejection.dart';
import 'package:pseudolearn_app/domain/ports/execution_reproduction.dart';

import '../../fakes/fake_program_execution.dart';

ExecutionStep _step(int revision, {String? haltReason}) => ExecutionStep(
  stepNumber: revision,
  focusRevision: revision,
  scopeName: 'global',
  scopeDepth: 1,
  isHalted: haltReason != null,
  haltReason: haltReason,
);

final class _RecordingExecution extends FakeProgramExecution
    implements ExecutionReproduction {
  int tapeReads = 0;

  @override
  EffectTape? get recordedTape {
    tapeReads++;
    return EffectTape.fromDocument(const {'entries': <Object?>[]});
  }

  @override
  ReplayRejection? get replayRejection => null;

  @override
  ExecutionProjection get projection => const ExecutionProjection(
    events: [],
    output: [],
    termination: 'running',
  );
}

const ExecutionState _continuous = ExecutionState(
  status: ExecutionStatus.running,
  currentStep: ExecutionStep(
    stepNumber: 0,
    focusRevision: 0,
    scopeName: 'global',
    scopeDepth: 1,
  ),
  outputLines: [],
  runId: 1,
  statementNumber: 0,
  isContinuous: true,
);

void main() {
  group('stateAfterStep tape', () {
    test('a running continuous step leaves the tape unread', () {
      final execution = _RecordingExecution();

      final next = stateAfterStep(_continuous, _step(1), execution);

      expect(execution.tapeReads, 0);
      expect(next.recordedTape, isNull);
    });

    test('a continuous run that halts publishes its tape', () {
      final execution = _RecordingExecution();

      final next = stateAfterStep(
        _continuous,
        _step(2, haltReason: 'division_by_zero'),
        execution,
      );

      expect(execution.tapeReads, 1);
      expect(next.recordedTape, isNotNull);
    });

    test('a step by step run publishes the tape on every step', () {
      final execution = _RecordingExecution();

      final next = stateAfterStep(
        const ExecutionState.initial(),
        _step(1),
        execution,
      );

      expect(execution.tapeReads, 1);
      expect(next.recordedTape, isNotNull);
    });
  });

  group('stateAfterStep', () {
    test('a new focus counts one more statement', () {
      final execution = FakeProgramExecution();
      const current = ExecutionState.initial();

      final next = stateAfterStep(current, _step(1), execution);

      expect(next.statementNumber, 1);
      expect(next.status, ExecutionStatus.running);
      expect(next.currentStep.focusRevision, 1);
    });

    test('the same focus does not count again', () {
      final execution = FakeProgramExecution();
      final current = stateAfterStep(
        const ExecutionState.initial(),
        _step(1),
        execution,
      );

      final next = stateAfterStep(current, _step(1), execution);

      expect(next.statementNumber, 1);
    });

    test('the first output opens the output panel', () {
      final execution = FakeProgramExecution(
        outputLinesList: const [OutputLine(text: 'hola', kind: OutputLineKind.programOutput)],
      );

      final next = stateAfterStep(
        const ExecutionState.initial(),
        _step(1),
        execution,
      );

      expect(next.isOutputPanelExpanded, isTrue);
    });

    test('a collapsed panel stays collapsed when output arrives', () {
      final execution = FakeProgramExecution(
        outputLinesList: const [OutputLine(text: 'hola', kind: OutputLineKind.programOutput)],
      );
      final collapsed = const ExecutionState.initial().copyWith(
        userCollapsedOutput: true,
      );

      final next = stateAfterStep(collapsed, _step(1), execution);

      expect(next.isOutputPanelExpanded, isFalse);
    });

    test('a halted step carries its reason', () {
      final next = stateAfterStep(
        const ExecutionState.initial(),
        _step(2, haltReason: 'division_by_zero'),
        FakeProgramExecution(),
      );

      expect(next.status, ExecutionStatus.haltedWithError);
      expect(next.haltMessage, 'division_by_zero');
    });
  });
}
