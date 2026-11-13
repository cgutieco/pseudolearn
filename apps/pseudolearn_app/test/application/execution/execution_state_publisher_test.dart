import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/execution/execution_state.dart';
import 'package:pseudolearn_app/application/execution/execution_state_publisher.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_step.dart';

ExecutionState _atStep(int stepNumber, {bool isFinished = false}) =>
    ExecutionState(
      status: ExecutionStatus.running,
      currentStep: ExecutionStep(
        stepNumber: stepNumber,
        scopeName: 'global',
        scopeDepth: 1,
        isFinished: isFinished,
      ),
      outputLines: const [],
    );

void main() {
  group('ExecutionStatePublisher', () {
    late List<ExecutionState> published;

    setUp(() => published = []);

    test('an unthrottled state is published at once', () {
      final publisher = ExecutionStatePublisher(
        published.add,
        interval: const Duration(hours: 1),
      );

      publisher.publish(_atStep(1), throttled: false);
      publisher.publish(_atStep(2), throttled: false);

      expect(published.map((state) => state.currentStep.stepNumber), [1, 2]);
    });

    test('throttled states wait for the interval and keep the latest', () {
      final publisher = ExecutionStatePublisher(
        published.add,
        interval: const Duration(hours: 1),
      );
      final initial = _atStep(0);

      publisher.publish(_atStep(1), throttled: true);
      publisher.publish(_atStep(2), throttled: true);

      expect(published, isEmpty);
      expect(publisher.latest(initial).currentStep.stepNumber, 2);
      publisher.flush();
      expect(published.single.currentStep.stepNumber, 2);
      expect(publisher.latest(initial), same(initial));
    });

    test('a terminal state is never held back', () {
      final publisher = ExecutionStatePublisher(
        published.add,
        interval: const Duration(hours: 1),
      );

      publisher.publish(_atStep(1), throttled: true);
      publisher.publish(_atStep(2, isFinished: true), throttled: true);

      expect(published.single.currentStep.isFinished, isTrue);
    });

    test('a spent interval publishes the throttled state', () {
      final publisher = ExecutionStatePublisher(
        published.add,
        interval: Duration.zero,
      );

      publisher.publish(_atStep(1), throttled: true);

      expect(published.single.currentStep.stepNumber, 1);
    });

    test('flushing with nothing held publishes nothing', () {
      ExecutionStatePublisher(published.add).flush();

      expect(published, isEmpty);
    });

    test('a discarded state is never published', () {
      final publisher = ExecutionStatePublisher(
        published.add,
        interval: const Duration(hours: 1),
      );
      final initial = _atStep(0);

      publisher.publish(_atStep(1), throttled: true);
      publisher.discard();
      publisher.flush();

      expect(published, isEmpty);
      expect(publisher.latest(initial), same(initial));
    });
  });
}
