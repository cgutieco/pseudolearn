import '../../domain/model/execution/execution_polling_policy.dart';
import 'execution_state.dart';

final class ExecutionHistoryLoadGate {
  final Duration _interval;
  final Stopwatch _sinceLoad = Stopwatch();

  ExecutionHistoryLoadGate({
    this._interval = ExecutionPollingPolicy.continuousRefreshInterval,
  });

  bool admits(ExecutionState state) {
    if (!state.isContinuousRun) return true;
    if (!state.isTasksVisible) return false;
    return !_sinceLoad.isRunning || _sinceLoad.elapsed >= _interval;
  }

  void loaded() => _sinceLoad
    ..reset()
    ..start();
}
