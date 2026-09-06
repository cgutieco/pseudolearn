import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

void main() {
  group('Comments and whitespace handling', () {
    late Lexer lexer;

    setUp(() {
      lexer = Lexer(const ClassicSpanishProfile.strict());
    });

    test('ignores comment at start of line', () {
      const source = '// este es un comentario\nx <- 10';
      final result = lexer.tokenize(source);

      expect(result.hasErrors, isFalse);
      final types = result.tokens.map((t) => t.type).toList();
      expect(
        types,
        equals([
          TokenType.identifier,
          TokenType.assignment,
          TokenType.integerLiteral,
          TokenType.endOfFile,
        ]),
      );
    });

    test('ignores comment at end of line without skipping newline', () {
      const source = 'x <- 10 // asignar valor\nb <- 20';
      final result = lexer.tokenize(source);

      final types = result.tokens.map((t) => t.type).toList();
      expect(
        types,
        equals([
          TokenType.identifier,
          TokenType.assignment,
          TokenType.integerLiteral,
          TokenType.endOfLine,
          TokenType.identifier,
          TokenType.assignment,
          TokenType.integerLiteral,
          TokenType.endOfFile,
        ]),
      );
    });

    test('entire file of comments produces single endOfFile token', () {
      const source = '// linea 1\n// linea 2\n// linea 3';
      final result = lexer.tokenize(source);

      expect(result.tokens.length, equals(1));
      expect(result.tokens.first.type, equals(TokenType.endOfFile));
    });

    test('last line comment without newline produces clean endOfFile', () {
      const source = 'x <- 1 // ultimo';
      final result = lexer.tokenize(source);

      final types = result.tokens.map((t) => t.type).toList();
      expect(
        types,
        equals([
          TokenType.identifier,
          TokenType.assignment,
          TokenType.integerLiteral,
          TokenType.endOfFile,
        ]),
      );
    });

    test('collapses consecutive blank lines and handles CRLF', () {
      const source = "x <- 1\r\n\r\n\r\nb <- 2\r\n";
      final result = lexer.tokenize(source);

      final types = result.tokens.map((t) => t.type).toList();
      expect(
        types,
        equals([
          TokenType.identifier,
          TokenType.assignment,
          TokenType.integerLiteral,
          TokenType.endOfLine,
          TokenType.identifier,
          TokenType.assignment,
          TokenType.integerLiteral,
          TokenType.endOfLine,
          TokenType.endOfFile,
        ]),
      );
    });

    test('empty string input produces only endOfFile', () {
      final result = lexer.tokenize('');
      expect(result.tokens.length, equals(1));
      expect(result.tokens.first.type, equals(TokenType.endOfFile));
      expect(result.tokens.first.span.start.offset, equals(0));
      expect(result.tokens.first.span.end.offset, equals(0));
    });
  });
}
