import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

void main() {
  group('Multilingual profile parity in lexer', () {
    late Lexer spanishLexer;
    late Lexer englishLexer;

    setUp(() {
      spanishLexer = Lexer(const ClassicSpanishProfile.strict());
      englishLexer = Lexer(const EnglishProfile.strict());
    });

    test('same program in Spanish and English yields identical token types',
        () {
      const spanishSource = '''
Proceso Paridad
  Definir n Como Entero;
  Leer n;
  Si n > 0 Entonces
    Escribir "Positivo";
  SiNo
    Escribir "No positivo";
  FinSi
FinProceso
''';

      const englishSource = '''
Algorithm Paridad
  Define n As Integer;
  Read n;
  If n > 0 Then
    Write "Positivo";
  Else
    Write "No positivo";
  EndIf
EndAlgorithm
''';

      final spanishResult = spanishLexer.tokenize(spanishSource);
      final englishResult = englishLexer.tokenize(englishSource);

      expect(spanishResult.hasErrors, isFalse);
      expect(englishResult.hasErrors, isFalse);

      final spanishTypes = spanishResult.tokens.map((t) => t.type).toList();
      final englishTypes = englishResult.tokens.map((t) => t.type).toList();

      expect(spanishTypes, equals(englishTypes));
    });

    test('multi-word tokens with multiple spaces and tabs match correctly', () {
      const source = 'Escribir "Hola" Sin    Saltar';
      final result = spanishLexer.tokenize(source);

      expect(result.tokens[0].type, equals(TokenType.write));
      expect(result.tokens[1].type, equals(TokenType.stringLiteral));
      expect(result.tokens[2].type, equals(TokenType.withoutNewline));
      expect(result.tokens[2].lexeme, equals('Sin    Saltar'));
    });

    test('multi-word token does not cross line breaks', () {
      const source = 'Sin\nSaltar';
      final result = spanishLexer.tokenize(source);

      expect(result.tokens[0].type, equals(TokenType.identifier));
      expect(result.tokens[0].lexeme, equals('Sin'));
      expect(result.tokens[1].type, equals(TokenType.endOfLine));
      expect(result.tokens[2].type, equals(TokenType.identifier));
      expect(result.tokens[2].lexeme, equals('Saltar'));
    });
  });
}
