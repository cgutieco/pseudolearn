import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/engine/rust/rust_effect_tape_assembly.dart';
import 'package:pseudolearn_app/engine/rust/rust_execution_api.dart';

import '../../fakes/fake_rust_transport.dart';

Map<String, Object?> _response(
  List<String> outcomes, {
  int? from,
  String kind = 'running',
}) => {
  'events': <Object?>[],
  'termination': {'kind': kind},
  'effect_tape_from': ?from,
  'effect_tape': {
    'format': 'pseudolearn.tape/v1',
    'entries': [
      for (final outcome in outcomes) {'outcome': outcome},
    ],
  },
};

List<Object?> _outcomes(RustEffectTapeAssembly tape) => [
  for (final entry in tape.document()!['entries'] as List<Object?>)
    (entry as Map<String, Object?>)['outcome'],
];

void main() {
  test('each advance asks for the entries it has not received yet', () {
    final requested = <Object?>[];
    final transport = FakeRustTransport({
      'advance': (arguments) {
        final from = arguments['effect_tape_from'] as int;
        requested.add(from);
        return _response(['written'], from: from);
      },
    });
    final api = RustExecutionApi(transport);
    final tape = RustEffectTapeAssembly();

    for (var call = 0; call < 3; call++) {
      api.advance(5, 25, tape: tape);
    }

    expect(requested, [0, 1, 2]);
    expect(_outcomes(tape), ['written', 'written', 'written']);
  });

  test('a replaced entry is spliced from the declared position', () {
    final windows = [
      _response(['requested'], from: 0),
      _response(['committed', 'requested'], from: 0),
      _response(['failed', 'written'], from: 1),
    ];
    var call = 0;
    final transport = FakeRustTransport({
      'advance': (_) => windows[call++],
    });
    final api = RustExecutionApi(transport);
    final tape = RustEffectTapeAssembly();

    for (var index = 0; index < windows.length; index++) {
      api.advance(5, 25, tape: tape);
    }

    expect(_outcomes(tape), ['committed', 'failed', 'written']);
  });

  test('a response without a declared position replaces the whole tape', () {
    final transport = FakeRustTransport({
      'advance': (_) => _response(['a', 'b']),
    });
    final tape = RustEffectTapeAssembly()
      ..receive(const {
        'entries': [
          {'outcome': 'x'},
          {'outcome': 'y'},
          {'outcome': 'z'},
        ],
      }, from: 0);

    RustExecutionApi(transport).advance(5, 25, tape: tape);

    expect(_outcomes(tape), ['a', 'b']);
  });

  test('an advance without assembly keeps the full tape request', () {
    Map<String, Object?>? received;
    final transport = FakeRustTransport({
      'advance': (arguments) {
        received = arguments;
        return _response(['written']);
      },
    });

    final batch = RustExecutionApi(transport).advance(5, 25);

    expect(received!.containsKey('effect_tape_from'), isFalse);
    expect(batch.effectTape!['entries'], hasLength(1));
  });

  test('confirming a cancellation also extends the assembled tape', () {
    final requested = <Object?>[];
    final transport = FakeRustTransport({
      'cancel': (_) => null,
      'advance': (arguments) {
        requested.add(arguments['effect_tape_from']);
        return _response(['cancelled'], from: 1, kind: 'cancelled');
      },
    });
    final tape = RustEffectTapeAssembly()
      ..receive(const {'entries': [<String, Object?>{'outcome': 'written'}]}, from: 0);

    RustExecutionApi(transport).stop(
      5,
      confirmCancellation: true,
      release: false,
      tape: tape,
    );

    expect(requested, [1]);
    expect(_outcomes(tape), ['written', 'cancelled']);
  });
}
