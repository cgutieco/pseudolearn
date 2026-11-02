import '../../domain/model/execution/execution_history_event.dart';
import '../../domain/model/execution/execution_observation_state.dart';
import '../../domain/model/execution/execution_value_page.dart';
import 'execution_history_surface.dart';

final class ExecutionHistoryPatch {
  final int? runId;
  final bool? hasExecution;
  final int? liveEvent;
  final int? selectedEvent;
  final int? selectedTaskId;
  final int? selectedFrame;
  final int? frameStart;
  final int? horizonFirst;
  final int? horizonLast;
  final int? rangeStart;
  final int? rangeEnd;
  final ExecutionHistorySurface? surface;
  final List<ExecutionHistoryEvent>? events;
  final ExecutionObservationState? inspection;
  final List<ExecutionValueEntry>? values;
  final int? valueTotal;
  final String? valueCursor;
  final String? error;
  final bool? followsLive;
  final bool clearInspection;
  final bool clearValues;
  final bool clearCursor;
  final bool clearError;

  const ExecutionHistoryPatch({
    this.runId,
    this.hasExecution,
    this.liveEvent,
    this.selectedEvent,
    this.selectedTaskId,
    this.selectedFrame,
    this.frameStart,
    this.horizonFirst,
    this.horizonLast,
    this.rangeStart,
    this.rangeEnd,
    this.surface,
    this.events,
    this.inspection,
    this.values,
    this.valueTotal,
    this.valueCursor,
    this.error,
    this.followsLive,
    this.clearInspection = false,
    this.clearValues = false,
    this.clearCursor = false,
    this.clearError = false,
  });
}
