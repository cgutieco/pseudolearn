import 'package:flutter/material.dart';
import '../../../../domain/model/knowledge/exercise.dart';
import '../../../../domain/model/knowledge/exercise_kind.dart';
import '../../../../domain/model/knowledge/exercise_level.dart';
import '../../../components/card/app_card.dart';
import '../../../components/typography/app_text.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/tokens/radii.dart';
import '../../../theme/tokens/spacing.dart';

final class ExerciseBankCard extends StatelessWidget {
  final Exercise exercise;
  final bool isCompleted;
  final VoidCallback onTap;

  const ExerciseBankCard({
    super.key,
    required this.exercise,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ExerciseBadgesRow(exercise: exercise, isCompleted: isCompleted),
          const SizedBox(height: SpacingTokens.space2),
          _ExerciseCardTexts(exercise: exercise),
        ],
      ),
    );
  }
}

final class _ExerciseCardTexts extends StatelessWidget {
  final Exercise exercise;

  const _ExerciseCardTexts({required this.exercise});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          exercise.title,
          variant: AppTextVariant.heading4,
          color: theme.colors.text.primary,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: SpacingTokens.space1),
        AppText(
          exercise.statement,
          variant: AppTextVariant.bodySmall,
          color: theme.colors.text.secondary,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

final class _ExerciseBadgesRow extends StatelessWidget {
  final Exercise exercise;
  final bool isCompleted;

  const _ExerciseBadgesRow({
    required this.exercise,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: SpacingTokens.space2,
      runSpacing: SpacingTokens.space1,
      children: [
        _LevelBadge(level: exercise.level),
        _KindBadge(kind: exercise.kind),
        if (isCompleted) const _CompletedBadge(),
      ],
    );
  }
}

final class _LevelBadge extends StatelessWidget {
  final ExerciseLevel level;

  const _LevelBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    final label = _levelLabel(level, l10n);
    final color = theme.colors.actions.primary.bgDefault;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.space2,
        vertical: SpacingTokens.spaceHalf,
      ),
      decoration: BoxDecoration(
        color: theme.colors.surfaces.brandSubtle,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusXs),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: AppText(label, variant: AppTextVariant.caption, color: color),
    );
  }
}

final class _KindBadge extends StatelessWidget {
  final ExerciseKind kind;

  const _KindBadge({required this.kind});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    final label = _kindLabel(kind, l10n);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.space2,
        vertical: SpacingTokens.spaceHalf,
      ),
      decoration: BoxDecoration(
        color: theme.colors.surfaces.subtle,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusXs),
        border: Border.all(color: theme.colors.borders.subtle),
      ),
      child: AppText(
        label,
        variant: AppTextVariant.caption,
        color: theme.colors.text.secondary,
      ),
    );
  }
}

final class _CompletedBadge extends StatelessWidget {
  const _CompletedBadge();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    final color = theme.colors.severities.success.fg;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.space2,
        vertical: SpacingTokens.spaceHalf,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(RadiusTokens.radiusXs),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_rounded, size: 12, color: color),
          const SizedBox(width: SpacingTokens.spaceHalf),
          AppText(
            l10n.exerciseCompletedBadge,
            variant: AppTextVariant.caption,
            color: color,
          ),
        ],
      ),
    );
  }
}

String _levelLabel(ExerciseLevel level, AppLocalizations l10n) => switch (level) {
      ExerciseLevel.reproduce => l10n.exerciseLevelShort1,
      ExerciseLevel.compose => l10n.exerciseLevelShort2,
      ExerciseLevel.design => l10n.exerciseLevelShort3,
    };

String _kindLabel(ExerciseKind kind, AppLocalizations l10n) => switch (kind) {
      ExerciseKind.predict => l10n.exerciseKindPredict,
      ExerciseKind.complete => l10n.exerciseKindComplete,
      ExerciseKind.modify => l10n.exerciseKindModify,
      ExerciseKind.create => l10n.exerciseKindCreate,
    };
