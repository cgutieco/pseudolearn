import 'package:pseudolearn_app/domain/model/knowledge/exercise_case.dart';
import 'package:pseudolearn_app/domain/model/knowledge/expected_value_kind.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_index.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_run.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_section_kind.dart';
import 'package:pseudolearn_app/domain/model/route/lesson_block.dart';
import 'package:pseudolearn_app/domain/model/route/route_evaluation.dart';
import 'package:pseudolearn_app/domain/model/route/route_exercise.dart';
import 'package:pseudolearn_app/domain/model/route/route_kinds.dart';
import 'package:pseudolearn_app/domain/model/route/route_lesson.dart';
import 'package:pseudolearn_app/domain/model/route/route_toc.dart';

List<ReferenceRun> runsOf(String text) => [ReferenceTextRun(text)];

RouteExerciseEntry exerciseEntry(
  String id, {
  String lessonId = 'inicio.primero',
  RouteExerciseKind kind = RouteExerciseKind.solve,
  RouteLevel level = RouteLevel.seed,
  bool required = true,
}) => RouteExerciseEntry(
  id: id,
  lessonId: lessonId,
  kind: kind,
  level: level,
  required: required,
  title: runsOf(id),
);

RouteLessonEntry lessonEntry(
  String id, {
  List<String> needs = const [],
  List<RouteExerciseEntry> exercises = const [],
}) => RouteLessonEntry(
  id: id,
  number: id,
  kind: RouteLessonKind.lesson,
  title: runsOf('Lección $id'),
  briefProblem: 'Problema $id',
  minutes: 10,
  levels: const [RouteLevel.seed],
  needs: needs,
  exercises: exercises,
);

final RouteToc sampleToc = RouteToc([
  RoutePartEntry(
    id: 'parte-inicio',
    number: '0',
    title: 'Empezar de cero',
    motto: '',
    summary: '',
    lessons: [
      lessonEntry(
        'inicio.primero',
        exercises: [
          exerciseEntry('inicio.primero.a'),
          exerciseEntry('inicio.primero.b', kind: RouteExerciseKind.predict, level: RouteLevel.sprout),
          exerciseEntry('inicio.primero.c', required: false, kind: RouteExerciseKind.explain),
        ],
      ),
    ],
  ),
  RoutePartEntry(
    id: 'parte-imperativo',
    number: 'I',
    title: 'Imperativo',
    motto: 'Órdenes',
    summary: '',
    lessons: [
      lessonEntry(
        'imperativo.segundo',
        needs: const ['inicio.primero'],
        exercises: [
          exerciseEntry('imperativo.segundo.a', lessonId: 'imperativo.segundo', level: RouteLevel.tree),
        ],
      ),
    ],
  ),
]);

ReferenceIndex sampleIndex() => ReferenceIndex([
  ReferencePart(
    id: 'parte-control',
    number: '6',
    title: 'Control',
    summary: '',
    sections: [
      ReferenceIndexEntry(
        id: 'control.si',
        number: '6.1',
        kind: ReferenceSectionKind.construction,
        title: runsOf('La decisión Si'),
        phrase: const [],
      ),
    ],
  ),
]);

RouteLesson sampleLesson(String id) => RouteLesson(
  id: id,
  number: '0.1',
  partId: 'inicio',
  kind: RouteLessonKind.lesson,
  title: runsOf('Lección'),
  minutes: 10,
  needs: const [],
  introducedLabels: const ['problema'],
  previous: null,
  next: null,
  blocks: [PhraseLessonBlock(runsOf('Una frase'))],
);

ExerciseCase caseOf(List<String> inputs, String expected) => ExerciseCase(
  inputs: inputs,
  expectedOutputs: expected.split('\n'),
  expectedValueKind: ExpectedValueKind.numeric,
);

RouteExercise sampleExercise(
  String id,
  RouteEvaluation evaluation, {
  RouteExerciseKind kind = RouteExerciseKind.solve,
}) => RouteExercise(
  id: id,
  lessonId: 'inicio.primero',
  kind: kind,
  level: RouteLevel.seed,
  required: true,
  title: runsOf('Ejercicio $id'),
  statement: [PhraseLessonBlock(runsOf('Enunciado'))],
  restriction: const [],
  hints: [runsOf('Pista uno'), runsOf('Pista dos')],
  variant: const [],
  explanation: const [],
  program: null,
  starterCode: 'Algoritmo X\nFinAlgoritmo\n',
  evaluation: evaluation,
);
