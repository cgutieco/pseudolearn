import 'package:pseudolearn_core/src/domain/lexeme_shape.dart';
import 'package:test/test.dart';

void main() {
  group('LexemeShape.isWord', () {
    test('accepts lexemes that start with an ASCII letter', () {
      expect(LexemeShape.isWord('Mientras'), isTrue);
      expect(LexemeShape.isWord('y'), isTrue);
      expect(LexemeShape.isWord('Hasta Que'), isTrue);
    });

    test('accepts lexemes that start with an underscore', () {
      expect(LexemeShape.isWord('_total'), isTrue);
      expect(LexemeShape.isWord('_'), isTrue);
    });

    test('rejects operator and delimiter lexemes', () {
      expect(LexemeShape.isWord('<-'), isFalse);
      expect(LexemeShape.isWord('&'), isFalse);
      expect(LexemeShape.isWord('%'), isFalse);
      expect(LexemeShape.isWord(';'), isFalse);
    });

    test('rejects the empty lexeme', () {
      expect(LexemeShape.isWord(''), isFalse);
    });

    test('rejects a lexeme that starts with a digit', () {
      expect(LexemeShape.isWord('1a'), isFalse);
    });
  });
}
