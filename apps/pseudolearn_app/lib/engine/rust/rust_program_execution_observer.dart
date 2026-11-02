import '../../domain/model/execution/execution_history_window.dart';
import '../../domain/model/execution/execution_observation_result.dart';
import '../../domain/model/execution/execution_observation_state.dart';
import '../../domain/model/execution/execution_value_page.dart';
import '../../domain/ports/program_execution_observer.dart';
import 'rust_execution_observation_api.dart';
import 'rust_execution_resource.dart';
import 'rust_transport.dart';

final class RustProgramExecutionObserver implements ProgramExecutionObserver {
  final RustExecutionObservationApi _api;

  RustProgramExecutionObserver(
    RustTransport transport,
    RustExecutionResource resource,
  ) : _api = RustExecutionObservationApi(transport, resource);

  @override
  ExecutionObservationResult<ExecutionHistoryWindow> historyWindow({
    required int start,
    required int count,
  }) => _read(() => _api.historyWindow(start: start, count: count));

  @override
  ExecutionObservationResult<ExecutionObservationState> stateAt({
    required int event,
    required int taskId,
    required int startFrame,
    required int frameCount,
  }) => _read(
    () => _api.stateAt(
      event: event,
      taskId: taskId,
      startFrame: startFrame,
      frameCount: frameCount,
    ),
  );

  @override
  ExecutionObservationResult<ExecutionValuePage> valuePage({
    required int event,
    required int taskId,
    required int frame,
    required int pageSize,
    String? cursor,
  }) => _read(
    () => _api.valuePage(
      event: event,
      taskId: taskId,
      frame: frame,
      pageSize: pageSize,
      cursor: cursor,
    ),
  );

  ExecutionObservationResult<T> _read<T>(T Function() read) {
    try {
      return ExecutionObservationValue(read());
    } on RustBridgeFailure catch (failure) {
      if (failure.isUsage) return const ExecutionObservationUsage();
      return ExecutionObservationFailure(failure.family);
    } on FormatException {
      return const ExecutionObservationFailure('invalid_observation_response');
    } on TypeError {
      return const ExecutionObservationFailure('invalid_observation_response');
    } on Object {
      return const ExecutionObservationFailure('invalid_observation_response');
    }
  }
}
