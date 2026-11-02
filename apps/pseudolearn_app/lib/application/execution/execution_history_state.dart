import 'package:equatable/equatable.dart';
import '../../domain/model/execution/execution_history_event.dart';
import '../../domain/model/execution/execution_observation_state.dart';
import '../../domain/model/execution/execution_task_context.dart';
import '../../domain/model/execution/execution_value_page.dart';
import 'execution_history_patch.dart';
import 'execution_history_surface.dart';

export 'execution_history_surface.dart';

typedef _ExecutionHistoryValues = ({
  int runId,
  bool hasExecution,
  int liveEvent,
  int selectedEvent,
  int selectedTaskId,
  int selectedFrame,
  int frameStart,
  int horizonFirst,
  int horizonLast,
  int rangeStart,
  int rangeEnd,
  ExecutionHistorySurface surface,
  List<ExecutionHistoryEvent> events,
  List<ExecutionTaskContext> taskContexts,
  ExecutionObservationState? inspection,
  List<ExecutionValueEntry> values,
  int valueTotal,
  String? valueCursor,
  String? error,
  bool followsLive,
});

final class ExecutionHistoryState extends Equatable {
  final int runId;
  final bool hasExecution;
  final int liveEvent;
  final int selectedEvent;
  final int selectedTaskId;
  final int selectedFrame;
  final int frameStart;
  final int horizonFirst;
  final int horizonLast;
  final int rangeStart;
  final int rangeEnd;
  final ExecutionHistorySurface surface;
  final List<ExecutionHistoryEvent> events;
  final List<ExecutionTaskContext> taskContexts;
  final ExecutionObservationState? inspection;
  final List<ExecutionValueEntry> values;
  final int valueTotal;
  final String? valueCursor;
  final String? error;
  final bool followsLive;

  const ExecutionHistoryState({
    required this.runId,
    required this.hasExecution,
    required this.liveEvent,
    required this.selectedEvent,
    required this.selectedTaskId,
    required this.selectedFrame,
    required this.frameStart,
    required this.horizonFirst,
    required this.horizonLast,
    required this.rangeStart,
    required this.rangeEnd,
    required this.surface,
    required this.events,
    this.taskContexts = const [],
    required this.inspection,
    required this.values,
    required this.valueTotal,
    required this.valueCursor,
    required this.error,
    required this.followsLive,
  });

  const ExecutionHistoryState.initial()
    : runId = 0,
      hasExecution = false,
      liveEvent = -1,
      selectedEvent = -1,
      selectedTaskId = 0,
      selectedFrame = 0,
      frameStart = 0,
      horizonFirst = 0,
      horizonLast = -1,
      rangeStart = 0,
      rangeEnd = -1,
      surface = ExecutionHistorySurface.flow,
      events = const [],
      taskContexts = const [],
      inspection = null,
      values = const [],
      valueTotal = 0,
      valueCursor = null,
      error = null,
      followsLive = true;

  ExecutionHistoryState._(_ExecutionHistoryValues values)
    : runId = values.runId,
      hasExecution = values.hasExecution,
      liveEvent = values.liveEvent,
      selectedEvent = values.selectedEvent,
      selectedTaskId = values.selectedTaskId,
      selectedFrame = values.selectedFrame,
      frameStart = values.frameStart,
      horizonFirst = values.horizonFirst,
      horizonLast = values.horizonLast,
      rangeStart = values.rangeStart,
      rangeEnd = values.rangeEnd,
      surface = values.surface,
      events = values.events,
      taskContexts = List.unmodifiable(values.taskContexts),
      inspection = values.inspection,
      values = values.values,
      valueTotal = values.valueTotal,
      valueCursor = values.valueCursor,
      error = values.error,
      followsLive = values.followsLive;

  List<ExecutionHistoryEvent> get visibleEvents => [
    for (final event in events)
      if (event.index >= rangeStart && event.index <= rangeEnd) event,
  ];

  ExecutionHistoryEvent? get selectedRecord {
    for (final event in events) {
      if (event.index == selectedEvent) return event;
    }
    return null;
  }

  bool get canLoadMoreValues => valueCursor != null;

  bool get hasSelectedTask =>
      inspection?.tasks.any((task) => task.taskId == selectedTaskId) ?? false;

  bool get hasSelectedFrame =>
      inspection?.frames.any((frame) => frame.id == selectedFrame) ?? false;

  ExecutionHistoryState copyWith(ExecutionHistoryPatch patch) =>
      ExecutionHistoryState._((
        runId: patch.runId ?? runId,
        hasExecution: patch.hasExecution ?? hasExecution,
        liveEvent: patch.liveEvent ?? liveEvent,
        selectedEvent: patch.selectedEvent ?? selectedEvent,
        selectedTaskId: patch.selectedTaskId ?? selectedTaskId,
        selectedFrame: patch.selectedFrame ?? selectedFrame,
        frameStart: patch.frameStart ?? frameStart,
        horizonFirst: patch.horizonFirst ?? horizonFirst,
        horizonLast: patch.horizonLast ?? horizonLast,
        rangeStart: patch.rangeStart ?? rangeStart,
        rangeEnd: patch.rangeEnd ?? rangeEnd,
        surface: patch.surface ?? surface,
        events: patch.events ?? events,
        taskContexts: patch.taskContexts ?? taskContexts,
        inspection: patch.clearInspection
            ? null
            : patch.inspection ?? inspection,
        values: patch.clearValues ? const [] : patch.values ?? values,
        valueTotal: patch.clearValues ? 0 : patch.valueTotal ?? valueTotal,
        valueCursor: patch.clearValues || patch.clearCursor
            ? null
            : patch.valueCursor ?? valueCursor,
        error: patch.clearError ? null : patch.error ?? error,
        followsLive: patch.followsLive ?? followsLive,
      ));

  @override
  List<Object?> get props => [
    runId,
    hasExecution,
    liveEvent,
    selectedEvent,
    selectedTaskId,
    selectedFrame,
    frameStart,
    horizonFirst,
    horizonLast,
    rangeStart,
    rangeEnd,
    surface,
    events,
    taskContexts,
    inspection,
    values,
    valueTotal,
    valueCursor,
    error,
    followsLive,
  ];
}
