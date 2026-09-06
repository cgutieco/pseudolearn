import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

import 'interpreter_test_harness.dart';

void main() {
  group('OOP Este Tests', () {
    test('Este.OtroMetodo() calls another method on the current receiver', () {
      const source = '''
Clase Calculo
  Definir valor Como Entero

  Metodo Constructor(v Como Entero)
    Este.valor <- v
  FinMetodo

  Metodo Duplicar() Como Entero
    Retornar Este.valor * 2
  FinMetodo

  Metodo Cuadruplicar() Como Entero
    Retornar Este.Duplicar() * 2
  FinMetodo
FinClase

Algoritmo Test
  Definir c Como Calculo
  c <- Nuevo Calculo(5)
  Escribir "Cuadruple: ", c.Cuadruplicar()
FinAlgoritmo
''';
      final result = runProgram(source);
      expect(result.output, equals('Cuadruple: 20\n'));
      expect(result.finalOutcome, isA<StepFinished>());
    });

    test('passing Este to another method associates receiver reference', () {
      const source = '''
Clase Contenedor
  Definir itemValor Como Entero

  Metodo Guardar(i Como Item)
    Este.itemValor <- i.ObtenerValor()
  FinMetodo
FinClase

Clase Item
  Definir miValor Como Entero

  Metodo Constructor(v Como Entero)
    Este.miValor <- v
  FinMetodo

  Metodo ObtenerValor() Como Entero
    Retornar Este.miValor
  FinMetodo

  Metodo TransferirA(c Como Contenedor)
    c.Guardar(Este)
  FinMetodo
FinClase

Algoritmo Test
  Definir it Como Item
  Definir cont Como Contenedor
  it <- Nuevo Item(42)
  cont <- Nuevo Contenedor()
  it.TransferirA(cont)
  Escribir "Contenedor tiene: ", cont.itemValor
FinAlgoritmo
''';
      final result = runProgram(source);
      expect(result.output, equals('Contenedor tiene: 42\n'));
      expect(result.finalOutcome, isA<StepFinished>());
    });
  });
}
