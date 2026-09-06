import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/dashboard/week_start.dart';

void main() {
  group('weekStartOf (PANT-06-F5)', () {
    test('a Monday is its own week start at midnight', () {
      expect(
        weekStartOf(DateTime(2026, 8, 31, 18, 45)),
        DateTime(2026, 8, 31),
      );
    });

    test('a Sunday belongs to the week that started six days earlier', () {
      expect(weekStartOf(DateTime(2026, 9, 6, 23, 59)), DateTime(2026, 8, 31));
    });

    test('a week that spans two months keeps the earlier month as origin', () {
      expect(weekStartOf(DateTime(2026, 9, 1)), DateTime(2026, 8, 31));
    });

    test('a week that spans two years keeps the earlier year as origin', () {
      expect(weekStartOf(DateTime(2027, 1, 1)), DateTime(2026, 12, 28));
    });

    test('two moments of the same day share the same week start', () {
      final morning = weekStartOf(DateTime(2026, 9, 2, 0, 1));
      final night = weekStartOf(DateTime(2026, 9, 2, 23, 59));
      expect(morning, night);
    });
  });
}
