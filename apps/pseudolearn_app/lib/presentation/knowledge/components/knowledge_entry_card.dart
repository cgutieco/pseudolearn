import 'package:flutter/material.dart';
import '../../../domain/model/knowledge/knowledge_entry.dart';
import '../../../domain/model/knowledge/knowledge_entry_type.dart';
import '../../../domain/model/profiles/syntax_profile_id.dart';
import '../../components/card/app_card.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/radii.dart';
import '../../theme/tokens/spacing.dart';
import 'knowledge_type_badge.dart';

final class KnowledgeEntryCard extends StatelessWidget {
  final KnowledgeEntry entry;
  final VoidCallback onTap;
  final bool isVisited;

  const KnowledgeEntryCard({
    super.key,
    required this.entry,
    required this.onTap,
    this.isVisited = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BadgesRow(entry: entry, isVisited: isVisited),
          const SizedBox(height: SpacingTokens.space2),
          AppText(
            entry.title,
            variant: AppTextVariant.heading4,
            color: theme.colors.text.primary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: SpacingTokens.space1),
          AppText(
            entry.summary,
            variant: AppTextVariant.bodySmall,
            color: theme.colors.text.secondary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

final class _BadgesRow extends StatelessWidget {
  final KnowledgeEntry entry;
  final bool isVisited;

  const _BadgesRow({required this.entry, required this.isVisited});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TypeBadge(type: entry.type),
        if (entry.profileId != null) ...[
          const SizedBox(width: SpacingTokens.space2),
          _ProfileBadge(profileId: entry.profileId!),
        ],
        if (isVisited) ...[
          const SizedBox(width: SpacingTokens.space2),
          const _VisitedBadge(),
        ],
      ],
    );
  }
}

final class _VisitedBadge extends StatelessWidget {
  const _VisitedBadge();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    final color = theme.colors.severities.success.fg;

    return Semantics(
      label: l10n.knowledgeModuleVisited,
      child: Container(
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
            AppText(l10n.knowledgeModuleVisited, variant: AppTextVariant.caption, color: color),
          ],
        ),
      ),
    );
  }
}

final class _TypeBadge extends StatelessWidget {
  final KnowledgeEntryType type;

  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);

    final (badgeLabel, badgeColor) = knowledgeTypeBadge(
      type: type,
      l10n: l10n,
      theme: theme,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.space2,
        vertical: SpacingTokens.spaceHalf,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(RadiusTokens.radiusXs),
        border: Border.all(color: badgeColor),
      ),
      child: AppText(
        badgeLabel,
        variant: AppTextVariant.caption,
        color: badgeColor,
      ),
    );
  }
}

final class _ProfileBadge extends StatelessWidget {
  final SyntaxProfileId profileId;

  const _ProfileBadge({required this.profileId});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.space2,
        vertical: SpacingTokens.spaceHalf,
      ),
      decoration: BoxDecoration(
        color: theme.colors.surfaces.subtle,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusXs),
        border: Border.all(color: theme.colors.borders.strong),
      ),
      child: AppText(
        profileId == SyntaxProfileId.classicSpanish ? 'ES' : 'EN',
        variant: AppTextVariant.caption,
        color: theme.colors.text.secondary,
      ),
    );
  }
}
