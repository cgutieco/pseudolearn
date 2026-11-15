import 'execution_history_event.dart';

final class ExecutionHistoryWindow {
  final int first;
  final int count;
  final int horizonFirst;
  final int horizonLast;
  final List<ExecutionHistoryEvent> events;

  ExecutionHistoryWindow({
    required this.first,
    required this.count,
    required this.horizonFirst,
    required this.horizonLast,
    required List<ExecutionHistoryEvent> events,
  }) : events = List.unmodifiable(events);
}
