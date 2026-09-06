import 'content_defect.dart';
import 'exercise.dart';
import 'exercise_case.dart';

List<ContentDefect> findExerciseDefects(Exercise exercise) {
  final defects = <ContentDefect>[];
  if (exercise.id.trim().isEmpty) defects.add(ContentDefect.emptyIdentifier);
  if (exercise.title.trim().isEmpty) defects.add(ContentDefect.emptyTitle);
  if (exercise.statement.trim().isEmpty) {
    defects.add(ContentDefect.emptyStatement);
  }
  if (exercise.visibleCases.isEmpty && exercise.hiddenCases.isEmpty) {
    defects.add(ContentDefect.exerciseWithoutCases);
    return defects;
  }
  if (_hasCaseWithoutExpectedOutputs(exercise.allCases)) {
    defects.add(ContentDefect.caseWithoutExpectedOutputs);
  }
  return defects;
}

bool _hasCaseWithoutExpectedOutputs(List<ExerciseCase> cases) {
  for (final exerciseCase in cases) {
    if (exerciseCase.expectedOutputs.isEmpty) return true;
  }
  return false;
}
