import '../knowledge/exercise_case.dart';
import '../knowledge/structural_assertion.dart';
import '../profiles/syntax_profile_id.dart';

final class UserExerciseDraft {
  final String title;
  final String narrative;
  final String statement;
  final List<String> restrictions;
  final List<String> hints;
  final List<ExerciseCase> visibleCases;
  final List<ExerciseCase> hiddenCases;
  final List<StructuralAssertion> assertions;
  final String referenceSolution;
  final String starterCode;
  final SyntaxProfileId profileId;

  const UserExerciseDraft({
    required this.title,
    required this.statement,
    required this.referenceSolution,
    required this.profileId,
    this.narrative = '',
    this.restrictions = const [],
    this.hints = const [],
    this.visibleCases = const [],
    this.hiddenCases = const [],
    this.assertions = const [],
    this.starterCode = '',
  });

  List<ExerciseCase> get allCases => [...visibleCases, ...hiddenCases];
}
