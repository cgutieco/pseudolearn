import 'package:pseudolearn_core/src/domain/pseudo_integer.dart';
import 'package:pseudolearn_core/src/evaluation/values/integer_division.dart';
import 'package:test/test.dart';

void main() {
  const division = IntegerDivision();

  group('IntegerDivision, truncation toward zero', () {
    test('positive operands', () {
      expect(
        division.quotient(PseudoInteger.fromInt(7), PseudoInteger.fromInt(2)),
        equals(PseudoInteger.fromInt(3)),
      );
      expect(
        division.remainder(PseudoInteger.fromInt(7), PseudoInteger.fromInt(2)),
        equals(PseudoInteger.fromInt(1)),
      );
    });

    test('negative dividend truncates toward zero, remainder takes its sign',
        () {
      expect(
        division.quotient(PseudoInteger.fromInt(-7), PseudoInteger.fromInt(2)),
        equals(PseudoInteger.fromInt(-3)),
      );
      expect(
        division.remainder(PseudoInteger.fromInt(-7), PseudoInteger.fromInt(2)),
        equals(PseudoInteger.fromInt(-1)),
      );
    });

    test('negative divisor', () {
      expect(
        division.quotient(PseudoInteger.fromInt(7), PseudoInteger.fromInt(-2)),
        equals(PseudoInteger.fromInt(-3)),
      );
      expect(
        division.remainder(PseudoInteger.fromInt(7), PseudoInteger.fromInt(-2)),
        equals(PseudoInteger.fromInt(1)),
      );
    });

    test('both operands negative', () {
      expect(
        division.quotient(PseudoInteger.fromInt(-7), PseudoInteger.fromInt(-2)),
        equals(PseudoInteger.fromInt(3)),
      );
      expect(
        division.remainder(
            PseudoInteger.fromInt(-7), PseudoInteger.fromInt(-2)),
        equals(PseudoInteger.fromInt(-1)),
      );
    });

    test(
        'the identity (a div b) * b + (a mod b) = a holds for all four sign combinations',
        () {
      for (final a in [7, -7]) {
        for (final b in [2, -2]) {
          final dividend = PseudoInteger.fromInt(a);
          final divisor = PseudoInteger.fromInt(b);
          final q = division.quotient(dividend, divisor)!;
          final r = division.remainder(dividend, divisor)!;
          expect(
            q.value * divisor.value + r.value,
            equals(dividend.value),
            reason: 'a=$a b=$b',
          );
        }
      }
    });

    test('quotient overflow: minValue divided by -1', () {
      expect(
        division.quotient(PseudoInteger.minValue, PseudoInteger.fromInt(-1)),
        isNull,
      );
    });

    test('remainder of minValue divided by -1 is exactly zero, no overflow',
        () {
      expect(
        division.remainder(PseudoInteger.minValue, PseudoInteger.fromInt(-1)),
        equals(PseudoInteger.zero),
      );
    });
  });
}
