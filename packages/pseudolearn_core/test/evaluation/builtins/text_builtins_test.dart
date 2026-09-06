import 'package:pseudolearn_core/src/evaluation/builtins/text_builtins.dart';
import 'package:test/test.dart';

void main() {
  const text = TextBuiltins();

  group('TextBuiltins.length', () {
    test('counts Unicode code points, not UTF-16 units', () {
      expect(text.length('año'), equals(3));
      expect(text.length(''), equals(0));
    });

    test('a character outside the basic multilingual plane still counts as one',
        () {
      expect(text.length('😀'), equals(1));
    });
  });

  group('TextBuiltins.characterAt', () {
    test('reads a character at a valid position (base zero)', () {
      expect(text.characterAt('hola', 0), equals('h'));
      expect(text.characterAt('hola', 3), equals('a'));
    });

    test('a position outside the string is rejected, not a crash', () {
      expect(text.characterAt('hola', 4), isNull);
      expect(text.characterAt('hola', -1), isNull);
      expect(text.characterAt('', 0), isNull);
    });

    test('indexes by code point through a character outside the basic plane',
        () {
      expect(text.characterAt('a😀b', 1), equals('😀'));
      expect(text.characterAt('a😀b', 2), equals('b'));
    });
  });

  group('TextBuiltins.characterCode and characterFromCode', () {
    test('round-trip a character through its code', () {
      final code = text.characterCode('A');
      expect(code, equals(65));
      expect(text.characterFromCode(code), equals('A'));
    });

    test('a negative code is invalid', () {
      expect(text.characterFromCode(-1), isNull);
    });

    test('a code beyond the maximum Unicode code point is invalid', () {
      expect(text.characterFromCode(0x110000), isNull);
    });

    test('a code inside the surrogate range is invalid', () {
      expect(text.characterFromCode(0xD800), isNull);
    });

    test('the maximum valid code point is accepted', () {
      expect(text.characterFromCode(0x10FFFF), isNotNull);
    });
  });
}
