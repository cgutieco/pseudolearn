import 'package:pseudolearn_core/src/evaluation/events/execution_event.dart';
import 'package:pseudolearn_core/src/evaluation/events/recording_execution_observer.dart';
import 'package:test/test.dart';

void main() {
  test('RecordingExecutionObserver accumulates events in arrival order', () {
    final observer = RecordingExecutionObserver();
    expect(observer.events, isEmpty);

    observer.onEvent(const OutputProducedEvent('uno'));
    observer.onEvent(const OutputProducedEvent('dos'));
    observer.onEvent(const ExecutionFinishedEvent());

    expect(observer.events, hasLength(3));
    expect(observer.events[0], isA<OutputProducedEvent>());
    expect(observer.events[2], isA<ExecutionFinishedEvent>());
  });
}
