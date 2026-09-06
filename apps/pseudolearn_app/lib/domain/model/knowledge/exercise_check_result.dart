import 'exercise_case_failure.dart';
import 'exercise_check_outcome.dart';
import 'list_equality.dart';
import 'structural_assertion.dart';

final class ExerciseCheckResult {
  final ExerciseCheckOutcome outcome;
  final int passedCases;
  final int totalCases;
  final ExerciseCaseFailure? firstFailure;
  final List<StructuralAssertion> unmetAssertions;

  const ExerciseCheckResult({
    required this.outcome,
    required this.passedCases,
    required this.totalCases,
    this.firstFailure,
    this.unmetAssertions = const [],
  });

  bool get isSolved =>
      outcome == ExerciseCheckOutcome.allCasesPassed && unmetAssertions.isEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseCheckResult &&
          runtimeType == other.runtimeType &&
          outcome == other.outcome &&
          passedCases == other.passedCases &&
          totalCases == other.totalCases &&
          firstFailure == other.firstFailure &&
          listEquals(unmetAssertions, other.unmetAssertions);

  @override
  int get hashCode => Object.hash(
        outcome,
        passedCases,
        totalCases,
        firstFailure,
        Object.hashAll(unmetAssertions),
      );
}
