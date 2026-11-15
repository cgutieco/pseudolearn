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
      rustTaskEventClasses.contains(event.eventClass) ? _decode(event) : null;

  static RustTaskEvent _decode(RustEvent event) {
    final fields = _fieldsByClass[event.eventClass]!;
    if (event.data.length != fields.length) {
      throw const FormatException('Invalid task event data');
    }
    for (final entry in fields.entries) {
      final value = event.data[entry.key];
      final valid = switch (entry.value) {
        _RustTaskField.number => value is int && value >= 0,
        _RustTaskField.text => value is String,
        _RustTaskField.flag => value is bool,
      };
      if (!valid) throw const FormatException('Invalid task event data');
    }
    return RustTaskEvent(
      eventClass: event.eventClass,
      line: event.line,
      data: event.data,
    );
  }

  int? intOf(String field) => data[field] as int?;

  String? textOf(String field) => data[field] as String?;

  bool? flagOf(String field) => data[field] as bool?;

  int? get task => intOf('task');

  int? get channel => intOf('channel');
}

enum _RustTaskField { number, text, flag }

const Map<String, Map<String, _RustTaskField>> _fieldsByClass = {
  'task_spawned': {
    'task': _RustTaskField.number,
    'parent': _RustTaskField.number,
    'scope': _RustTaskField.number,
  },
  'task_suspended': {
    'task': _RustTaskField.number,
    'cause': _RustTaskField.text,
    'target': _RustTaskField.number,
  },
  'task_ready': {'task': _RustTaskField.number, 'cause': _RustTaskField.text},
  'task_resumed': {'task': _RustTaskField.number},
  'task_completed': {
    'task': _RustTaskField.number,
    'outcome': _RustTaskField.text,
  },
  'task_cancel_requested': {
    'task': _RustTaskField.number,
    'reason': _RustTaskField.text,
    'origin': _RustTaskField.number,
  },
  'scope_joined': {
    'task': _RustTaskField.number,
    'outcome': _RustTaskField.text,
  },
  'channel_created': {
    'channel': _RustTaskField.number,
    'capacity': _RustTaskField.number,
  },
  'channel_sent': {'channel': _RustTaskField.number},
  'channel_received': {
    'channel': _RustTaskField.number,
    'present': _RustTaskField.flag,
  },
  'channel_closed': {'channel': _RustTaskField.number},
  'effect_delivered': {
    'effect_seq': _RustTaskField.number,
    'delivery_seq': _RustTaskField.number,
    'task': _RustTaskField.number,
  },
};
