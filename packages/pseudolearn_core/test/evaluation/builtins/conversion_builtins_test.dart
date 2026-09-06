import 'package:pseudolearn_core/src/domain/profile/profiles/classic_spanish_profile.dart';
import 'package:pseudolearn_core/src/domain/pseudo_integer.dart';
import 'package:pseudolearn_core/src/evaluation/builtins/conversion_builtins.dart';
import 'package:pseudolearn_core/src/evaluation/values/runtime_value.dart';
import 'package:pseudolearn_core/src/evaluation/values/value_formatter.dart';
import 'package:test/test.dart';

void main() {
  final conversion =
      ConversionBuiltins(const ValueFormatter(ClassicSpanishProfile.strict()));

  group('ConversionBuiltins.toText', () {
    test('matches the same text the output statement would emit', () {
      expect(conversion.toText(IntegerValue(PseudoInteger.fromInt(7))),
          equals('7'));
      expect(conversion.toText(const RealValue(2.0)), equals('2.0'));
      expect(conversion.toText(const BooleanValue(true)), equals('Verdadero'));
    });
  });

  group('ConversionBuiltins.textToInteger', () {
    test('a valid integer text converts', () {
      expect(conversion.textToInteger('42'), equals(PseudoInteger.fromInt(42)));
      expect(conversion.textToInteger('-7'), equals(PseudoInteger.fromInt(-7)));
    });

    test('text that is not a number fails (null, not an exception)', () {
      expect(conversion.textToInteger('hola'), isNull);
    });

    test('text with a decimal point is not an integer', () {
      expect(conversion.textToInteger('3.5'), isNull);
    });
  });

  group('ConversionBuiltins.textToReal', () {
    test('a decimal text converts', () {
      expect(conversion.textToReal('3.14'), equals(3.14));
    });

    test('a plain digit sequence is also a valid real', () {
      expect(conversion.textToReal('42'), equals(42.0));
    });

    test('text that is not a number fails', () {
      expect(conversion.textToReal('hola'), isNull);
    });
  });
}
