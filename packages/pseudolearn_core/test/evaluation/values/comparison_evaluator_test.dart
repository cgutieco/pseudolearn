import 'package:pseudolearn_core/src/domain/pseudo_integer.dart';
import 'package:pseudolearn_core/src/evaluation/values/comparison_evaluator.dart';
import 'package:pseudolearn_core/src/evaluation/values/runtime_value.dart';
import 'package:test/test.dart';

void main() {
  const comparison = ComparisonEvaluator();

  group('ComparisonEvaluator compareOrdered numbers', () {
    test('compares integers correctly for less, equal, and greater', () {
      final three = IntegerValue(PseudoInteger.fromInt(3));
      final five = IntegerValue(PseudoInteger.fromInt(5));
      final threeAgain = IntegerValue(PseudoInteger.fromInt(3));

      expect(comparison.compareOrdered(three, five), lessThan(0));
      expect(comparison.compareOrdered(five, three), greaterThan(0));
      expect(comparison.compareOrdered(three, threeAgain), equals(0));
    });

    test('compares reals correctly for less, equal, and greater', () {
      const small = RealValue(1.25);
      const large = RealValue(3.75);
      const smallAgain = RealValue(1.25);

      expect(comparison.compareOrdered(small, large), lessThan(0));
      expect(comparison.compareOrdered(large, small), greaterThan(0));
      expect(comparison.compareOrdered(small, smallAgain), equals(0));
    });

    test(
        'compares integer with real across widening boundary in both directions',
        () {
      final three = IntegerValue(PseudoInteger.fromInt(3));
      const twoPointFive = RealValue(2.5);
      const threePointZero = RealValue(3.0);
      const threePointFive = RealValue(3.5);

      expect(comparison.compareOrdered(three, twoPointFive), greaterThan(0));
      expect(comparison.compareOrdered(twoPointFive, three), lessThan(0));
      expect(comparison.compareOrdered(three, threePointZero), equals(0));
      expect(comparison.compareOrdered(threePointZero, three), equals(0));
      expect(comparison.compareOrdered(three, threePointFive), lessThan(0));
      expect(comparison.compareOrdered(threePointFive, three), greaterThan(0));
    });

    test(
        'throws StateError when comparing non-numeric values in compareOrdered',
        () {
      final one = IntegerValue(PseudoInteger.fromInt(1));
      const booleanVal = BooleanValue(true);
      const stringVal = StringValue('text');

      expect(
          () => comparison.compareOrdered(booleanVal, one), throwsStateError);
      expect(
          () => comparison.compareOrdered(one, booleanVal), throwsStateError);
      expect(() => comparison.compareOrdered(stringVal, one), throwsStateError);
      expect(() => comparison.compareOrdered(booleanVal, booleanVal),
          throwsStateError);
    });
  });

  group('ComparisonEvaluator compareOrdered strings and characters', () {
    test('lexicographic comparison for strings', () {
      expect(
        comparison.compareOrdered(
          const StringValue('abc'),
          const StringValue('abd'),
        ),
        lessThan(0),
      );
      expect(
        comparison.compareOrdered(
          const StringValue('xyz'),
          const StringValue('abc'),
        ),
        greaterThan(0),
      );
      expect(
        comparison.compareOrdered(
          const StringValue('hello'),
          const StringValue('hello'),
        ),
        equals(0),
      );
      expect(
        comparison.compareOrdered(
          const StringValue(''),
          const StringValue('a'),
        ),
        lessThan(0),
      );
    });

    test('character comparison by code points', () {
      expect(
        comparison.compareOrdered(
          const CharacterValue('a'),
          const CharacterValue('b'),
        ),
        lessThan(0),
      );
      expect(
        comparison.compareOrdered(
          const CharacterValue('z'),
          const CharacterValue('a'),
        ),
        greaterThan(0),
      );
      expect(
        comparison.compareOrdered(
          const CharacterValue('k'),
          const CharacterValue('k'),
        ),
        equals(0),
      );
    });
  });

  group('ComparisonEvaluator equalValues', () {
    test('handles boolean equality and inequality', () {
      expect(
        comparison.equalValues(
          const BooleanValue(true),
          const BooleanValue(true),
        ),
        isTrue,
      );
      expect(
        comparison.equalValues(
          const BooleanValue(false),
          const BooleanValue(false),
        ),
        isTrue,
      );
      expect(
        comparison.equalValues(
          const BooleanValue(true),
          const BooleanValue(false),
        ),
        isFalse,
      );
    });

    test('handles character and string equality and inequality', () {
      expect(
        comparison.equalValues(
          const CharacterValue('a'),
          const CharacterValue('a'),
        ),
        isTrue,
      );
      expect(
        comparison.equalValues(
          const CharacterValue('a'),
          const CharacterValue('b'),
        ),
        isFalse,
      );
      expect(
        comparison.equalValues(
          const StringValue('hello'),
          const StringValue('hello'),
        ),
        isTrue,
      );
      expect(
        comparison.equalValues(
          const StringValue('hello'),
          const StringValue('world'),
        ),
        isFalse,
      );
    });

    test('handles integer and real equality with widening', () {
      final three = IntegerValue(PseudoInteger.fromInt(3));
      final four = IntegerValue(PseudoInteger.fromInt(4));
      const threePointZero = RealValue(3.0);
      const threePointFive = RealValue(3.5);

      expect(comparison.equalValues(three, three), isTrue);
      expect(comparison.equalValues(three, four), isFalse);
      expect(comparison.equalValues(threePointZero, threePointZero), isTrue);
      expect(comparison.equalValues(threePointZero, threePointFive), isFalse);
      expect(comparison.equalValues(three, threePointZero), isTrue);
      expect(comparison.equalValues(threePointZero, three), isTrue);
      expect(comparison.equalValues(three, threePointFive), isFalse);
    });

    test('throws StateError when comparing incompatible non-numeric types', () {
      final one = IntegerValue(PseudoInteger.fromInt(1));
      const boolVal = BooleanValue(true);
      const strVal = StringValue('text');

      expect(() => comparison.equalValues(boolVal, one), throwsStateError);
      expect(() => comparison.equalValues(one, boolVal), throwsStateError);
      expect(() => comparison.equalValues(strVal, one), throwsStateError);
    });
  });
}
