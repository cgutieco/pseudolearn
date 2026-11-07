import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/export/export_blocker.dart';
import 'package:pseudolearn_app/domain/model/export/export_result.dart';
import 'package:pseudolearn_app/domain/model/export/target_language_id.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';

import '../../../fakes/native_test_engine.dart';

List<ExportBlocker> _blockersOf(
  String source,
  TargetLanguageId target, {
  SyntaxProfileId profile = SyntaxProfileId.classicSpanish,
}) {
  final result = nativeTestEngine.programExporter.export(
    sourceCode: source,
    targetLanguage: target,
    profileId: profile,
  );
  expect(result, isA<ExportUnavailable>(), reason: source);
  return (result as ExportUnavailable).blockers;
}

String _textOf(String source, ExportBlocker blocker) =>
    source.substring(blocker.range.startOffset, blocker.range.endOffset);

ExportBlocker _blocker(List<ExportBlocker> blockers, String construct) =>
    blockers.firstWhere((blocker) => blocker.construct == construct);

void main() {
  test('collection calls and extended numeric builtins declare blockers', () {
    const collection =
        'algorithm P\ndefine values as vector<integer> <- vector();\nvalues.sort();\nendAlgorithm\n';
    const numeric = 'algorithm P\nwrite tan(0);\nendAlgorithm\n';
    for (final target in TargetLanguageId.values) {
      expect(
        _blockersOf(
          collection,
          target,
          profile: SyntaxProfileId.english,
        ).map((blocker) => blocker.construct),
        contains('collection:vectorSort'),
      );
      expect(
        _blockersOf(
          numeric,
          target,
          profile: SyntaxProfileId.english,
        ).map((blocker) => blocker.construct),
        contains('builtin:tangent'),
      );
    }
  });

  test('random builtins are not exportable to Rust', () {
    const source =
        'Proceso P\n  Escribir Azar(3);\n  Escribir Aleatorio(1, 2);\n'
        '  Escribir AzarReal();\nFinProceso\n';
    final blockers = _blockersOf(source, TargetLanguageId.rust);
    expect(
      blockers.map((blocker) => blocker.construct),
      containsAll([
        'builtin:random',
        'builtin:randomBetween',
        'builtin:randomUnit',
      ]),
    );
    expect(_textOf(source, _blocker(blockers, 'builtin:random')), 'Azar(3)');
    expect(_blocker(blockers, 'builtin:randomBetween').range.startLine, 3);
    expect(_blocker(blockers, 'builtin:randomUnit').range.startLine, 4);
  });

  test('a program without random builtins is not blocked by them', () {
    final result = nativeTestEngine.programExporter.export(
      sourceCode: 'Proceso P\n  Escribir Longitud("ab");\nFinProceso\n',
      targetLanguage: TargetLanguageId.rust,
      profileId: SyntaxProfileId.classicSpanish,
    );
    expect(result, isA<ExportSuccess>());
  });

  group('a program with a construct no emitter proves is withheld whole', () {
    test('a known valid unit does not rescue a mixed program', () {
      const source =
          'Proceso P\n  Definir x Como Logico <- Falso;\n  Escribir "antes";\n'
          '  Leer x;\n  Escribir "despues";\nFinProceso\n';

      final blockers = _blockersOf(source, TargetLanguageId.python);
      final reading = _blocker(blockers, 'input:boolean');

      expect(reading.range.startLine, 4);
      expect(_textOf(source, reading), contains('Leer'));
    });

    test('a new construct is named by its public syntax kind and range', () {
      const source =
          'Interfaz Legible\n  Metodo obtener() Como Entero;\nFinInterfaz\n'
          'Proceso P\n  Escribir 1;\nFinProceso\n';

      for (final target in TargetLanguageId.values) {
        final blockers = _blockersOf(source, target);
        expect(blockers, isNotEmpty);
        expect(blockers.first.range.startLine, 1);
        expect(blockers.every((blocker) => blocker.origin.value >= 0), isTrue);
      }
    });

    test('records, enumerations and loops over collections are withheld', () {
      const record =
          'Registro Par\n  Definir a Como Entero;\nFinRegistro\n'
          'Proceso P\nFinProceso\n';
      const enumeration =
          'Enumerado Nivel\n  bajo, alto\nFinEnumerado\nProceso P\nFinProceso\n';

      for (final source in [record, enumeration]) {
        for (final target in TargetLanguageId.values) {
          expect(_blockersOf(source, target), isNotEmpty, reason: source);
        }
      }
    });

    test('exits and deferred cleanups are withheld in both targets', () {
      const source =
          'Proceso P\n  Para i <- 1 Hasta 3 Con Paso 1 Hacer\n    Diferir\n'
          '      Escribir i;\n    FinDiferir\n    Si i = 2 Entonces\n'
          '      Salir;\n    FinSi\n  FinPara\nFinProceso\n';

      for (final target in TargetLanguageId.values) {
        final constructs = _blockersOf(
          source,
          target,
        ).map((blocker) => blocker.construct);
        expect(constructs, containsAll(['defer_statement', 'break_statement']));
      }
    });

    test('suspendable functions are withheld', () {
      const source =
          'SubProceso Suspendible Produce()\n  Escribir 1;\nFinSubProceso\n'
          'Proceso P\nFinProceso\n';

      for (final target in TargetLanguageId.values) {
        expect(_blockersOf(source, target), isNotEmpty);
      }
    });
  });

  group('Python needs a proven equivalent for what it prints and branches', () {
    test('boolean output is withheld because the spelling differs', () {
      const comparison = 'Proceso P\n  Escribir 3 > 2;\nFinProceso\n';
      const variable =
          'Proceso P\n  Definir a Como Logico <- Verdadero;\n  Escribir a;\n'
          'FinProceso\n';

      for (final source in [comparison, variable]) {
        for (final target in TargetLanguageId.values) {
          expect(
            _blockersOf(source, target).map((blocker) => blocker.construct),
            contains('boolean_output'),
            reason: source,
          );
        }
      }
    });

    test('a program without boolean values still exports its output', () {
      const source =
          'Proceso P\n  Definir a Como Logico <- Verdadero;\n'
          '  Si a Entonces\n    Escribir "ok";\n  FinSi\nFinProceso\n';

      expect(
        nativeTestEngine.programExporter.export(
          sourceCode: source,
          targetLanguage: TargetLanguageId.python,
          profileId: SyntaxProfileId.classicSpanish,
        ),
        isA<ExportSuccess>(),
      );
    });

    test('selection by cases is withheld because match needs Python 3.10', () {
      const source =
          'Proceso P\n  Segun 1 Hacer\n    1:\n      Escribir "uno";\n'
          '  FinSegun\nFinProceso\n';

      expect(
        _blockersOf(
          source,
          TargetLanguageId.python,
        ).map((blocker) => blocker.construct),
        contains('switch'),
      );
    });
  });

  group('Rust withholds numeric and class behaviour it cannot yet prove', () {
    test('power and text concatenation', () {
      for (final (source, construct) in [
        ('Proceso P\n  Escribir 2 ^ 3;\nFinProceso\n', 'operator:power'),
        (
          'Proceso P\n  Escribir "a" + "b";\nFinProceso\n',
          'text_concatenation',
        ),
      ]) {
        expect(
          _blockersOf(
            source,
            TargetLanguageId.rust,
          ).map((blocker) => blocker.construct),
          contains(construct),
          reason: source,
        );
      }
    });

    test('an operation whose operand type is unknown', () {
      const source = 'Proceso P\n  Escribir Trunc(2.7) + 1;\nFinProceso\n';

      final blockers = _blockersOf(source, TargetLanguageId.rust);

      expect(
        _textOf(source, _blocker(blockers, 'untyped_operation')),
        contains('Trunc(2.7) + 1'),
      );
    });
  });

  group('Rust converts what the engine converts implicitly', () {
    String rustOf(String source) {
      final result = nativeTestEngine.programExporter.export(
        sourceCode: source,
        targetLanguage: TargetLanguageId.rust,
        profileId: SyntaxProfileId.classicSpanish,
      );
      expect(result, isA<ExportSuccess>(), reason: source);
      return (result as ExportSuccess).program.sourceCode;
    }

    test('a function returns its declared type', () {
      final code = rustOf(
        'Funcion Mitad(x Como Entero) Como Real\n  Retornar x / 2;\n'
        'FinFuncion\nProceso P\n  Escribir Mitad(3);\nFinProceso\n',
      );

      expect(code, contains('fn Mitad(x: i64) -> f64 {'));
      expect(code, contains('return x as f64 / 2.0;'));
      expect(code, contains('println!("{}", real_text(Mitad(3)));'));
    });

    test('a division by a variable stops on zero like the engine', () {
      final code = rustOf(
        'Proceso P\n  Definir a Como Entero <- 1;\n  Definir b Como Entero <- 1;\n'
        '  Escribir a / b;\nFinProceso\n',
      );

      expect(code, contains('divide(a as f64, b as f64)'));
      expect(code, contains('panic!("division by zero")'));
    });
  });

  group('English documents are classified like Spanish ones', () {
    test('withholds the same constructs and exports the same subset', () {
      const withheld =
          'algorithm Main\n  define x as boolean <- false;\n  read x;\n'
          'endAlgorithm\n';
      const proven =
          'algorithm Main\n  define a as integer <- 1;\n  write a, a;\n'
          'endAlgorithm\n';

      expect(
        _blockersOf(
          withheld,
          TargetLanguageId.python,
          profile: SyntaxProfileId.english,
        ).map((blocker) => blocker.construct),
        contains('input:boolean'),
      );
      final exported = nativeTestEngine.programExporter.export(
        sourceCode: proven,
        targetLanguage: TargetLanguageId.python,
        profileId: SyntaxProfileId.english,
      );
      expect(exported, isA<ExportSuccess>());
      expect(
        (exported as ExportSuccess).program.sourceCode,
        contains('print(a, a, sep="")'),
      );
    });
  });

  group('constructions added by the language have no equivalent yet', () {
    const genericClass =
        'Clase Caja<T>\nDefinir dato Como T;\nMetodo Constructor(d Como T)\n'
        'Este.dato <- d;\nFinMetodo\nFinClase\nAlgoritmo P\n'
        'Definir c Como Caja<Entero> <- Nuevo Caja<Entero>(1);\n'
        'Escribir c.dato;\nFinAlgoritmo\n';
    const variant =
        'Variante Forma\nAlternativa Circulo(radio Como Entero)\n'
        'Alternativa Punto\nFinVariante\nAlgoritmo P\n'
        'Definir f Como Forma <- Forma.Punto;\nSegun f Hacer\n'
        'Forma.Circulo(r): Escribir r;\nForma.Punto: Escribir 0;\n'
        'FinSegun\nFinAlgoritmo\n';
    const recordArray =
        'Registro Punto\nDefinir x Como Entero;\nFinRegistro\nAlgoritmo P\n'
        'Dimension a[2] Como Punto;\na[0] <- Punto(1);\nEscribir a[0].x;\n'
        'FinAlgoritmo\n';

    for (final (name, source, construct) in [
      ('a generic class', genericClass, 'type_parameters'),
      ('a declared variant', variant, 'variant_unit'),
      ('an array of records', recordArray, 'record_unit'),
    ]) {
      test('$name is withheld for every target and named', () {
        for (final target in TargetLanguageId.values) {
          expect(
            _blockersOf(source, target).map((blocker) => blocker.construct),
            contains(construct),
            reason: '$name / $target',
          );
        }
      });
    }
  });

  group('Leer exports only when every target has a typed reading', () {
    String exported(String source, TargetLanguageId target) {
      final result = nativeTestEngine.programExporter.export(
        sourceCode: source,
        targetLanguage: target,
        profileId: SyntaxProfileId.classicSpanish,
      );
      expect(result, isA<ExportSuccess>(), reason: '$target\n$source');
      return (result as ExportSuccess).program.sourceCode;
    }

    test('an integer is read with a re-asking helper in every target', () {
      const source =
          'Proceso P\n  Definir x Como Entero;\n  Leer x;\n'
          '  Escribir x;\nFinProceso\n';

      for (final target in TargetLanguageId.values) {
        final code = exported(source, target);
        expect(code, contains('x = read_integer()'), reason: '$target');
        expect(code, isNot(contains('read input into')), reason: '$target');
      }
    });

    test('Python converts a real and keeps a text as typed', () {
      const source =
          'Proceso P\n  Definir r Como Real;\n  Definir s Como Cadena;\n'
          '  Leer r, s;\n  Escribir s;\nFinProceso\n';

      final code = exported(source, TargetLanguageId.python);

      expect(code, contains('r = read_real()'));
      expect(code, contains('s = input()'));
      expect(code, isNot(contains('def read_integer')));
    });

    test('a target without a proven reading names its type', () {
      const text =
          'Proceso P\n  Definir s Como Cadena;\n  Leer s;\nFinProceso\n';
      const character =
          'Proceso P\n  Definir c Como Caracter;\n  Leer c;\nFinProceso\n';

      expect(
        _blockersOf(text, TargetLanguageId.rust).map((b) => b.construct),
        contains('input:string'),
      );
      for (final target in TargetLanguageId.values) {
        expect(
          _blockersOf(character, target).map((b) => b.construct),
          contains('input:character'),
          reason: '$target',
        );
      }
    });
  });

  test('analysis errors stay analysis errors, never unavailable', () {
    for (final target in TargetLanguageId.values) {
      expect(
        nativeTestEngine.programExporter.export(
          sourceCode: 'Proceso P\n  Escribir ;\n',
          targetLanguage: target,
          profileId: SyntaxProfileId.classicSpanish,
        ),
        isA<ExportAnalysisError>(),
      );
    }
  });
}
