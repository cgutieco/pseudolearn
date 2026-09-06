import 'package:pseudolearn_app/domain/model/knowledge/exercise_case.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_check_outcome.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_check_result.dart';
import 'package:pseudolearn_app/domain/model/knowledge/structural_assertion.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/domain/ports/exercise_checker.dart';

final class FakeExerciseChecker implements ExerciseChecker {
  ExerciseCheckResult? nextResult;

  FakeExerciseChecker([this.nextResult]);

  @override
  ExerciseCheckResult check({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
    required List<ExerciseCase> visibleCases,
    required List<ExerciseCase> hiddenCases,
    required List<StructuralAssertion> assertions,
  }) {
    if (nextResult != null) return nextResult!;

    return ExerciseCheckResult(
      outcome: ExerciseCheckOutcome.allCasesPassed,
      passedCases: visibleCases.length + hiddenCases.length,
      totalCases: visibleCases.length + hiddenCases.length,
    );
  }
}
