import 'package:pseudolearn_core/src/evaluation/events/composite_execution_observer.dart';
import 'package:pseudolearn_core/src/evaluation/events/execution_event.dart';
import 'package:pseudolearn_core/src/evaluation/events/recording_execution_observer.dart';
import 'package:test/test.dart';

void main() {
  group('CompositeExecutionObserver', () {
    test('several observers receive the same events in the same order', () {
      final first = RecordingExecutionObserver();
      final second = RecordingExecutionObserver();
      final composite = CompositeExecutionObserver([first, second]);

      const eventA = OutputProducedEvent('a');
      const eventB = OutputProducedEvent('b');
      composite.onEvent(eventA);
      composite.onEvent(eventB);

      expect(first.events, equals([eventA, eventB]));
      expect(second.events, equals([eventA, eventB]));
    });

    test('zero observers does not throw', () {
      final composite = CompositeExecutionObserver(const []);
      expect(() => composite.onEvent(const ExecutionFinishedEvent()),
          returnsNormally);
    });
  });
}
