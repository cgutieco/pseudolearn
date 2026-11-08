import '../knowledge/exercise.dart';
import '../reference/reference_block.dart';
import '../reference/reference_run.dart';
import 'lesson_block.dart';
import 'route_evaluation.dart';
import 'route_exercise.dart';

Exercise editorExerciseOf(RouteExercise exercise) {
  final evaluation = exercise.evaluation;
  final cases = evaluation is CasesEvaluation ? evaluation : null;
  return Exercise(
    id: exercise.id,
    title: plainTextOf(exercise.title),
    statement: plainTextOfBlocks(exercise.statement),
    level: exercise.level,
    kind: exercise.kind,
    lessonId: exercise.lessonId,
    visibleCases: cases?.visibleCases ?? const [],
    hiddenCases: cases?.hiddenCases ?? const [],
    assertions: cases?.assertions ?? const [],
    starterCode: exercise.starterCode,
    hints: [for (final hint in exercise.hints) plainTextOf(hint)],
  );
}

String plainTextOfBlocks(List<LessonBlock> blocks) =>
    blocks.map(_plainTextOfBlock).where((text) => text.isNotEmpty).join('\n\n');

String _plainTextOfBlock(LessonBlock block) => switch (block) {
  SharedLessonBlock(:final block) => _plainTextOfShared(block),
  ProblemLessonBlock(:final blocks) => plainTextOfBlocks(blocks),
  CalloutLessonBlock(:final blocks) => plainTextOfBlocks(blocks),
  PhraseLessonBlock(:final runs) => plainTextOf(runs),
  _ => '',
};

String _plainTextOfShared(ReferenceBlock block) => switch (block) {
  ReferenceParagraph(:final runs) => plainTextOf(runs),
  ReferenceList(:final entries) => entries.map(plainTextOf).join('\n'),
  _ => '',
};
