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
  group('a program with a construct no emitter proves is withheld whole', () {
    test('a known valid unit does not rescue a mixed program', () {
      const source =
          'Proceso P\n  Definir Mutable x Como Entero <- 0;\n  Escribir "antes";\n'
          '  Leer x;\n  Escribir "despues";\nFinProceso\n';

      final blockers = _blockersOf(source, TargetLanguageId.python);

      expect(_blocker(blockers, 'input').range.startLine, 4);
      expect(_textOf(source, _blocker(blockers, 'input')), contains('Leer'));
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
    test('division, power, real values and text concatenation', () {
      for (final (source, construct) in [
        ('Proceso P\n  Escribir 7 / 2;\nFinProceso\n', 'operator:divide'),
        ('Proceso P\n  Escribir 2 ^ 3;\nFinProceso\n', 'operator:power'),
        ('Proceso P\n  Escribir 1.5;\nFinProceso\n', 'literal:real'),
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

    test('functions that return a value', () {
      const source =
          'Funcion Doble(x Como Entero) Como Entero\n  Retornar x * 2;\n'
          'FinFuncion\nProceso P\n  Escribir Doble(2);\nFinProceso\n';

      final blockers = _blockersOf(source, TargetLanguageId.rust);

      expect(_textOf(source, _blocker(blockers, 'value_return')), contains('x * 2'));
    });
  });

  group('English documents are classified like Spanish ones', () {
    test('withholds the same constructs and exports the same subset', () {
      const withheld =
          'algorithm Main\n  define mutable x as integer <- 0;\n  read x;\n'
          'endAlgorithm\n';
      const proven =
          'algorithm Main\n  define mutable a as integer <- 1;\n  write a, a;\n'
          'endAlgorithm\n';

      expect(
        _blockersOf(
          withheld,
          TargetLanguageId.python,
          profile: SyntaxProfileId.english,
        ).map((blocker) => blocker.construct),
        contains('input'),
      );
      final exported = nativeTestEngine.programExporter.export(
        sourceCode: proven,
        targetLanguage: TargetLanguageId.python,
        profileId: SyntaxProfileId.english,
      );
      expect(exported, isA<ExportSuccess>());
      expect((exported as ExportSuccess).program.sourceCode, contains('print(a, a, sep="")'));
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
