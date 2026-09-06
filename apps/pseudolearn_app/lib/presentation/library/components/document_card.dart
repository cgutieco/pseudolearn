import 'package:flutter/material.dart';
import '../../../domain/model/documents/document.dart';
import '../../../domain/model/profiles/syntax_profile_id.dart';
import '../../components/button/app_button.dart';
import '../../components/button/app_icon_button.dart';
import '../../components/card/app_card.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/card_metrics.dart';
import '../../theme/tokens/spacing.dart';

final class DocumentCard extends StatelessWidget {
  final DocumentSummary document;
  final VoidCallback onTap;
  final VoidCallback onMenuTap;

  const DocumentCard({
    super.key,
    required this.document,
    required this.onTap,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitleRow(title: document.title, onMenuTap: onMenuTap),
          SizedBox(height: DesignCanvasScope.of(context).scaled(CardMetricsTokens.gapInternal)),
          _CardMetaRow(
            profileId: document.profileId,
            updatedAt: document.updatedAt,
            isConflict: document.title.contains('(conflicto)'),
          ),
        ],
      ),
    );
  }
}

final class _CardTitleRow extends StatelessWidget {
  final String title;
  final VoidCallback onMenuTap;

  const _CardTitleRow({required this.title, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: AppText(
            title,
            variant: AppTextVariant.heading4,
            color: theme.colors.text.primary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        AppIconButton(
          icon: Icons.more_vert,
          semanticLabel: l10n.libraryDocumentOptions,
          variant: AppButtonVariant.tertiary,
          onPressed: onMenuTap,
        ),
      ],
    );
  }
}

final class _CardMetaRow extends StatelessWidget {
  final SyntaxProfileId profileId;
  final DateTime updatedAt;
  final bool isConflict;

  const _CardMetaRow({
    required this.profileId,
    required this.updatedAt,
    required this.isConflict,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final profileLabel = profileId == SyntaxProfileId.classicSpanish ? 'ES' : 'EN';
    final dateStr = '${updatedAt.year}-${updatedAt.month.toString().padLeft(2, '0')}-${updatedAt.day.toString().padLeft(2, '0')}';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.space1 + SpacingTokens.spaceHalf, vertical: SpacingTokens.spaceHalf),
          decoration: BoxDecoration(
            color: theme.colors.surfaces.subtle,
            borderRadius: BorderRadius.circular(CardMetricsTokens.radiusInner),
          ),
          child: AppText(profileLabel, variant: AppTextVariant.caption, color: theme.colors.text.secondary),
        ),
        const SizedBox(width: SpacingTokens.space2),
        AppText(dateStr, variant: AppTextVariant.bodySmall, color: theme.colors.text.tertiary),
        if (isConflict) ...[
          const Spacer(),
          const _ConflictBadge(),
        ],
      ],
    );
  }
}

final class _ConflictBadge extends StatelessWidget {
  const _ConflictBadge();

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.space1 + SpacingTokens.spaceHalf,
        vertical: SpacingTokens.spaceHalf,
      ),
      decoration: BoxDecoration(
        color: theme.colors.severities.warning.surface,
        borderRadius: BorderRadius.circular(CardMetricsTokens.radiusInner),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, size: 12, color: theme.colors.severities.warning.fg),
          const SizedBox(width: SpacingTokens.spaceHalf),
          AppText(
            l10n.syncConflictBadge,
            variant: AppTextVariant.caption,
            color: theme.colors.severities.warning.fg,
          ),
        ],
      ),
    );
  }
}
