import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';
import 'integration_test_harness.dart';

void main() {
  group('Integration: OOP Recursive Data Structures', () {
    test('builds and traverses recursive linked list of instances', () {
      const source = '''
Clase Nodo
  Definir valor Como Entero
  Definir tieneSiguiente Como Logico
  Definir siguiente Como Nodo

  Metodo Constructor(v Como Entero)
    Este.valor <- v
    Este.tieneSiguiente <- Falso
  FinMetodo

  Metodo Enlazar(sig Como Nodo)
    Este.siguiente <- sig
    Este.tieneSiguiente <- Verdadero
  FinMetodo

  Metodo Contar() Como Entero
    Si Este.tieneSiguiente = Falso Entonces
      Retornar 1
    SiNo
      Retornar 1 + Este.siguiente.Contar()
    FinSi
  FinMetodo

  Metodo Sumar() Como Entero
    Si Este.tieneSiguiente = Falso Entonces
      Retornar Este.valor
    SiNo
      Retornar Este.valor + Este.siguiente.Sumar()
    FinSi
  FinMetodo
FinClase

Algoritmo PruebaListaRecursiva
  Definir n1, n2, n3, n4 Como Nodo
  n1 <- Nuevo Nodo(10)
  n2 <- Nuevo Nodo(20)
  n3 <- Nuevo Nodo(30)
  n4 <- Nuevo Nodo(40)

  n1.Enlazar(n2)
  n2.Enlazar(n3)
  n3.Enlazar(n4)

  Escribir "Cantidad: ", n1.Contar()
  Escribir "Suma total: ", n1.Sumar()
FinAlgoritmo
''';

      final observer = RecordingExecutionObserver();
      final result = runPipeline(source, observer: observer);

      expect(result.hasErrors, isFalse);
      expect(result.finalOutcome, isA<StepFinished>());
      expect(result.output, equals('Cantidad: 4\nSuma total: 100\n'));

      final methodStarts =
          observer.events.whereType<SubroutineEnteredEvent>().toList();
      final methodEnds =
          observer.events.whereType<SubroutineExitedEvent>().toList();

      expect(methodStarts.length, equals(methodEnds.length));
      expect(methodStarts.any((e) => e.subroutineName == 'Nodo.Contar'), isTrue);
      expect(methodStarts.any((e) => e.subroutineName == 'Nodo.Sumar'), isTrue);
      expect(methodStarts.any((e) => e.subroutineName == 'Nodo.Enlazar'), isTrue);
    });

    test('recursively builds and searches a binary search tree structure', () {
      const source = '''
Clase ArbolBinario
  Definir valor Como Entero
  Definir tieneIzq Como Logico
  Definir izq Como ArbolBinario
  Definir tieneDer Como Logico
  Definir der Como ArbolBinario

  Metodo Constructor(v Como Entero)
    Este.valor <- v
    Este.tieneIzq <- Falso
    Este.tieneDer <- Falso
  FinMetodo

  Metodo Insertar(v Como Entero)
    Si v < Este.valor Entonces
      Si Este.tieneIzq = Falso Entonces
        Este.izq <- Nuevo ArbolBinario(v)
        Este.tieneIzq <- Verdadero
      SiNo
        Este.izq.Insertar(v)
      FinSi
    SiNo
      Si Este.tieneDer = Falso Entonces
        Este.der <- Nuevo ArbolBinario(v)
        Este.tieneDer <- Verdadero
      SiNo
        Este.der.Insertar(v)
      FinSi
    FinSi
  FinMetodo

  Metodo Contiene(v Como Entero) Como Logico
    Si v = Este.valor Entonces
      Retornar Verdadero
    SiNo
      Si v < Este.valor Entonces
        Si Este.tieneIzq = Falso Entonces
          Retornar Falso
        SiNo
          Retornar Este.izq.Contiene(v)
        FinSi
      SiNo
        Si Este.tieneDer = Falso Entonces
          Retornar Falso
        SiNo
          Retornar Este.der.Contiene(v)
        FinSi
      FinSi
    FinSi
  FinMetodo
FinClase

Algoritmo PruebaBST
  Definir raiz Como ArbolBinario
  raiz <- Nuevo ArbolBinario(50)
  raiz.Insertar(30)
  raiz.Insertar(70)
  raiz.Insertar(20)
  raiz.Insertar(40)

  Escribir "Contiene 40: ", raiz.Contiene(40)
  Escribir "Contiene 99: ", raiz.Contiene(99)
FinAlgoritmo
''';

      final result = runPipeline(source);
      expect(result.hasErrors, isFalse);
      expect(result.finalOutcome, isA<StepFinished>());
      expect(result.output, equals('Contiene 40: Verdadero\nContiene 99: Falso\n'));
    });
  });
}
