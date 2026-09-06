import 'package:flutter/material.dart';
import '../../../domain/model/knowledge/content_block.dart';
import '../../brand/brand_lockup.dart';
import '../../components/card/app_card_surface.dart';
import '../../components/typography/app_text.dart';
import '../../knowledge/detail/components/content_block_view.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/brand_metrics.dart';
import '../../theme/tokens/spacing.dart';

final class ContactHeroCard extends StatelessWidget {
  final String? introText;

  const ContactHeroCard({super.key, this.introText});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final theme = AppThemeExtension.of(context);

    return AppCardSurface(
      padding: EdgeInsets.all(canvas.scaled(SpacingTokens.space5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BrandLockup(typeSize: BrandMetricsTokens.lockupTypeSizeFooter),
          if (introText != null) ...[
            SizedBox(height: canvas.scaled(SpacingTokens.space3)),
            AppText(
              introText!,
              variant: AppTextVariant.bodyLarge,
              color: theme.colors.text.secondary,
            ),
          ],
        ],
      ),
    );
  }
}

final class ContactPedagogicalCard extends StatelessWidget {
  final List<ContentBlock> blocks;

  const ContactPedagogicalCard({super.key, required this.blocks});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final theme = AppThemeExtension.of(context);

    return AppCardSurface(
      padding: EdgeInsets.all(canvas.scaled(SpacingTokens.space5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.school_outlined, size: 28, color: theme.colors.text.link),
          SizedBox(height: canvas.scaled(SpacingTokens.space2)),
          for (final block in blocks) ContentBlockView(block: block),
        ],
      ),
    );
  }
}

final class ContactTipsCard extends StatelessWidget {
  const ContactTipsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);

    return AppCardSurface(
      padding: EdgeInsets.all(canvas.scaled(SpacingTokens.space5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TipsHeader(title: l10n.settingsContactTipsTitle),
          SizedBox(height: canvas.scaled(SpacingTokens.space2)),
          AppText(
            l10n.settingsContactTipsBody,
            variant: AppTextVariant.bodyDefault,
            color: theme.colors.text.secondary,
          ),
        ],
      ),
    );
  }
}

final class _TipsHeader extends StatelessWidget {
  final String title;

  const _TipsHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final theme = AppThemeExtension.of(context);

    return Row(
      children: [
        Icon(Icons.lightbulb_outline, size: 22, color: theme.colors.text.link),
        SizedBox(width: canvas.scaled(SpacingTokens.space2)),
        Expanded(
          child: AppText(title, variant: AppTextVariant.heading3, color: theme.colors.text.primary),
        ),
      ],
    );
  }
}
