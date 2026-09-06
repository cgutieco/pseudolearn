import 'package:flutter/material.dart';
import '../../../document/components/exercise_strip_badges.dart';
import '../../../../domain/model/knowledge/exercise.dart';
import '../../../../domain/model/knowledge/exercise_case.dart';
import '../../../../domain/model/knowledge/exercise_kind.dart';
import '../../../../domain/model/knowledge/exercise_level.dart';
import '../../../../domain/model/knowledge/knowledge_detail_content.dart';
import '../../../components/button/app_button.dart';
import '../../../components/typography/app_text.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/tokens/border_metrics.dart';
import '../../../theme/tokens/radii.dart';
import '../../../theme/tokens/spacing.dart';

final class ExerciseDetailView extends StatelessWidget {
  final ExerciseDetailContent content;
  final ValueChanged<Exercise> onOpenInNewDocument;

  const ExerciseDetailView({
    super.key,
    required this.content,
    required this.onOpenInNewDocument,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    final exercise = content.exercise;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ExerciseBadgesRow(exercise: exercise, isCompleted: content.isCompleted),
          const SizedBox(height: SpacingTokens.space3),
          AppText(exercise.statement,
              variant: AppTextVariant.bodyDefault,
              color: theme.colors.text.primary),
          if (exercise.visibleCases.isNotEmpty)
            _VisibleCasesSection(
                visibleCases: exercise.visibleCases, l10n: l10n, theme: theme),
          _OpenInNewDocumentButton(
              exercise: exercise,
              label: l10n.knowledgeDetailOpenInNewDocument,
              onPressed: onOpenInNewDocument),
        ],
      ),
    );
  }
}

final class _OpenInNewDocumentButton extends StatelessWidget {
  final Exercise exercise;
  final String label;
  final ValueChanged<Exercise> onPressed;

  const _OpenInNewDocumentButton({
    required this.exercise,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: SpacingTokens.space5),
      child: Align(
        alignment: Alignment.centerLeft,
        child: AppButton(
          label: label,
          variant: AppButtonVariant.primary,
          onPressed: () => onPressed(exercise),
        ),
      ),
    );
  }
}

final class _ExerciseBadgesRow extends StatelessWidget {
  final Exercise exercise;
  final bool isCompleted;

  const _ExerciseBadgesRow({required this.exercise, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    return Wrap(
      spacing: SpacingTokens.space2,
      runSpacing: SpacingTokens.space1,
      children: [
        _Badge(label: _levelLabel(exercise.level, l10n), theme: theme, emphasized: true),
        _Badge(label: _kindLabel(exercise.kind, l10n), theme: theme, emphasized: false),
        if (isCompleted) const StripCompletedBadge(),
      ],
    );
  }
}

final class _Badge extends StatelessWidget {
  final String label;
  final AppThemeExtension theme;
  final bool emphasized;

  const _Badge(
      {required this.label, required this.theme, required this.emphasized});

  @override
  Widget build(BuildContext context) {
    final color = emphasized
        ? theme.colors.actions.primary.bgDefault
        : theme.colors.text.secondary;
    final background = emphasized
        ? theme.colors.surfaces.brandSubtle
        : theme.colors.surfaces.subtle;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.space2,
        vertical: SpacingTokens.spaceHalf,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusXs),
        border: Border.all(color: theme.colors.borders.subtle),
      ),
      child: AppText(label, variant: AppTextVariant.caption, color: color),
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
    return Padding(
      padding: const EdgeInsets.only(top: SpacingTokens.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(l10n.exerciseVisibleCasesTitle,
              variant: AppTextVariant.label,
              color: theme.colors.text.secondary),
          const SizedBox(height: SpacingTokens.space1),
          Wrap(
            spacing: SpacingTokens.space2,
            runSpacing: SpacingTokens.space1,
            children: [
              for (final testCase in visibleCases)
                _TestCaseBadge(testCase: testCase, l10n: l10n, theme: theme),
            ],
          ),
        ],
      ),
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
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.space2, vertical: SpacingTokens.space1),
      decoration: BoxDecoration(
        color: theme.colors.surfaces.canvas,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusXs),
        border: Border.all(
            color: theme.colors.borders.subtle,
            width: BorderMetricsTokens.widthHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(l10n.exerciseCaseInputsLabel(_joinedOrDash(testCase.inputs)),
              variant: AppTextVariant.codeCaption,
              color: theme.colors.text.secondary),
          AppText(
              l10n.exerciseCaseOutputsLabel(
                  _joinedOrDash(testCase.expectedOutputs)),
              variant: AppTextVariant.codeCaption,
              color: theme.colors.text.primary),
        ],
      ),
    );
  }
}

String _joinedOrDash(List<String> values) =>
    values.isEmpty ? '—' : values.join(', ');

String _levelLabel(ExerciseLevel level, AppLocalizations l10n) =>
    switch (level) {
      ExerciseLevel.reproduce => l10n.exerciseLevel1,
      ExerciseLevel.compose => l10n.exerciseLevel2,
      ExerciseLevel.design => l10n.exerciseLevel3,
    };

String _kindLabel(ExerciseKind kind, AppLocalizations l10n) => switch (kind) {
      ExerciseKind.predict => l10n.exerciseKindPredict,
      ExerciseKind.complete => l10n.exerciseKindComplete,
      ExerciseKind.modify => l10n.exerciseKindModify,
      ExerciseKind.create => l10n.exerciseKindCreate,
    };
