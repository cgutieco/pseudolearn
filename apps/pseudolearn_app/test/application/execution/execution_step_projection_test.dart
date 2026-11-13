import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/execution/execution_state.dart';
import 'package:pseudolearn_app/application/execution/execution_step_projection.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_step.dart';
import 'package:pseudolearn_app/domain/model/execution/output_line.dart';

import '../../fakes/fake_program_execution.dart';

ExecutionStep _step(int revision, {String? haltReason}) => ExecutionStep(
  stepNumber: revision,
  focusRevision: revision,
  scopeName: 'global',
  scopeDepth: 1,
  isHalted: haltReason != null,
  haltReason: haltReason,
);

void main() {
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
