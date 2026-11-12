import 'dart:convert';

import 'package:pseudolearn_app/engine/rust/rust_execution_api.dart';
import 'package:pseudolearn_app/engine/rust/rust_transport.dart';
import 'package:pseudolearn_app/engine/rust/rust_wire_models.dart';

Map<String, Object?> failureHistory(
  RustTransport transport,
  int execution,
  List<RustEvent> events, {
  required Object? before,
}) {
  final query = {'resource': execution, 'event': 0, 'frame': 0};
  final continuation = RustExecutionApi(transport).advance(execution, 25);
  final after = transport.call('query_frame', query);
  return {
    'events_before_failure_preserved':
        events.isNotEmpty &&
        before is Map<String, Object?> &&
        before['unidad'] is String &&
        jsonEncode(before) == jsonEncode(after),
    'later_events_absent':
        continuation.events.isEmpty &&
        continuation.termination == RustTerminationKind.failed,
  };
}
