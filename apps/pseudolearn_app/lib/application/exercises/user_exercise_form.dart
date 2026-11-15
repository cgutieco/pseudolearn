import '../../domain/model/exercises/exercise_text_format.dart';
import '../../domain/model/exercises/user_exercise_draft.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import 'user_exercise_editor_state.dart';

final class UserExerciseForm {
  final String title;
  final String narrative;
  final String statement;
  final String restrictions;
  final String hints;
  final String visibleCases;
  final String hiddenCases;
  final String assertions;
  final String referenceSolution;
  final String starterCode;
  final SyntaxProfileId profileId;

  const UserExerciseForm({
    required this.title,
    required this.narrative,
    required this.statement,
    required this.restrictions,
    required this.hints,
    required this.visibleCases,
    required this.hiddenCases,
    required this.assertions,
    required this.referenceSolution,
    required this.starterCode,
    required this.profileId,
  });

  factory UserExerciseForm.of(UserExerciseDraft draft) => UserExerciseForm(
    title: draft.title,
    narrative: draft.narrative,
    statement: draft.statement,
    restrictions: draft.restrictions.join('\n'),
    hints: draft.hints.join('\n'),
    visibleCases: formatCases(draft.visibleCases),
    hiddenCases: formatCases(draft.hiddenCases),
    assertions: formatAssertions(draft.assertions),
    referenceSolution: draft.referenceSolution,
    starterCode: draft.starterCode,
    profileId: draft.profileId,
  );

  (UserExerciseDraft?, UserExerciseFormField?) toDraft() {
    final visible = parseCases(visibleCases);
    if (visible == null) return (null, UserExerciseFormField.visibleCases);
    final hidden = parseCases(hiddenCases);
    if (hidden == null) return (null, UserExerciseFormField.hiddenCases);
    final parsedAssertions = parseAssertions(assertions);
    if (parsedAssertions == null) return (null, UserExerciseFormField.assertions);
    return (
      UserExerciseDraft(
        title: title.trim(),
        narrative: narrative.trim(),
        statement: statement.trim(),
        restrictions: linesOf(restrictions),
        hints: linesOf(hints),
        visibleCases: visible,
        hiddenCases: hidden,
        assertions: parsedAssertions,
        referenceSolution: referenceSolution,
        starterCode: starterCode,
        profileId: profileId,
      ),
      null,
    );
  }
}
