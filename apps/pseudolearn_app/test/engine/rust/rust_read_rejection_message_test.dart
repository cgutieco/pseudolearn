import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/engine/rust/rust_read_rejection_message.dart';

void main() {
  group('readRejectionMessageOf', () {
    test('returns the most recent type mismatch message', () {
      final message = readRejectionMessageOf([
        {'code': 'readValueTypeMismatch', 'message': 'first'},
        {'code': 'unusedVariable', 'message': 'other'},
        {'code': 'readValueTypeMismatch', 'message': 'second'},
      ]);
      expect(message, 'second');
    });

    test('ignores other diagnostics', () {
      expect(
        readRejectionMessageOf([
          {'code': 'divisionByZero', 'message': 'nope'},
        ]),
        isNull,
      );
    });

    test('an empty list or a message of another shape gives nothing', () {
      expect(readRejectionMessageOf(const []), isNull);
      expect(
        readRejectionMessageOf([
          {'code': 'readValueTypeMismatch', 'message': 7},
        ]),
        isNull,
      );
    });
  });
}
