import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/engine/rust/rust_wire_models.dart';

import '../../tool/see_app_failure_history.dart';
import '../fakes/fake_rust_transport.dart';

void main() {
  test('failure history detects lost state and events after failure', () {
    for (final changed in [false, true]) {
      final transport = FakeRustTransport({
        'query_frame': (_) => {
          'unidad': 'P',
          'variables': {'x': changed ? 1 : 0},
        },
        'advance': (_) => {
          'events': changed
              ? <Map<String, Object?>>[
                  {'class': 'output', 'line': 3, 'depth': 1},
                ]
              : <Map<String, Object?>>[],
          'termination': {'kind': 'failed'},
        },
      });
      final result = failureHistory(
        transport,
        1,
        [
          const RustEvent(
            eventClass: 'statement_entered',
            line: 1,
            depth: 1,
            data: {},
            nodeId: null,
          ),
        ],
        before: {
          'unidad': 'P',
          'variables': {'x': 0},
        },
      );
      expect(result['events_before_failure_preserved'], !changed);
      expect(result['later_events_absent'], !changed);
      transport.close();
    }
  });
}
