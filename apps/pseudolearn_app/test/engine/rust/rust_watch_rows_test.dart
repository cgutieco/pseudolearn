import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/engine/rust/rust_state_api.dart';
import 'package:pseudolearn_app/engine/rust/rust_transport.dart';
import 'package:pseudolearn_app/engine/rust/rust_watch_rows.dart';

void main() {
  test('collection rows preserve identity and distinguish lengths', () {
    final rows = RustWatchRows(
      const RustStateApi(_CollectionTransport()),
    ).at(execution: 1, event: 2, depth: 1).rows;
    expect(rows.map((row) => row.formattedValue), ['[2]#7', '{0}#8']);
    expect(rows.map((row) => row.identityBadge), [7, 8]);
  });
}

final class _CollectionTransport implements RustTransport {
  const _CollectionTransport();

  @override
  Object? call(String operation, Map<String, Object?> arguments) {
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
