import 'package:flutter/material.dart';
import '../../../../domain/model/knowledge/knowledge_entry.dart';
import '../../../components/button/app_button.dart';
import '../../../components/button/app_icon_button.dart';
import '../../../components/typography/app_text.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../components/knowledge_type_badge.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/tokens/radii.dart';
import '../../../theme/tokens/spacing.dart';

final class DetailHeader extends StatelessWidget {
  final KnowledgeEntry? entry;
  final VoidCallback onBack;

  const DetailHeader({
    super.key,
    required this.entry,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);

    return Row(
      children: [
        AppIconButton(
          icon: Icons.arrow_back_rounded,
          semanticLabel: l10n.knowledgeDetailBack,
          variant: AppButtonVariant.tertiary,
          onPressed: onBack,
        ),
        const SizedBox(width: SpacingTokens.space2),
        Expanded(
          child: AppText(
            entry?.title ?? '',
            variant: AppTextVariant.heading2,
            color: theme.colors.text.primary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (entry != null) ...[
          const SizedBox(width: SpacingTokens.space2),
          _DetailBadges(entry: entry!),
        ],
      ],
    );
  }
}

final class _DetailBadges extends StatelessWidget {
  final KnowledgeEntry entry;

  const _DetailBadges({required this.entry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);

    final (label, color) = knowledgeTypeBadge(
      type: entry.type,
      l10n: l10n,
      theme: theme,
    );

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
      child: AppText(
        label,
        variant: AppTextVariant.caption,
        color: color,
      ),
    );
  }
}
