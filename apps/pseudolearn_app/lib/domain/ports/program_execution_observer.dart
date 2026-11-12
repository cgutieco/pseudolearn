import '../model/execution/execution_history_window.dart';
import '../model/execution/execution_observation_result.dart';
import '../model/execution/execution_observation_state.dart';
import '../model/execution/execution_value_page.dart';

abstract interface class ProgramExecutionObserver {
  ExecutionObservationResult<ExecutionHistoryWindow> historyWindow({
    required int start,
    required int count,
  });

  ExecutionObservationResult<ExecutionObservationState> stateAt({
    required int event,
    required int taskId,
    required int startFrame,
    required int frameCount,
  });

  ExecutionObservationResult<ExecutionValuePage> valuePage({
    required int event,
    required int taskId,
    required int frame,
    required int pageSize,
    String? cursor,
  });
}
