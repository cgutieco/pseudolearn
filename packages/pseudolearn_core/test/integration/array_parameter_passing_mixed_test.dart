import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';
import 'integration_test_harness.dart';

void main() {
  group('Integration: Mixed Array Parameter Passing Modes', () {
    test('subroutine modifying full array by reference vs element by value in same program', () {
      const source = '''
SubProceso ModificarArregloCompleto(arr[] Como Entero Por Referencia)
  arr[0] <- 99
FinSubProceso

SubProceso ModificarElementoPorValor(val Como Entero Por Valor)
  val <- 888
FinSubProceso

SubProceso ModificarElementoPorReferencia(val Como Entero Por Referencia)
  val <- 777
FinSubProceso

Algoritmo PruebaArregloMixto
  Dimension datos[3] Como Entero
  datos[0] <- 10
  datos[1] <- 20
  datos[2] <- 30

  Escribir "Inicial: ", datos[0], " ", datos[1], " ", datos[2]
  ModificarElementoPorValor(datos[1])
  Escribir "Tras PorValor: ", datos[0], " ", datos[1], " ", datos[2]
  ModificarArregloCompleto(datos)
  Escribir "Tras ModificarArreglo: ", datos[0], " ", datos[1], " ", datos[2]
  ModificarElementoPorReferencia(datos[2])
  Escribir "Tras ModificarElementoRef: ", datos[0], " ", datos[1], " ", datos[2]
FinAlgoritmo
''';

      final observer = RecordingExecutionObserver();
      final result = runPipeline(source, observer: observer);

      expect(result.hasErrors, isFalse);
      expect(result.finalOutcome, isA<StepFinished>());
      expect(
        result.output,
        equals(
          'Inicial: 10 20 30\n'
          'Tras PorValor: 10 20 30\n'
          'Tras ModificarArreglo: 99 20 30\n'
          'Tras ModificarElementoRef: 99 20 777\n',
        ),
      );

      final enteredEvents = observer.events
          .whereType<SubroutineEnteredEvent>()
          .map((e) => e.subroutineName)
          .toList();

      expect(enteredEvents, contains('ModificarElementoPorValor'));
      expect(enteredEvents, contains('ModificarArregloCompleto'));
      expect(enteredEvents, contains('ModificarElementoPorReferencia'));
    });

    test('matrix 2D passed by-reference with element passed by-value', () {
      const source = '''
SubProceso RellenarDiagonal(mat[,] Como Entero Por Referencia, n Como Entero)
  Definir i Como Entero
  Para i <- 0 Hasta n - 1 Con Paso 1 Hacer
    mat[i, i] <- (i + 1) * 10
  FinPara
FinSubProceso

SubProceso IntentoModificarCelda(val Como Entero Por Valor)
  val <- 0
FinSubProceso

Algoritmo MatrizMixta
  Dimension m[2, 2] Como Entero
  m[0, 0] <- 1
  m[0, 1] <- 2
  m[1, 0] <- 3
  m[1, 1] <- 4

  RellenarDiagonal(m, 2)
  Escribir "Diagonal: ", m[0, 0], " ", m[1, 1]
  IntentoModificarCelda(m[0, 0])
  Escribir "Tras intento celda: ", m[0, 0], " ", m[1, 1]
FinAlgoritmo
''';

      final result = runPipeline(source);
      expect(result.hasErrors, isFalse);
      expect(result.finalOutcome, isA<StepFinished>());
      expect(
        result.output,
        equals(
          'Diagonal: 10 20\n'
          'Tras intento celda: 10 20\n',
        ),
      );
    });
  });
}
