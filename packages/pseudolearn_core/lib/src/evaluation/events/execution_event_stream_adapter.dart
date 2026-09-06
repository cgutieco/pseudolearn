import 'dart:async';

import 'execution_event.dart';
import 'execution_observer.dart';

final class ExecutionEventStreamAdapter implements ExecutionObserver {
  final StreamController<ExecutionEvent> _controller =
      StreamController<ExecutionEvent>();

  Stream<ExecutionEvent> get stream => _controller.stream;

  @override
  void onEvent(ExecutionEvent event) => _controller.add(event);

  Future<void> close() => _controller.close();
}
