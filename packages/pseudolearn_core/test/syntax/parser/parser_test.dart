import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

ParseResult parseProgram(String source) {
  final lexer = Lexer(const ClassicSpanishProfile.flexible());
  final lexerResult = lexer.tokenize(source);
  final stream = TokenStream(lexerResult.tokens);
  return Parser().parse(stream);
}

void main() {
  group('Parser - Program structure', () {
    test('parses minimal valid program', () {
      final result = parseProgram('''
Proceso Minimal
FinProceso
''');
      expect(result.diagnostics, isEmpty);
      expect(result.program, isNotNull);
      expect(result.program!.algorithm!.name, 'Minimal');
    });

    test('program body contains parsed statements', () {
      final result = parseProgram('''
Proceso Test
  Definir x Como Entero
  x <- 42
FinProceso
''');
      expect(result.diagnostics, isEmpty);
      expect(result.program!.algorithm!.body, hasLength(2));
    });

    test('reports missing algorithm when algorithm keyword is missing', () {
      final result = parseProgram('x <- 1');
      expect(result.program?.algorithm, isNull);
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.expectedAlgorithmStart),
      );
    });

    test('reports expectedAlgorithmName when identifier is missing', () {
      final result = parseProgram('''
Proceso
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.expectedAlgorithmName),
      );
    });

    test('reports unclosedAlgorithm with relatedSpan when FinProceso missing',
        () {
      final result = parseProgram('''
Proceso Test
  Definir x Como Entero
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.unclosedAlgorithm),
      );
      final unclosed = result.diagnostics
          .firstWhere((d) => d.code == DiagnosticCode.unclosedAlgorithm);
      expect(unclosed.relatedSpans, hasLength(1));
    });

    test(
        'reports unexpectedTokenOutsideProgramUnit when tokens follow FinProceso',
        () {
      final result = parseProgram('''
Proceso Test
FinProceso
extraToken
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.unexpectedTokenOutsideProgramUnit),
      );
    });

    test('applies 100 diagnostics cap and appends maxDiagnosticsExceeded', () {
      final manyCases =
          List.generate(110, (i) => '  $i: Escribir $i').join('\n');
      final result = parseProgram('''
Proceso Test
$manyCases
FinProceso
''');
      expect(result.diagnostics.length, lessThanOrEqualTo(101));
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.maxDiagnosticsExceeded),
      );
    });

    test('nested compound statements parse without diagnostics', () {
      final result = parseProgram('''
Proceso Test
  Definir i Como Entero
  Para i <- 1 Hasta 10 Con Paso 1 Hacer
    Si i > 5 Entonces
      Escribir i
    FinSi
  FinPara
FinProceso
''');
      expect(result.diagnostics, isEmpty);
      expect(result.program!.algorithm!.body, hasLength(2));
    });

    test('single error recovery allows parsing subsequent statements', () {
      final result = parseProgram('''
Proceso Test
  Definir total Como Entero
  total
  Definir opct Como Entero
FinProceso
''');
      final codes = result.diagnostics.map((d) => d.code).toList();
      expect(codes, contains(DiagnosticCode.unexpectedStatement));
      expect(result.program!.algorithm!.body.length, greaterThanOrEqualTo(2));
    });

    test('empty program body is valid', () {
      final result = parseProgram('''
Proceso Vacio
FinProceso
''');
      expect(result.diagnostics, isEmpty);
      expect(result.program!.algorithm!.body, isEmpty);
    });
  });
}
