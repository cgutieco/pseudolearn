import 'package:pseudolearn_core/src/evaluation/events/execution_event.dart';
import 'package:pseudolearn_core/src/evaluation/events/execution_event_stream_adapter.dart';
import 'package:test/test.dart';

void main() {
  test('events emitted before anyone listens are not lost', () async {
    final adapter = ExecutionEventStreamAdapter();

    adapter.onEvent(const OutputProducedEvent('uno'));
    adapter.onEvent(const OutputProducedEvent('dos'));

    final received = <ExecutionEvent>[];
    final subscription = adapter.stream.listen(received.add);
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();
    await adapter.close();

    expect(received, hasLength(2));
  });

  test('events emitted after listening arrive in order', () async {
    final adapter = ExecutionEventStreamAdapter();
    final received = <ExecutionEvent>[];
    final subscription = adapter.stream.listen(received.add);

    adapter.onEvent(const OutputProducedEvent('uno'));
    adapter.onEvent(const ExecutionFinishedEvent());
    await Future<void>.delayed(Duration.zero);

    expect(received, hasLength(2));
    expect(received.last, isA<ExecutionFinishedEvent>());

    await subscription.cancel();
    await adapter.close();
  });
}
