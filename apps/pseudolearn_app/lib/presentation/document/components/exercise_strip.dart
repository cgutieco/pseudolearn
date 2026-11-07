import 'package:flutter/material.dart';
import '../../../application/route/session/exercise_session_state.dart';
import '../../../domain/model/knowledge/exercise.dart';
import '../../../domain/model/knowledge/exercise_check_result.dart';
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

  const ExerciseStrip({
    super.key,
    required this.exerciseId,
    required this.sessionState,
    required this.isExpanded,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    final header = _ExerciseStripHeader(
      exercise: sessionState.exercise,
      isCompleted: sessionState.isCompleted || sessionState.isSolved,
      lastResult: sessionState.lastResult,
      isExpanded: isExpanded,
      onToggleExpand: onToggleExpand,
    );
    return _StripSurface(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          if (isExpanded)
            Flexible(
              child: SingleChildScrollView(
                child: _ExerciseStripBodyDispatcher(
                  exerciseId: exerciseId,
                  sessionState: sessionState,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

final class _StripSurface extends StatelessWidget {
  final Widget child;

  const _StripSurface({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final border = BorderSide(
      color: theme.colors.borders.subtle,
      width: BorderMetricsTokens.widthHairline,
    );
    return Container(
      decoration: BoxDecoration(
        color: theme.colors.surfaces.subtle,
        border: Border(bottom: border),
      ),
      child: child,
    );
  }
}

final class _ExerciseStripHeader extends StatelessWidget {
  final Exercise? exercise;
  final bool isCompleted;
  final ExerciseCheckResult? lastResult;
  final bool isExpanded;
  final VoidCallback onToggleExpand;

  const _ExerciseStripHeader({
    required this.exercise,
    required this.isCompleted,
    required this.lastResult,
    required this.isExpanded,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = exercise?.title ?? l10n.exerciseNotFoundTitle;

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.space4),
      child: Row(
        children: [
          const Icon(Icons.assignment_outlined, size: 16),
          const SizedBox(width: SpacingTokens.space2),
          Expanded(child: _StripTitle(text: l10n.exerciseStripTitle(title))),
          if (exercise != null)
            _HeaderBadges(
              exercise: exercise!,
              isCompleted: isCompleted,
              lastResult: lastResult,
            ),
          const SizedBox(width: SpacingTokens.space2),
          _ExpandToggle(isExpanded: isExpanded, onToggleExpand: onToggleExpand),
        ],
      ),
    );
  }
}

final class _StripTitle extends StatelessWidget {
  final String text;

  const _StripTitle({required this.text});

  @override
  Widget build(BuildContext context) => AppText(
    text,
    variant: AppTextVariant.label,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
}

final class _ExpandToggle extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggleExpand;

  const _ExpandToggle({required this.isExpanded, required this.onToggleExpand});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppIconButton(
      icon: isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
      semanticLabel: isExpanded
          ? l10n.exerciseStripCollapse
          : l10n.exerciseStripExpand,
      variant: AppButtonVariant.tertiary,
      onPressed: onToggleExpand,
    );
  }
}

final class _HeaderBadges extends StatelessWidget {
  final Exercise exercise;
  final bool isCompleted;
  final ExerciseCheckResult? lastResult;

  const _HeaderBadges({
    required this.exercise,
    required this.isCompleted,
    required this.lastResult,
  });

  @override
  Widget build(BuildContext context) {
    final result = lastResult;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: SpacingTokens.space2),
        StripLevelBadge(level: exercise.level),
        if (result != null) ...[
          const SizedBox(width: SpacingTokens.space1),
          StripResultBadge(result: result),
        ] else if (isCompleted) ...[
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

  const _ExerciseStripBodyDispatcher({
    required this.exerciseId,
    required this.sessionState,
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
        lastResult: sessionState.lastResult,
        revealedHiddenFailure: sessionState.revealedHiddenFailure,
      );
    }
    return const SizedBox.shrink();
  }
}
