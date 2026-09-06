import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

void main() {
  group('Evaluation Determinism', () {
    late final LanguageProfile profile;

    setUpAll(() {
      profile = const ClassicSpanishProfile.flexible();
    });

    RunResult executeProgram(String source, {int seed = 42}) {
      final lexResult = Lexer(profile).tokenize(source);
      final parseResult =
          Parser(profile: profile).parse(TokenStream(lexResult.tokens));

      final sourceUnit = parseResult.program!;
      final resolution = NameResolver(profile: profile).resolve(sourceUnit);
      final typeCheck =
          TypeChecker(resolution: resolution, profile: profile).check(sourceUnit);

      final syntaxDiagnostics = [
        ...lexResult.diagnostics,
        ...parseResult.diagnostics,
      ];

      final analyzedProgram = AnalyzedProgram(
        sourceUnit: sourceUnit,
        syntaxDiagnostics: syntaxDiagnostics,
        resolution: resolution,
        typeCheck: typeCheck,
        profile: profile,
      );

      final observer = RecordingExecutionObserver();
      final random = SeededRandomSource(seed);
      final startResult = Interpreter.start(
        program: analyzedProgram,
        observer: observer,
        random: random,
      );

      if (startResult is! ExecutionReady) {
        final renderer = DiagnosticRenderer(
          locale: DiagnosticLocale.es,
          syntaxLexicon: profile,
        );
        for (final d in [...syntaxDiagnostics, ...typeCheck.diagnostics]) {
          renderer.render(d);
        }
        throw StateError('Interpreter start failed.');
      }

      final outcome =
          const ProgramRunner().runToCompletion(startResult.interpreter);

      final buffer = StringBuffer();
      for (final event in observer.events) {
        if (event is OutputProducedEvent) {
          buffer.write(event.text);
        }
      }

      return RunResult(
        events: observer.events,
        output: buffer.toString(),
        finalOutcome: outcome,
      );
    }

    test(
        'identical program execution produces identical event trace and output byte-for-byte',
        () {
      const source = '''
Clase Item
  Definir codigo Como Entero
  Definir valor Como Real

  Metodo Constructor(c Como Entero, v Como Real)
    Este.codigo <- c
    Este.valor <- v
  FinMetodo

  Metodo Escalar(factor Como Real)
    Este.valor <- Este.valor * factor
  FinMetodo
FinClase

SubProceso BarajarYCalcular(arr[] Como Entero Por Referencia, n Como Entero)
  Definir i Como Entero
  Para i <- 0 Hasta n - 1 Con Paso 1 Hacer
    arr[i] <- arr[i] + trunc(azar() * 100)
  FinPara
FinSubProceso

Algoritmo DeterminismoTotal
  Dimension items[3] Como Item
  Dimension numeros[3] Como Entero
  Definir i Como Entero

  Para i <- 0 Hasta 2 Con Paso 1 Hacer
    numeros[i] <- (i + 1) * 10
    items[i] <- Nuevo Item(i + 1, (i + 1) * 1.5)
    items[i].Escalar(2.0)
  FinPara

  BarajarYCalcular(numeros, 3)

  Para i <- 0 Hasta 2 Con Paso 1 Hacer
    Escribir "Item ", items[i].codigo, " val=", items[i].valor, " num=", numeros[i]
  FinPara
FinAlgoritmo
''';

      final run1 = executeProgram(source, seed: 12345);
      final run2 = executeProgram(source, seed: 12345);

      expect(run1.finalOutcome, isA<StepFinished>());
      expect(run2.finalOutcome, isA<StepFinished>());

      expect(run1.output, equals(run2.output));
      expect(run1.output.isNotEmpty, isTrue);

      expect(run1.events.length, equals(run2.events.length));

      for (var i = 0; i < run1.events.length; i++) {
        final e1 = run1.events[i];
        final e2 = run2.events[i];

        expect(e1.runtimeType, equals(e2.runtimeType),
            reason: 'Event $i type mismatch');

        if (e1 is OutputProducedEvent && e2 is OutputProducedEvent) {
          expect(e1.text, equals(e2.text));
        }

        if (e1 is StatementEnteredEvent && e2 is StatementEnteredEvent) {
          expect(e1.statementId, equals(e2.statementId));
          expect(e1.snapshot?.frames.length, equals(e2.snapshot?.frames.length));
        }

        if (e1 is StatementExitedEvent && e2 is StatementExitedEvent) {
          expect(e1.statementId, equals(e2.statementId));
          expect(e1.snapshot?.frames.length, equals(e2.snapshot?.frames.length));
        }

        if (e1 is SubroutineEnteredEvent && e2 is SubroutineEnteredEvent) {
          expect(e1.subroutineName, equals(e2.subroutineName));
          expect(e1.callSpan.start.offset, equals(e2.callSpan.start.offset));
        }

        if (e1 is SubroutineExitedEvent && e2 is SubroutineExitedEvent) {
          expect(e1.subroutineName, equals(e2.subroutineName));
        }
      }
    });

    test('different random seeds produce different random outputs', () {
      const source = '''
Algoritmo TestSemilla
  Definir a, b Como Real
  a <- azar()
  b <- azar()
  Escribir a, ",", b
FinAlgoritmo
''';

      final runA = executeProgram(source, seed: 1111);
      final runB = executeProgram(source, seed: 9999);

      expect(runA.output, isNot(equals(runB.output)));
    });
  });
}

final class RunResult {
  final List<ExecutionEvent> events;
  final String output;
  final StepOutcome finalOutcome;

  const RunResult({
    required this.events,
    required this.output,
    required this.finalOutcome,
  });
}
