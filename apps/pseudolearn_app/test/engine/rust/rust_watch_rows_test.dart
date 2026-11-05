import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/engine/rust/rust_state_api.dart';
import 'package:pseudolearn_app/engine/rust/rust_transport.dart';
import 'package:pseudolearn_app/engine/rust/rust_watch_rows.dart';

void main() {
  test('collection rows preserve identity and distinguish lengths', () {
    final transport = _CollectionTransport();
    final result = RustWatchRows(
      RustStateApi(transport),
    ).at(execution: 1, event: 2, taskId: 7, depth: 1);
    final rows = (result as RustEnvironmentValue).environment.rows;
    expect(rows.map((row) => row.formattedValue), ['[2]#7', '{0}#8']);
    expect(rows.map((row) => row.identityBadge), [7, 8]);
    expect(transport.queries, hasLength(5));
    expect(transport.queries.map((query) => query['task_id']), everyElement(7));
  });

  test('record leaves are listed one row per leaf with their own value', () {
    final result = RustWatchRows(
      RustStateApi(_LeafTransport()),
    ).at(execution: 1, event: 2, taskId: 0, depth: 1);
    final rows = (result as RustEnvironmentValue).environment.rows;

    expect(rows.map((row) => row.name), ['q.x', 'q.y', 'total']);
    expect(rows.map((row) => row.formattedValue), ['3', '-', '6']);
    expect(rows.map((row) => row.isAbsent), [false, true, false]);
  });

  test('a rejected task query becomes a state failure', () {
    final result = RustWatchRows(
      RustStateApi(_CollectionTransport(frameFailure: 'usage')),
    ).at(execution: 1, event: 2, taskId: 99, depth: 1);

    expect(result, isA<RustEnvironmentFailure>());
    expect((result as RustEnvironmentFailure).reason, 'task_state_unavailable');
  });
}

final class _LeafTransport implements RustTransport {
  @override
  Object? call(String operation, Map<String, Object?> arguments) =>
      switch (operation) {
        'query_frame' => {
          'unidad': 'P',
          'variables': {
            'q.x': {'valor': '3', 'tipo': 'entero'},
            'q.y': <String, Object?>{},
            'total': {'valor': '6', 'tipo': 'entero'},
          },
        },
        _ => throw StateError(operation),
      };

  @override
  void close() {}
}

final class _CollectionTransport implements RustTransport {
  final String? frameFailure;
  final List<Map<String, Object?>> queries = [];

  _CollectionTransport({this.frameFailure});

  @override
  Object? call(String operation, Map<String, Object?> arguments) {
    queries.add(arguments);
    final failureFamily = frameFailure;
    if (operation == 'query_frame' && failureFamily != null) {
      throw RustBridgeFailure(
        family: failureFamily,
        detail: 'frame query rejected',
      );
    }
    return switch (operation) {
      'query_frame' => {
        'unidad': 'Main',
        'variables': {
          'values': {'ref': 7},
          'entries': {'ref': 8},
        },
      },
      'query_page' => throw const RustBridgeFailure(
        family: 'usage',
        detail: 'collection is not an array',
      ),
      'query_object' =>
        arguments['reference'] == 7
            ? {
                'vector': {'longitud': 2},
              }
            : {
                'diccionario': {'longitud': 0},
              },
      _ => throw StateError(operation),
    };
  }

  @override
  void close() {}
}
