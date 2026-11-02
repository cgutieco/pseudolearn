import '../../domain/model/execution/execution_history_event.dart';

final class TaskFlowGeometry {
  static const double laneSpacing = 64;
  static const double leftMargin = 104;
  static const double rightMargin = 24;
  static const double eventSpacing = 48;

  const TaskFlowGeometry._();

  static List<ExecutionHistoryEvent> orderedEvents(
    List<ExecutionHistoryEvent> events,
  ) =>
      events.toList()..sort((left, right) => left.index.compareTo(right.index));

  static List<int> taskIds(List<ExecutionHistoryEvent> events) {
    final values = <int>{0};
    for (final event in events) {
      values.add(event.taskId);
      final child = integer(event.data['task']);
      if (event.eventClass == 'task_spawned' && child != null) {
        values.add(child);
      }
      final target = integer(event.data['target']);
      if (event.eventClass == 'task_suspended' &&
          event.data['cause'] == 'task' &&
          target != null) {
        values.add(target);
      }
    }
    return values.toList()..sort();
  }

  static double contentWidth({
    required double width,
    required int start,
    required int end,
  }) {
    final eventCount = end - start + 1;
    final minimum = leftMargin + rightMargin + eventCount * eventSpacing;
    return width > minimum ? width : minimum;
  }

  static double eventX({
    required int event,
    required int start,
    required int end,
    required double width,
  }) {
    final span = end - start;
    final fraction = span <= 0 ? 0.0 : (event - start) / span;
    final available = (width - leftMargin - rightMargin)
        .clamp(0.0, width)
        .toDouble();
    return leftMargin + available * fraction;
  }

  static int? integer(Object? value) =>
      value is int && value >= 0 ? value : null;
}
