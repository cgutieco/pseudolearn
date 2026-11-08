import 'package:flutter/material.dart';
import '../components/field/app_text_field.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/tokens/spacing.dart';
import 'user_exercise_controllers.dart';

final class UserExerciseFormFields extends StatelessWidget {
  final UserExerciseControllers controllers;

  const UserExerciseFormFields({super.key, required this.controllers});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final code = resolveAppTextStyle(context, AppTextVariant.codeEditor);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Field(label: l10n.userExerciseFieldTitle, name: 'title', controller: controllers.title),
        _Field(label: l10n.userExerciseFieldNarrative, name: 'narrative', controller: controllers.narrative, lines: 3),
        _Field(label: l10n.userExerciseFieldStatement, name: 'statement', controller: controllers.statement, lines: 3),
        _Field(label: l10n.userExerciseFieldRestrictions, name: 'restrictions', controller: controllers.restrictions, lines: 2),
        _Field(label: l10n.userExerciseFieldHints, name: 'hints', controller: controllers.hints, lines: 3),
        _Field(label: l10n.userExerciseFieldVisibleCases, name: 'visibleCases', controller: controllers.visibleCases, lines: 3, helper: l10n.userExerciseCasesHelp, style: code),
        _Field(label: l10n.userExerciseFieldHiddenCases, name: 'hiddenCases', controller: controllers.hiddenCases, lines: 3, style: code),
        _Field(label: l10n.userExerciseFieldAssertions, name: 'assertions', controller: controllers.assertions, lines: 2, helper: l10n.userExerciseAssertionsHelp, style: code),
        _Field(label: l10n.userExerciseFieldSolution, name: 'solution', controller: controllers.solution, lines: 8, style: code),
        _Field(label: l10n.userExerciseFieldStarter, name: 'starter', controller: controllers.starter, lines: 3, style: code),
      ],
    );
  }
}

final class _Field extends StatelessWidget {
  final String label;
  final String name;
  final TextEditingController controller;
  final int lines;
  final String? helper;
  final TextStyle? style;

  const _Field({
    required this.label,
    required this.name,
    required this.controller,
    this.lines = 1,
    this.helper,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.space4),
      child: AppTextField(
        key: ValueKey('user-exercise-field:$name'),
        label: label,
        controller: controller,
        minLines: lines,
        helperText: helper,
        textStyle: style,
      ),
    );
  }
}
