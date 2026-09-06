import 'package:pseudolearn_core/src/domain/diagnostic.dart';
import 'package:pseudolearn_core/src/domain/diagnostic_argument.dart';
import 'package:pseudolearn_core/src/domain/diagnostic_code.dart';
import 'package:pseudolearn_core/src/domain/profile/language_profile.dart';
import 'package:pseudolearn_core/src/domain/profile/profiles/classic_spanish_profile.dart';
import 'package:pseudolearn_core/src/domain/profile/profiles/english_profile.dart';
import 'package:pseudolearn_core/src/domain/token_type.dart';
import 'package:pseudolearn_core/src/syntax/lexer/lexer.dart';
import 'package:pseudolearn_core/src/syntax/parser/parser.dart';
import 'package:pseudolearn_core/src/syntax/parser/token_stream.dart';
import 'package:test/test.dart';

List<Diagnostic> diagnose(
  String source, {
  LanguageProfile profile = const ClassicSpanishProfile.strict(),
}) {
  final tokens = Lexer(profile).tokenize(source).tokens;
  return Parser(profile: profile).parse(TokenStream(tokens)).diagnostics;
}

List<DiagnosticCode> codes(List<Diagnostic> diagnostics) =>
    diagnostics.map((d) => d.code).toList();

void main() {
  group('Reserved lexeme written where a name is required', () {
    test('a name that is not reserved parses without diagnostics', () {
      final diagnostics = diagnose('''
Algoritmo A
  Definir valor Como Entero;
  valor <- 6;
FinAlgoritmo
''');
      expect(diagnostics, isEmpty);
    });

    test('a name that merely contains a reserved word is a valid name', () {
      final diagnostics = diagnose('''
Algoritmo A
  Definir numeroDeCasos Como Entero;
  numeroDeCasos <- 6;
FinAlgoritmo
''');
      expect(diagnostics, isEmpty);
    });

    test('reports one diagnostic for a reserved word in a declaration', () {
      final diagnostics = diagnose('''
Algoritmo A
  Definir y Como Entero;
FinAlgoritmo
''');
      expect(codes(diagnostics), equals([DiagnosticCode.reservedLexemeUsedAsName]));
    });

    test('reports one diagnostic for a reserved word as assignment target', () {
      final diagnostics = diagnose('''
Algoritmo A
  Definir x Como Entero;
  y <- 6;
FinAlgoritmo
''');
      expect(codes(diagnostics), equals([DiagnosticCode.reservedLexemeUsedAsName]));
    });

    test('reports one diagnostic for a reserved counted loop variable', () {
      final diagnostics = diagnose('''
Algoritmo A
  Para y <- 1 Hasta 3 Con Paso 1 Hacer
  FinPara
FinAlgoritmo
''');
      expect(codes(diagnostics), equals([DiagnosticCode.reservedLexemeUsedAsName]));
    });

    test('recovers to the type clause when the reserved word is mid list', () {
      final diagnostics = diagnose('''
Algoritmo A
  Definir a, y, b Como Entero;
FinAlgoritmo
''');
      expect(codes(diagnostics), equals([DiagnosticCode.reservedLexemeUsedAsName]));
    });

    test('carries the written lexeme and the token it collides with', () {
      final diagnostics = diagnose('''
Algoritmo A
  Definir NO Como Logico;
FinAlgoritmo
''');
      expect(diagnostics.single.arguments, {
        'lexeme': const LexemeDiagnosticArgument('NO'),
        'token': const TokenDiagnosticArgument(TokenType.not),
      });
    });

    test('spans only the offending word', () {
      final diagnostics = diagnose('''
Algoritmo A
  Definir y Como Entero;
FinAlgoritmo
''');
      final span = diagnostics.single.span;
      expect(span.start.line, equals(2));
      expect(span.start.column, equals(11));
      expect(span.end.column, equals(12));
    });

    test('applies to any profile: English reserved word in a declaration', () {
      final diagnostics = diagnose(
        '''
algorithm A
  define step as integer
endAlgorithm
''',
        profile: const EnglishProfile.flexible(),
      );
      expect(codes(diagnostics), equals([DiagnosticCode.reservedLexemeUsedAsName]));
    });

    test('an omitted name is not reported as a reserved name', () {
      final diagnostics = diagnose('''
Algoritmo A
  Definir Como Entero;
FinAlgoritmo
''');
      expect(
        codes(diagnostics),
        equals([DiagnosticCode.expectedIdentifierInDeclaration]),
      );
    });

    test('an omitted counted loop variable is not reported as a name', () {
      final diagnostics = diagnose('''
Algoritmo A
  Para Hasta 3 Con Paso 1 Hacer
  FinPara
FinAlgoritmo
''');
      expect(
        codes(diagnostics),
        contains(DiagnosticCode.expectedForLoopVariable),
      );
      expect(
        codes(diagnostics),
        isNot(contains(DiagnosticCode.reservedLexemeUsedAsName)),
      );
    });

    test('an incomplete expression before a keyword is not a name collision',
        () {
      final diagnostics = diagnose('''
Algoritmo A
  Definir x Como Entero;
  x <- 1;
  Si x > Entonces
  FinSi
FinAlgoritmo
''');
      expect(
        codes(diagnostics),
        isNot(contains(DiagnosticCode.reservedLexemeUsedAsName)),
      );
    });

    test('an operator written as a symbol is never a name collision', () {
      final diagnostics = diagnose('''
Algoritmo A
  Definir & Como Entero;
FinAlgoritmo
''');
      expect(
        codes(diagnostics),
        isNot(contains(DiagnosticCode.reservedLexemeUsedAsName)),
      );
    });
  });

  group('Pruned Classic Spanish type aliases', () {
    test('numero, numerico and texto are ordinary names again', () {
      final diagnostics = diagnose('''
Algoritmo A
  Definir numero, numerico, texto Como Entero;
  numero <- 6;
FinAlgoritmo
''');
      expect(diagnostics, isEmpty);
    });

    test('Real and Caracter remain the canonical type lexemes', () {
      final diagnostics = diagnose('''
Algoritmo A
  Definir r Como Real;
  Definir c Como Caracter;
  r <- 1.5;
  c <- 'a';
FinAlgoritmo
''');
      expect(diagnostics, isEmpty);
    });
  });
}
