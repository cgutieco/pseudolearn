import 'package:flutter/material.dart';
import '../../../application/knowledge/session/exercise_session_state.dart';
import '../../../domain/model/knowledge/exercise.dart';
import '../../components/button/app_button.dart';
import '../../components/button/app_icon_button.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/border_metrics.dart';
import '../../theme/tokens/spacing.dart';
import 'exercise_strip_badges.dart';
import 'exercise_strip_body.dart';

final class ExerciseStrip extends StatelessWidget {
  final String exerciseId;
  final ExerciseSessionState sessionState;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final VoidCallback onCheck;

  const ExerciseStrip({
    super.key,
    required this.exerciseId,
    required this.sessionState,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.onCheck,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final border = BorderSide(
      color: theme.colors.borders.subtle,
      width: BorderMetricsTokens.widthHairline,
    );
    final header = _ExerciseStripHeader(
      exercise: sessionState.exercise,
      isCompleted: sessionState.isCompleted || sessionState.isSolved,
      isExpanded: isExpanded,
      onToggleExpand: onToggleExpand,
    );
    final body = isExpanded
        ? _ExerciseStripBodyDispatcher(
            exerciseId: exerciseId,
            sessionState: sessionState,
            onCheck: onCheck,
          )
        : null;

    return Container(
      decoration: BoxDecoration(color: theme.colors.surfaces.subtle, border: Border(bottom: border)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [header, if (body != null) body],
      ),
    );
  }
}

final class _ExerciseStripHeader extends StatelessWidget {
  final Exercise? exercise;
  final bool isCompleted;
  final bool isExpanded;
  final VoidCallback onToggleExpand;

  const _ExerciseStripHeader({
    required this.exercise,
    required this.isCompleted,
    required this.isExpanded,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = exercise?.title ?? l10n.exerciseNotFoundTitle;
    final icon = isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down;
    final semantic = isExpanded ? l10n.exerciseStripCollapse : l10n.exerciseStripExpand;

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.space4),
      child: Row(
        children: [
          const Icon(Icons.assignment_outlined, size: 16),
          const SizedBox(width: SpacingTokens.space2),
          Expanded(
            child: AppText(
              l10n.exerciseStripTitle(title),
              variant: AppTextVariant.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (exercise != null) _HeaderBadges(exercise: exercise!, isCompleted: isCompleted),
          const SizedBox(width: SpacingTokens.space2),
          AppIconButton(icon: icon, semanticLabel: semantic, variant: AppButtonVariant.tertiary, onPressed: onToggleExpand),
        ],
      ),
    );
  }
}

final class _HeaderBadges extends StatelessWidget {
  final Exercise exercise;
  final bool isCompleted;

  const _HeaderBadges({required this.exercise, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: SpacingTokens.space2),
        StripLevelBadge(level: exercise.level),
        const SizedBox(width: SpacingTokens.space1),
        StripKindBadge(kind: exercise.kind),
        if (isCompleted) ...[
          const SizedBox(width: SpacingTokens.space1),
          const StripCompletedBadge(),
        ],
      ],
    );
  }
}

final class _ExerciseStripBodyDispatcher extends StatelessWidget {
  final String exerciseId;
  final ExerciseSessionState sessionState;
  final VoidCallback onCheck;

  const _ExerciseStripBodyDispatcher({
    required this.exerciseId,
    required this.sessionState,
    required this.onCheck,
  });

  @override
  Widget build(BuildContext context) {
    if (sessionState.status == ExerciseSessionStatus.exerciseNotFound) {
      return NotFoundWarning(exerciseId: exerciseId);
    }
    if (sessionState.status == ExerciseSessionStatus.loading) {
      return const Padding(
        padding: EdgeInsets.all(SpacingTokens.space3),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (sessionState.exercise != null) {
      return ExerciseStripBodyContent(
        exercise: sessionState.exercise!,
        isChecking: sessionState.status == ExerciseSessionStatus.checking,
        lastResult: sessionState.lastResult,
        revealedHiddenFailure: sessionState.revealedHiddenFailure,
        onCheck: onCheck,
      );
    }
    return const SizedBox.shrink();
  }
}
