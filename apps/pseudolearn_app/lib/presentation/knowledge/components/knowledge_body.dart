import 'package:flutter/material.dart';
import '../../../application/knowledge/bank/exercise_bank_state.dart';
import '../../../application/knowledge/knowledge_state.dart';
import '../../../application/knowledge/route/learning_route_state.dart';
import '../../../domain/model/knowledge/ast_construct.dart';
import '../../../domain/model/knowledge/exercise_level.dart';
import '../../../domain/model/knowledge/knowledge_entry.dart';
import '../../components/empty/app_empty_state.dart';
import '../../components/layout/app_card_grid.dart';
import '../../components/progress/app_skeleton_list.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/tokens/grid_metrics.dart';
import '../../theme/tokens/spacing.dart';
import 'exercise_bank/exercise_bank_section.dart';
import 'knowledge_entry_card.dart';
import 'knowledge_route_section.dart';
import 'knowledge_section_empty_view.dart';
import 'knowledge_section_selector.dart';

final class KnowledgeBody extends StatelessWidget {
  final KnowledgeSectionKind activeSection;
  final ValueChanged<KnowledgeSectionKind> onSectionSelected;
  final KnowledgeState knowledgeState;
  final LearningRouteState routeState;
  final ExerciseBankState exerciseBankState;
  final ValueChanged<ExerciseLevel?> onLevelSelected;
  final ValueChanged<String?> onModuleSelected;
  final ValueChanged<AstConstruct?> onConstructSelected;
  final VoidCallback onClearFilters;
  final ValueChanged<KnowledgeEntry> onOpenEntry;
  final ValueChanged<String> onOpenExercise;
  final VoidCallback onRetry;

  const KnowledgeBody({
    super.key,
    required this.activeSection,
    required this.onSectionSelected,
    required this.knowledgeState,
    required this.routeState,
    required this.exerciseBankState,
    required this.onLevelSelected,
    required this.onModuleSelected,
    required this.onConstructSelected,
    required this.onClearFilters,
    required this.onOpenEntry,
    required this.onOpenExercise,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KnowledgeSectionSelector(
          activeSection: activeSection,
          onSectionSelected: onSectionSelected,
        ),
        const SizedBox(height: SpacingTokens.space4),
        Expanded(
          child: _SectionContent(
            activeSection: activeSection,
            knowledgeState: knowledgeState,
            routeState: routeState,
            exerciseBankState: exerciseBankState,
            onLevelSelected: onLevelSelected,
            onModuleSelected: onModuleSelected,
            onConstructSelected: onConstructSelected,
            onClearFilters: onClearFilters,
            onOpenEntry: onOpenEntry,
            onOpenExercise: onOpenExercise,
            onRetry: onRetry,
          ),
        ),
      ],
    );
  }
}

final class _SectionContent extends StatelessWidget {
  final KnowledgeSectionKind activeSection;
  final KnowledgeState knowledgeState;
  final LearningRouteState routeState;
  final ExerciseBankState exerciseBankState;
  final ValueChanged<ExerciseLevel?> onLevelSelected;
  final ValueChanged<String?> onModuleSelected;
  final ValueChanged<AstConstruct?> onConstructSelected;
  final VoidCallback onClearFilters;
  final ValueChanged<KnowledgeEntry> onOpenEntry;
  final ValueChanged<String> onOpenExercise;
  final VoidCallback onRetry;

  const _SectionContent({
    required this.activeSection,
    required this.knowledgeState,
    required this.routeState,
    required this.exerciseBankState,
    required this.onLevelSelected,
    required this.onModuleSelected,
    required this.onConstructSelected,
    required this.onClearFilters,
    required this.onOpenEntry,
    required this.onOpenExercise,
    required this.onRetry,
  });

  bool get _isLoading =>
      knowledgeState.status == KnowledgeStatus.loading ||
      routeState.status == LearningRouteStatus.loading;

  bool get _hasError =>
      knowledgeState.status == KnowledgeStatus.error ||
      routeState.status == LearningRouteStatus.error;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AppSkeletonList(itemExtent: GridMetricsTokens.cardExtentKnowledge);
    }
    if (_hasError) {
      return _ErrorView(onRetry: onRetry);
    }
    return switch (activeSection) {
      KnowledgeSectionKind.route =>
        KnowledgeRouteSection(routeState: routeState, onOpenEntry: onOpenEntry),
      KnowledgeSectionKind.specification => _EntryGridSection(
          allEntries: knowledgeState.specificationEntries,
          filteredEntries: knowledgeState.filteredSpecificationEntries,
          searchQuery: knowledgeState.searchQuery,
          onOpenEntry: onOpenEntry,
        ),
      KnowledgeSectionKind.exercises => ExerciseBankSection(
          state: exerciseBankState,
          onLevelSelected: onLevelSelected,
          onModuleSelected: onModuleSelected,
          onConstructSelected: onConstructSelected,
          onClearFilters: onClearFilters,
          onOpenExercise: onOpenExercise,
          onRetry: onRetry,
        ),
    };
  }
}

final class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({required this.onRetry});

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

final class _EntryGridSection extends StatelessWidget {
  final List<KnowledgeEntry> allEntries;
  final List<KnowledgeEntry> filteredEntries;
  final String searchQuery;
  final ValueChanged<KnowledgeEntry> onOpenEntry;

  const _EntryGridSection({
    required this.allEntries,
    required this.filteredEntries,
    required this.searchQuery,
    required this.onOpenEntry,
  });

  @override
  Widget build(BuildContext context) {
    if (allEntries.isEmpty) return const KnowledgeSectionEmptyView.content();
    if (filteredEntries.isEmpty) {
      return KnowledgeSectionEmptyView.search(searchQuery: searchQuery.trim());
    }

    return AppCardGrid(
      itemCount: filteredEntries.length,
      cardExtent: GridMetricsTokens.cardExtentKnowledge,
      padding: const EdgeInsets.only(bottom: SpacingTokens.space6),
      itemBuilder: (context, index) {
        final entry = filteredEntries[index];
        return KnowledgeEntryCard(entry: entry, onTap: () => onOpenEntry(entry));
      },
    );
  }
}
