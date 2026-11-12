import 'dart:async';

import 'package:bloc/bloc.dart';
import '../../domain/model/execution/execution_history_event.dart';
import '../../domain/model/execution/execution_observation_policy.dart';
import '../../domain/model/execution/execution_task_context.dart';
import '../../domain/model/execution/task_flow_scene.dart';
import '../../domain/model/execution/task_structure_scene.dart';
import '../../domain/ports/program_execution_observer.dart';
import '../../domain/ports/task_flow_projector.dart';
import '../../domain/ports/task_structure_projector.dart';
import 'execution_history_command.dart';
import 'execution_history_patch.dart';
import 'execution_history_inspection_controller.dart';
import 'execution_history_state.dart';
import 'execution_history_task_pin.dart';
import 'execution_history_window_controller.dart';
import 'execution_inspection_loader.dart';
import 'execution_state.dart';

final class ExecutionHistoryCubit extends Cubit<ExecutionHistoryState> {
  final TaskFlowProjector _flowProjector;
  final TaskStructureProjector _structureProjector;
  late final ExecutionHistoryInspectionController _inspections;
  late final ExecutionHistoryWindowController _windows;
  late final StreamSubscription<ExecutionState> _subscription;

  ExecutionHistoryCubit({
    required Stream<ExecutionState> executionStates,
    required ProgramExecutionObserver? observer,
    required this._flowProjector,
    required this._structureProjector,
  }) : super(const ExecutionHistoryState.initial()) {
    _windows = ExecutionHistoryWindowController(
      observer: observer,
      currentState: () => state,
      emit: (next) => emit(next),
      onEventSelected: _onSelectedEvent,
    );
    _inspections = ExecutionHistoryInspectionController(
      ExecutionInspectionLoader(observer),
    );
    _subscription = executionStates.listen(_onExecutionState);
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }

  TaskFlowScene projectFlow() => _flowProjector.project(
    events: state.events,
    rangeStart: state.rangeStart,
    rangeEnd: state.rangeEnd,
  );

  TaskStructureScene projectStructure() => _structureProjector.project(
    events: state.events,
    horizonFirst: state.horizonFirst,
    selectedEvent: state.selectedEvent,
    liveEvent: state.liveEvent,
    taskContexts: state.taskContexts,
  );

  void dispatch(ExecutionHistoryCommand command) {
    switch (command) {
      case SelectHistorySurface(:final surface):
        _selectSurface(surface);
      case SelectHistoryEvent(:final event):
        _windows.selectEvent(event);
      case SelectHistoryTask(:final taskId):
        _selectTask(taskId);
      case SelectHistoryFrame(:final frame):
        _selectFrame(frame);
      case SelectHistoryFramePage(:final frameStart):
        _selectFramePage(frameStart);
      case SelectHistoryRange(:final start, :final count):
        _windows.selectRange(start, count);
      case FollowCurrentHistoryEvent():
        _windows.followLive();
      case LoadNextValuePage():
        _loadNextValues();
    }
  }

  void _selectSurface(ExecutionHistorySurface surface) {
    emit(
      state.copyWith(ExecutionHistoryPatch(surface: surface, clearError: true)),
    );
    if (surface == ExecutionHistorySurface.events && state.selectedEvent >= 0) {
      _loadInspection(state.selectedEvent, state.selectedTaskId);
    }
  }

  void _selectTask(int? taskId) {
    final selected = taskId ?? state.selectedRecord?.taskId ?? 0;
    emit(
      state.copyWith(
        ExecutionHistoryPatch(
          selectedTaskId: selected,
          taskPinned: taskId != null,
        ),
      ),
    );
    if (state.selectedEvent >= 0 &&
        state.surface == ExecutionHistorySurface.events) {
      _loadInspection(state.selectedEvent, selected);
    }
  }

  void _selectFrame(int frame) {
    final frames = state.inspection?.frames ?? const [];
    if (frames.any((item) => item.id == frame)) {
      _loadInspection(
        state.selectedEvent,
        state.selectedTaskId,
        frameStart: state.frameStart,
        selectedFrame: frame,
      );
    }
  }

  void _selectFramePage(int frameStart) {
    final total = state.inspection?.totalFrames ?? 0;
    if (frameStart >= 0 && frameStart < total) {
      _loadInspection(
        state.selectedEvent,
        state.selectedTaskId,
        frameStart: frameStart,
      );
    }
  }

  void _loadNextValues() {
    emit(_inspections.loadNextValues(state, append: true));
  }

  void _onExecutionState(ExecutionState executionState) {
    if (executionState.runId != state.runId) _beginRun(executionState);
    _updateTaskContexts(executionState);
    final event = executionState.currentStep.eventIndex;
    if (event < 0) {
      if (!executionState.isInFlight) _clearRun(executionState.runId);
      return;
    }
    _windows.loadNewEvents(event);
  }

  void _beginRun(ExecutionState executionState) {
    _windows.reset();
    emit(
      ExecutionHistoryState.initial().copyWith(
        ExecutionHistoryPatch(
          runId: executionState.runId,
          hasExecution: true,
          taskContexts: executionState.currentStep.taskContexts,
        ),
      ),
    );
  }

  void _updateTaskContexts(ExecutionState executionState) {
    final contexts = executionState.currentStep.taskContexts;
    if (contexts.isEmpty && state.taskContexts.isEmpty) return;
    if (_sameContexts(contexts, state.taskContexts)) return;
    emit(state.copyWith(ExecutionHistoryPatch(taskContexts: contexts)));
  }

  void _clearRun(int runId) {
    _windows.reset();
    emit(
      ExecutionHistoryState.initial().copyWith(
        ExecutionHistoryPatch(runId: runId),
      ),
    );
  }

  void _onSelectedEvent(ExecutionHistoryEvent event, bool followsLive) {
    final taskId = inspectedTaskAt(state, event);
    emit(
      state.copyWith(
        ExecutionHistoryPatch(
          selectedEvent: event.index,
          selectedTaskId: taskId,
          rangeStart: _visibleStart(event.index),
          rangeEnd: _visibleEnd(event.index),
          followsLive: followsLive,
          frameStart: 0,
          clearInspection: true,
          clearValues: true,
          clearError: true,
        ),
      ),
    );
    if (state.surface == ExecutionHistorySurface.events) {
      _loadInspection(event.index, taskId);
    }
  }

  int _visibleStart(int event) =>
      (event - ExecutionObservationPolicy.eventWindowSize + 1)
          .clamp(state.horizonFirst, event)
          .toInt();

  int _visibleEnd(int event) {
    final latest = state.liveEvent < event ? event : state.liveEvent;
    return (event + ExecutionObservationPolicy.eventWindowSize ~/ 2)
        .clamp(event, latest)
        .toInt();
  }

  void _loadInspection(
    int event,
    int taskId, {
    int frameStart = 0,
    int? selectedFrame,
  }) {
    emit(
      _inspections.inspect(
        state,
        event,
        taskId,
        frameStart: frameStart,
        selectedFrame: selectedFrame,
      ),
    );
  }
}

bool _sameContexts(
  List<ExecutionTaskContext> left,
  List<ExecutionTaskContext> right,
) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) return false;
  }
  return true;
}
