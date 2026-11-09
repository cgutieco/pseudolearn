import 'package:flutter/material.dart';
import '../../domain/model/route/route_exercise.dart';
import '../../domain/model/route/route_verdict.dart';
import '../components/button/app_button.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../reference/blocks/reference_callout_view.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/spacing.dart';
import 'blocks/lesson_callouts.dart';
import 'lesson_block_view.dart';
import 'lesson_scope.dart';

final class ExerciseHints extends StatelessWidget {
  final RouteExercise exercise;
  final int shown;
  final bool canShowMore;
  final LessonScope scope;
  final VoidCallback onHint;

  const ExerciseHints({
    super.key,
    required this.exercise,
    required this.shown,
    required this.canShowMore,
    required this.scope,
    required this.onHint,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: SpacingTokens.space3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < shown; index++)
            AccentPanel(
              accent: theme.colors.severities.warning.fg,
              child: ReferenceCalloutBody(
                title: l10n.routeExerciseHintNumber(index + 1),
                color: theme.colors.severities.warning.fg,
                child: LessonRunsText(runs: exercise.hints[index], scope: scope),
              ),
            ),
          if (canShowMore)
            Align(
              alignment: Alignment.centerLeft,
              child: AppButton(label: l10n.routeExerciseHint, variant: AppButtonVariant.secondary, icon: Icons.lightbulb_outline_rounded, onPressed: onHint),
            ),
        ],
      ),
    );
  }
}

final class ExerciseReveal extends StatelessWidget {
  final RouteExercise exercise;
  final bool open;
  final LessonScope scope;
  final VoidCallback onReveal;

  const ExerciseReveal({
    super.key,
    required this.exercise,
    required this.open,
    required this.scope,
    required this.onReveal,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    if (!open) {
      return Align(
        alignment: Alignment.centerLeft,
        child: AppButton(label: l10n.routeExerciseReveal, variant: AppButtonVariant.tertiary, onPressed: onReveal),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (exercise.explanation.isNotEmpty)
          RevealSection(title: l10n.routeExerciseExplanation, color: theme.colors.text.link, child: LessonBlockColumn(blocks: exercise.explanation, scope: scope)),
        if (exercise.variant.isNotEmpty)
          RevealSection(title: l10n.routeExerciseVariant, color: theme.colors.severities.success.fg, child: LessonBlockColumn(blocks: exercise.variant, scope: scope)),
      ],
    );
  }
}

final class RevealSection extends StatelessWidget {
  final String title;
  final Color color;
  final Widget child;

  const RevealSection({
    super.key,
    required this.title,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: SpacingTokens.space3),
      child: AccentPanel(
        accent: color,
        child: ReferenceCalloutBody(title: title, color: color, child: child),
      ),
    );
  }
}

final class ExerciseFeedback extends StatelessWidget {
  final RouteVerdict? verdict;

  const ExerciseFeedback({super.key, required this.verdict});

  @override
  Widget build(BuildContext context) {
    final verdict = this.verdict;
    if (verdict == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    final text = verdict.solved ? l10n.routeExerciseSolved : feedbackText(verdict.feedback, l10n);
    return Padding(
      padding: const EdgeInsets.only(top: SpacingTokens.space2),
      child: AppText(
        text,
        variant: AppTextVariant.bodyDefault,
        color: verdict.solved ? theme.colors.severities.success.fg : theme.colors.severities.error.fg,
      ),
    );
  }
}

String feedbackText(RouteFeedback feedback, AppLocalizations l10n) =>
    switch (feedback) {
      LineMismatchFeedback(:final line) => l10n.routeFeedbackLine(line + 1),
      WrongCellsFeedback(:final cells) => l10n.routeFeedbackCells(cells.length),
      CaseFailureFeedback() => l10n.routeFeedbackCase,
      UnbrokenFeedback(:final referenceOutput) => l10n.routeFeedbackUnbroken(referenceOutput.join(' / ')),
      ReferenceRejectsFeedback(:final caseIndex, :final referenceOutput) =>
        l10n.routeFeedbackReferenceRejects(caseIndex + 1, referenceOutput.join(' / ')),
      SurvivorsFeedback(:final survivors) => l10n.routeFeedbackSurvivors(survivors),
      WrongCountFeedback(:final minimum, :final maximum) => l10n.routeFeedbackWrongCount(minimum, maximum),
      MisplacedFeedback(:final elements) => l10n.routeFeedbackMisplaced(elements.length),
      NoFeedback() => l10n.routeFeedbackNotYet,
    };
