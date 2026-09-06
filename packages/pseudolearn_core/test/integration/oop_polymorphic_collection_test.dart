import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';
import 'integration_test_harness.dart';

void main() {
  group('Integration: OOP Polymorphic Collections', () {
    test('dynamic dispatch over array of superclass references', () {
      const source = '''
Clase Figura
  Metodo Nombre() Como Cadena
    Retornar "Generica"
  FinMetodo

  Metodo CalcularArea() Como Real
    Retornar 0.0
  FinMetodo
FinClase

Clase Rectangulo HeredaDe Figura
  Definir base Como Real
  Definir altura Como Real

  Metodo Constructor(b Como Real, h Como Real)
    Este.base <- b
    Este.altura <- h
  FinMetodo

  Metodo Nombre() Como Cadena
    Retornar "Rectangulo"
  FinMetodo

  Metodo CalcularArea() Como Real
    Retornar Este.base * Este.altura
  FinMetodo
FinClase

Clase Circulo HeredaDe Figura
  Definir radio Como Real

  Metodo Constructor(r Como Real)
    Este.radio <- r
  FinMetodo

  Metodo Nombre() Como Cadena
    Retornar "Circulo"
  FinMetodo

  Metodo CalcularArea() Como Real
    Retornar 3.14 * Este.radio * Este.radio
  FinMetodo
FinClase

Clase Triangulo HeredaDe Figura
  Definir baseT Como Real
  Definir alturaT Como Real

  Metodo Constructor(b Como Real, h Como Real)
    Este.baseT <- b
    Este.alturaT <- h
  FinMetodo

  Metodo Nombre() Como Cadena
    Retornar "Triangulo"
  FinMetodo

  Metodo CalcularArea() Como Real
    Retornar (Este.baseT * Este.alturaT) / 2.0
  FinMetodo
FinClase

Algoritmo PruebaColeccionPolimorfica
  Dimension coleccion[3] Como Figura
  coleccion[0] <- Nuevo Rectangulo(4.0, 5.0)
  coleccion[1] <- Nuevo Circulo(2.0)
  coleccion[2] <- Nuevo Triangulo(6.0, 3.0)

  Definir i Como Entero
  Para i <- 0 Hasta 2 Con Paso 1 Hacer
    Escribir "Figura: ", coleccion[i].Nombre(), " | Area: ", coleccion[i].CalcularArea()
  FinPara
FinAlgoritmo
''';

      final observer = RecordingExecutionObserver();
      final result = runPipeline(source, observer: observer);

      expect(result.hasErrors, isFalse);
      expect(result.finalOutcome, isA<StepFinished>());
      expect(
        result.output,
        equals(
          'Figura: Rectangulo | Area: 20.0\n'
          'Figura: Circulo | Area: 12.56\n'
          'Figura: Triangulo | Area: 9.0\n',
        ),
      );

      final enteredEvents = observer.events
          .whereType<SubroutineEnteredEvent>()
          .map((e) => e.subroutineName)
          .toList();

      expect(enteredEvents, contains('Rectangulo.Nombre'));
      expect(enteredEvents, contains('Rectangulo.CalcularArea'));
      expect(enteredEvents, contains('Circulo.Nombre'));
      expect(enteredEvents, contains('Circulo.CalcularArea'));
      expect(enteredEvents, contains('Triangulo.Nombre'));
      expect(enteredEvents, contains('Triangulo.CalcularArea'));
    });

    test('three-level hierarchy polymorphism with intermediate override', () {
      const source = '''
Clase Notificador
  Metodo Canal() Como Cadena
    Retornar "Base"
  FinMetodo

  Metodo Prioridad() Como Entero
    Retornar 1
  FinMetodo
FinClase

Clase NotificadorDigital HeredaDe Notificador
  Metodo Canal() Como Cadena
    Retornar "Digital"
  FinMetodo
FinClase

Clase NotificadorEmail HeredaDe NotificadorDigital
  Metodo Prioridad() Como Entero
    Retornar 5
  FinMetodo
FinClase

Algoritmo TestJerarquiaTresNiveles
  Dimension lista[3] Como Notificador
  lista[0] <- Nuevo Notificador()
  lista[1] <- Nuevo NotificadorDigital()
  lista[2] <- Nuevo NotificadorEmail()

  Definir idx Como Entero
  Para idx <- 0 Hasta 2 Con Paso 1 Hacer
    Escribir "Canal: ", lista[idx].Canal(), " - Prioridad: ", lista[idx].Prioridad()
  FinPara
FinAlgoritmo
''';

      final result = runPipeline(source);
      expect(result.hasErrors, isFalse);
      expect(result.finalOutcome, isA<StepFinished>());
      expect(
        result.output,
        equals(
          'Canal: Base - Prioridad: 1\n'
          'Canal: Digital - Prioridad: 1\n'
          'Canal: Digital - Prioridad: 5\n',
        ),
      );
    });
  });
}
