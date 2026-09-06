import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

void main() {
  group('Error recovery in lexer', () {
    late Lexer lexer;

    setUp(() {
      lexer = Lexer(const ClassicSpanishProfile.strict());
    });

    test('recovers from single unrecognized character in stream', () {
      const source = 'a + @ + b';
      final result = lexer.tokenize(source);

      expect(result.hasErrors, isTrue);
      expect(result.diagnostics.length, equals(1));
      expect(
        result.diagnostics.first.code,
        equals(DiagnosticCode.unrecognizedCharacter),
      );
      expect(result.diagnostics.first.span.start.column, equals(5));
      expect(result.diagnostics.first.span.end.column, equals(6));

      final types = result.tokens.map((t) => t.type).toList();
      expect(
        types,
        equals([
          TokenType.identifier,
          TokenType.plus,
          TokenType.plus,
          TokenType.identifier,
          TokenType.endOfFile,
        ]),
      );
    });

    test('recovers from consecutive bursts of invalid characters', () {
      const source = 'x @#\$ z';
      final result = lexer.tokenize(source);

      expect(result.diagnostics.length, equals(3));
      for (final diagnostic in result.diagnostics) {
        expect(diagnostic.code, equals(DiagnosticCode.unrecognizedCharacter));
      }

      final identifiers = result.tokens
          .where((t) => t.type == TokenType.identifier)
          .map((t) => t.lexeme)
          .toList();
      expect(identifiers, equals(['x', 'z']));
    });

    test('recovers from unclosed string on previous line to tokenize next line',
        () {
      const source = '"cadena sin terminar\nx <- 100';
      final result = lexer.tokenize(source);

      expect(result.diagnostics.length, equals(1));
      expect(
        result.diagnostics.first.code,
        equals(DiagnosticCode.unterminatedString),
      );

      final types = result.tokens.map((t) => t.type).toList();
      expect(
        types,
        equals([
          TokenType.endOfLine,
          TokenType.identifier,
          TokenType.assignment,
          TokenType.integerLiteral,
          TokenType.endOfFile,
        ]),
      );
    });

    test('single unrecognized character file produces diagnostic and endOfFile',
        () {
      const source = '@';
      final result = lexer.tokenize(source);

      expect(result.diagnostics.length, equals(1));
      expect(result.tokens.length, equals(1));
      expect(result.tokens.first.type, equals(TokenType.endOfFile));
    });
  });
}
