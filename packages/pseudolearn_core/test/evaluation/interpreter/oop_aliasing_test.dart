import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

import 'interpreter_test_harness.dart';

void main() {
  group('OOP Aliasing and Identity Tests', () {
    test('assigning object variable copies reference and shares mutable state', () {
      const source = '''
Clase Nodo
  Definir valor Como Entero

  Metodo Constructor(v Como Entero)
    Este.valor <- v
  FinMetodo
FinClase

Algoritmo Test
  Definir n1, n2 Como Nodo
  n1 <- Nuevo Nodo(10)
  n2 <- n1
  n2.valor <- 99
  Escribir "n1.valor: ", n1.valor, ", n2.valor: ", n2.valor
FinAlgoritmo
''';
      final result = runProgram(source);
      expect(result.output, equals('n1.valor: 99, n2.valor: 99\n'));
      expect(result.finalOutcome, isA<StepFinished>());
    });

    test('equality comparisons check object identity id', () {
      const source = '''
Clase Elemento
  Definir clave Como Entero

  Metodo Constructor(k Como Entero)
    Este.clave <- k
  FinMetodo
FinClase

Algoritmo Test
  Definir e1, e2, e3 Como Elemento
  e1 <- Nuevo Elemento(5)
  e2 <- e1
  e3 <- Nuevo Elemento(5)

  Si e1 = e2 Entonces
    Escribir "e1 igual e2"
  FinSi

  Si e1 <> e3 Entonces
    Escribir "e1 distinto e3"
  FinSi
FinAlgoritmo
''';
      final result = runProgram(source);
      expect(result.output, equals('e1 igual e2\ne1 distinto e3\n'));
      expect(result.finalOutcome, isA<StepFinished>());
    });

    test('EnvironmentSnapshot reflects same instance id across aliased variables', () {
      const source = '''
Clase Dato
  Definir info Como Entero
FinClase

Algoritmo Test
  Definir d1, d2 Como Dato
  d1 <- Nuevo Dato()
  d1.info <- 7
  d2 <- d1
  Escribir d2.info
FinAlgoritmo
''';
      final observer = RecordingExecutionObserver();
      final interpreter = readyInterpreter(source, observer: observer);
      const ProgramRunner().runToCompletion(interpreter);

      final finishEvent = observer.events
          .whereType<StatementEnteredEvent>()
          .lastWhere((e) => e.snapshot != null);
      final snapshot = finishEvent.snapshot!;
      final frameVars = snapshot.frames.first.variables;

      final d1Entry = frameVars.firstWhere((v) => v.name == 'd1');
      final d2Entry = frameVars.firstWhere((v) => v.name == 'd2');

      expect(d1Entry.hasValue, isTrue);
      expect(d2Entry.hasValue, isTrue);
      expect(d1Entry.value, isA<ObjectValue>());
      expect(d2Entry.value, isA<ObjectValue>());

      final d1Val = d1Entry.value as ObjectValue;
      final d2Val = d2Entry.value as ObjectValue;

      expect(d1Val.instance.id, equals(d2Val.instance.id));
    });
  });
}
