import 'package:flutter/material.dart';
import '../../../domain/model/knowledge/exercise.dart';
import '../../../domain/model/knowledge/exercise_case.dart';
import '../../../domain/model/knowledge/exercise_case_failure.dart';
import '../../../domain/model/knowledge/exercise_check_result.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/border_metrics.dart';
import '../../theme/tokens/radii.dart';
import '../../theme/tokens/spacing.dart';
import 'exercise_strip_feedback.dart';

final class ExerciseStripBodyContent extends StatelessWidget {
  final Exercise exercise;
  final bool isChecking;
  final ExerciseCheckResult? lastResult;
  final ExerciseCaseFailure? revealedHiddenFailure;
  final VoidCallback onCheck;

  const ExerciseStripBodyContent({
    super.key,
    required this.exercise,
    required this.isChecking,
    required this.lastResult,
    required this.revealedHiddenFailure,
    required this.onCheck,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: SpacingTokens.space4,
        right: SpacingTokens.space4,
        bottom: SpacingTokens.space3,
      ),
      child: _ExerciseContentList(
        exercise: exercise,
        isChecking: isChecking,
        lastResult: lastResult,
        revealedHiddenFailure: revealedHiddenFailure,
        onCheck: onCheck,
      ),
    );
  }
}


final class _ExerciseContentList extends StatelessWidget {
  final Exercise exercise;
  final bool isChecking;
  final ExerciseCheckResult? lastResult;
  final ExerciseCaseFailure? revealedHiddenFailure;
  final VoidCallback onCheck;

  const _ExerciseContentList({
    required this.exercise,
    required this.isChecking,
    required this.lastResult,
    required this.revealedHiddenFailure,
    required this.onCheck,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;
    final cases = exercise.visibleCases.isNotEmpty
        ? _VisibleCasesSection(visibleCases: exercise.visibleCases, l10n: l10n, theme: theme)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(exercise.statement, variant: AppTextVariant.bodyDefault, color: theme.colors.text.primary),
        if (cases != null) ...[const SizedBox(height: SpacingTokens.space3), cases],
        const SizedBox(height: SpacingTokens.space3),
        CheckActionBar(
          isChecking: isChecking,
          lastResult: lastResult,
          revealedHiddenFailure: revealedHiddenFailure,
          onCheck: onCheck,
        ),
      ],
    );
  }
}


final class _VisibleCasesSection extends StatelessWidget {
  final List<ExerciseCase> visibleCases;
  final AppLocalizations l10n;
  final AppThemeExtension theme;

  const _VisibleCasesSection({
    required this.visibleCases,
    required this.l10n,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          l10n.exerciseVisibleCasesTitle,
          variant: AppTextVariant.label,
          color: theme.colors.text.secondary,
        ),
        const SizedBox(height: SpacingTokens.space1),
        Wrap(
          spacing: SpacingTokens.space2,
          runSpacing: SpacingTokens.space1,
          children: [
            for (final c in visibleCases) _TestCaseBadge(testCase: c, l10n: l10n, theme: theme),
          ],
        ),
      ],
    );
  }
}

final class _TestCaseBadge extends StatelessWidget {
  final ExerciseCase testCase;
  final AppLocalizations l10n;
  final AppThemeExtension theme;

  const _TestCaseBadge({
    required this.testCase,
    required this.l10n,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final inStr = testCase.inputs.isEmpty ? '—' : testCase.inputs.join(', ');
    final outStr = testCase.expectedOutputs.isEmpty ? '—' : testCase.expectedOutputs.join(', ');
    final inText = AppText(l10n.exerciseCaseInputsLabel(inStr), variant: AppTextVariant.codeCaption, color: theme.colors.text.secondary);
    final outText = AppText(l10n.exerciseCaseOutputsLabel(outStr), variant: AppTextVariant.codeCaption, color: theme.colors.text.primary);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.space2, vertical: SpacingTokens.space1),
      decoration: BoxDecoration(
        color: theme.colors.surfaces.canvas,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusXs),
        border: Border.all(color: theme.colors.borders.subtle, width: BorderMetricsTokens.widthHairline),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [inText, outText]),
    );
  }
}
