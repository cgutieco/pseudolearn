import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

void main() {
  group('Number tokenization', () {
    late Lexer lexer;

    setUp(() {
      lexer = Lexer(const ClassicSpanishProfile.strict());
    });

    test('tokenizes integer literals with exact value', () {
      const source = '0 42 1000000 999';
      final result = lexer.tokenize(source);

      expect(result.hasErrors, isFalse);

      final integerTokens = result.tokens
          .where((t) => t.type == TokenType.integerLiteral)
          .toList();

      expect(
          integerTokens.map((t) => t.literalValue),
          equals([
            PseudoInteger.fromInt(0),
            PseudoInteger.fromInt(42),
            PseudoInteger.fromInt(1000000),
            PseudoInteger.fromInt(999),
          ]));
      expect(integerTokens.map((t) => t.lexeme),
          equals(['0', '42', '1000000', '999']));
    });

    test('tokenizes real literals with exact value', () {
      const source = '0.0 3.14159 100.5';
      final result = lexer.tokenize(source);

      expect(result.hasErrors, isFalse);

      final realTokens =
          result.tokens.where((t) => t.type == TokenType.realLiteral).toList();

      expect(
          realTokens.map((t) => t.literalValue), equals([0.0, 3.14159, 100.5]));
      expect(
          realTokens.map((t) => t.lexeme), equals(['0.0', '3.14159', '100.5']));
    });

    test('integer followed by dot and non-digit splits into integer and dot',
        () {
      const source = '12.foo';
      final result = lexer.tokenize(source);

      expect(result.tokens[0].type, equals(TokenType.integerLiteral));
      expect(result.tokens[0].lexeme, equals('12'));
      expect(result.tokens[1].type, equals(TokenType.dot));
      expect(result.tokens[1].lexeme, equals('.'));
      expect(result.tokens[2].type, equals(TokenType.identifier));
      expect(result.tokens[2].lexeme, equals('foo'));
    });

    test('dot followed by digits splits into dot and integer', () {
      const source = '.5';
      final result = lexer.tokenize(source);

      expect(result.tokens[0].type, equals(TokenType.dot));
      expect(result.tokens[1].type, equals(TokenType.integerLiteral));
      expect(result.tokens[1].literalValue, equals(PseudoInteger.fromInt(5)));
    });

    test(
        'number followed immediately by letters splits into number and identifier',
        () {
      const source = '123abc';
      final result = lexer.tokenize(source);

      expect(result.tokens[0].type, equals(TokenType.integerLiteral));
      expect(result.tokens[0].literalValue, equals(PseudoInteger.fromInt(123)));
      expect(result.tokens[1].type, equals(TokenType.identifier));
      expect(result.tokens[1].lexeme, equals('abc'));
    });
  });
}
