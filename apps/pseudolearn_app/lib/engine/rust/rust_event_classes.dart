import 'rust_wire_models.dart';

const Set<String> rustOrdinaryEventClasses = {
  'statement_entered',
  'statement_exited',
  'decision',
  'call',
  'return',
  'output',
  'input_requested',
  'input_received',
  'failure',
};

const Set<String> rustTaskEventClasses = {
  'task_spawned',
  'task_suspended',
  'task_ready',
  'task_resumed',
  'task_completed',
  'task_cancel_requested',
  'scope_joined',
  'channel_created',
  'channel_sent',
  'channel_received',
  'channel_closed',
  'effect_delivered',
};

bool rustKnownEventClass(String eventClass) =>
    rustOrdinaryEventClasses.contains(eventClass) ||
    rustTaskEventClasses.contains(eventClass);

final class RustTaskEvent {
  final String eventClass;
  final int line;
  final Map<String, Object?> data;

  const RustTaskEvent({
    required this.eventClass,
    required this.line,
    required this.data,
  });

  static RustTaskEvent? tryFrom(RustEvent event) =>
      rustTaskEventClasses.contains(event.eventClass)
      ? RustTaskEvent(
          eventClass: event.eventClass,
          line: event.line,
          data: event.data,
        )
      : null;

  int? intOf(String field) => (data[field] as num?)?.toInt();

  String? textOf(String field) => data[field] as String?;

  bool? flagOf(String field) => data[field] as bool?;

  int? get task => intOf('task');

  int? get channel => intOf('channel');
}
