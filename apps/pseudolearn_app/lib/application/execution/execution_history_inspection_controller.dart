import '../../domain/model/execution/execution_observation_result.dart';
import '../../domain/model/execution/execution_observation_state.dart';
import '../../domain/model/execution/execution_value_page.dart';
import 'execution_history_patch.dart';
import 'execution_history_state.dart';
import 'execution_inspection_loader.dart';

final class ExecutionHistoryInspectionController {
  final ExecutionInspectionLoader _loader;

  const ExecutionHistoryInspectionController(this._loader);

  ExecutionHistoryState inspect(
    ExecutionHistoryState state,
    int event,
    int taskId, {
    int frameStart = 0,
    int? selectedFrame,
  }) {
    final snapshot = _loader.load(
      event: event,
      taskId: taskId,
      frameStart: frameStart,
      selectedFrame: selectedFrame,
    );
    final inspection = snapshot.observation;
    if (inspection == null) {
      return state.copyWith(
        ExecutionHistoryPatch(
          error: snapshot.error,
          clearInspection: true,
          clearValues: true,
        ),
      );
    }
    return _withInspection(
      state: state,
      snapshot: snapshot,
      inspection: inspection,
      frameStart: frameStart,
    );
  }

  ExecutionHistoryState loadNextValues(
    ExecutionHistoryState state, {
    bool append = false,
  }) {
    final cursor = state.valueCursor;
    if (state.inspection == null || cursor == null) return state;
    final result = _loader.loadNextValues(
      event: state.selectedEvent,
      taskId: state.selectedTaskId,
      frame: state.selectedFrame,
      cursor: cursor,
    );
    if (result is! ExecutionObservationValue<ExecutionValuePage>) {
      return state.copyWith(ExecutionHistoryPatch(error: _reasonOf(result)));
    }
    final page = result.value;
    return state.copyWith(
      ExecutionHistoryPatch(
        values: append ? [...state.values, ...page.entries] : page.entries,
        valueTotal: page.total,
        valueCursor: page.nextCursor,
        clearCursor: page.nextCursor == null,
        clearError: true,
      ),
    );
  }

  ExecutionHistoryState _withInspection({
    required ExecutionHistoryState state,
    required ExecutionInspectionSnapshot snapshot,
    required ExecutionObservationState inspection,
    required int frameStart,
  }) {
    final page = snapshot.valuePage;
    return state.copyWith(
      ExecutionHistoryPatch(
        inspection: inspection,
        selectedFrame: snapshot.selectedFrame,
        frameStart: frameStart,
        selectedTaskId: inspection.taskId,
        values: page?.entries ?? const [],
        valueTotal: page?.total ?? 0,
        valueCursor: page?.nextCursor,
        clearCursor: page?.nextCursor == null,
        clearError: snapshot.error == null,
        error: snapshot.error,
      ),
    );
  }
}

String _reasonOf(ExecutionObservationResult<Object?>? result) =>
    switch (result) {
      ExecutionObservationUsage() => 'usage',
      ExecutionObservationFailure(reason: final reason) => reason,
      _ => 'invalid_observation_response',
    };
