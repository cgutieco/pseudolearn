import 'package:pseudolearn_core/src/domain/position.dart';
import 'package:pseudolearn_core/src/domain/span.dart';
import 'package:pseudolearn_core/src/domain/token.dart';
import 'package:pseudolearn_core/src/domain/token_type.dart';
import 'package:test/test.dart';

void main() {
  group('Token', () {
    final span = Span(
      start: const Position(line: 1, column: 1, offset: 0),
      end: const Position(line: 1, column: 8, offset: 7),
    );

    test('creates token with properties and checks equality', () {
      final token1 = Token(
        type: TokenType.algorithm,
        span: span,
        lexeme: 'Proceso',
      );
      final token2 = Token(
        type: TokenType.algorithm,
        span: span,
        lexeme: 'Proceso',
      );

      expect(token1, equals(token2));
      expect(token1.hashCode, equals(token2.hashCode));
      expect(token1.type, equals(TokenType.algorithm));
      expect(token1.lexeme, equals('Proceso'));
      expect(token1.span, equals(span));
      expect(token1.literalValue, isNull);
    });

    test('token with literalValue distinguishes equality', () {
      final tokenNumber1 = Token(
        type: TokenType.integerLiteral,
        span: span,
        lexeme: '42',
        literalValue: 42,
      );
      final tokenNumber2 = Token(
        type: TokenType.integerLiteral,
        span: span,
        lexeme: '42',
        literalValue: 42,
      );
      final tokenNumber3 = Token(
        type: TokenType.integerLiteral,
        span: span,
        lexeme: '42',
        literalValue: 43,
      );

      expect(tokenNumber1, equals(tokenNumber2));
      expect(tokenNumber1, isNot(equals(tokenNumber3)));
    });

    test('toString formatting produces readable summary', () {
      final token = Token(
        type: TokenType.ifKeyword,
        span: span,
        lexeme: 'Si',
      );
      expect(token.toString(), contains('Token(TokenType.ifKeyword, "Si"'));
    });
  });
}
