import 'package:material_ui/material_ui.dart';
import '../../application/exercises/user_exercise_form.dart';
import '../../domain/model/exercises/user_exercise_draft.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';

final class UserExerciseControllers {
  final TextEditingController title = TextEditingController();
  final TextEditingController narrative = TextEditingController();
  final TextEditingController statement = TextEditingController();
  final TextEditingController restrictions = TextEditingController();
  final TextEditingController hints = TextEditingController();
  final TextEditingController visibleCases = TextEditingController();
  final TextEditingController hiddenCases = TextEditingController();
  final TextEditingController assertions = TextEditingController();
  final TextEditingController solution = TextEditingController();
  final TextEditingController starter = TextEditingController();
  SyntaxProfileId profileId = SyntaxProfileId.classicSpanish;

  List<TextEditingController> get _all => [
    title, narrative, statement, restrictions, hints,
    visibleCases, hiddenCases, assertions, solution, starter,
  ];

  void fill(UserExerciseDraft draft) {
    final form = UserExerciseForm.of(draft);
    title.text = form.title;
    narrative.text = form.narrative;
    statement.text = form.statement;
    restrictions.text = form.restrictions;
    hints.text = form.hints;
    visibleCases.text = form.visibleCases;
    hiddenCases.text = form.hiddenCases;
    assertions.text = form.assertions;
    solution.text = form.referenceSolution;
    starter.text = form.starterCode;
    profileId = draft.profileId;
  }

  UserExerciseForm read() => UserExerciseForm(
    title: title.text,
    narrative: narrative.text,
    statement: statement.text,
    restrictions: restrictions.text,
    hints: hints.text,
    visibleCases: visibleCases.text,
    hiddenCases: hiddenCases.text,
    assertions: assertions.text,
    referenceSolution: solution.text,
    starterCode: starter.text,
    profileId: profileId,
  );

  void dispose() {
    for (final controller in _all) {
      controller.dispose();
    }
  }
}
