import 'package:pseudolearn_app/engine/rust/rust_transport.dart';

Map<String, Object?> executeApiRequest(
  RustTransport transport,
  Map<String, Object?> request,
) {
  final calls = request['calls'];
  if (calls is List<Object?>) {
    return {'kind': 'api', 'results': _executeCalls(transport, calls)};
  }
  final operation = request['operation'];
  final arguments = request['arguments'];
  if (operation is! String || arguments is! Map) {
    return _usageFailure('invalid request');
  }
  return {
    'kind': 'api',
    'result': _callResult(
      transport,
      operation,
      arguments.cast<String, Object?>(),
    ),
  };
}

List<Map<String, Object?>> _executeCalls(
  RustTransport transport,
  List<Object?> calls,
) {
  final results = <Map<String, Object?>>[];
  for (final value in calls) {
    if (value is! Map) {
      results.add(_callResult(transport, '', <String, Object?>{}));
      continue;
    }
    final call = value.cast<String, Object?>();
    final operation = call['operation'];
    final rawArguments = call['arguments'];
    final arguments = rawArguments is Map
        ? rawArguments.cast<String, Object?>()
        : <String, Object?>{};
    final resourceIndex = call['resource_from'];
    if (resourceIndex is int) {
      arguments['resource'] = _resourceFrom(results, resourceIndex);
    }
    if (operation == 'input') _injectPendingInputIdentity(results, arguments);
    results.add(
      _callResult(transport, operation is String ? operation : '', arguments),
    );
  }
  return results;
}

void _injectPendingInputIdentity(
  List<Map<String, Object?>> results,
  Map<String, Object?> arguments,
) {
  for (final result in results.reversed) {
    final value = result['value'];
    final pending = value is Map ? value['pending_input'] : null;
    if (pending is! Map) continue;
    for (final field in const ['resource_id', 'task_id', 'request_id']) {
      if (pending.containsKey(field)) {
        arguments.putIfAbsent(field, () => pending[field]);
      }
    }
    return;
  }
}

Object? _resourceFrom(List<Map<String, Object?>> results, int index) {
  if (index < 0 || index >= results.length) return null;
  final value = results[index]['value'];
  if (value is! Map) return null;
  return value['resource'];
}

Map<String, Object?> _callResult(
  RustTransport transport,
  String operation,
  Map<String, Object?> arguments,
) {
  try {
    return {'value': transport.call(operation, arguments)};
  } on RustBridgeFailure catch (failure) {
    return {
      'failure': {'family': failure.family},
    };
  } catch (_) {
    return {
      'failure': {'family': 'internal'},
    };
  }
}

Map<String, Object?> _usageFailure(String detail) => {
  'kind': 'api',
  'result': {
    'failure': {'family': 'usage', 'detail': detail},
  },
};
