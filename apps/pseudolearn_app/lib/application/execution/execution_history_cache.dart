import '../../domain/model/execution/execution_history_event.dart';
import '../../domain/model/execution/execution_history_window.dart';
import '../../domain/model/execution/execution_observation_policy.dart';

final class ExecutionHistoryCache {
  final Map<int, ExecutionHistoryEvent> _events = {};

  void clear() => _events.clear();

  void retain(ExecutionHistoryWindow window) {
    for (final event in window.events) {
      _events[event.index] = event;
    }
    final stale = [
      for (final index in _events.keys)
        if (index < window.horizonFirst) index,
    ];
    for (final index in stale) {
      _events.remove(index);
    }
    final indexes = _events.keys.toList()..sort();
    while (indexes.length > ExecutionObservationPolicy.maximumCachedEvents) {
      _events.remove(indexes.removeAt(0));
    }
  }

  ExecutionHistoryEvent? eventAt(int index) => _events[index];

  List<ExecutionHistoryEvent> get events {
    final indexes = _events.keys.toList()..sort();
    return [for (final index in indexes) _events[index]!];
  }
}
