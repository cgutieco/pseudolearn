import 'package:flutter/material.dart';
import '../../../../application/knowledge/bank/exercise_bank_state.dart';
import '../../../../domain/model/knowledge/ast_construct.dart';
import '../../../../domain/model/knowledge/exercise_level.dart';
import '../../../components/empty/app_empty_state.dart';
import '../../../components/layout/app_card_grid.dart';
import '../../../components/progress/app_skeleton_list.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/tokens/grid_metrics.dart';
import '../../../theme/tokens/spacing.dart';
import 'exercise_bank_card.dart';
import 'exercise_filter_bar.dart';

final class ExerciseBankSection extends StatelessWidget {
  final ExerciseBankState state;
  final ValueChanged<ExerciseLevel?> onLevelSelected;
  final ValueChanged<String?> onModuleSelected;
  final ValueChanged<AstConstruct?> onConstructSelected;
  final VoidCallback onClearFilters;
  final ValueChanged<String> onOpenExercise;
  final VoidCallback onRetry;

  const ExerciseBankSection({
    super.key,
    required this.state,
    required this.onLevelSelected,
    required this.onModuleSelected,
    required this.onConstructSelected,
    required this.onClearFilters,
    required this.onOpenExercise,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (state.status == ExerciseBankStatus.loading) {
      return const AppSkeletonList(itemExtent: GridMetricsTokens.cardExtentKnowledge);
    }
    if (state.status == ExerciseBankStatus.error) {
      return _BankErrorView(onRetry: onRetry);
    }
    if (state.isEmptyBank) {
      return const _BankEmptyView();
    }
    return _BankContent(
      state: state,
      onLevelSelected: onLevelSelected,
      onModuleSelected: onModuleSelected,
      onConstructSelected: onConstructSelected,
      onClearFilters: onClearFilters,
      onOpenExercise: onOpenExercise,
    );
  }
}

final class _BankContent extends StatelessWidget {
  final ExerciseBankState state;
  final ValueChanged<ExerciseLevel?> onLevelSelected;
  final ValueChanged<String?> onModuleSelected;
  final ValueChanged<AstConstruct?> onConstructSelected;
  final VoidCallback onClearFilters;
  final ValueChanged<String> onOpenExercise;

  const _BankContent({
    required this.state,
    required this.onLevelSelected,
    required this.onModuleSelected,
    required this.onConstructSelected,
    required this.onClearFilters,
    required this.onOpenExercise,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExerciseFilterBar(
          selectedLevel: state.selectedLevel,
          selectedConstruct: state.selectedConstruct,
          availableConstructs: state.availableConstructs,
          isAnyFilterActive: state.isAnyFilterActive,
          onLevelSelected: onLevelSelected,
          onConstructSelected: onConstructSelected,
          onClearFilters: onClearFilters,
        ),
        const SizedBox(height: SpacingTokens.space4),
        Expanded(
          child: state.isEmptyFilterResult
              ? _FilterEmptyView(onClearFilters: onClearFilters)
              : _ExerciseGrid(state: state, onOpenExercise: onOpenExercise),
        ),
      ],
    );
  }
}

final class _ExerciseGrid extends StatelessWidget {
  final ExerciseBankState state;
  final ValueChanged<String> onOpenExercise;

  const _ExerciseGrid({
    required this.state,
    required this.onOpenExercise,
  });

  @override
  Widget build(BuildContext context) {
    final exercises = state.filteredExercises;
    return AppCardGrid(
      itemCount: exercises.length,
      cardExtent: GridMetricsTokens.cardExtentKnowledge,
      padding: const EdgeInsets.only(bottom: SpacingTokens.space6),
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        final isCompleted = state.isExerciseCompleted(exercise.id);
        return ExerciseBankCard(
          exercise: exercise,
          isCompleted: isCompleted,
          onTap: () => onOpenExercise(exercise.id),
        );
      },
    );
  }
}

final class _BankErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _BankErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppEmptyState(
      icon: Icons.error_outline_rounded,
      title: l10n.knowledgeErrorTitle,
      description: l10n.knowledgeErrorDescription,
      actionLabel: l10n.knowledgeActionRetry,
      onAction: onRetry,
    );
  }
}

final class _BankEmptyView extends StatelessWidget {
  const _BankEmptyView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppEmptyState(
      icon: Icons.code_rounded,
      title: l10n.exerciseBankEmptyTitle,
      description: l10n.exerciseBankEmptyDescription,
    );
  }
}

final class _FilterEmptyView extends StatelessWidget {
  final VoidCallback onClearFilters;

  const _FilterEmptyView({required this.onClearFilters});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppEmptyState(
      icon: Icons.filter_alt_off_rounded,
      title: l10n.exerciseBankEmptyFilterTitle,
      description: l10n.exerciseBankEmptyFilterDescription,
      actionLabel: l10n.exerciseClearFilters,
      onAction: onClearFilters,
    );
  }
}
