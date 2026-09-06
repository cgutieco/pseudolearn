import 'package:pseudolearn_core/src/evaluation/values/random_source.dart';
import 'package:test/test.dart';

void main() {
  group('SeededRandomSource, determinism', () {
    test('the same seed produces the exact same sequence', () {
      final a = SeededRandomSource(1234);
      final b = SeededRandomSource(1234);
      final sequenceA = List.generate(20, (_) => a.nextUnitInterval());
      final sequenceB = List.generate(20, (_) => b.nextUnitInterval());
      expect(sequenceA, equals(sequenceB));
    });

    test('different seeds produce different sequences', () {
      final a = SeededRandomSource(1);
      final b = SeededRandomSource(2);
      expect(a.nextUnitInterval(), isNot(equals(b.nextUnitInterval())));
    });

    test('every value is within [0, 1)', () {
      final source = SeededRandomSource(42);
      for (var i = 0; i < 1000; i++) {
        final value = source.nextUnitInterval();
        expect(value, greaterThanOrEqualTo(0.0));
        expect(value, lessThan(1.0));
      }
    });

    test('the default seed is fixed and documented, not derived from the clock',
        () {
      final a = SeededRandomSource();
      final b = SeededRandomSource(SeededRandomSource.defaultSeed);
      expect(a.nextUnitInterval(), equals(b.nextUnitInterval()));
    });
  });
}
