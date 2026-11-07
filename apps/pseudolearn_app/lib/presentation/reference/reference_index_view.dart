import 'package:flutter/material.dart';
import '../../application/reference/reference_index_state.dart';
import '../../domain/model/reference/reference_index.dart';
import '../components/empty/app_empty_state.dart';
import '../components/progress/app_skeleton_list.dart';
import '../components/typography/app_text.dart';
import '../knowledge/components/knowledge_section_empty_view.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/spacing.dart';
import 'reference_runs_text.dart';

final class ReferenceIndexView extends StatelessWidget {
  final ReferenceIndexState state;
  final ValueChanged<String> onOpenSection;
  final VoidCallback onRetry;

  const ReferenceIndexView({
    super.key,
    required this.state,
    required this.onOpenSection,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final parts = state.visibleParts;
    return switch (state.status) {
      ReferenceIndexStatus.error => AppEmptyState(
        icon: Icons.error_outline_rounded,
        title: l10n.referenceIndexErrorTitle,
        description: l10n.knowledgeErrorDescription,
        actionLabel: l10n.knowledgeActionRetry,
        onAction: onRetry,
      ),
      ReferenceIndexStatus.success when parts.isEmpty && !state.isSearching =>
        const KnowledgeSectionEmptyView.content(),
      ReferenceIndexStatus.success when parts.isEmpty => AppEmptyState(
        icon: Icons.search_off_rounded,
        title: l10n.referenceSearchEmpty(state.query.trim()),
        description: '',
      ),
      ReferenceIndexStatus.success => ListView(
        padding: const EdgeInsets.only(bottom: SpacingTokens.space6),
        children: [
          for (final part in parts)
            ReferencePartView(part: part, onOpenSection: onOpenSection),
        ],
      ),
      _ => const AppSkeletonList(itemExtent: 72),
    };
  }
}

final class ReferencePartView extends StatelessWidget {
  final ReferencePart part;
  final ValueChanged<String> onOpenSection;

  const ReferencePartView({
    super.key,
    required this.part,
    required this.onOpenSection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(part.title, variant: AppTextVariant.heading4),
          AppText(
            part.summary,
            variant: AppTextVariant.bodySmall,
            color: theme.colors.text.secondary,
          ),
          for (final section in part.sections)
            ReferenceIndexTile(entry: section, onOpenSection: onOpenSection),
        ],
      ),
    );
  }
}

final class ReferenceIndexTile extends StatelessWidget {
  final ReferenceIndexEntry entry;
  final ValueChanged<String> onOpenSection;

  const ReferenceIndexTile({
    super.key,
    required this.entry,
    required this.onOpenSection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: SizedBox(
        width: SpacingTokens.space12,
        child: AppText(
          entry.number,
          variant: AppTextVariant.label,
          color: theme.colors.text.tertiary,
        ),
      ),
      title: ReferenceRunsText(
        runs: entry.title,
        variant: AppTextVariant.label,
        onOpenSection: onOpenSection,
      ),
      subtitle: ReferenceRunsText(
        runs: entry.phrase,
        variant: AppTextVariant.bodySmall,
        color: theme.colors.text.secondary,
        onOpenSection: onOpenSection,
      ),
      onTap: () => onOpenSection(entry.id),
    );
  }
}
