import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

import 'interpreter_test_harness.dart';

void main() {
  group('OOP Dynamic Dispatch Tests', () {
    test('dynamic dispatch invokes overridden method of concrete subclass', () {
      const source = '''
Clase Animal
  Metodo Hablar() Como Cadena
    Retornar "Sonido generico"
  FinMetodo
FinClase

Clase Perro HeredaDe Animal
  Metodo Hablar() Como Cadena
    Retornar "Guau"
  FinMetodo
FinClase

Clase Gato HeredaDe Animal
  Metodo Hablar() Como Cadena
    Retornar "Miau"
  FinMetodo
FinClase

Algoritmo Test
  Definir a1, a2 Como Animal
  a1 <- Nuevo Perro()
  a2 <- Nuevo Gato()
  Escribir a1.Hablar(), " y ", a2.Hablar()
FinAlgoritmo
''';
      final result = runProgram(source);
      expect(result.output, equals('Guau y Miau\n'));
      expect(result.finalOutcome, isA<StepFinished>());
    });

    test('dynamic dispatch with 3 levels where middle level does not override', () {
      const source = '''
Clase Base
  Metodo Describir() Como Cadena
    Retornar "Base"
  FinMetodo
FinClase

Clase Intermedia HeredaDe Base
FinClase

Clase Hoja HeredaDe Intermedia
  Metodo Describir() Como Cadena
    Retornar "Hoja"
  FinMetodo
FinClase

Algoritmo Test
  Definir b1, b2 Como Base
  b1 <- Nuevo Intermedia()
  b2 <- Nuevo Hoja()
  Escribir b1.Describir(), " -> ", b2.Describir()
FinAlgoritmo
''';
      final result = runProgram(source);
      expect(result.output, equals('Base -> Hoja\n'));
      expect(result.finalOutcome, isA<StepFinished>());
    });

    test('polymorphic dispatch when passing subclass instance to subprogram', () {
      const source = '''
Clase Figura
  Metodo CalcularArea() Como Entero
    Retornar 0
  FinMetodo
FinClase

Clase Cuadrado HeredaDe Figura
  Definir lado Como Entero

  Metodo Constructor(l Como Entero)
    Este.lado <- l
  FinMetodo

  Metodo CalcularArea() Como Entero
    Retornar Este.lado * Este.lado
  FinMetodo
FinClase

SubProceso ImprimirArea(f Como Figura)
  Escribir "Area: ", f.CalcularArea()
FinSubProceso

Algoritmo Test
  Definir c Como Cuadrado
  c <- Nuevo Cuadrado(6)
  ImprimirArea(c)
FinAlgoritmo
''';
      final result = runProgram(source);
      expect(result.output, equals('Area: 36\n'));
      expect(result.finalOutcome, isA<StepFinished>());
    });
  });
}
