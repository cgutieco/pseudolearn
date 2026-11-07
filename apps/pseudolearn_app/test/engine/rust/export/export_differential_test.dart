import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/export/target_language_id.dart';

import 'export_differential_support.dart';

String _procedure(String body, [String declarations = '']) =>
    '${declarations}Proceso P\n$body\nFinProceso\n';

const String _doubleFunction =
    'Funcion Doble(x Como Entero) Como Entero\n  Retornar x * 2;\nFinFuncion\n';

const String _counter =
    'Clase Contador\n  Privado Definir n Como Entero;\n'
    '  Metodo Constructor(e Como Entero)\n    Este.n <- e;\n  FinMetodo\n'
    '  Metodo Sumar(d Como Entero)\n    Este.n <- Este.n + d;\n  FinMetodo\n'
    '  Publico Metodo Valor() Como Entero\n    Retornar Este.n;\n  FinMetodo\n'
    'FinClase\n';

const String _inheritance =
    'Clase Base\n  Publico Definir n Como Entero;\n'
    '  Metodo Constructor(e Como Entero)\n    Este.n <- e;\n  FinMetodo\n'
    'FinClase\n'
    'Clase Hija Hereda De Base\n'
    '  Metodo Constructor(e Como Entero)\n    Super.Constructor(e);\n  FinMetodo\n'
    '  Publico Metodo Doble() Como Entero\n    Retornar Este.n * 2;\n  FinMetodo\n'
    'FinClase\n';

final Map<String, ({String source, Set<TargetLanguageId> targets})> _cases = {
  'integer arithmetic': (
    source: _procedure('Escribir 7 + 3 * 2 - 4 % 3;'),
    targets: TargetLanguageId.values.toSet(),
  ),
  'negation': (
    source: _procedure('Escribir -5 + 2;'),
    targets: TargetLanguageId.values.toSet(),
  ),
  'output without line break': (
    source: _procedure('Escribir "a" Sin Saltar;\nEscribir "b";'),
    targets: TargetLanguageId.values.toSet(),
  ),
  'output of several arguments': (
    source: _procedure('Escribir "a", 1, "b", 2;'),
    targets: TargetLanguageId.values.toSet(),
  ),
  'selection': (
    source: _procedure(
      'Definir x Como Entero <- 5;\nSi x > 3 Entonces\n'
      'Escribir "g";\nSino\nEscribir "p";\nFinSi',
    ),
    targets: TargetLanguageId.values.toSet(),
  ),
  'while loop': (
    source: _procedure(
      'Definir i Como Entero <- 0;\nMientras i < 3 Hacer\n'
      'Escribir i;\ni <- i + 1;\nFinMientras',
    ),
    targets: TargetLanguageId.values.toSet(),
  ),
  'repeat loop': (
    source: _procedure(
      'Definir i Como Entero <- 0;\nRepetir\ni <- i + 1;\n'
      'Hasta Que i >= 3;\nEscribir i;',
    ),
    targets: TargetLanguageId.values.toSet(),
  ),
  'counted loops': (
    source: _procedure(
      'Para i <- 1 Hasta 3 Con Paso 1 Hacer\nEscribir i;\nFinPara\n'
      'Para j <- 3 Hasta 1 Con Paso -1 Hacer\nEscribir j;\nFinPara',
    ),
    targets: TargetLanguageId.values.toSet(),
  ),
  'nested loops': (
    source: _procedure(
      'Para i <- 1 Hasta 2 Con Paso 1 Hacer\nPara j <- 1 Hasta 2 Con Paso 1 Hacer\n'
      'Escribir i * j;\nFinPara\nFinPara',
    ),
    targets: TargetLanguageId.values.toSet(),
  ),
  'procedure call': (
    source: _procedure(
      'Hola();',
      'SubProceso Hola()\nEscribir "hola";\nFinSubProceso\n',
    ),
    targets: TargetLanguageId.values.toSet(),
  ),
  'text builtins': (
    source: _procedure(
      'Escribir Longitud("hola"), ConvertirATexto(5), Trunc(2.7);',
    ),
    targets: {TargetLanguageId.python},
  ),
  'selection by cases': (
    source: _procedure(
      'Segun 2 Hacer\n1:\nEscribir "uno";\n2:\nEscribir "dos";\n'
      'De Otro Modo:\nEscribir "otro";\nFinSegun',
    ),
    targets: {TargetLanguageId.rust},
  ),
  'division and power': (
    source: _procedure('Escribir 7 / 2, 2 ^ 3;'),
    targets: {TargetLanguageId.python},
  ),
  'real arithmetic': (
    source: _procedure(
      'Definir r Como Real <- 1.5;\nr <- r * 2 + 1;\nEscribir r;',
    ),
    targets: TargetLanguageId.values.toSet(),
  ),
  'text concatenation': (
    source: _procedure('Escribir "a" + "b";'),
    targets: {TargetLanguageId.python},
  ),
  'square root': (
    source: _procedure('Escribir Raiz(9);'),
    targets: {TargetLanguageId.python},
  ),
  'function with return value': (
    source: _procedure('Escribir Doble(4);', _doubleFunction),
    targets: TargetLanguageId.values.toSet(),
  ),
  'recursion': (
    source: _procedure(
      'Escribir Fact(5);',
      'Funcion Fact(n Como Entero) Como Entero\nSi n <= 1 Entonces\n'
          'Retornar 1;\nFinSi\nRetornar n * Fact(n - 1);\nFinFuncion\n',
    ),
    targets: TargetLanguageId.values.toSet(),
  ),
  'integer and real mixed in one expression': (
    source: _procedure(
      'Definir a Como Real;\nDefinir n Como Entero <- 3;\n'
          'a <- Mitad(n) + Doble(2) * 1.5 - 7 / 2;\nEscribir a;\n'
          'Escribir n / 3, " ", -n * 0.5;\na <- n;\nEscribir a;',
      '${_doubleFunction}Funcion Mitad(x Como Entero) Como Real\n'
          '  Retornar x / 2;\nFinFuncion\n',
    ),
    targets: TargetLanguageId.values.toSet(),
  ),
  'class with methods': (
    source: _procedure(
      'Definir c Como Contador <- Nuevo Contador(2);\nc.Sumar(3);\n'
      'Escribir c.Valor();',
      _counter,
    ),
    targets: {TargetLanguageId.python},
  ),
  'inheritance and super call': (
    source: _procedure(
      'Definir h Como Hija <- Nuevo Hija(4);\nEscribir h.Doble();',
      _inheritance,
    ),
    targets: {TargetLanguageId.python},
  ),
};

