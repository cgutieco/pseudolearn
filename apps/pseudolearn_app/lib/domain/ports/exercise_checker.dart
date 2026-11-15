import '../model/knowledge/exercise_case.dart';
import '../model/knowledge/exercise_check_result.dart';
import '../model/knowledge/structural_assertion.dart';
import '../model/profiles/syntax_profile_id.dart';
import '../model/settings/ui_language_id.dart';

abstract interface class ExerciseChecker {
  ExerciseCheckResult check({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
    required List<ExerciseCase> visibleCases,
    required List<ExerciseCase> hiddenCases,
    required List<StructuralAssertion> assertions,
  });
}
