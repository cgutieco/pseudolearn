import 'package:pseudolearn_core/src/domain/position.dart';
import 'package:pseudolearn_core/src/domain/span.dart';
import 'package:test/test.dart';

void main() {
  group('Span', () {
    const start = Position(line: 1, column: 1, offset: 0);
    const middle = Position(line: 1, column: 6, offset: 5);
    const end = Position(line: 2, column: 3, offset: 12);

    test('constructs valid span', () {
      final span = Span(start: start, end: middle);
      expect(span.start, equals(start));
      expect(span.end, equals(middle));
      expect(span.length, equals(5));
      expect(span.isEmpty, isFalse);
      expect(span.crossesLines, isFalse);
      expect(span.toString(), equals('1:1 (0)..1:6 (5)'));
    });

    test('validates start is not after end', () {
      expect(
        () => Span(start: middle, end: start),
        throwsA(isA<AssertionError>()),
      );
    });

    test('handles zero-length span correctly', () {
      final emptySpan = Span(start: start, end: start);
      expect(emptySpan.length, equals(0));
      expect(emptySpan.isEmpty, isTrue);
      expect(emptySpan.crossesLines, isFalse);
    });

    test('detects multiline span', () {
      final multilineSpan = Span(start: start, end: end);
      expect(multilineSpan.crossesLines, isTrue);
      expect(multilineSpan.length, equals(12));
    });

    test('calculates union of two spans', () {
      final span1 = Span(
        start: const Position(line: 1, column: 2, offset: 1),
        end: const Position(line: 1, column: 8, offset: 7),
      );
      final span2 = Span(
        start: const Position(line: 1, column: 5, offset: 4),
        end: const Position(line: 2, column: 4, offset: 15),
      );

      final combined = span1.union(span2);
      expect(combined.start, equals(span1.start));
      expect(combined.end, equals(span2.end));
      expect(combined.length, equals(14));

      final reversedCombined = span2.union(span1);
      expect(reversedCombined, equals(combined));
    });

    test('checks position containment', () {
      final span = Span(
        start: const Position(line: 1, column: 3, offset: 2),
        end: const Position(line: 1, column: 9, offset: 8),
      );

      const inside = Position(line: 1, column: 5, offset: 4);
      const atStart = Position(line: 1, column: 3, offset: 2);
      const atEnd = Position(line: 1, column: 9, offset: 8);
      const before = Position(line: 1, column: 2, offset: 1);
      const after = Position(line: 1, column: 10, offset: 9);

      expect(span.contains(inside), isTrue);
      expect(span.contains(atStart), isTrue);
      expect(span.contains(atEnd), isTrue);
      expect(span.contains(before), isFalse);
      expect(span.contains(after), isFalse);
    });

    test('checks span containment', () {
      final outer = Span(
        start: const Position(line: 1, column: 1, offset: 0),
        end: const Position(line: 2, column: 10, offset: 20),
      );
      final inner = Span(
        start: const Position(line: 1, column: 4, offset: 3),
        end: const Position(line: 2, column: 2, offset: 12),
      );
      final overlapping = Span(
        start: const Position(line: 2, column: 5, offset: 15),
        end: const Position(line: 3, column: 1, offset: 25),
      );

      expect(outer.containsSpan(inner), isTrue);
      expect(outer.containsSpan(outer), isTrue);
      expect(inner.containsSpan(outer), isFalse);
      expect(outer.containsSpan(overlapping), isFalse);
    });

    test('orders spans by start then end', () {
      final span1 = Span(
        start: const Position(line: 1, column: 1, offset: 0),
        end: const Position(line: 1, column: 5, offset: 4),
      );
      final span2 = Span(
        start: const Position(line: 1, column: 1, offset: 0),
        end: const Position(line: 1, column: 10, offset: 9),
      );
      final span3 = Span(
        start: const Position(line: 1, column: 3, offset: 2),
        end: const Position(line: 1, column: 7, offset: 6),
      );

      expect(span1.compareTo(span2), isNegative);
      expect(span2.compareTo(span1), isPositive);
      expect(span1.compareTo(span3), isNegative);
      expect(span1.compareTo(span1), equals(0));
    });

    test('implements value equality and hashCode', () {
      final s1 = Span(start: start, end: middle);
      final s2 = Span(start: start, end: middle);
      final s3 = Span(start: start, end: end);

      expect(s1, equals(s2));
      expect(s1.hashCode, equals(s2.hashCode));
      expect(s1, isNot(equals(s3)));
    });
  });
}
