import 'package:pseudolearn_core/src/domain/position.dart';
import 'package:test/test.dart';

void main() {
  group('Position', () {
    test('constructs valid position', () {
      const position = Position(line: 1, column: 1, offset: 0);
      expect(position.line, equals(1));
      expect(position.column, equals(1));
      expect(position.offset, equals(0));
      expect(position.toString(), equals('1:1 (0)'));
    });

    test('validates 1-indexed line and column', () {
      expect(
        () => Position(line: 0, column: 1, offset: 0),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => Position(line: 1, column: 0, offset: 0),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => Position(line: 1, column: 1, offset: -1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('compares positions correctly by offset', () {
      const first = Position(line: 1, column: 1, offset: 0);
      const second = Position(line: 1, column: 5, offset: 4);
      const third = Position(line: 2, column: 1, offset: 10);

      expect(first < second, isTrue);
      expect(first <= second, isTrue);
      expect(second > first, isTrue);
      expect(second >= first, isTrue);
      expect(first.compareTo(second), isNegative);
      expect(second.compareTo(first), isPositive);
      expect(second.compareTo(second), equals(0));
      expect(second < third, isTrue);
    });

    test('implements value equality and hashCode', () {
      const pos1 = Position(line: 3, column: 8, offset: 25);
      const pos2 = Position(line: 3, column: 8, offset: 25);
      const pos3 = Position(line: 3, column: 9, offset: 26);

      expect(pos1, equals(pos2));
      expect(pos1.hashCode, equals(pos2.hashCode));
      expect(pos1, isNot(equals(pos3)));
    });
  });
}
