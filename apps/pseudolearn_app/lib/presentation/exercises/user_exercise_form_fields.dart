import 'package:flutter/material.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/card_metrics.dart';
import '../theme/tokens/icon_metrics.dart';
import '../theme/tokens/spacing.dart';
import 'user_exercise_controllers.dart';
import 'user_exercise_field_spec.dart';
import 'user_exercise_form_section.dart';

List<UserExerciseFieldSpec> _problemFields(AppLocalizations l10n, UserExerciseControllers controllers) => [
  UserExerciseFieldSpec(name: 'title', label: l10n.userExerciseFieldTitle, controller: controllers.title, isRequired: true, placeholder: l10n.userExerciseTitlePlaceholder, helper: l10n.userExerciseTitleHelp),
  UserExerciseFieldSpec(name: 'statement', label: l10n.userExerciseFieldStatement, controller: controllers.statement, isRequired: true, placeholder: l10n.userExerciseStatementPlaceholder, helper: l10n.userExerciseStatementHelp, lines: 3),
  UserExerciseFieldSpec(name: 'narrative', label: l10n.userExerciseFieldNarrative, controller: controllers.narrative, isRequired: false, placeholder: l10n.userExerciseNarrativePlaceholder, helper: l10n.userExerciseNarrativeHelp, lines: 3),
  UserExerciseFieldSpec(name: 'restrictions', label: l10n.userExerciseFieldRestrictions, controller: controllers.restrictions, isRequired: false, placeholder: l10n.userExerciseRestrictionsPlaceholder, helper: l10n.userExerciseRestrictionsHelp, lines: 2),
  UserExerciseFieldSpec(name: 'hints', label: l10n.userExerciseFieldHints, controller: controllers.hints, isRequired: false, placeholder: l10n.userExerciseHintsPlaceholder, helper: l10n.userExerciseHintsHelp, lines: 2),
];

List<UserExerciseFieldSpec> _checkFields(AppLocalizations l10n, UserExerciseControllers controllers) => [
  UserExerciseFieldSpec(name: 'visibleCases', label: l10n.userExerciseFieldVisibleCases, controller: controllers.visibleCases, isRequired: true, placeholder: l10n.userExerciseVisibleCasesPlaceholder, helper: l10n.userExerciseCasesHelp, lines: 3, isCode: true),
  UserExerciseFieldSpec(name: 'hiddenCases', label: l10n.userExerciseFieldHiddenCases, controller: controllers.hiddenCases, isRequired: false, placeholder: l10n.userExerciseHiddenCasesPlaceholder, helper: l10n.userExerciseHiddenCasesHelp, lines: 3, isCode: true),
  UserExerciseFieldSpec(name: 'assertions', label: l10n.userExerciseFieldAssertions, controller: controllers.assertions, isRequired: false, placeholder: l10n.userExerciseAssertionsPlaceholder, helper: l10n.userExerciseAssertionsHelp, lines: 2, isCode: true),
];

List<UserExerciseFieldSpec> _solutionFields(AppLocalizations l10n, UserExerciseControllers controllers) => [
  UserExerciseFieldSpec(name: 'solution', label: l10n.userExerciseFieldSolution, controller: controllers.solution, isRequired: true, helper: l10n.userExerciseSolutionHelp, lines: 8, isCode: true),
  UserExerciseFieldSpec(name: 'starter', label: l10n.userExerciseFieldStarter, controller: controllers.starter, isRequired: false, helper: l10n.userExerciseStarterHelp, lines: 3, isCode: true),
];

final class UserExerciseFormFields extends StatelessWidget {
  final UserExerciseControllers controllers;

  const UserExerciseFormFields({super.key, required this.controllers});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Intro(),
        UserExerciseFormSection(step: 1, title: l10n.userExerciseSectionProblem, description: l10n.userExerciseSectionProblemHelp, fields: _problemFields(l10n, controllers)),
        UserExerciseFormSection(step: 2, title: l10n.userExerciseSectionChecks, description: l10n.userExerciseSectionChecksHelp, fields: _checkFields(l10n, controllers)),
        UserExerciseFormSection(step: 3, title: l10n.userExerciseSectionSolution, description: l10n.userExerciseSectionSolutionHelp, fields: _solutionFields(l10n, controllers)),
      ],
    );
  }
}

final class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppThemeExtension.of(context).colors;
    return Container(
      margin: const EdgeInsets.only(bottom: SpacingTokens.space4),
      padding: const EdgeInsets.all(SpacingTokens.space4),
      decoration: BoxDecoration(
        color: colors.surfaces.brandSubtle,
        borderRadius: BorderRadius.circular(CardMetricsTokens.radius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, size: IconMetricsTokens.iconSm, color: colors.text.link),
          const SizedBox(width: SpacingTokens.space3),
          Expanded(child: AppText(l10n.userExerciseEditorIntro, variant: AppTextVariant.bodySmall, color: colors.text.primary)),
        ],
      ),
    );
  }
}
