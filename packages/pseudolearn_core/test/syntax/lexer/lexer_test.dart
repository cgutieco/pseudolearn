import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

void main() {
  group('Lexer happy path and token categories', () {
    late Lexer lexer;

    setUp(() {
      lexer = Lexer(const ClassicSpanishProfile.strict());
    });

    test('tokenizes complete structured program with exact token types', () {
      const source = '''
Proceso Sumar
  Definir a, b Como Entero;
  a <- 5;
  b <- 10.5;
  Escribir "Resultado:", a + b;
FinProceso
''';
      final result = lexer.tokenize(source);

      expect(result.hasErrors, isFalse);
      expect(result.diagnostics, isEmpty);

      final tokenTypes = result.tokens.map((t) => t.type).toList();
      expect(
        tokenTypes,
        equals([
          TokenType.algorithm,
          TokenType.identifier,
          TokenType.endOfLine,
          TokenType.declare,
          TokenType.identifier,
          TokenType.comma,
          TokenType.identifier,
          TokenType.typeConnector,
          TokenType.integerType,
          TokenType.semicolon,
          TokenType.endOfLine,
          TokenType.identifier,
          TokenType.assignment,
          TokenType.integerLiteral,
          TokenType.semicolon,
          TokenType.endOfLine,
          TokenType.identifier,
          TokenType.assignment,
          TokenType.realLiteral,
          TokenType.semicolon,
          TokenType.endOfLine,
          TokenType.write,
          TokenType.stringLiteral,
          TokenType.comma,
          TokenType.identifier,
          TokenType.plus,
          TokenType.identifier,
          TokenType.semicolon,
          TokenType.endOfLine,
          TokenType.endAlgorithm,
          TokenType.endOfLine,
          TokenType.endOfFile,
        ]),
      );
    });

    test('exact span calculation on first token and line transitions', () {
      const source = 'Proceso Demo\nFinProceso';
      final result = lexer.tokenize(source);

      expect(result.tokens[0].type, equals(TokenType.algorithm));
      expect(result.tokens[0].span.start.line, equals(1));
      expect(result.tokens[0].span.start.column, equals(1));
      expect(result.tokens[0].span.start.offset, equals(0));
      expect(result.tokens[0].span.end.line, equals(1));
      expect(result.tokens[0].span.end.column, equals(8));
      expect(result.tokens[0].span.end.offset, equals(7));

      expect(result.tokens[1].type, equals(TokenType.identifier));
      expect(result.tokens[1].lexeme, equals('Demo'));
      expect(result.tokens[1].span.start.column, equals(9));
      expect(result.tokens[1].span.end.column, equals(13));

      expect(result.tokens[2].type, equals(TokenType.endOfLine));

      expect(result.tokens[3].type, equals(TokenType.endAlgorithm));
      expect(result.tokens[3].span.start.line, equals(2));
      expect(result.tokens[3].span.start.column, equals(1));
      expect(result.tokens[3].span.end.column, equals(11));

      expect(result.tokens[4].type, equals(TokenType.endOfFile));
    });

    test('tokenizes all relational and arithmetic operators', () {
      const source = '+ - * / div mod ^ < <= > >= = <> Y O NO';
      final result = lexer.tokenize(source);

      final types = result.tokens.map((t) => t.type).toList();
      expect(
        types,
        equals([
          TokenType.plus,
          TokenType.minus,
          TokenType.multiply,
          TokenType.divide,
          TokenType.integerDivide,
          TokenType.modulo,
          TokenType.power,
          TokenType.lessThan,
          TokenType.lessThanOrEqual,
          TokenType.greaterThan,
          TokenType.greaterThanOrEqual,
          TokenType.equal,
          TokenType.notEqual,
          TokenType.and,
          TokenType.or,
          TokenType.not,
          TokenType.endOfFile,
        ]),
      );
    });

    test('tokenizes control structures and keywords', () {
      const source =
          'Si Entonces SiNo FinSi Mientras Hacer FinMientras Repetir Hasta Que Para Hasta Con Paso FinPara';
      final result = lexer.tokenize(source);

      final types = result.tokens.map((t) => t.type).toList();
      expect(
        types,
        equals([
          TokenType.ifKeyword,
          TokenType.then,
          TokenType.elseKeyword,
          TokenType.endIf,
          TokenType.whileKeyword,
          TokenType.doKeyword,
          TokenType.endWhile,
          TokenType.repeat,
          TokenType.until,
          TokenType.forKeyword,
          TokenType.to,
          TokenType.step,
          TokenType.endFor,
          TokenType.endOfFile,
        ]),
      );
    });

    test('never throws exceptions on arbitrary inputs', () {
      final inputs = [
        '',
        ' ',
        '\n',
        '///',
        '"""',
        '\\',
        '123.45.67',
        '!@#\$%^&*()',
        '0' * 1000,
      ];
      for (final input in inputs) {
        expect(() => lexer.tokenize(input), returnsNormally);
      }
    });
  });
}
