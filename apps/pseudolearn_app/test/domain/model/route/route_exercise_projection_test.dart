import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_block.dart';
import 'package:pseudolearn_app/domain/model/route/lesson_block.dart';
import 'package:pseudolearn_app/domain/model/route/route_evaluation.dart';
import 'package:pseudolearn_app/domain/model/route/route_exercise_projection.dart';
import 'package:pseudolearn_app/domain/model/route/route_kinds.dart';
import '../../../fakes/route_fixtures.dart';

void main() {
  test('a code exercise becomes an editor exercise with its cases', () {
    final exercise = editorExerciseOf(
      sampleExercise(
        'e',
        CasesEvaluation(
          visibleCases: [caseOf(const ['1'], '1')],
          hiddenCases: [caseOf(const ['2'], '2')],
          assertions: const [],
          reference: 'x',
        ),
      ),
    );

    expect(exercise.title, 'Ejercicio e');
    expect(exercise.statement, 'Enunciado');
    expect(exercise.kind, RouteExerciseKind.solve);
    expect(exercise.allCases.length, 2);
    expect(exercise.starterCode, contains('Algoritmo'));
  });

  test('an exercise without cases projects no cases', () {
    final exercise = editorExerciseOf(sampleExercise('e', const PredictEvaluation('1')));
    expect(exercise.allCases, isEmpty);
  });

  test('plain text joins paragraphs, lists and nested boxes', () {
    final text = plainTextOfBlocks([
      SharedLessonBlock(ReferenceParagraph(runsOf('uno'))),
      SharedLessonBlock(ReferenceList(ordered: false, entries: [runsOf('dos'), runsOf('tres')])),
      ProblemLessonBlock([SharedLessonBlock(ReferenceParagraph(runsOf('cuatro')))]),
      const CycleLessonBlock([1]),
    ]);
    expect(text, 'uno\n\ndos\ntres\n\ncuatro');
  });
}
