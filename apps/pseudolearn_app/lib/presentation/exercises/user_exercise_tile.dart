import 'package:flutter/material.dart';
import '../../domain/model/exercises/user_exercise.dart';
import '../components/button/app_button.dart';
import '../components/button/app_icon_button.dart';
import '../components/card/app_card.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/card_metrics.dart';
import '../theme/tokens/icon_metrics.dart';
import '../theme/tokens/spacing.dart';

final class UserExerciseTile extends StatelessWidget {
  final UserExercise exercise;
  final VoidCallback onSolve;
  final VoidCallback onMenu;

  const UserExerciseTile({
    super.key,
    required this.exercise,
    required this.onSolve,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.space3),
      child: AppCard(
        onTap: onSolve,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Summary(exercise: exercise, onMenu: onMenu),
            const SizedBox(height: SpacingTokens.space4),
            _Footer(exercise: exercise, onSolve: onSolve),
          ],
        ),
      ),
    );
  }
}

final class _Summary extends StatelessWidget {
  final UserExercise exercise;
  final VoidCallback onMenu;

  const _Summary({required this.exercise, required this.onMenu});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppThemeExtension.of(context).colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(exercise.title, variant: AppTextVariant.heading4, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: SpacingTokens.space1),
              AppText(exercise.statement, variant: AppTextVariant.bodySmall, color: colors.text.secondary, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        AppIconButton(
          key: ValueKey('user-exercise-menu:${exercise.id}'),
          icon: Icons.more_vert,
          semanticLabel: l10n.userExercisesOptions(exercise.title),
          variant: AppButtonVariant.tertiary,
          onPressed: onMenu,
        ),
      ],
    );
  }
}

final class _Footer extends StatelessWidget {
  final UserExercise exercise;
  final VoidCallback onSolve;

  const _Footer({required this.exercise, required this.onSolve});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hintCount = exercise.hints.length;
    return Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: SpacingTokens.space2,
            runSpacing: SpacingTokens.space2,
            children: [
              _Fact(icon: Icons.checklist, text: l10n.userExercisesCaseCount(exercise.visibleCases.length + exercise.hiddenCases.length)),
              if (hintCount > 0) _Fact(icon: Icons.lightbulb_outline, text: l10n.userExercisesHintCount(hintCount)),
            ],
          ),
        ),
        const SizedBox(width: SpacingTokens.space2),
        AppButton(
          key: ValueKey('user-exercise-solve:${exercise.id}'),
          label: l10n.userExercisesSolve,
          icon: Icons.play_arrow_rounded,
          variant: AppButtonVariant.primary,
          onPressed: onSolve,
        ),
      ],
    );
  }
}

final class _Fact extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Fact({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeExtension.of(context).colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.space2, vertical: SpacingTokens.space1),
      decoration: BoxDecoration(
        color: colors.surfaces.subtle,
        borderRadius: BorderRadius.circular(CardMetricsTokens.radiusInner),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: IconMetricsTokens.iconXs, color: colors.text.secondary),
          const SizedBox(width: SpacingTokens.space1),
          AppText(text, variant: AppTextVariant.caption, color: colors.text.secondary),
        ],
      ),
    );
  }
}
