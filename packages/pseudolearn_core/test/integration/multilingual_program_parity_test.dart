import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';
import 'integration_test_harness.dart';

void main() {
  group('Integration: Multilingual Full Program Parity', () {
    test(
        'Spanish vs English identical program execution output and event trace parity',
        () {
      const spanishSource = '''
Clase Contador
  Definir valor Como Entero

  Metodo Constructor(inicio Como Entero)
    Este.valor <- inicio
  FinMetodo

  Metodo Incrementar(paso Como Entero)
    Este.valor <- Este.valor + paso
  FinMetodo

  Metodo Obtener() Como Entero
    Retornar Este.valor
  FinMetodo
FinClase

SubProceso Factorial(n Como Entero) Como Entero
  Si n <= 1 Entonces
    Retornar 1
  SiNo
    Retornar n * Factorial(n - 1)
  FinSi
FinSubProceso

Algoritmo ProgramaCompleto
  Definir c Como Contador
  c <- Nuevo Contador(10)
  c.Incrementar(5)

  Definir f Como Entero
  f <- Factorial(5)

  Dimension arr[3] Como Entero
  Definir i Como Entero
  Para i <- 0 Hasta 2 Con Paso 1 Hacer
    arr[i] <- (i + 1) * 10
  FinPara

  Escribir "Contador: ", c.Obtener()
  Escribir "Factorial: ", f
  Escribir "Arreglo: ", arr[0], ", ", arr[1], ", ", arr[2]
FinAlgoritmo
''';

      const englishSource = '''
class Counter
  define value as integer

  method constructor(startVal as integer)
    this.value <- startVal
  endMethod

  method increment(stepVal as integer)
    this.value <- this.value + stepVal
  endMethod

  method get() as integer
    return this.value
  endMethod
endClass

subroutine Factorial(n as integer) as integer
  if n <= 1 then
    return 1
  else
    return n * Factorial(n - 1)
  endIf
endSubroutine

algorithm CompleteProgram
  define c as Counter
  c <- new Counter(10)
  c.increment(5)

  define f as integer
  f <- Factorial(5)

  dimension arr[3] as integer
  define i as integer
  for i <- 0 to 2 step 1 do
    arr[i] <- (i + 1) * 10
  endFor

  write "Contador: ", c.get()
  write "Factorial: ", f
  write "Arreglo: ", arr[0], ", ", arr[1], ", ", arr[2]
endAlgorithm
''';

      final spanishResult = runPipeline(
        spanishSource,
        profile: const ClassicSpanishProfile.flexible(),
      );

      final englishResult = runPipeline(
        englishSource,
        profile: const EnglishProfile.flexible(),
      );

      expect(spanishResult.hasErrors, isFalse);
      expect(englishResult.hasErrors, isFalse);

      expect(spanishResult.finalOutcome, isA<StepFinished>());
      expect(englishResult.finalOutcome, isA<StepFinished>());

      expect(
        spanishResult.output,
        equals(
          'Contador: 15\n'
          'Factorial: 120\n'
          'Arreglo: 10, 20, 30\n',
        ),
      );
      expect(englishResult.output, equals(spanishResult.output));

      final spanishOutputs = spanishResult.events
          .whereType<OutputProducedEvent>()
          .map((e) => e.text)
          .toList();
      final englishOutputs = englishResult.events
          .whereType<OutputProducedEvent>()
          .map((e) => e.text)
          .toList();

      expect(englishOutputs, equals(spanishOutputs));
    });
  });
}
