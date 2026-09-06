import 'execution_event.dart';
import 'execution_observer.dart';

final class CompositeExecutionObserver implements ExecutionObserver {
  final List<ExecutionObserver> observers;

  const CompositeExecutionObserver(this.observers);

  @override
  void onEvent(ExecutionEvent event) {
    for (final observer in observers) {
      observer.onEvent(event);
    }
  }
}
