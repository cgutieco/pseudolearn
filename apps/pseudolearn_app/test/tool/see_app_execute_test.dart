import 'package:flutter_test/flutter_test.dart';

import '../../tool/see_app_execute.dart';
import '../fakes/fake_rust_transport.dart';

void main() {
  test(
    'assembles batches with a view from the same document and releases it',
    () {
      var batches = 0;
      final transport = FakeRustTransport({
        'create_analysis': (_) => {'document': 1, 'resource': 2},
        'analysis': (_) => {'tree': true, 'diagnostics': <Object?>[]},
        'start': (_) => {'resource': 3},
        'advance': (_) => {
          'events': [batches++],
          'output': 'result',
          'termination': {'kind': batches == 2 ? 'completed' : 'running'},
        },
        'program_view': (arguments) => {'revision': arguments['resource']},
        'release': (arguments) {
          expect(arguments['resource'], 1);
          return null;
        },
      });
      final result = executeThroughTransport(transport, {
        'include_program_view': true,
      });
      expect(result['events'], [0, 1]);
      expect(result['program_view'], {'revision': 1});
      expect(transport.calls.last, 'release');
    },
  );

  test(
    'rejects analysis errors and releases resources after transport errors',
    () {
      final transport = FakeRustTransport({
        'create_analysis': (_) => {'document': 1, 'resource': 2},
        'analysis': (_) => {'tree': false, 'diagnostics': <Object?>[]},
        'release': (_) => null,
      });
      final result = executeThroughTransport(transport, {});
      expect(result['termination'], {
        'kind': 'failed',
        'code': 'analysisFailed',
      });
      expect(transport.calls, ['create_analysis', 'analysis', 'release']);
      transport.handlers['analysis'] = (_) =>
          throw StateError('failed analysis query');
      expect(() => executeThroughTransport(transport, {}), throwsStateError);
      expect(transport.calls.last, 'release');
    },
  );
}
