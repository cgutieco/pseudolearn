import '../../domain/model/knowledge/exercise_case.dart';
import '../../domain/model/knowledge/exercise_check_result.dart';
import '../../domain/model/knowledge/structural_assertion.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/exercise_checker.dart';
import 'behaviour_checker.dart';
import 'structural_assertion_checker.dart';

final class ExerciseCheckRunner implements ExerciseChecker {
  final BehaviourChecker _behaviour;
  final StructuralAssertionChecker _structure;

  const ExerciseCheckRunner({
    required BehaviourChecker behaviour,
    required StructuralAssertionChecker structure,
  })  : _behaviour = behaviour,
        _structure = structure;

  @override
  ExerciseCheckResult check({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
    required List<ExerciseCase> visibleCases,
    required List<ExerciseCase> hiddenCases,
    required List<StructuralAssertion> assertions,
  }) {
    final behaviour = _behaviour.checkBehaviour(
      sourceCode: sourceCode,
      profileId: profileId,
      languageId: languageId,
      visibleCases: visibleCases,
      hiddenCases: hiddenCases,
    );
    return ExerciseCheckResult(
      outcome: behaviour.outcome,
      passedCases: behaviour.passedCases,
      totalCases: behaviour.totalCases,
      firstFailure: behaviour.firstFailure,
      unmetAssertions: _structure.unmetAssertions(
        sourceCode: sourceCode,
        profileId: profileId,
        assertions: assertions,
      ),
    );
  }
}
