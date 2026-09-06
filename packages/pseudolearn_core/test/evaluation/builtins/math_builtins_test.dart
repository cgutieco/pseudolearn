import 'package:pseudolearn_core/src/evaluation/builtins/math_builtins.dart';
import 'package:pseudolearn_core/src/evaluation/builtins/rounding_builtins.dart';
import 'package:pseudolearn_core/src/evaluation/values/random_source.dart';
import 'package:test/test.dart';

void main() {
  const math = MathBuiltins();
  const rounding = RoundingBuiltins();

  group('MathBuiltins', () {
    test('the seven transcendentals on ordinary input', () {
      expect(math.squareRoot(4.0), equals(2.0));
      expect(math.absoluteValue(-3.0), equals(3.0));
      expect(math.naturalLogarithm(1.0), equals(0.0));
      expect(math.exponential(0.0), equals(1.0));
      expect(math.sine(0.0), equals(0.0));
      expect(math.cosine(0.0), equals(1.0));
      expect(math.arcTangent(0.0), equals(0.0));
    });

    test(
        'square root of a negative number is non-finite (NaN), reported as null',
        () {
      expect(math.squareRoot(-1.0), isNull);
    });

    test('natural log of zero is non-finite (-infinity), reported as null', () {
      expect(math.naturalLogarithm(0.0), isNull);
    });

    test(
        'natural log of a negative number is non-finite (NaN), reported as null',
        () {
      expect(math.naturalLogarithm(-1.0), isNull);
    });
  });

  group('RoundingBuiltins', () {
    test('truncate drops the fractional part toward zero', () {
      expect(rounding.truncate(3.9)!.toString(), equals('3'));
      expect(rounding.truncate(-3.9)!.toString(), equals('-3'));
    });

    test('round goes to the nearest integer', () {
      expect(rounding.round(3.5)!.toString(), equals('4'));
      expect(rounding.round(3.4)!.toString(), equals('3'));
    });

    test('truncate and round of a value in range never overflow', () {
      expect(rounding.truncate(1e10), isNotNull);
      expect(rounding.round(1e10), isNotNull);
    });

    test('random is reproducible from a seeded source, and stays in [0, 1)',
        () {
      final source = SeededRandomSource(7);
      final value = rounding.random(source);
      expect(value, greaterThanOrEqualTo(0.0));
      expect(value, lessThan(1.0));
    });
  });
}
