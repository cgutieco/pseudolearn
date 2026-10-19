import 'dart:convert';
import 'dart:math' as math;

import 'package:pseudolearn_app/engine/rust/rust_analysis_api.dart';
import 'package:pseudolearn_app/engine/rust/rust_execution_api.dart';
import 'package:pseudolearn_app/engine/rust/rust_transport.dart';
import 'package:pseudolearn_app/engine/rust/rust_wire_models.dart';

Future<Map<String, Object?>> runSnapshotScenario(
  RustTransport transport,
  Map<String, Object?> input,
) async {
  final handle = RustAnalysisApi(
    transport,
  ).open(source: input['program'] as String, profile: 'es', locale: 'es');
  final analysisApi = RustAnalysisApi(transport);
  final executionApi = RustExecutionApi(transport);
  try {
    final analysis = analysisApi.report(handle);
    if (analysis['tree'] != true) return {'error': 'analysis'};
    final execution = executionApi.start(handle);
    final retention = input['retention_events'];
    if (retention is int) {
      transport.call('set_retention', {
        'resource': execution,
        'events': retention,
      });
    }
    final events = <RustEvent>[];
    var termination = RustTerminationKind.running;
    while (termination == RustTerminationKind.running) {
      final batch = executionApi.advance(execution, 25);
      events.addAll(batch.events);
      termination = batch.termination;
    }
    if (input['query'] == 'array' || input['reuse_cursor_for_event'] is int) {
      return _arrayResult(transport, execution, events, input);
    }
    if (input['query'] == 'object_graph') {
      return _objectGraphResult(transport, execution, handle.document, events);
    }
    if (input['query_event'] is int) {
      return _retentionResult(transport, execution, events, input);
    }
    return {'error': 'unsupported_snapshot_case'};
  } finally {
    analysisApi.release(handle);
  }
}

Map<String, Object?> _arrayResult(
  RustTransport transport,
  int execution,
  List<RustEvent> events,
  Map<String, Object?> input,
) {
  var event = math.max(0, events.length - 1);
  int? reference;
  for (var candidateEvent = event; candidateEvent >= 0; candidateEvent--) {
    try {
      final frame = _map(
        transport.call('query_frame', {
          'resource': execution,
          'event': candidateEvent,
          'frame': 0,
        }),
      );
      final variables = _map(frame['variables']);
      for (final variable in variables.values) {
        final candidateReference = _mapOrEmpty(variable)['ref'];
        if (candidateReference is int) {
          event = candidateEvent;
          reference = candidateReference;
          break;
        }
      }
      if (reference != null) break;
    } on RustBridgeFailure {
      continue;
    }
  }
  if (reference == null) {
    throw const RustBridgeFailure(
      family: 'usage',
      detail: 'execution has no visible array reference',
    );
  }
  final referenceId = reference;
  final pageSize = input['page_size'] as int? ?? 4096;
  final firstPage = _page(transport, execution, event, referenceId, pageSize);
  final dimensions = (firstPage['dimensions'] as List<Object?>).cast<int>();
  final elements = (firstPage['elements'] as List<Object?>)
      .cast<Map<String, Object?>>();
  final output = <String, Object?>{};
  if (input['reuse_cursor_for_event'] == 1) {
    return _cursorResult(
      transport,
      execution,
      event,
      referenceId,
      pageSize,
      firstPage,
    );
  }
  if (input['page_size'] is int) {
    return _pagesResult(
      transport,
      execution,
      event,
      referenceId,
      pageSize,
      firstPage,
    );
  }
  output['array'] = {
    'rank': dimensions.length,
    'dimensions': dimensions,
    'indices': List<int>.generate(elements.length, (index) => index),
    'cells': elements.map(_valueProjection).toList(),
    if (dimensions.length > 1)
      'cells_by_index': {
        for (var index = 0; index < elements.length; index++)
          _coordinates(index, dimensions).join(','): _valueProjection(
            elements[index],
          ),
      },
  };
  return output;
}

Map<String, Object?> _pagesResult(
  RustTransport transport,
  int execution,
  int event,
  int reference,
  int pageSize,
  Map<String, Object?> firstPage,
) {
  final firstCount = (firstPage['elements'] as List<Object?>).length;
  final first = {
    'indices': List<int>.generate(firstCount, (index) => index),
    'truncated': firstPage['truncated'],
    'next_cursor': firstPage['next_cursor'],
  };
  var cursor = firstPage['next_cursor'] as String?;
  var offset = firstCount;
  Map<String, Object?> last = firstPage;
  while (cursor != null) {
    last = _page(
      transport,
      execution,
      event,
      reference,
      pageSize,
      cursor: cursor,
    );
    final count = (last['elements'] as List<Object?>).length;
    if (last['next_cursor'] == null) {
      return {
        'first_page': first,
        'last_page': {
          'indices': List<int>.generate(count, (index) => offset + index),
          'truncated': last['truncated'],
          'next_cursor': last['next_cursor'],
        },
      };
    }
    offset += count;
    cursor = last['next_cursor'] as String?;
  }
  return {'first_page': first, 'last_page': <String, Object?>{}};
}

