import '../../domain/model/execution/execution_polling_policy.dart';
import 'execution_state.dart';

final class ExecutionStatePublisher {
  final void Function(ExecutionState) _emit;
  final Duration _interval;
  final Stopwatch _sincePublish = Stopwatch()..start();
  ExecutionState? _pending;

  ExecutionStatePublisher(
    this._emit, {
    this._interval = ExecutionPollingPolicy.continuousRefreshInterval,
  });

  ExecutionState latest(ExecutionState published) => _pending ?? published;

  void publish(ExecutionState next, {required bool throttled}) {
    final isDue = _sincePublish.elapsed >= _interval;
    if (throttled && !isDue && !next.currentStep.isTerminal) {
      _pending = next;
      return;
    }
    _pending = null;
    _sincePublish.reset();
    _emit(next);
  }

  void flush() {
    final pending = _pending;
    if (pending == null) return;
    publish(pending, throttled: false);
  }

  void discard() => _pending = null;
}
