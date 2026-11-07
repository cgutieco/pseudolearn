import '../reference/reference_program.dart';
import '../reference/reference_run.dart';
import 'lesson_block.dart';
import 'route_evaluation.dart';
import 'route_kinds.dart';

final class RouteExercise {
  final String id;
  final String lessonId;
  final RouteExerciseKind kind;
  final RouteLevel level;
  final bool required;
  final List<ReferenceRun> title;
  final List<LessonBlock> statement;
  final List<LessonBlock> restriction;
  final List<List<ReferenceRun>> hints;
  final List<LessonBlock> variant;
  final List<LessonBlock> explanation;
  final List<LessonBlock> teachers;
  final ReferenceProgram? program;
  final String? starterCode;
  final RouteEvaluation evaluation;

  const RouteExercise({
    required this.id,
    required this.lessonId,
    required this.kind,
    required this.level,
    required this.required,
    required this.title,
    required this.statement,
    required this.restriction,
    required this.hints,
    required this.variant,
    required this.explanation,
    required this.teachers,
    required this.program,
    required this.starterCode,
    required this.evaluation,
  });
}
