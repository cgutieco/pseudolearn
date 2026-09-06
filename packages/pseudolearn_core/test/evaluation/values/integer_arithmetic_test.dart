import 'package:pseudolearn_core/src/domain/pseudo_integer.dart';
import 'package:pseudolearn_core/src/evaluation/values/integer_arithmetic.dart';
import 'package:test/test.dart';

void main() {
  const arithmetic = IntegerArithmetic();

  group('IntegerArithmetic addition, subtraction, multiplication', () {
    test('happy path within range', () {
      expect(
        arithmetic.add(PseudoInteger.fromInt(2), PseudoInteger.fromInt(3)),
        equals(PseudoInteger.fromInt(5)),
      );
      expect(
        arithmetic.subtract(PseudoInteger.fromInt(2), PseudoInteger.fromInt(3)),
        equals(PseudoInteger.fromInt(-1)),
      );
      expect(
        arithmetic.multiply(PseudoInteger.fromInt(6), PseudoInteger.fromInt(7)),
        equals(PseudoInteger.fromInt(42)),
      );
    });

    test('the operation right at the upper border does not overflow', () {
      expect(
        arithmetic.add(PseudoInteger.maxValue, PseudoInteger.zero),
        equals(PseudoInteger.maxValue),
      );
    });

    test('overflow at the upper border is detected', () {
      expect(arithmetic.add(PseudoInteger.maxValue, PseudoInteger.one), isNull);
      expect(
        arithmetic.multiply(PseudoInteger.maxValue, PseudoInteger.fromInt(2)),
        isNull,
      );
    });

    test('overflow at the lower border is detected', () {
      expect(arithmetic.subtract(PseudoInteger.minValue, PseudoInteger.one),
          isNull);
      expect(arithmetic.negate(PseudoInteger.minValue), isNull);
    });
  });

  group('IntegerArithmetic power', () {
    test('integer base and exponent give an integer result', () {
      expect(
        arithmetic.power(PseudoInteger.fromInt(2), PseudoInteger.fromInt(10)),
        equals(PseudoInteger.fromInt(1024)),
      );
    });

    test('exponent zero gives one, any base including zero', () {
      expect(
        arithmetic.power(PseudoInteger.fromInt(5), PseudoInteger.zero),
        equals(PseudoInteger.one),
      );
      expect(
        arithmetic.power(PseudoInteger.zero, PseudoInteger.zero),
        equals(PseudoInteger.one),
      );
    });

    test('base one or minus one never overflows for a huge exponent', () {
      final hugeExponent =
          PseudoInteger.fromBigInt(BigInt.parse('123456789012345'))!;
      expect(
        arithmetic.power(PseudoInteger.one, hugeExponent),
        equals(PseudoInteger.one),
      );
      expect(
        arithmetic.power(PseudoInteger.fromInt(-1), hugeExponent),
        equals(PseudoInteger.fromInt(-1)),
      );
    });

    test('negative exponent is rejected (caller reports it, not overflow)', () {
      expect(
        arithmetic.power(PseudoInteger.fromInt(2), PseudoInteger.fromInt(-1)),
        isNull,
      );
    });

    test('overflow from a large base and exponent is detected quickly', () {
      expect(
        arithmetic.power(PseudoInteger.fromInt(2), PseudoInteger.fromInt(62)),
        isNotNull,
      );
      expect(
        arithmetic.power(PseudoInteger.fromInt(2), PseudoInteger.fromInt(63)),
        isNull,
      );
    });
  });
}
