import 'package:flutter/material.dart';
import '../../../domain/model/knowledge/exercise_kind.dart';
import '../../../domain/model/knowledge/exercise_level.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/radii.dart';
import '../../theme/tokens/spacing.dart';

final class StripLevelBadge extends StatelessWidget {
  final ExerciseLevel level;

  const StripLevelBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    final label = switch (level) {
      ExerciseLevel.reproduce => l10n.exerciseLevelShort1,
      ExerciseLevel.compose => l10n.exerciseLevelShort2,
      ExerciseLevel.design => l10n.exerciseLevelShort3,
    };
    final color = theme.colors.actions.primary.bgDefault;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.space1,
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

final class StripKindBadge extends StatelessWidget {
  final ExerciseKind kind;

  const StripKindBadge({super.key, required this.kind});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    final label = switch (kind) {
      ExerciseKind.predict => l10n.exerciseKindPredict,
      ExerciseKind.complete => l10n.exerciseKindComplete,
      ExerciseKind.modify => l10n.exerciseKindModify,
      ExerciseKind.create => l10n.exerciseKindCreate,
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.space1,
        vertical: SpacingTokens.spaceHalf,
      ),
      decoration: BoxDecoration(
        color: theme.colors.surfaces.subtle,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusXs),
        border: Border.all(color: theme.colors.borders.subtle),
      ),
      child: AppText(label, variant: AppTextVariant.caption, color: theme.colors.text.secondary),
    );
  }
}

final class StripCompletedBadge extends StatelessWidget {
  const StripCompletedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    final successSev = theme.colors.severities.success;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.space1,
        vertical: SpacingTokens.spaceHalf,
      ),
      decoration: BoxDecoration(
        color: successSev.surface,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusXs),
        border: Border.all(color: successSev.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_rounded, size: 10, color: successSev.fg),
          const SizedBox(width: SpacingTokens.spaceHalf),
          AppText(l10n.exerciseCompletedBadge, variant: AppTextVariant.caption, color: successSev.fg),
        ],
      ),
    );
  }
}

final class NotFoundWarning extends StatelessWidget {
  final String exerciseId;

  const NotFoundWarning({super.key, required this.exerciseId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    final warningSev = theme.colors.severities.warning;

    return Padding(
      padding: const EdgeInsets.only(
        left: SpacingTokens.space4,
        right: SpacingTokens.space4,
        bottom: SpacingTokens.space3,
      ),
      child: Container(
        padding: const EdgeInsets.all(SpacingTokens.space2),
        decoration: BoxDecoration(
          color: warningSev.surface,
          borderRadius: BorderRadius.circular(RadiusTokens.radiusXs),
          border: Border.all(color: warningSev.border),
        ),
        child: AppText(
          l10n.exerciseNotFoundInCatalog(exerciseId),
          variant: AppTextVariant.caption,
          color: warningSev.fg,
        ),
      ),
    );
  }
}
