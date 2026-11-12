import 'package:material_ui/material_ui.dart';
import '../../../domain/model/knowledge/exercise_case_failure.dart';
import '../../../domain/model/knowledge/exercise_check_outcome.dart';
import '../../../domain/model/knowledge/exercise_check_result.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/color_semantic_severity.dart';
import '../../theme/tokens/radii.dart';
import '../../theme/tokens/spacing.dart';

final class CheckResultFeedback extends StatelessWidget {
  final ExerciseCheckResult result;
  final ExerciseCaseFailure? revealedHiddenFailure;
  final AppLocalizations l10n;
  final AppThemeExtension theme;

  const CheckResultFeedback({
    super.key,
    required this.result,
    required this.revealedHiddenFailure,
    required this.l10n,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final sev = _resolveSeverity(result, theme);
    final icon = result.isSolved ? Icons.check_circle_rounded : Icons.info_outline_rounded;
    final hidden = revealedHiddenFailure != null
        ? RevealedHiddenCaseView(failure: revealedHiddenFailure!, l10n: l10n, theme: theme)
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SpacingTokens.space3),
      decoration: BoxDecoration(color: sev.surface, borderRadius: BorderRadius.circular(RadiusTokens.radiusSm), border: Border.all(color: sev.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 16, color: sev.fg),
            const SizedBox(width: SpacingTokens.space2),
            Expanded(child: AppText(summaryText(result, l10n), variant: AppTextVariant.bodyDefault, color: sev.fg)),
          ]),
          if (hidden != null) ...[const SizedBox(height: SpacingTokens.space2), hidden],
        ],
      ),
    );
  }
}

SeverityItemColors _resolveSeverity(ExerciseCheckResult result, AppThemeExtension theme) {
  if (result.isSolved) return theme.colors.severities.success;
  if (result.outcome == ExerciseCheckOutcome.allCasesPassed) return theme.colors.severities.warning;
  return theme.colors.severities.error;
}

final class RevealedHiddenCaseView extends StatelessWidget {
  final ExerciseCaseFailure failure;
  final AppLocalizations l10n;
  final AppThemeExtension theme;

  const RevealedHiddenCaseView({
    super.key,
    required this.failure,
    required this.l10n,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final inStr = failure.inputs.isEmpty ? '—' : failure.inputs.join(', ');
    final expStr = failure.expectedOutputs.isEmpty ? '—' : failure.expectedOutputs.join(', ');
    final actStr = failure.actualOutputs.isEmpty ? '—' : failure.actualOutputs.join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          l10n.exerciseHiddenFailureTitle,
          variant: AppTextVariant.label,
          color: theme.colors.severities.error.fg,
        ),
        const SizedBox(height: SpacingTokens.spaceHalf),
        AppText(l10n.exerciseHiddenInputs(inStr), variant: AppTextVariant.codeCaption),
        AppText(l10n.exerciseHiddenExpected(expStr), variant: AppTextVariant.codeCaption),
        AppText(l10n.exerciseHiddenActual(actStr), variant: AppTextVariant.codeCaption),
      ],
    );
  }
}

String summaryText(ExerciseCheckResult result, AppLocalizations l10n) {
  return switch (result.outcome) {
    ExerciseCheckOutcome.allCasesPassed => l10n.exercisePassedCount(result.passedCases, result.totalCases),
    ExerciseCheckOutcome.caseFailed => l10n.exercisePassedCount(result.passedCases, result.totalCases),
    ExerciseCheckOutcome.programDidNotParse => l10n.exerciseOutcomeParseError,
    ExerciseCheckOutcome.programHalted => l10n.exerciseOutcomeHalted,
    ExerciseCheckOutcome.stepLimitReached => l10n.exerciseOutcomeStepLimit,
    ExerciseCheckOutcome.inputScriptExhausted => l10n.exerciseOutcomeInputExhausted,
  };
}
