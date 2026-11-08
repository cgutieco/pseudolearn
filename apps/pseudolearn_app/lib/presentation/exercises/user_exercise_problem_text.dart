import '../../application/exercises/user_exercise_editor_state.dart';
import '../../domain/model/exercises/exercise_publication.dart';
import '../l10n/generated/app_localizations.dart';

String? userExerciseFeedback(AppLocalizations l10n, UserExerciseEditorState state) {
  return switch (state.status) {
    UserExerciseEditorStatus.missing => l10n.userExerciseMissing,
    UserExerciseEditorStatus.storageError => l10n.userExerciseStorageError,
    UserExerciseEditorStatus.formatError =>
      state.malformedField == UserExerciseFormField.assertions
          ? l10n.userExerciseMalformedAssertions
          : l10n.userExerciseMalformedCases,
    UserExerciseEditorStatus.saving => l10n.userExerciseSaving,
    _ => _publicationText(l10n, state.publication),
  };
}

String? _publicationText(AppLocalizations l10n, ExercisePublication? publication) {
  final problem = publication?.problem;
  if (publication == null || problem == null) return null;
  final number = (publication.failingCaseIndex ?? 0) + 1;
  return switch (problem) {
    ExercisePublicationProblem.emptyTitle => l10n.userExerciseProblemEmptyTitle,
    ExercisePublicationProblem.emptyStatement => l10n.userExerciseProblemEmptyStatement,
    ExercisePublicationProblem.noVisibleCase => l10n.userExerciseProblemNoVisibleCase,
    ExercisePublicationProblem.emptyReferenceSolution => l10n.userExerciseProblemEmptySolution,
    ExercisePublicationProblem.referenceDoesNotParse =>
      l10n.userExerciseProblemSolutionDoesNotParse,
    ExercisePublicationProblem.referenceFailsCase => publication.failingCaseIsHidden
        ? l10n.userExerciseProblemSolutionFailsHiddenCase(number)
        : l10n.userExerciseProblemSolutionFailsCase(number),
    ExercisePublicationProblem.referenceMissesAssertion =>
      l10n.userExerciseProblemSolutionMissesAssertion(
        publication.unmetAssertions.isEmpty
            ? ''
            : publication.unmetAssertions.first.requirement,
      ),
  };
}
