import '../../domain/model/analysis/source_range.dart';
import '../../domain/model/execution/execution_history_event.dart';
import '../../domain/model/execution/execution_history_window.dart';
import '../../domain/model/execution/execution_observation_state.dart';
import '../../domain/model/execution/execution_value_page.dart';
import 'rust_execution_resource.dart';
import 'rust_transport.dart';
import 'rust_wire_models.dart';

final class RustExecutionObservationApi {
  final RustTransport _transport;
  final RustExecutionResource _resource;

  const RustExecutionObservationApi(this._transport, this._resource);

  ExecutionHistoryWindow historyWindow({
    required int start,
    required int count,
  }) {
    final execution = _identifier();
    final response = _call('history_events', {
      'resource': execution,
      'start': start,
      'count': count,
    });
    return _historyWindow(response);
  }

  ExecutionObservationState stateAt({
    required int event,
    required int taskId,
    required int startFrame,
    required int frameCount,
  }) {
    final execution = _identifier();
    if (!_resource.debugConfigured) {
      _call('debug_configure', {
        'resource': execution,
        'breakpoints': const [],
      });
      _resource.markDebugConfigured();
    }
    final response = _call('debug_state', {
      'resource': execution,
      'event': event,
      'task_id': taskId,
      'start_frame': startFrame,
      'frame_count': frameCount,
    });
    return _observationState(response);
  }

  ExecutionValuePage valuePage({
    required int event,
    required int taskId,
    required int frame,
    required int pageSize,
    String? cursor,
  }) {
    final arguments = <String, Object?>{
      'resource': _identifier(),
      'event': event,
      'task_id': taskId,
      'query': 'frame_variables',
      'target': frame,
      'page_size': pageSize,
      'cursor': ?cursor,
    };
    final response = _call('query_page', arguments);
    return _valuePage(response);
  }

  int _identifier() =>
      _resource.identifier ??
      (throw const RustBridgeFailure(
        family: 'usage',
        detail: 'execution is not active',
      ));

  Map<String, Object?> _call(String operation, Map<String, Object?> arguments) {
    final response = _transport.call(operation, arguments);
    if (response is Map<String, Object?>) return response;
    throw const FormatException('Invalid observation response');
  }

  ExecutionHistoryWindow _historyWindow(Map<String, Object?> response) {
    final first = _requiredInt(response, 'first');
    final count = _requiredInt(response, 'count');
    final horizon = _requiredMap(response, 'horizon');
    final events = response['events'];
    if (events is! List<Object?>) {
      throw const FormatException('Invalid history events');
    }
    return ExecutionHistoryWindow(
      first: first,
      count: count,
      horizonFirst: _requiredInt(horizon, 'first'),
      horizonLast: _requiredInt(horizon, 'last'),
      events: [
        for (var index = 0; index < events.length; index++)
          _historyEvent(_requiredMapValue(events[index]), first + index),
      ],
    );
  }

  ExecutionHistoryEvent _historyEvent(Map<String, Object?> json, int index) {
    final event = RustEvent.fromJson(json);
    final taskId = event.taskId;
    if (taskId == null) throw const FormatException('Missing event task');
    final source = json['source'] as Map<String, Object?>?;
    final span = source?['span'] as Map<String, Object?>?;
    return ExecutionHistoryEvent(
      index: index,
      taskId: taskId,
      eventClass: event.eventClass,
      line: event.line,
      depth: event.depth,
      data: event.data,
      revisionId: event.sourceRevisionId,
      nodeId: event.nodeId,
      sourceRange: span == null ? null : _sourceRange(span),
    );
  }

  ExecutionObservationState _observationState(Map<String, Object?> response) {
    final rawFrames = response['frames'];
    final rawTasks = response['threads'];
    if (rawFrames is! List<Object?> || rawTasks is! List<Object?>) {
      throw const FormatException('Invalid observation state');
    }
    return ExecutionObservationState(
      event: _requiredInt(response, 'event'),
      taskId: _requiredInt(response, 'task_id'),
      totalFrames: _requiredInt(response, 'total_frames'),
      frames: [
        for (final frame in rawFrames) _observedFrame(_requiredMapValue(frame)),
      ],
      tasks: [
        for (final task in rawTasks) _observedTask(_requiredMapValue(task)),
      ],
    );
  }

  ExecutionObservedFrame _observedFrame(Map<String, Object?> json) =>
      ExecutionObservedFrame(
        id: _requiredInt(json, 'id'),
        name: _requiredString(json, 'name'),
        sourceId: _requiredInt(json, 'source_id'),
        revisionId: json['revision'] as String?,
        line: _requiredInt(json, 'line'),
        column: _requiredInt(json, 'column'),
      );

  ExecutionObservedTask _observedTask(Map<String, Object?> json) =>
      ExecutionObservedTask(
        taskId: _requiredInt(json, 'id'),
        name: _requiredString(json, 'name'),
        state: _requiredString(json, 'state'),
      );

  ExecutionValuePage _valuePage(Map<String, Object?> response) {
    final rawEntries = response['elements'];
    if (rawEntries is! List<Object?>) {
      throw const FormatException('Invalid value page');
    }
    return ExecutionValuePage(
      entries: [
        for (final entry in rawEntries) _valueEntry(_requiredMapValue(entry)),
      ],
      total: _requiredInt(response, 'total'),
      valuesRead: _requiredInt(response, 'values_read'),
      truncated: response['truncated'] as bool,
      nextCursor: response['next_cursor'] as String?,
    );
  }

  ExecutionValueEntry _valueEntry(Map<String, Object?> json) {
    final value = json['value'];
    if (value is! Map<String, Object?>) {
      throw const FormatException('Invalid variable value');
    }
    return ExecutionValueEntry(
      name: _requiredString(json, 'name'),
      value: value,
    );
  }
}

Map<String, Object?> _requiredMap(Map<String, Object?> source, String key) {
  final value = source[key];
  if (value is! Map<String, Object?>) {
    throw const FormatException('Invalid observation map');
  }
  return value;
}

Map<String, Object?> _requiredMapValue(Object? value) {
  if (value is! Map<String, Object?>) {
    throw const FormatException('Invalid observation item');
  }
  return value;
}

int _requiredInt(Map<String, Object?> source, String key) {
  final value = source[key];
  if (value is! int || value < 0) {
    throw const FormatException('Invalid observation number');
  }
  return value;
}

String _requiredString(Map<String, Object?> source, String key) {
  final value = source[key];
  if (value is! String) throw const FormatException('Invalid observation text');
  return value;
}

SourceRange _sourceRange(Map<String, Object?> span) {
  final start = _requiredMap(span, 'start');
  final end = _requiredMap(span, 'end');
  return SourceRange(
    startOffset: int.parse(_requiredString(span, 'start_byte')),
    endOffset: int.parse(_requiredString(span, 'end_byte')),
    startLine: _requiredInt(start, 'line'),
    startColumn: _requiredInt(start, 'column'),
    endLine: _requiredInt(end, 'line'),
    endColumn: _requiredInt(end, 'column'),
  );
}
