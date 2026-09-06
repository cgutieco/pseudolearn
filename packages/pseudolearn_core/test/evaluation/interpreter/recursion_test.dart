import 'package:test/test.dart';

import 'interpreter_test_harness.dart';

void main() {
  group('Recursion', () {
    test('a base case terminates normally', () {
      const src = '''
SubProceso Factorial(n Como Entero) Como Entero
    Si n <= 1 Entonces
        Retornar 1
    SiNo
        Retornar n * Factorial(n - 1)
    FinSi
FinSubProceso

Proceso Principal
    Escribir Factorial(5)
FinProceso
''';
      expect(runProgram(src).output, equals('120\n'));
    });

    test(
        'a deep but bounded recursion (999) terminates normally, not as a diagnostic',
        () {
      const src = '''
SubProceso Contar(n Como Entero) Como Entero
    Si n <= 0 Entonces
        Retornar 0
    SiNo
        Retornar 1 + Contar(n - 1)
    FinSi
FinSubProceso

Proceso Principal
    Escribir Contar(999)
FinProceso
''';
      expect(runProgram(src).output, equals('999\n'));
    });

    test(
        'recursion without a base case halts with a diagnostic, not a host exception',
        () {
      const src = '''
SubProceso SinBase(n Como Entero) Como Entero
    Retornar n * SinBase(n - 1)
FinSubProceso

Proceso Principal
    Escribir SinBase(1)
FinProceso
''';
      final result = runProgram(src);
      expect(result.haltDiagnostic.code.name, equals('recursionDepthExceeded'));
    });

    test(
        'mutual recursion between two subroutines works without any special declaration',
        () {
      const src = '''
SubProceso EsPar(n Como Entero) Como Logico
    Si n = 0 Entonces
        Retornar Verdadero
    SiNo
        Retornar EsImpar(n - 1)
    FinSi
FinSubProceso

SubProceso EsImpar(n Como Entero) Como Logico
    Si n = 0 Entonces
        Retornar Falso
    SiNo
        Retornar EsPar(n - 1)
    FinSi
FinSubProceso

Proceso Principal
    Escribir EsPar(10)
FinProceso
''';
      expect(runProgram(src).output, equals('Verdadero\n'));
    });
  });
}
