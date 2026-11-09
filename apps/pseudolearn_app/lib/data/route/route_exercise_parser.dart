import '../../domain/model/route/route_exercise.dart';
import '../reference/reference_json.dart';
import '../reference/reference_program_parser.dart';
import '../reference/reference_run_parser.dart';
import 'route_evaluation_parser.dart';
import 'route_lesson_parser.dart';
import 'route_toc_parser.dart';

RouteExercise parseRouteExercise(Object? json) {
  final source = objectOf(json);
  final program = source['program'];
  final starter = source['starter_code'];
  return RouteExercise(
    id: textOf(source, 'id'),
    lessonId: textOf(source, 'lesson'),
    kind: exerciseKindOf(textOf(source, 'kind')),
    level: levelOf(textOf(source, 'level')),
    required: flagOf(source, 'required'),
    title: parseRuns(source['title']),
    statement: parseLessonBlocks(source['statement']),
    restriction: parseLessonBlocks(source['restriction']),
    hints: parseRunGroups(source['hints']),
    variant: parseLessonBlocks(source['variant']),
    explanation: parseLessonBlocks(source['explanation']),
    program: program == null ? null : parseProgram(objectOf(program)),
    starterCode: starter is String ? starter : null,
    evaluation: parseRouteEvaluation(objectOf(source['evaluation'])),
  );
}
