import 'package:flutter/material.dart';
import '../../../application/knowledge/route/learning_route_state.dart';
import '../../../domain/model/knowledge/knowledge_entry.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import 'knowledge_entry_card.dart';
import 'knowledge_section_empty_view.dart';

final class KnowledgeRouteSection extends StatelessWidget {
  final LearningRouteState routeState;
  final ValueChanged<KnowledgeEntry> onOpenEntry;

  const KnowledgeRouteSection({
    super.key,
    required this.routeState,
    required this.onOpenEntry,
  });

  @override
  Widget build(BuildContext context) {
    if (routeState.isRouteEmpty) {
      return const KnowledgeSectionEmptyView.content();
    }
    if (routeState.isRouteSearchEmpty) {
      return KnowledgeSectionEmptyView.search(
          searchQuery: routeState.searchQuery.trim());
    }
    return _TrackList(routeState: routeState, onOpenEntry: onOpenEntry);
  }
}

final class _TrackList extends StatelessWidget {
  final LearningRouteState routeState;
  final ValueChanged<KnowledgeEntry> onOpenEntry;

  const _TrackList({required this.routeState, required this.onOpenEntry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      children: [
        _TrackGroup(
          title: l10n.knowledgeRouteTrackFoundations,
          entries: routeState.filteredTrackA,
          routeState: routeState,
          onOpenEntry: onOpenEntry,
        ),
        _TrackGroup(
          title: l10n.knowledgeRouteTrackImperative,
          entries: routeState.filteredTrackB,
          routeState: routeState,
          onOpenEntry: onOpenEntry,
        ),
        _TrackGroup(
          title: l10n.knowledgeRouteTrackObjectOriented,
          entries: routeState.filteredTrackC,
          routeState: routeState,
          onOpenEntry: onOpenEntry,
        ),
      ],
    );
  }
}

final class _TrackGroup extends StatelessWidget {
  final String title;
  final List<KnowledgeEntry> entries;
  final LearningRouteState routeState;
  final ValueChanged<KnowledgeEntry> onOpenEntry;

  const _TrackGroup({
    required this.title,
    required this.entries,
    required this.routeState,
    required this.onOpenEntry,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();
    final theme = AppThemeExtension.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.space6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(title,
              variant: AppTextVariant.heading3,
              color: theme.colors.text.primary),
          const SizedBox(height: SpacingTokens.space3),
          for (final entry in entries)
            Padding(
              padding: const EdgeInsets.only(bottom: SpacingTokens.space3),
              child: KnowledgeEntryCard(
                entry: entry,
                onTap: () => onOpenEntry(entry),
                isVisited: routeState.isModuleVisited(entry.id),
              ),
            ),
        ],
      ),
    );
  }
}
