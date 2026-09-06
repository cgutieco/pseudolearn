import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

void main() {
  group('String and character tokenization', () {
    late Lexer lexer;

    setUp(() {
      lexer = Lexer(const ClassicSpanishProfile.strict());
    });

    test('tokenizes empty string as stringLiteral', () {
      const source = '""';
      final result = lexer.tokenize(source);

      expect(result.tokens[0].type, equals(TokenType.stringLiteral));
      expect(result.tokens[0].literalValue, equals(''));
    });

    test('tokenizes single character as characterLiteral in both quotes', () {
      const source = '"a" \'b\'';
      final result = lexer.tokenize(source);

      expect(result.tokens[0].type, equals(TokenType.characterLiteral));
      expect(result.tokens[0].literalValue, equals('a'));
      expect(result.tokens[1].type, equals(TokenType.characterLiteral));
      expect(result.tokens[1].literalValue, equals('b'));
    });

    test('tokenizes multi-character string in both quote types', () {
      const source = '"hola mundo" \'adios mundo\'';
      final result = lexer.tokenize(source);

      expect(result.tokens[0].type, equals(TokenType.stringLiteral));
      expect(result.tokens[0].literalValue, equals('hola mundo'));
      expect(result.tokens[1].type, equals(TokenType.stringLiteral));
      expect(result.tokens[1].literalValue, equals('adios mundo'));
    });

    test('allows opposing quote inside string without escaping', () {
      const source = '"it\'s fine" \'He said "Hello"\'';
      final result = lexer.tokenize(source);

      expect(result.tokens[0].literalValue, equals("it's fine"));
      expect(result.tokens[1].literalValue, equals('He said "Hello"'));
    });

    test('resolves valid escape sequences', () {
      const source = '"\\n\\t\\r\\\\\\"\\\'"';
      final result = lexer.tokenize(source);

      expect(result.hasErrors, isFalse);
      expect(result.tokens[0].type, equals(TokenType.stringLiteral));
      expect(result.tokens[0].literalValue, equals('\n\t\r\\"' "'"));
    });

    test('single escaped character has length 1 and produces characterLiteral',
        () {
      const source = r'"\n"';
      final result = lexer.tokenize(source);

      expect(result.tokens[0].type, equals(TokenType.characterLiteral));
      expect(result.tokens[0].literalValue, equals('\n'));
    });

    test('unterminated string at end of line produces diagnostic and recovers',
        () {
      const source = '"sin cerrar\nx <- 10';
      final result = lexer.tokenize(source);

      expect(result.hasErrors, isTrue);
      expect(result.diagnostics.length, equals(1));
      expect(
        result.diagnostics.first.code,
        equals(DiagnosticCode.unterminatedString),
      );
      expect(result.diagnostics.first.span.start.line, equals(1));
      expect(result.diagnostics.first.span.start.column, equals(1));

      final remainingTokens = result.tokens.map((t) => t.type).toList();
      expect(
        remainingTokens,
        equals([
          TokenType.endOfLine,
          TokenType.identifier,
          TokenType.assignment,
          TokenType.integerLiteral,
          TokenType.endOfFile,
        ]),
      );
    });

    test(
        'unterminated string at end of file produces diagnostic with span to EOF',
        () {
      const source = '"unclosed at EOF';
      final result = lexer.tokenize(source);

      expect(result.hasErrors, isTrue);
      expect(result.diagnostics.length, equals(1));
      expect(
        result.diagnostics.first.code,
        equals(DiagnosticCode.unterminatedString),
      );
      expect(result.diagnostics.first.span.end.offset, equals(source.length));
    });

    test('invalid escape sequence produces diagnostic with exact token span',
        () {
      const source = r'"hola \z mundo"';
      final result = lexer.tokenize(source);

      expect(result.hasErrors, isTrue);
      expect(result.diagnostics.length, equals(1));
      expect(
        result.diagnostics.first.code,
        equals(DiagnosticCode.invalidEscapeSequence),
      );
      expect(
        result.diagnostics.first.arguments['lexeme'],
        equals(const LexemeDiagnosticArgument(r'\z')),
      );
    });
  });
}
