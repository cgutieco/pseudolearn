import 'package:pseudolearn_core/src/evaluation/values/real_arithmetic.dart';
import 'package:test/test.dart';

void main() {
  const arithmetic = RealArithmetic();

  group('RealArithmetic', () {
    test('the four basic operations', () {
      expect(arithmetic.add(1.5, 2.5), equals(4.0));
      expect(arithmetic.subtract(5.0, 2.0), equals(3.0));
      expect(arithmetic.multiply(2.0, 3.0), equals(6.0));
      expect(arithmetic.divide(5.0, 2.0), equals(2.5));
    });

    test('division of two integers as doubles gives a real result', () {
      expect(arithmetic.divide(5.0, 2.0), equals(2.5));
    });

    test('power with a real exponent', () {
      expect(arithmetic.power(2.0, 0.5), closeTo(1.4142135623730951, 1e-12));
    });

    test(
        'division by zero produces a non-finite result, detected and not thrown',
        () {
      final result = arithmetic.divide(1.0, 0.0);
      expect(arithmetic.isFiniteResult(result), isFalse);
    });

    test('a finite result is reported as finite', () {
      expect(arithmetic.isFiniteResult(arithmetic.add(1.0, 1.0)), isTrue);
    });
  });
}
