import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/execution/replay_rejection.dart';
import 'package:pseudolearn_app/engine/rust/rust_replay_rejection.dart';
import 'package:pseudolearn_app/engine/rust/rust_transport.dart';

RustBridgeFailure failure(String family, String detail) =>
    RustBridgeFailure(family: family, detail: detail);

void main() {
  group('replayRejectionOf', () {
    test('every engine replay code maps to its own rejection', () {
      const codes = {
        'replay_identity_mismatch': ReplayRejection.identityMismatch,
        'replay_divergence': ReplayRejection.divergence,
        'replay_truncated_tape': ReplayRejection.truncatedTape,
        'replay_corrupted_tape': ReplayRejection.corruptedTape,
        'replay_non_reproducible': ReplayRejection.nonReproducible,
      };
      for (final entry in codes.entries) {
        expect(
          replayRejectionOf(failure('usage', 'Invalid protocol: ${entry.key}')),
          entry.value,
        );
      }
    });

    test('a missing tape and an unknown schema are distinct rejections', () {
      expect(
        replayRejectionOf(
          failure('usage', 'Invalid protocol: missing effect tape for replay'),
        ),
        ReplayRejection.missingTape,
      );
      expect(
        replayRejectionOf(failure('version', 'Unsupported version: v0')),
        ReplayRejection.unsupportedSchema,
      );
    });

    test('unrecognised failures are refused without a fabricated code', () {
      expect(
        replayRejectionOf(failure('usage', 'Invalid protocol: other')),
        ReplayRejection.engineRefused,
      );
      expect(
        replayRejectionOf(failure('internal', 'boom')),
        ReplayRejection.engineRefused,
      );
      expect(
        replayRejectionOf(failure('usage', '')),
        ReplayRejection.engineRefused,
      );
    });

    test('rejection codes are unique', () {
      final codes = ReplayRejection.values.map((value) => value.code);
      expect(codes.toSet(), hasLength(ReplayRejection.values.length));
    });
  });
}
