import '../../../domain/model/exercises/exercise_publication.dart';
import '../../../domain/model/exercises/user_exercise_draft.dart';
import '../../../domain/model/knowledge/exercise_check_outcome.dart';
import '../../../domain/model/knowledge/exercise_check_result.dart';
import '../../../domain/model/settings/ui_language_id.dart';
import '../../../domain/ports/exercise_checker.dart';
import '../../../domain/ports/program_analyzer.dart';

final class ValidateUserExercise {
  final ProgramAnalyzer _analyzer;
  final ExerciseChecker _checker;

  const ValidateUserExercise({
    required ProgramAnalyzer analyzer,
    required ExerciseChecker checker,
  }) : _analyzer = analyzer,
       _checker = checker;

  ExercisePublication call(UserExerciseDraft draft, {UiLanguageId languageId = UiLanguageId.spanish}) {
    final shape = _shapeProblem(draft);
    if (shape != null) return ExercisePublication.rejected(shape);
    final report = _analyzer.analyze(
      sourceCode: draft.referenceSolution,
      profileId: draft.profileId,
      languageId: languageId,
    );
    if (report.hasErrors || !report.isExecutable) {
      return const ExercisePublication.rejected(
        ExercisePublicationProblem.referenceDoesNotParse,
      );
    }
    try {
      return _publicationOf(_check(draft, languageId));
    } catch (_) {
      return const ExercisePublication.rejected(
        ExercisePublicationProblem.referenceFailsCase,
        outcome: ExerciseCheckOutcome.programHalted,
      );
    }
  }

  ExercisePublicationProblem? _shapeProblem(UserExerciseDraft draft) {
    if (draft.title.trim().isEmpty) return ExercisePublicationProblem.emptyTitle;
    if (draft.statement.trim().isEmpty) {
      return ExercisePublicationProblem.emptyStatement;
    }
    if (draft.visibleCases.isEmpty) return ExercisePublicationProblem.noVisibleCase;
    if (draft.referenceSolution.trim().isEmpty) {
      return ExercisePublicationProblem.emptyReferenceSolution;
    }
    return null;
  }

  ExerciseCheckResult _check(UserExerciseDraft draft, UiLanguageId languageId) =>
      _checker.check(
        sourceCode: draft.referenceSolution,
        profileId: draft.profileId,
        languageId: languageId,
        visibleCases: draft.visibleCases,
        hiddenCases: draft.hiddenCases,
        assertions: draft.assertions,
      );

  ExercisePublication _publicationOf(ExerciseCheckResult result) {
    if (result.isSolved) return const ExercisePublication.accepted();
    if (result.outcome == ExerciseCheckOutcome.allCasesPassed) {
      return ExercisePublication.rejected(
        ExercisePublicationProblem.referenceMissesAssertion,
        unmetAssertions: result.unmetAssertions,
      );
    }
    final failure = result.firstFailure;
    return ExercisePublication.rejected(
      ExercisePublicationProblem.referenceFailsCase,
      failingCaseIndex: failure?.caseIndex,
      failingCaseIsHidden: failure?.isHidden ?? false,
      outcome: result.outcome,
    );
  }
}