Map<String, Object?> _cursorResult(
  RustTransport transport,
  int execution,
  int event,
  int reference,
  int pageSize,
  Map<String, Object?> firstPage,
) {
  final cursor = firstPage['next_cursor'] as String?;
  var error = 'none';
  if (cursor != null) {
    try {
      _page(
        transport,
        execution,
        event + 1,
        reference,
        pageSize,
        cursor: cursor,
      );
    } on RustBridgeFailure catch (failure) {
      error = failure.family;
    }
  }
  final unchanged = _page(transport, execution, event, reference, pageSize);
  return {
    'next_query': {'error': error},
    'previous_page_unchanged':
        jsonEncode(unchanged['elements']) == jsonEncode(firstPage['elements']),
  };
}

Map<String, Object?> _objectGraphResult(
  RustTransport transport,
  int execution,
  int document,
  List<RustEvent> events,
) {
  final event = math.max(0, events.length - 1);
  final frame = _map(
    transport.call('query_frame', {
      'resource': execution,
      'event': event,
      'frame': 0,
    }),
  );
  final variables = _map(frame['variables']);
  final references = <String, String>{};
  final objects = <String, Object?>{};
  for (final entry in variables.entries) {
    final value = _mapOrEmpty(entry.value);
    final reference = value['ref'];
    if (reference is! int) continue;
    final identity = '$reference';
    references[entry.key] = identity;
    final object = _map(
      transport.call('query_object', {
        'resource': execution,
        'event': event,
        'reference': reference,
      }),
    );
    final className = object['clase'];
    final rawFields = _map(object['campos']);
    final declaredIn = _declaringClasses(transport, document);
    objects[identity] = {
      'class': className,
      'fields': {
        for (final field in rawFields.entries)
          field.key: {
            ..._valueProjection(field.value) as Map<String, Object?>,
            if (declaredIn[field.key] is String)
              'declared_in': declaredIn[field.key],
          },
      },
    };
  }
  return {'references': references, 'objects': objects};
}

Map<String, String> _declaringClasses(RustTransport transport, int document) {
  final view = _map(transport.call('program_view', {'resource': document}));
  final members = (view['members'] as List<Object?>? ?? [])
      .cast<Map<String, Object?>>();
  return {
    for (final member in members)
      if (member['kind'] == 'field' &&
          member['name'] is String &&
          member['class'] is String)
        member['name'] as String: member['class'] as String,
  };
}

Map<String, Object?> _retentionResult(
  RustTransport transport,
  int execution,
  List<RustEvent> events,
  Map<String, Object?> input,
) {
  var error = 'none';
  final event = input['query_event'] as int;
  try {
    transport.call('query_frame', {
      'resource': execution,
      'event': event,
      'frame': 0,
    });
  } on RustBridgeFailure catch (failure) {
    error = failure.family;
  }
  final previousCount = events.length;
  final continuation = RustExecutionApi(transport).advance(execution, 25);
  return {
    'query': {'error': error},
    'continuation_unchanged':
        continuation.events.isEmpty &&
        continuation.termination == RustTerminationKind.completed &&
        events.length == previousCount,
  };
}

Map<String, Object?> _page(
  RustTransport transport,
  int execution,
  int event,
  int reference,
  int pageSize, {
  String? cursor,
}) => _map(
  transport.call('query_page', {
    'resource': execution,
    'event': event,
    'query': 'array_cells',
    'target': reference,
    'page_size': pageSize,
    'cursor': ?cursor,
  }),
);

Object _valueProjection(Object? value) {
  final fields = _mapOrEmpty(value);
  if (fields['sin_valor'] == true) return {'uninitialized': true};
  if (fields['ref'] != null) return {'ref': '${fields['ref']}'};
  if (fields['valor'] != null) return {'value': fields['valor']};
  if (fields['nulo'] == true) return {'null': true};
  return value ?? <String, Object?>{};
}

List<int> _coordinates(int index, List<int> dimensions) {
  final coordinates = List<int>.filled(dimensions.length, 0);
  var remaining = index;
  for (var dimension = dimensions.length - 1; dimension >= 0; dimension--) {
    final size = dimensions[dimension];
    if (size == 0) continue;
    coordinates[dimension] = remaining % size;
    remaining ~/= size;
  }
  return coordinates;
}

Map<String, Object?> _map(Object? value) =>
    (value as Map).cast<String, Object?>();

Map<String, Object?> _mapOrEmpty(Object? value) =>
    value is Map ? value.cast<String, Object?>() : <String, Object?>{};
