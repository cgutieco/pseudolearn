import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

import 'interpreter_test_harness.dart';

void main() {
  group('Call and return (10.5, 10.6)', () {
    test('a subroutine without a return type runs as a statement', () {
      const src = '''
SubProceso Saludar()
    Escribir "hola"
FinSubProceso

Proceso Principal
    Saludar()
FinProceso
''';
      expect(runProgram(src).output, equals('hola\n'));
    });

    test('a function is used as a value inside an expression', () {
      const src = '''
SubProceso Doble(x Como Entero) Como Entero
    Retornar x * 2
FinSubProceso

Proceso Principal
    Definir resultado Como Entero
    resultado <- Doble(21)
    Escribir resultado
FinProceso
''';
      expect(runProgram(src).output, equals('42\n'));
    });

    test('multiple returns from different branches', () {
      const src = '''
SubProceso Maximo(a Como Entero, b Como Entero) Como Entero
    Si a > b Entonces
        Retornar a
    SiNo
        Retornar b
    FinSi
FinSubProceso

Proceso Principal
    Escribir Maximo(3, 7)
    Escribir Maximo(9, 2)
FinProceso
''';
      expect(runProgram(src).output, equals('7\n9\n'));
    });
  });

  group('Parameter passing (10.3, 10.4)', () {
    test('by value does not modify the caller\'s variable', () {
      const src = '''
SubProceso Incrementar(n Como Entero)
    n <- n + 1
FinSubProceso

Proceso Principal
    Definir x Como Entero
    x <- 5
    Incrementar(x)
    Escribir x
FinProceso
''';
      expect(runProgram(src).output, equals('5\n'));
    });

    test('by reference modifies the caller\'s variable', () {
      const src = '''
SubProceso Incrementar(n Como Entero Por Referencia)
    n <- n + 1
FinSubProceso

Proceso Principal
    Definir x Como Entero
    x <- 5
    Incrementar(x)
    Escribir x
FinProceso
''';
      expect(runProgram(src).output, equals('6\n'));
    });

    test('by reference on an array element: the index is fixed at call time',
        () {
      const src = '''
SubProceso PonerCero(n Como Entero Por Referencia)
    n <- 0
FinSubProceso

Proceso Principal
    Dimension datos[3] Como Entero
    Definir i Como Entero
    datos[0] <- 1
    datos[1] <- 2
    datos[2] <- 3
    i <- 1
    PonerCero(datos[i])
    Escribir datos[0], ",", datos[1], ",", datos[2]
FinProceso
''';
      expect(runProgram(src).output, equals('1,0,3\n'));
    });
  });

  group('Subroutine events', () {
    test('entering and exiting a call produces matching events', () {
      const src = '''
SubProceso Saludar()
    Escribir "hola"
FinSubProceso

Proceso Principal
    Saludar()
FinProceso
''';
      final result = runProgram(src);
      expect(result.events.whereType<SubroutineEnteredEvent>(), hasLength(1));
      expect(result.events.whereType<SubroutineExitedEvent>(), hasLength(1));
      expect(
        result.events.whereType<SubroutineEnteredEvent>().single.subroutineName,
        equals('Saludar'),
      );
    });
  });

  group('Subroutine without return on every path', () {
    test(
        'reaching the closing brace of a function with a declared return type halts',
        () {
      const src = '''
SubProceso SiempreCero(x Como Entero) Como Entero
    Si x > 10 Entonces
        Retornar 0
    FinSi
FinSubProceso

Proceso Principal
    Escribir SiempreCero(1)
FinProceso
''';
      final result = runProgram(src);
      expect(result.haltDiagnostic.code.name,
          equals('subroutineEndedWithoutReturn'));
    });
  });
}
