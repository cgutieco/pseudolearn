import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/editor/caret_range.dart';

void main() {
  group('CaretRange', () {
    test('a collapsed range reports the same lower and upper bound', () {
      const range = CaretRange.collapsed(7);

      expect(range.isCollapsed, isTrue);
      expect(range.lower, 7);
      expect(range.upper, 7);
    });

    test('a backwards selection still reports its bounds in order', () {
      const range = CaretRange(start: 12, end: 4);

      expect(range.isCollapsed, isFalse);
      expect(range.lower, 4);
      expect(range.upper, 12);
    });

    test('clamping keeps the range inside the document', () {
      const range = CaretRange(start: -5, end: 900);

      expect(range.clampedTo(10), const CaretRange(start: 0, end: 10));
    });

    test('clamping an empty document collapses the range at the origin', () {
      const range = CaretRange(start: 3, end: 8);

      expect(range.clampedTo(0), const CaretRange(start: 0, end: 0));
    });
  });
}
