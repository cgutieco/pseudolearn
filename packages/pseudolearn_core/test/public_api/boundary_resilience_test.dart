import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

void main() {
  group('Public API Boundary Resilience', () {
    late final LanguageProfile strictProfile;
    late final LanguageProfile flexibleProfile;
    late final DiagnosticRenderer rendererEs;
    late final DiagnosticRenderer rendererEn;

    setUpAll(() {
      strictProfile = const ClassicSpanishProfile.strict();
      flexibleProfile = const ClassicSpanishProfile.flexible();
      rendererEs = DiagnosticRenderer(
        locale: DiagnosticLocale.es,
        syntaxLexicon: strictProfile,
      );
      rendererEn = DiagnosticRenderer(
        locale: DiagnosticLocale.en,
        syntaxLexicon: strictProfile,
      );
    });

    void assertPipelineResilience(String source, {LanguageProfile? profile}) {
      expect(() {
        final activeProfile = profile ?? strictProfile;
        final lexResult = Lexer(activeProfile).tokenize(source);
        final parseResult = Parser(profile: activeProfile)
            .parse(TokenStream(lexResult.tokens));

        final syntaxDiagnostics = [
          ...lexResult.diagnostics,
          ...parseResult.diagnostics,
        ];

        for (final d in syntaxDiagnostics) {
          rendererEs.render(d);
          rendererEn.render(d);
        }

        final sourceUnit = parseResult.program;
        if (sourceUnit != null) {
          final resolution =
              NameResolver(profile: activeProfile).resolve(sourceUnit);
          for (final d in resolution.diagnostics) {
            rendererEs.render(d);
            rendererEn.render(d);
          }

          final typeCheck =
              TypeChecker(resolution: resolution, profile: activeProfile)
                  .check(sourceUnit);
          for (final d in typeCheck.diagnostics) {
            rendererEs.render(d);
            rendererEn.render(d);
          }

          final program = AnalyzedProgram(
            sourceUnit: sourceUnit,
            syntaxDiagnostics: syntaxDiagnostics,
            resolution: resolution,
            typeCheck: typeCheck,
            profile: activeProfile,
          );

          final startResult = Interpreter.start(
            program: program,
            observer: RecordingExecutionObserver(),
          );

          if (startResult is ExecutionReady) {
            final outcome =
                const ProgramRunner().runToCompletion(startResult.interpreter);
            expect(outcome, isA<StepOutcome>());
          } else {
            expect(startResult, isA<ExecutionNotExecutable>());
          }
        }
      }, returnsNormally, reason: 'Pipeline must never throw on adverse input');
    }

    test('resilience against empty and whitespace-only text', () {
      assertPipelineResilience('');
      assertPipelineResilience('   \n\t  \r\n   ');
    });

    test('resilience against random garbage, emojis and unclosed tokens', () {
      final garbageInputs = [
        '🚀🔥🎉🤖👾 @#\$%^&*()',
        '"unclosed string literal at end of file',
        "'unclosed character literal",
        'Algoritmo 123 !@#\$%^&*() FinAlgoritmo',
        '<<< >>> === !== +++ --- *** /// %%% ^^^ ::: ;;; ,,, ...',
        'Si Sino Mientras Repetir Para Segun Algoritmo FinAlgoritmo',
        '/// nested invalid comment / * * /',
        'Definir 123Como <- @#\$% * &',
      ];

      for (final input in garbageInputs) {
        assertPipelineResilience(input);
      }
    });

    test('resilience against binary data, null bytes and escape codes', () {
      final binaryInputs = [
        'Algoritmo Binary\x00\x01\x02\x03\xFF FinAlgoritmo',
        '\x00\x00\x00\x00\x00',
        'Algoritmo AnsiEscape\x1B[31mRed\x1B[0m FinAlgoritmo',
        'Definir\x00x\x00Como\x00Entero\x00',
      ];

      for (final input in binaryInputs) {
        assertPipelineResilience(input);
      }
    });

    test('resilience against massive inputs (50,000 lines of statements)', () {
      final buffer = StringBuffer();
      buffer.writeln('Algoritmo CargaMasiva');
      buffer.writeln('Definir x Como Entero');
      buffer.writeln('x <- 0');
      for (var i = 0; i < 50000; i++) {
        buffer.writeln('x <- x + 1');
      }
      buffer.writeln('Escribir x');
      buffer.writeln('FinAlgoritmo');

      final source = buffer.toString();

      expect(() {
        final lexResult = Lexer(strictProfile).tokenize(source);
        final parseResult = Parser(profile: strictProfile)
            .parse(TokenStream(lexResult.tokens));
        expect(parseResult.program, isNotNull);
      }, returnsNormally);
    });

    test('resilience against pathological nesting (deep parentheses)', () {
      final open = '(' * 500;
      final close = ')' * 500;
      final source = '''
Algoritmo AnidacionProfunda
Definir x Como Entero
x <- ${open}1$close
Escribir x
FinAlgoritmo
''';
      assertPipelineResilience(source);
    });

    test('resilience against pathological nesting (500 nested conditionals)',
        () {
      final buffer = StringBuffer();
      buffer.writeln('Algoritmo CondicionalesProfundos');
      buffer.writeln('Definir x Como Entero');
      buffer.writeln('x <- 1');
      for (var i = 0; i < 500; i++) {
        buffer.writeln('Si x > 0 Entonces');
      }
      buffer.writeln('Escribir x');
      for (var i = 0; i < 500; i++) {
        buffer.writeln('FinSi');
      }
      buffer.writeln('FinAlgoritmo');

      assertPipelineResilience(buffer.toString());
    });

    test('resilience against 500 continuous unary operators', () {
      final unaries = '-' * 500;
      final source = '''
Algoritmo UnariosProfundos
Definir x Como Entero
x <- ${unaries}1
Escribir x
FinAlgoritmo
''';
      assertPipelineResilience(source);
    });

    test('resilience against program with errors in all phases simultaneously',
        () {
      const multiErrorSource = '''
Algoritmo ErroresMultiples
@caracterInvalido
Definir x Como Entero
Definir obj Como ClaseInexistente
x <- "texto incompatible"
Si x > 0
Escribir 10 / 0
FinAlgoritmo
''';
      assertPipelineResilience(multiErrorSource, profile: strictProfile);
      assertPipelineResilience(multiErrorSource, profile: flexibleProfile);
    });

    test('resilience of public models and renderers with extreme values', () {
      expect(
        () => Position(line: 1, column: 1, offset: 0),
        returnsNormally,
      );
      expect(
        () => Position(line: 1000000, column: 1000000, offset: 1000000),
        returnsNormally,
      );

      final validSpan = Span(
        start: const Position(line: 1, column: 1, offset: 0),
        end: const Position(line: 100, column: 50, offset: 500),
      );
      expect(validSpan.start.line, equals(1));

      final customDiagnostic = Diagnostic(
        code: DiagnosticCode.expectedThenKeyword,
        severity: Severity.error,
        span: validSpan,
        arguments: {
          'token': const TokenDiagnosticArgument(TokenType.then),
        },
      );

      expect(() => rendererEs.render(customDiagnostic), returnsNormally);
      expect(() => rendererEn.render(customDiagnostic), returnsNormally);
      expect(
        () => rendererEs.renderFormatted(customDiagnostic),
        returnsNormally,
      );
    });
  });
}
