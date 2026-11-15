import '../../domain/model/execution/execution_history_window.dart';
import '../../domain/model/execution/execution_observation_policy.dart';
import 'execution_history_state.dart';

typedef ExecutionHistoryWindowSelectionResult = ({
  int liveEvent,
  int selectedEvent,
  int rangeStart,
  int rangeEnd,
  bool followsLive,
  bool followsLiveSelection,
  bool notifySelection,
});

final class ExecutionHistoryWindowSelection {
  const ExecutionHistoryWindowSelection._();

  static ExecutionHistoryWindowSelectionResult resolve({
    required ExecutionHistoryState state,
    required ExecutionHistoryWindow window,
    required int? selectedEvent,
    required int? liveEvent,
    required bool? followsLive,
    required bool forceRange,
  }) {
    final expired = _isExpired(state, window, selectedEvent);
    final follows = followsLive ?? state.followsLive;
    final selected = _resolvedEvent(
      state: state,
      window: window,
      selectedEvent: selectedEvent,
      expired: expired,
    );
    final live = liveEvent ?? state.liveEvent;
    final changeRange = forceRange || follows || expired;
    final range = _visibleRange(
      state: state,
      window: window,
      selectedEvent: selectedEvent,
      liveEvent: live,
      changeRange: changeRange,
    );
    return _selectionResult(
      liveEvent: live,
      selectedEvent: selected,
      range: range,
      followsLive: follows,
      requestedEvent: selectedEvent,
      expired: expired,
    );
  }

  static ExecutionHistoryWindowSelectionResult _selectionResult({
    required int liveEvent,
    required int selectedEvent,
    required ({int start, int end}) range,
    required bool followsLive,
    required int? requestedEvent,
    required bool expired,
  }) => (
    liveEvent: liveEvent,
    selectedEvent: selectedEvent,
    rangeStart: range.start,
    rangeEnd: range.end,
    followsLive: followsLive,
    followsLiveSelection: requestedEvent != null && followsLive,
    notifySelection: requestedEvent != null || expired,
  );

  static ({int start, int end}) _visibleRange({
    required ExecutionHistoryState state,
    required ExecutionHistoryWindow window,
    required int? selectedEvent,
    required int liveEvent,
    required bool changeRange,
  }) => (
    start: selectedEvent != null
        ? _windowStart(selectedEvent, window.horizonFirst)
        : changeRange
        ? window.first
        : state.rangeStart,
    end: selectedEvent != null
        ? _windowEnd(selectedEvent, liveEvent)
        : changeRange
        ? window.first + window.events.length - 1
        : state.rangeEnd,
  );

  static bool _isExpired(
    ExecutionHistoryState state,
    ExecutionHistoryWindow window,
    int? selectedEvent,
  ) => selectedEvent == null && state.selectedEvent < window.horizonFirst;

  static int _resolvedEvent({
    required ExecutionHistoryState state,
    required ExecutionHistoryWindow window,
    required int? selectedEvent,
    required bool expired,
  }) => selectedEvent ?? (expired ? window.first : state.selectedEvent);

  static int _windowStart(int event, int first) =>
      (event - ExecutionObservationPolicy.eventWindowSize + 1)
          .clamp(first, event)
          .toInt();

  static int _windowEnd(int event, int live) {
    final upper = live < event ? event : live;
    return (event + ExecutionObservationPolicy.eventWindowSize ~/ 2)
        .clamp(event, upper)
        .toInt();
  }
}
