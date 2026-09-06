import 'execution_event.dart';
import 'execution_observer.dart';

final class RecordingExecutionObserver implements ExecutionObserver {
  final List<ExecutionEvent> events = [];

  @override
  void onEvent(ExecutionEvent event) => events.add(event);
}
