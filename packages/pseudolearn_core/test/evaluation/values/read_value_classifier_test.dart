import 'package:pseudolearn_core/src/domain/primitive_type.dart';
import 'package:pseudolearn_core/src/domain/profile/profiles/classic_spanish_profile.dart';
import 'package:pseudolearn_core/src/domain/pseudo_integer.dart';
import 'package:pseudolearn_core/src/evaluation/values/read_value_classifier.dart';
import 'package:pseudolearn_core/src/evaluation/values/runtime_value.dart';
import 'package:test/test.dart';

void main() {
  final classifier = ReadValueClassifier(const ClassicSpanishProfile.strict());

  group('ReadValueClassifier, deterministic order', () {
    test('1: integer wins when input parses as integer', () {
      expect(classifier.classify('42'),
          equals(IntegerValue(PseudoInteger.fromInt(42))));
      expect(classifier.classify('-7'),
          equals(IntegerValue(PseudoInteger.fromInt(-7))));
    });

    test('2: real wins when it has a decimal point and parses as double', () {
      expect(classifier.classify('3.14'), equals(const RealValue(3.14)));
    });

    test('3: logical wins when it matches profile keywords', () {
      expect(
          classifier.classify('Verdadero'), equals(const BooleanValue(true)));
      expect(classifier.classify('Falso'), equals(const BooleanValue(false)));
      expect(
          classifier.classify('VERDADERO'), equals(const BooleanValue(true)));
    });

    test('4: anything else is string, including single character', () {
      expect(classifier.classify('a'), equals(const StringValue('a')));
      expect(classifier.classify('hola mundo'),
          equals(const StringValue('hola mundo')));
      expect(classifier.classify(''), equals(const StringValue('')));
    });
  });

  group('ReadValueClassifier, parseAs', () {
    test('accepts single character as character when target is character', () {
      final value = classifier.parseAs('a', PrimitiveType.character);
      expect(value, equals(const CharacterValue('a')));
    });

    test('rejects multiple characters when target is character', () {
      final value = classifier.parseAs('ab', PrimitiveType.character);
      expect(value, isNull);
    });

    test('accepts integer text when target is real, promoting it to double',
        () {
      final value = classifier.parseAs('42', PrimitiveType.real);
      expect(value, equals(const RealValue(42.0)));
    });
  });
}
