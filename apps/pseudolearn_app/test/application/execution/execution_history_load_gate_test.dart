import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/execution/execution_history_load_gate.dart';
import 'package:pseudolearn_app/application/execution/execution_state.dart';

ExecutionState _state(
  ExecutionStatus status, {
  bool isContinuous = true,
  bool isTasksVisible = false,
}) => const ExecutionState.initial().copyWith(
  status: status,
  isContinuous: isContinuous,
  isTasksVisible: isTasksVisible,
);

void main() {
  group('ExecutionHistoryLoadGate', () {
    test('a stepping run always reads history', () {
      final gate = ExecutionHistoryLoadGate(
        interval: const Duration(hours: 1),
      );
      gate.loaded();

      expect(
        gate.admits(_state(ExecutionStatus.running, isContinuous: false)),
        isTrue,
      );
    });

    test('a continuous run with the tasks hidden never reads history', () {
      final gate = ExecutionHistoryLoadGate(interval: Duration.zero);

      expect(gate.admits(_state(ExecutionStatus.running)), isFalse);
      expect(gate.admits(_state(ExecutionStatus.pausedAwaitingEffect)), isFalse);
    });

    test('a continuous run that stops reads history at once', () {
      final gate = ExecutionHistoryLoadGate(
        interval: const Duration(hours: 1),
      );
      gate.loaded();

      expect(gate.admits(_state(ExecutionStatus.finishedSuccess)), isTrue);
      expect(gate.admits(_state(ExecutionStatus.idle)), isTrue);
    });

    test('visible tasks read history once the interval has passed', () {
      final gate = ExecutionHistoryLoadGate(interval: Duration.zero);

      expect(
        gate.admits(_state(ExecutionStatus.running, isTasksVisible: true)),
        isTrue,
      );
    });

    test('visible tasks read history before any read happened', () {
      final gate = ExecutionHistoryLoadGate(
        interval: const Duration(hours: 1),
      );

      expect(
        gate.admits(_state(ExecutionStatus.running, isTasksVisible: true)),
        isTrue,
      );
    });

    test('visible tasks wait for the interval after a read', () {
      final gate = ExecutionHistoryLoadGate(
        interval: const Duration(hours: 1),
      );
      gate.loaded();

      expect(
        gate.admits(_state(ExecutionStatus.running, isTasksVisible: true)),
        isFalse,
      );
    });
  });
}
