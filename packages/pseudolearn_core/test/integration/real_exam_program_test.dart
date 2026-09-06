import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';
import 'integration_test_harness.dart';

void main() {
  group('Integration: Real Exam Algorithmic Program', () {
    test('Student grade management and course statistics exam problem', () {
      const source = '''
Clase RegistroAlumno
  Definir nombre Como Cadena
  Definir nota1 Como Real
  Definir nota2 Como Real

  Metodo Constructor(nom Como Cadena, n1 Como Real, n2 Como Real)
    Este.nombre <- nom
    Este.nota1 <- n1
    Este.nota2 <- n2
  FinMetodo

  Metodo Promedio() Como Real
    Retornar (Este.nota1 + Este.nota2) / 2.0
  FinMetodo

  Metodo EsAprobado() Como Logico
    Si Este.Promedio() >= 60.0 Entonces
      Retornar Verdadero
    SiNo
      Retornar Falso
    FinSi
  FinMetodo
FinClase

SubProceso ReportarCurso(lista[] Como RegistroAlumno Por Referencia, total Como Entero)
  Definir sumaPromedios Como Real
  sumaPromedios <- 0.0
  Definir aprobados Como Entero
  aprobados <- 0
  Definir mejorIdx Como Entero
  mejorIdx <- 0
  Definir mejorProm Como Real
  mejorProm <- -1.0

  Definir i Como Entero
  Para i <- 0 Hasta total - 1 Con Paso 1 Hacer
    Definir prom Como Real
    prom <- lista[i].Promedio()
    sumaPromedios <- sumaPromedios + prom

    Si lista[i].EsAprobado() Entonces
      aprobados <- aprobados + 1
    FinSi

    Si prom > mejorProm Entonces
      mejorProm <- prom
      mejorIdx <- i
    FinSi

    Escribir lista[i].nombre, " - Promedio: ", prom
  FinPara

  Definir promGeneral Como Real
  promGeneral <- sumaPromedios / (total * 1.0)

  Escribir "--- RESUMEN DEL CURSO ---"
  Escribir "Promedio General: ", promGeneral
  Escribir "Aprobados: ", aprobados
  Escribir "Reprobados: ", total - aprobados
  Escribir "Mejor Alumno: ", lista[mejorIdx].nombre, " (", mejorProm, ")"
FinSubProceso

Algoritmo ExamenCalificaciones
  Definir totalAlumnos Como Entero
  Leer totalAlumnos

  Dimension alumnos[3] Como RegistroAlumno

  Definir k Como Entero
  Para k <- 0 Hasta totalAlumnos - 1 Con Paso 1 Hacer
    Definir nom Como Cadena
    Definir n1 Como Real
    Definir n2 Como Real
    Leer nom
    Leer n1
    Leer n2
    alumnos[k] <- Nuevo RegistroAlumno(nom, n1, n2)
  FinPara

  ReportarCurso(alumnos, totalAlumnos)
FinAlgoritmo
''';

      final observer = RecordingExecutionObserver();
      final result = runPipeline(
        source,
        inputs: [
          '3',
          'Ana',
          '80.0',
          '90.0',
          'Bruno',
          '50.0',
          '60.0',
          'Carlos',
          '95.0',
          '95.0',
        ],
        observer: observer,
      );

      expect(result.hasErrors, isFalse);
      expect(result.finalOutcome, isA<StepFinished>());

      final lines = result.output.trim().split('\n');
      expect(lines[0], equals('Ana - Promedio: 85.0'));
      expect(lines[1], equals('Bruno - Promedio: 55.0'));
      expect(lines[2], equals('Carlos - Promedio: 95.0'));
      expect(lines[3], equals('--- RESUMEN DEL CURSO ---'));
      expect(lines[4], startsWith('Promedio General: 78.333'));
      expect(lines[5], equals('Aprobados: 2'));
      expect(lines[6], equals('Reprobados: 1'));
      expect(lines[7], equals('Mejor Alumno: Carlos (95.0)'));

      final acceptedInputs =
          observer.events.whereType<InputAcceptedEvent>().length;
      expect(acceptedInputs, equals(10));
    });
  });
}
