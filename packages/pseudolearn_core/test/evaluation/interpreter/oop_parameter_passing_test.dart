import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

import 'interpreter_test_harness.dart';

void main() {
  group('OOP Parameter Passing Tests (By-Value Reference vs By-Reference Binding)', () {
    test('by-value reference passing allows field mutation but isolates parameter reassignment', () {
      const source = '''
Clase Registro
  Definir valor Como Entero

  Metodo Constructor(v Como Entero)
    Este.valor <- v
  FinMetodo
FinClase

SubProceso ModificarCampos(r Como Registro)
  r.valor <- 88
FinSubProceso

SubProceso ReasignarParametro(r Como Registro)
  r <- Nuevo Registro(999)
FinSubProceso

Algoritmo Test
  Definir reg Como Registro
  reg <- Nuevo Registro(10)

  ModificarCampos(reg)
  Escribir "Tras mutar campo: ", reg.valor

  ReasignarParametro(reg)
  Escribir "Tras reasignar parametro: ", reg.valor
FinAlgoritmo
''';
      final result = runProgram(source);
      expect(result.output, equals('Tras mutar campo: 88\nTras reasignar parametro: 88\n'));
      expect(result.finalOutcome, isA<StepFinished>());
    });

    test('explicit Por Referencia parameter passing allows parameter reassignment to affect caller variable', () {
      const source = '''
Clase Registro
  Definir valor Como Entero

  Metodo Constructor(v Como Entero)
    Este.valor <- v
  FinMetodo
FinClase

SubProceso ReasignarPorReferencia(r Como Registro Por Referencia)
  r <- Nuevo Registro(999)
FinSubProceso

Algoritmo Test
  Definir reg Como Registro
  reg <- Nuevo Registro(10)

  ReasignarPorReferencia(reg)
  Escribir "Tras reasignar por referencia: ", reg.valor
FinAlgoritmo
''';
      final result = runProgram(source);
      expect(result.output, equals('Tras reasignar por referencia: 999\n'));
      expect(result.finalOutcome, isA<StepFinished>());
    });
  });
}
