import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_defect.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_case.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_defects.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_kind.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_level.dart';
import 'package:pseudolearn_app/domain/model/knowledge/expected_value_kind.dart';

const _case = ExerciseCase(
  inputs: ['4'],
  expectedOutputs: ['16'],
  expectedValueKind: ExpectedValueKind.numeric,
);

Exercise _exercise({
  String id = 'CON-B1-E1',
  String title = 'Cuadrado',
  String statement = 'Escribe el cuadrado del valor leido.',
  List<ExerciseCase> visibleCases = const [_case],
  List<ExerciseCase> hiddenCases = const [_case],
}) {
  return Exercise(
    id: id,
    title: title,
    statement: statement,
    level: ExerciseLevel.reproduce,
    kind: ExerciseKind.create,
    visibleCases: visibleCases,
    hiddenCases: hiddenCases,
  );
}

void main() {
  group('findExerciseDefects', () {
    test('a complete exercise has no defects', () {
      expect(findExerciseDefects(_exercise()), isEmpty);
    });

    test('an exercise without any case is reported and stops further checks', () {
      final defects = findExerciseDefects(
        _exercise(visibleCases: const [], hiddenCases: const []),
      );

      expect(defects, [ContentDefect.exerciseWithoutCases]);
    });

    test('a case without expected outputs is reported', () {
      final defects = findExerciseDefects(
        _exercise(
          hiddenCases: const [
            ExerciseCase(
              inputs: ['4'],
              expectedOutputs: [],
              expectedValueKind: ExpectedValueKind.numeric,
            ),
          ],
        ),
      );

      expect(defects, [ContentDefect.caseWithoutExpectedOutputs]);
    });

    test('a case without inputs is not a defect: not every program reads', () {
      final defects = findExerciseDefects(
        _exercise(
          visibleCases: const [
            ExerciseCase(
              inputs: [],
              expectedOutputs: ['16'],
              expectedValueKind: ExpectedValueKind.numeric,
            ),
          ],
        ),
      );

      expect(defects, isEmpty);
    });

    test('an empty statement is reported', () {
      expect(
        findExerciseDefects(_exercise(statement: '   ')),
        contains(ContentDefect.emptyStatement),
      );
    });

    test('an empty identifier and an empty title are reported together', () {
      final defects = findExerciseDefects(_exercise(id: '', title: ' '));

      expect(defects, containsAll([
        ContentDefect.emptyIdentifier,
        ContentDefect.emptyTitle,
      ]));
    });

    test('a one character identifier and a one character title are valid', () {
      expect(findExerciseDefects(_exercise(id: 'a', title: 'b')), isEmpty);
    });
  });
}
