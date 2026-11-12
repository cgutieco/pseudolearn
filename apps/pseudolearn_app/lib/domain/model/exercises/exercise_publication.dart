import '../knowledge/exercise_check_outcome.dart';
import '../knowledge/structural_assertion.dart';

enum ExercisePublicationProblem {
  emptyTitle,
  emptyStatement,
  noVisibleCase,
  emptyReferenceSolution,
  referenceDoesNotParse,
  referenceFailsCase,
  referenceMissesAssertion,
}

final class ExercisePublication {
  final ExercisePublicationProblem? problem;
  final int? failingCaseIndex;
  final bool failingCaseIsHidden;
  final ExerciseCheckOutcome? outcome;
  final List<StructuralAssertion> unmetAssertions;

  const ExercisePublication.accepted()
    : problem = null,
      failingCaseIndex = null,
      failingCaseIsHidden = false,
      outcome = null,
      unmetAssertions = const [];

  const ExercisePublication.rejected(
    ExercisePublicationProblem this.problem, {
    this.failingCaseIndex,
    this.failingCaseIsHidden = false,
    this.outcome,
    this.unmetAssertions = const [],
  });

  bool get isPublishable => problem == null;
}
