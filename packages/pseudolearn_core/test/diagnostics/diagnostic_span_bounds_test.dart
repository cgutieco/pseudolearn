import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

void main() {
  group('Diagnostic span bounds verification', () {
    const profile = ClassicSpanishProfile.strict();

    void assertSpanWithinBounds(Span span, String source, String context) {
      expect(
        span.start.offset,
        greaterThanOrEqualTo(0),
        reason: '$context: span.start.offset must be >= 0',
      );
      expect(
        span.end.offset,
        greaterThanOrEqualTo(span.start.offset),
        reason: '$context: span.end.offset must be >= span.start.offset',
      );
      expect(
        span.end.offset,
        lessThanOrEqualTo(source.length),
        reason:
            '$context: span.end.offset (${span.end.offset}) must be <= source length (${source.length})',
      );
      expect(
        span.start.line,
        greaterThanOrEqualTo(1),
        reason: '$context: line must be >= 1',
      );
      expect(
        span.start.column,
        greaterThanOrEqualTo(1),
        reason: '$context: column must be >= 1',
      );
    }

    void verifyDiagnosticSpans(
      Iterable<Diagnostic> diagnostics,
      String source,
      String context,
    ) {
      for (final diag in diagnostics) {
        assertSpanWithinBounds(
          diag.span,
          source,
          '$context [${diag.code.name}]',
        );
        for (final related in diag.relatedSpans) {
          assertSpanWithinBounds(
            related,
            source,
            '$context [${diag.code.name} relatedSpan]',
          );
        }
      }
    }

    test('lexer diagnostics have spans within source bounds', () {
      const source = 'Proceso Test @ # "cadena sin cerrar';
      final result = Lexer(profile).tokenize(source);
      expect(result.diagnostics, isNotEmpty);
      verifyDiagnosticSpans(result.diagnostics, source, 'Lexer');
    });

    test('parser diagnostics have spans within source bounds', () {
      const source = '''
Proceso Test
  Definir x Como
  Si Verdadero
    Escribir 1
FinProceso
''';
      final tokens = Lexer(profile).tokenize(source).tokens;
      final parsed = Parser().parse(TokenStream(tokens));
      expect(parsed.diagnostics, isNotEmpty);
      verifyDiagnosticSpans(parsed.diagnostics, source, 'Parser');
    });

    test('semantic name resolver and type checker diagnostics have spans within source bounds', () {
      const source = '''
Proceso Test
  x <- 10;
  Escribir x;
FinProceso
''';
      final tokens = Lexer(profile).tokenize(source).tokens;
      final parsed = Parser().parse(TokenStream(tokens));
      final sourceUnit = parsed.program!;
      final resolution = NameResolver(profile: profile).resolve(sourceUnit);
      final typeCheck =
          TypeChecker(resolution: resolution, profile: profile).check(sourceUnit);
      final allSemantic = [...resolution.diagnostics, ...typeCheck.diagnostics];
      expect(allSemantic, isNotEmpty);
      verifyDiagnosticSpans(allSemantic, source, 'Semantic');
    });

    test('runtime execution diagnostics have spans within source bounds', () {
      const source = '''
Proceso Test
  Definir x Como Real;
  x <- 10 / 0;
FinProceso
''';
      final tokens = Lexer(profile).tokenize(source).tokens;
      final parsed = Parser().parse(TokenStream(tokens));
      final sourceUnit = parsed.program!;
      final resolution = NameResolver(profile: profile).resolve(sourceUnit);
      final typeCheck =
          TypeChecker(resolution: resolution, profile: profile).check(sourceUnit);
      final analyzed = AnalyzedProgram(
        sourceUnit: sourceUnit,
        syntaxDiagnostics: [...parsed.diagnostics],
        resolution: resolution,
        typeCheck: typeCheck,
        profile: profile,
      );
      final ready = Interpreter.start(program: analyzed) as ExecutionReady;
      final outcome = const ProgramRunner().runToCompletion(ready.interpreter);
      expect(outcome, isA<StepHalted>());
      final haltDiag = (outcome as StepHalted).diagnostic;
      verifyDiagnosticSpans([haltDiag], source, 'Execution');
    });

    test('fails when span exceeds source bounds (negative test)', () {
      const source = 'abc';
      final invalidSpan = Span(
        start: const Position(line: 1, column: 1, offset: 0),
        end: const Position(line: 1, column: 10, offset: 10),
      );

      expect(
        () => assertSpanWithinBounds(invalidSpan, source, 'Deliberate violation'),
        throwsA(isA<TestFailure>()),
      );
    });
  });
}
