import 'execution_event.dart';

abstract interface class ExecutionObserver {
  void onEvent(ExecutionEvent event);
}
