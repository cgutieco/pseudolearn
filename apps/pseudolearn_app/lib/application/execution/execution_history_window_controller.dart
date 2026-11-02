import '../../domain/model/execution/execution_history_event.dart';
import '../../domain/model/execution/execution_history_window.dart';
import '../../domain/model/execution/execution_observation_policy.dart';
import '../../domain/model/execution/execution_observation_result.dart';
import '../../domain/ports/program_execution_observer.dart';
import 'execution_history_cache.dart';
import 'execution_history_patch.dart';
import 'execution_history_selection.dart';
import 'execution_history_state.dart';

final class ExecutionHistoryWindowController {
  final ProgramExecutionObserver? _observer;
  final ExecutionHistoryState Function() _currentState;
  final void Function(ExecutionHistoryState) _emit;
  final void Function(ExecutionHistoryEvent, bool) _onEventSelected;
  final ExecutionHistoryCache _cache = ExecutionHistoryCache();

  ExecutionHistoryWindowController({
    required ProgramExecutionObserver? observer,
    required ExecutionHistoryState Function() currentState,
    required void Function(ExecutionHistoryState) emit,
    required void Function(ExecutionHistoryEvent, bool) onEventSelected,
  }) : _observer = observer,
       _currentState = currentState,
       _emit = emit,
       _onEventSelected = onEventSelected;

  void reset() => _cache.clear();

  void selectEvent(int event) {
    final state = _currentState();
    if (event < state.horizonFirst || event > state.liveEvent) {
      _emit(
        state.copyWith(
          const ExecutionHistoryPatch(error: 'event_outside_horizon'),
        ),
      );
      return;
    }
    final start = _windowStart(event, state.horizonFirst);
    final end = _windowEnd(event, state.liveEvent);
    _loadWindow(
      start,
      end - start + 1,
      selectedEvent: event,
      followsLive: event == state.liveEvent,
    );
  }

  void selectRange(int start, int count) {
    final state = _currentState();
    if (start < state.horizonFirst ||
        count < 1 ||
        count > ExecutionObservationPolicy.maximumHistoryWindow ||
        start + count - 1 > state.liveEvent) {
      _emit(
        state.copyWith(
          const ExecutionHistoryPatch(error: 'invalid_history_range'),
        ),
      );
      return;
    }
    _loadWindow(start, count, followsLive: false, forceRange: true);
  }

  void followLive() {
    final state = _currentState();
    if (state.liveEvent >= state.horizonFirst) selectEvent(state.liveEvent);
  }

  void loadNewEvents(int currentEvent) {
    final state = _currentState();
    if (_observer == null) {
      _emit(
        state.copyWith(
          const ExecutionHistoryPatch(error: 'observation_unavailable'),
        ),
      );
      return;
    }
    final newest = state.events.isEmpty ? -1 : state.events.last.index;
    if (currentEvent <= newest && state.horizonLast >= currentEvent) return;
    var start = newest < 0
        ? _windowStart(currentEvent, state.horizonFirst)
        : newest + 1;
    if (state.horizonLast >= 0 && start < state.horizonFirst) {
      start = state.horizonFirst;
    }
    if (start > currentEvent) {
      start = _windowStart(currentEvent, state.horizonFirst);
    }
    if (currentEvent - start + 1 >
        ExecutionObservationPolicy.maximumHistoryWindow) {
      start =
          currentEvent - ExecutionObservationPolicy.maximumHistoryWindow + 1;
    }
    final count = (currentEvent - start + 1)
        .clamp(1, ExecutionObservationPolicy.maximumHistoryWindow)
        .toInt();
    _loadWindow(
      start,
      count,
      selectedEvent: state.followsLive ? currentEvent : null,
      liveEvent: currentEvent,
      followsLive: state.followsLive,
    );
  }

  void _loadWindow(
    int start,
    int count, {
    int? selectedEvent,
    int? liveEvent,
    bool? followsLive,
    bool forceRange = false,
  }) {
    final state = _currentState();
    final observer = _observer;
    if (observer == null) {
      _emit(
        state.copyWith(
          const ExecutionHistoryPatch(error: 'observation_unavailable'),
        ),
      );
      return;
    }
    final result = observer.historyWindow(start: start, count: count);
    if (result is! ExecutionObservationValue<ExecutionHistoryWindow>) {
      _emit(state.copyWith(ExecutionHistoryPatch(error: _reasonOf(result))));
      return;
    }
    final window = result.value;
    _cache.retain(window);
    _emitWindow(
      window,
      selectedEvent: selectedEvent,
      liveEvent: liveEvent,
      followsLive: followsLive,
      forceRange: forceRange,
    );
  }

  void _emitWindow(
    ExecutionHistoryWindow window, {
    int? selectedEvent,
    int? liveEvent,
    bool? followsLive,
    bool forceRange = false,
  }) {
    final state = _currentState();
    final selection = ExecutionHistoryWindowSelection.resolve(
      state: state,
      window: window,
      selectedEvent: selectedEvent,
      liveEvent: liveEvent,
      followsLive: followsLive,
      forceRange: forceRange,
    );
    final selectedRecord = _cache.eventAt(selection.selectedEvent);
    _emit(
      state.copyWith(
        ExecutionHistoryPatch(
          hasExecution: true,
          liveEvent: selection.liveEvent,
          selectedEvent: selection.selectedEvent,
          selectedTaskId: selectedRecord?.taskId ?? state.selectedTaskId,
          horizonFirst: window.horizonFirst,
          horizonLast: window.horizonLast,
          rangeStart: selection.rangeStart,
          rangeEnd: selection.rangeEnd,
          events: _cache.events,
          followsLive: selection.followsLive,
          clearError: true,
        ),
      ),
    );
    if (selectedRecord != null && selection.notifySelection) {
      _onEventSelected(selectedRecord, selection.followsLiveSelection);
    }
  }

  int _windowStart(int event, int first) =>
      (event - ExecutionObservationPolicy.eventWindowSize + 1)
          .clamp(first, event)
          .toInt();

  int _windowEnd(int event, int live) {
    final upper = live < event ? event : live;
    return (event + ExecutionObservationPolicy.eventWindowSize ~/ 2)
        .clamp(event, upper)
        .toInt();
  }
}

String _reasonOf(ExecutionObservationResult<Object?> result) =>
    switch (result) {
      ExecutionObservationUsage() => 'usage',
      ExecutionObservationFailure(reason: final reason) => reason,
      _ => 'invalid_observation_response',
    };
