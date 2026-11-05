import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/engine/rust/rust_wire_models.dart';

Map<String, Object?> _wire(Object? ranges) => {
  'events': <Object?>[],
  'termination': {'kind': 'completed'},
  'error_ranges': ranges,
  'exit_code': 7,
};

void main() {
  test('reads the error ranges and the exit code of a batch', () {
    final batch = RustBatch.fromJson(
      _wire([
        [0, 3],
        [5, 9],
      ]),
    );

    expect(batch.errorRanges, [(0, 3), (5, 9)]);
    expect(batch.exitCode, 7);
  });

  test('defaults to no error ranges when the field is absent', () {
    final batch = RustBatch.fromJson(_wire(null));

    expect(batch.errorRanges, isEmpty);
  });

  test('rejects a malformed range', () {
    expect(
      () => RustBatch.fromJson(
        _wire([
          [1],
        ]),
      ),
      throwsFormatException,
    );
  });
}
