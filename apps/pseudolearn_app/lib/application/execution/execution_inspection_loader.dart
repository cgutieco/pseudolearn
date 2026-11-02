import '../../domain/model/execution/execution_observation_result.dart';
import '../../domain/model/execution/execution_observation_state.dart';
import '../../domain/model/execution/execution_value_page.dart';
import '../../domain/model/execution/execution_observation_policy.dart';
import '../../domain/ports/program_execution_observer.dart';

final class ExecutionInspectionSnapshot {
  final ExecutionObservationState? observation;
  final int selectedFrame;
  final ExecutionValuePage? valuePage;
  final String? error;

  const ExecutionInspectionSnapshot({
    required this.observation,
    required this.selectedFrame,
    required this.valuePage,
    required this.error,
  });
}

final class ExecutionInspectionLoader {
  final ProgramExecutionObserver? _observer;

  const ExecutionInspectionLoader(this._observer);

  ExecutionInspectionSnapshot load({
    required int event,
    required int taskId,
    required int frameStart,
    int? selectedFrame,
  }) {
    final observer = _observer;
    if (observer == null) return _failure('observation_unavailable');
    final result = observer.stateAt(
      event: event,
      taskId: taskId,
      startFrame: frameStart,
      frameCount: ExecutionObservationPolicy.frameWindowSize,
    );
    if (result is! ExecutionObservationValue<ExecutionObservationState>) {
      return _failure(_reasonOf(result));
    }
    final observation = result.value;
    final frame = _selectedFrame(observation, selectedFrame);
    final values = observation.totalFrames > 0 && observation.frames.isNotEmpty
        ? _loadValues(
            observer: observer,
            event: event,
            taskId: taskId,
            frame: frame,
          )
        : const _LoadedValues(page: null, error: null);
    return ExecutionInspectionSnapshot(
      observation: observation,
      selectedFrame: frame,
      valuePage: values.page,
      error: values.error,
    );
  }

  ExecutionObservationResult<ExecutionValuePage>? loadNextValues({
    required int event,
    required int taskId,
    required int frame,
    required String cursor,
  }) => _observer?.valuePage(
    event: event,
    taskId: taskId,
    frame: frame,
    pageSize: ExecutionObservationPolicy.valuePageSize,
    cursor: cursor,
  );

  int _selectedFrame(ExecutionObservationState observation, int? requested) {
    for (final frame in observation.frames) {
      if (frame.id == requested) return frame.id;
    }
    return observation.frames.isEmpty ? 0 : observation.frames.first.id;
  }

  _LoadedValues _loadValues({
    required ProgramExecutionObserver observer,
    required int event,
    required int taskId,
    required int frame,
  }) {
    final result = observer.valuePage(
      event: event,
      taskId: taskId,
      frame: frame,
      pageSize: ExecutionObservationPolicy.valuePageSize,
    );
    return result is ExecutionObservationValue<ExecutionValuePage>
        ? _LoadedValues(page: result.value, error: null)
        : _LoadedValues(page: null, error: _reasonOf(result));
  }

  ExecutionInspectionSnapshot _failure(String error) =>
      ExecutionInspectionSnapshot(
        observation: null,
        selectedFrame: 0,
        valuePage: null,
        error: error,
      );
}

final class _LoadedValues {
  final ExecutionValuePage? page;
  final String? error;

  const _LoadedValues({required this.page, required this.error});
}

String _reasonOf(ExecutionObservationResult<Object?> result) =>
    switch (result) {
      ExecutionObservationUsage() => 'usage',
      ExecutionObservationFailure(reason: final reason) => reason,
      _ => 'invalid_observation_response',
    };