const String _triangle =
    'SubProceso calcularArea(base Como Entero, altura Como Entero) Como Real\n'
    '  Retornar (base * altura) / 2;\nFinSubProceso\n'
    'Algoritmo Triangulo\n  Definir base, altura Como Entero;\n'
    '  Definir area Como Real;\n  Leer base;\n  Leer altura;\n'
    '  area <- calcularArea(base, altura);\n  Escribir area;\nFinAlgoritmo\n';

final Map<
  String,
  ({String source, List<String> inputs, Set<TargetLanguageId> targets})
>
_readingCases = {
  'integer reading that re-asks an invalid value': (
    source: _procedure(
      'Definir a, b Como Entero;\nLeer a, b;\nEscribir a + b;',
    ),
    inputs: ['oops', '2', '5'],
    targets: TargetLanguageId.values.toSet(),
  ),
  'typed reading of every readable type': (
    source: _procedure(
      'Definir n Como Entero;\nDefinir r Como Real;\nDefinir s Como Cadena;\n'
      'Leer n, r;\nLeer s;\n'
      'Escribir n * 2;\nEscribir r + 1;\nEscribir s;',
    ),
    inputs: ['4', 'x', '2.5', 'hola mundo'],
    targets: {TargetLanguageId.python},
  ),
  'reading inside a subroutine': (
    source: _procedure(
      'Pedir();',
      'SubProceso Pedir()\nDefinir x Como Entero;\nLeer x;\n'
          'Escribir x * 3;\nFinSubProceso\n',
    ),
    inputs: ['7'],
    targets: TargetLanguageId.values.toSet(),
  ),
  'real reading and comparison': (
    source: _procedure(
      'Definir r Como Real;\nLeer r;\nEscribir r * 2;\n'
      'Si r >= 2 Entonces\nEscribir "grande";\nSino\nEscribir "chico";\nFinSi',
    ),
    inputs: ['abc', '2.25'],
    targets: TargetLanguageId.values.toSet(),
  ),
  'division by a read divisor': (
    source: _procedure(
      'Definir a, b Como Entero;\nDefinir q Como Real;\nLeer a, b;\n'
      'q <- a / b;\nEscribir q;\nEscribir a * b / 4 + 1;',
    ),
    inputs: ['7', '2'],
    targets: TargetLanguageId.values.toSet(),
  ),
  'triangle area from read values': (
    source: _triangle,
    inputs: ['3', '5'],
    targets: TargetLanguageId.values.toSet(),
  ),
};

void main() {
  setUpAll(() {
    for (final tool in ['python3', 'rustc']) {
      final probe = Process.runSync(tool, ['--version']);
      expect(
        probe.exitCode,
        0,
        reason: '$tool is required by the equivalence evidence',
      );
    }
  });

  for (final entry in _cases.entries) {
    for (final target in entry.value.targets) {
      test('${entry.key} behaves the same as the engine in ${target.id}', () {
        final source = entry.value.source;
        final code = exportedCode(source, target);

        expect(code, isNotNull, reason: 'the claimed subset must export');
        expect(runTarget(code!, target), engineOutput(source));
      });
    }
  }

  for (final entry in _readingCases.entries) {
    for (final target in entry.value.targets) {
      test('${entry.key} behaves the same as the engine in ${target.id}', () {
        final (:source, :inputs, targets: _) = entry.value;
        final code = exportedCode(source, target);

        expect(code, isNotNull, reason: 'the claimed subset must export');
        expect(runTarget(code!, target, inputs), engineOutput(source, inputs));
      });
    }
  }

  test('the evidence covers every claimed construct family', () {
    final claimed = _cases.values.expand((entry) => entry.targets).toSet();

    expect(claimed, TargetLanguageId.values.toSet());
  });
}
