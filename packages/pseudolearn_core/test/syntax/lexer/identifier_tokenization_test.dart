import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

void main() {
  group('Identifier tokenization', () {
    late Lexer strictLexer;
    late Lexer flexibleLexer;

    setUp(() {
      strictLexer = Lexer(const ClassicSpanishProfile.strict());
      flexibleLexer = Lexer(const ClassicSpanishProfile.flexible());
    });

    test('tokenizes valid ASCII identifiers in standard alphabet', () {
      const source = 'x _contador variable1 _private_var VAR_2';
      final result = strictLexer.tokenize(source);

      expect(result.hasErrors, isFalse);
      final identifiers = result.tokens
          .where((t) => t.type == TokenType.identifier)
          .map((t) => t.lexeme)
          .toList();

      expect(
        identifiers,
        equals(['x', '_contador', 'variable1', '_private_var', 'VAR_2']),
      );
    });

    test('preserves exact casing in identifier lexeme', () {
      const source = 'total Total TOTAL';
      final result = strictLexer.tokenize(source);

      final identifiers = result.tokens
          .where((t) => t.type == TokenType.identifier)
          .map((t) => t.lexeme)
          .toList();

      expect(identifiers, equals(['total', 'Total', 'TOTAL']));
    });

    test('reserved keywords take precedence over identifiers', () {
      const source = 'mientras Mientras MIENTRAS';
      final result = strictLexer.tokenize(source);

      final types = result.tokens.map((t) => t.type).toList();
      expect(
        types,
        equals([
          TokenType.whileKeyword,
          TokenType.whileKeyword,
          TokenType.whileKeyword,
          TokenType.endOfFile,
        ]),
      );
    });

    test(
        'extended alphabet handles accents and ñ correctly in flexible profile',
        () {
      const source = 'año índice límite canción';
      final result = flexibleLexer.tokenize(source);

      expect(result.hasErrors, isFalse);
      final identifiers = result.tokens
          .where((t) => t.type == TokenType.identifier)
          .map((t) => t.lexeme)
          .toList();

      expect(identifiers, equals(['año', 'índice', 'límite', 'canción']));
    });

    test(
        'standard alphabet emits unrecognized character diagnostics for accents and ñ',
        () {
      const source = 'añz';
      final result = strictLexer.tokenize(source);

      expect(result.hasErrors, isTrue);
      expect(result.diagnostics.length, equals(1));
      expect(
        result.diagnostics.first.code,
        equals(DiagnosticCode.unrecognizedCharacter),
      );

      final identifiers = result.tokens
          .where((t) => t.type == TokenType.identifier)
          .map((t) => t.lexeme)
          .toList();

      expect(identifiers, equals(['a', 'z']));
    });

    test('single character and single underscore identifier', () {
      const source = 'a _';
      final result = strictLexer.tokenize(source);

      expect(result.tokens[0].lexeme, equals('a'));
      expect(result.tokens[1].lexeme, equals('_'));
    });
  });
}
