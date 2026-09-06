import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

import 'interpreter_test_harness.dart';

void main() {
  test('an empty algorithm body finishes immediately with no output', () {
    const src = '''
Proceso Principal
FinProceso
''';
    final result = runProgram(src);
    expect(result.output, equals(''));
    expect(result.finalOutcome, isA<StepFinished>());
  });

  test('a zero-iteration Mientras produces no output', () {
    const src = '''
Proceso Principal
    Mientras Falso Hacer
        Escribir "nunca"
    FinMientras
FinProceso
''';
    expect(runProgram(src).output, equals(''));
  });

  test(
      'a Para with a negative step and initial less than final runs zero times',
      () {
    const src = '''
Proceso Principal
    Definir i Como Entero
    Para i <- 1 Hasta 5 Con Paso -1 Hacer
        Escribir i
    FinPara
FinProceso
''';
    expect(runProgram(src).output, equals(''));
  });

  test('a subroutine with an empty body and no return type is valid', () {
    const src = '''
SubProceso NoHaceNada()
FinSubProceso

Proceso Principal
    NoHaceNada()
    Escribir "listo"
FinProceso
''';
    expect(runProgram(src).output, equals('listo\n'));
  });

  test('a run stopped mid-way and abandoned does not throw', () {
    const src = '''
Proceso Principal
    Escribir "1"
    Escribir "2"
    Escribir "3"
FinProceso
''';
    final interpreter =
        readyInterpreter(src, observer: RecordingExecutionObserver());
    interpreter.step();
    interpreter.step();
    expect(() => interpreter.step(), returnsNormally);
  });

  test('a program that declares a class runs successfully under Sprint 16 OOP evaluation',
      () {
    const src = '''
Clase Punto
    Publico Definir coordX Como Entero
FinClase

Proceso Principal
    Escribir "ejecuta correctamente"
FinProceso
''';
    final program = analyzeProgram(src);
    final result = Interpreter.start(program: program);
    expect(result, isA<ExecutionReady>());
  });
}
