import '../knowledge/exercise.dart';
import '../route/route_kinds.dart';
import 'exercise_reference.dart';
import 'user_exercise.dart';

Exercise exerciseOfUser(UserExercise exercise) {
  final draft = exercise.draft;
  final narrative = draft.narrative.trim();
  return Exercise(
    id: exercise.id,
    title: draft.title,
    statement: narrative.isEmpty
        ? draft.statement
        : '$narrative\n\n${draft.statement}',
    level: RouteLevel.seed,
    kind: RouteExerciseKind.solve,
    visibleCases: draft.visibleCases,
    hiddenCases: draft.hiddenCases,
    assertions: draft.assertions,
    starterCode: exercise.starterCode,
    hints: draft.hints,
    origin: ExerciseOrigin.user,
    solution: draft.referenceSolution,
  );
}
