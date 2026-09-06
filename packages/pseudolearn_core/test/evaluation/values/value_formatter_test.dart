import 'package:pseudolearn_core/src/domain/profile/profiles/classic_spanish_profile.dart';
import 'package:pseudolearn_core/src/domain/profile/profiles/english_profile.dart';
import 'package:pseudolearn_core/src/domain/pseudo_integer.dart';
import 'package:pseudolearn_core/src/evaluation/values/runtime_value.dart';
import 'package:pseudolearn_core/src/evaluation/values/value_formatter.dart';
import 'package:test/test.dart';

void main() {
  final spanish = ValueFormatter(ClassicSpanishProfile.strict());
  final english = ValueFormatter(EnglishProfile.strict());

  group('ValueFormatter', () {
    test('integers format as plain digits', () {
      expect(spanish.format(IntegerValue(PseudoInteger.fromInt(42))), '42');
      expect(spanish.format(IntegerValue(PseudoInteger.fromInt(-7))), '-7');
      expect(spanish.format(IntegerValue(PseudoInteger.zero)), '0');
    });

    test('reals always carry a decimal point', () {
      expect(spanish.format(const RealValue(2.0)), '2.0');
      expect(spanish.format(const RealValue(100.5)), '100.5');
      expect(spanish.format(const RealValue(-0.5)), '-0.5');
      expect(spanish.format(const RealValue(0.0)), '0.0');
    });

    test('booleans format via active profile keywords', () {
      expect(spanish.format(const BooleanValue(true)), 'Verdadero');
      expect(spanish.format(const BooleanValue(false)), 'Falso');
      expect(english.format(const BooleanValue(true)), 'true');
      expect(english.format(const BooleanValue(false)), 'false');
    });

    test('strings and characters format verbatim', () {
      expect(spanish.format(const StringValue('hola mundo')), 'hola mundo');
      expect(spanish.format(const CharacterValue('x')), 'x');
    });
  });
}
