import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/knowledge/exercise_document_parser.dart';
import 'package:pseudolearn_app/domain/model/knowledge/ast_construct.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_load_failure.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_load_result.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_kind.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_level.dart';
import 'package:pseudolearn_app/domain/model/knowledge/expected_value_kind.dart';
import 'package:pseudolearn_app/domain/model/knowledge/structural_assertion.dart';

const String _exercise = '''
{
  "id": "CON-B1-E1",
  "title": "Cuadrado",
  "statement": "Lee un entero y escribe su cuadrado.",
  "level": 1,
  "kind": "crear",
  "module": "CON-B1",
  "visibleCases": [
    {"inputs": ["4"], "expectedOutputs": ["16"], "expected": "numerico"}
  ],
  "hiddenCases": [
    {"inputs": ["7"], "expectedOutputs": ["49"], "expected": "numerico"}
  ],
  "assertions": [
    {
      "kind": "contiene",
      "requirement": "El enunciado pedia un bucle contado.",
      "construct": "bucle-contado"
    }
  ],
  "referenceSolution": "Algoritmo C\\nFinAlgoritmo"
}
''';

Exercise _parse(String source) {
  final result = const ExerciseDocumentParser().parse(source);
  return (result as ContentLoaded<Exercise>).value;
}

ContentLoadFailure _failureOf(String source) {
  final result = const ExerciseDocumentParser().parse(source);
  return (result as ContentLoadFailed<Exercise>).failure;
}

void main() {
  group('ExerciseDocumentParser', () {
    test('reads statement, level, kind, cases and assertions', () {
      final exercise = _parse(_exercise);

      expect(exercise.id, 'CON-B1-E1');
      expect(exercise.level, ExerciseLevel.reproduce);
      expect(exercise.kind, ExerciseKind.create);
      expect(exercise.moduleId, 'CON-B1');
      expect(exercise.visibleCases.single.inputs, ['4']);
      expect(exercise.hiddenCases.single.expectedOutputs, ['49']);
      expect(exercise.visibleCases.single.expectedValueKind, ExpectedValueKind.numeric);
      expect(exercise.assertions.single, isA<ContainsConstructAssertion>());
      expect(
        (exercise.assertions.single as ContainsConstructAssertion).construct,
        AstConstruct.countedLoop,
      );
    });

    test('the reference solution is not part of the published exercise', () {
      final exercise = _parse(_exercise);

      expect(exercise.statement, isNot(contains('Algoritmo C')));
    });

    test('an exercise with no hidden cases is valid', () {
      final source = _exercise.replaceAll(
        '"hiddenCases": [\n    {"inputs": ["7"], "expectedOutputs": ["49"], "expected": "numerico"}\n  ]',
        '"hiddenCases": []',
      );

      expect(_parse(source).hiddenCases, isEmpty);
    });

    test('an exercise with no assertions is valid', () {
      final source = _exercise.replaceAll('"assertions"', '"unusedAssertions"');

      expect(_parse(source).assertions, isEmpty);
    });

    test('a level out of range is a named failure', () {
      expect(
        _failureOf(_exercise.replaceAll('"level": 1', '"level": 9')),
        ContentLoadFailure.exerciseMalformed,
      );
    });

    test('an unknown kind is a named failure', () {
      expect(
        _failureOf(_exercise.replaceAll('"kind": "crear"', '"kind": "reordenar"')),
        ContentLoadFailure.exerciseMalformed,
      );
    });

    test('an unknown expected value kind is a named failure', () {
      expect(
        _failureOf(_exercise.replaceAll('"expected": "numerico"', '"expected": "entero"')),
        ContentLoadFailure.exerciseMalformed,
      );
    });

    test('an assertion without its requirement is a named failure', () {
      expect(
        _failureOf(_exercise.replaceAll(
          '"requirement": "El enunciado pedia un bucle contado.",',
          '"requirement": "   ",',
        )),
        ContentLoadFailure.exerciseMalformed,
      );
    });

    test('an assertion naming a construct the language does not have is a named failure', () {
      expect(
        _failureOf(_exercise.replaceAll('"bucle-contado"', '"corrutina"')),
        ContentLoadFailure.exerciseMalformed,
      );
    });

    test('a document that is not valid json is a named failure, never an exception', () {
      expect(_failureOf('{ not json'), ContentLoadFailure.exerciseMalformed);
    });

    test('a case with no inputs and no outputs is read as declared', () {
      final source = _exercise.replaceAll(
        '{"inputs": ["4"], "expectedOutputs": ["16"], "expected": "numerico"}',
        '{"inputs": [], "expectedOutputs": [], "expected": "texto"}',
      );
      final exercise = _parse(source);

      expect(exercise.visibleCases.single.inputs, isEmpty);
      expect(exercise.visibleCases.single.expectedOutputs, isEmpty);
    });

    test('reads starterCode when present', () {
      final source = _exercise.replaceAll(
        '"referenceSolution":',
        '"starterCode": "Proceso P\\nFinProceso",\n  "referenceSolution":',
      );
      final exercise = _parse(source);

      expect(exercise.starterCode, 'Proceso P\nFinProceso');
    });

    test('starterCode is null when absent', () {
      final exercise = _parse(_exercise);

      expect(exercise.starterCode, isNull);
    });
  });
}
