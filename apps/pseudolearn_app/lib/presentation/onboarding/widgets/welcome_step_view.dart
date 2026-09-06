import 'package:flutter/material.dart';
import '../../brand/brand_symbol.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/brand_metrics.dart';
import '../../theme/tokens/icon_metrics.dart';
import '../../theme/tokens/spacing.dart';

final class WelcomeStepView extends StatelessWidget {
  const WelcomeStepView({super.key});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _WelcomeHeading(),
        SizedBox(height: canvas.scaled(SpacingTokens.space6)),
        const _WelcomeHighlights(),
      ],
    );
  }
}

final class _WelcomeHeading extends StatelessWidget {
  const _WelcomeHeading();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canvas = DesignCanvasScope.of(context);
    final theme = AppThemeExtension.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _WelcomeMark(),
        SizedBox(height: canvas.scaled(SpacingTokens.space3)),
        AppText(
          l10n.onboardingWelcomeTitle,
          variant: AppTextVariant.heading2,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: canvas.scaled(SpacingTokens.space2)),
        AppText(
          l10n.onboardingWelcomeSubtitle,
          variant: AppTextVariant.bodyDefault,
          color: theme.colors.text.secondary,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

final class _WelcomeMark extends StatelessWidget {
  const _WelcomeMark();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BrandSymbol(
        size: BrandMetricsTokens.symbolSizeHero,
        color: AppThemeExtension.of(context).colors.brandInk.signature,
      ),
    );
  }
}

final class _WelcomeHighlights extends StatelessWidget {
  const _WelcomeHighlights();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canvas = DesignCanvasScope.of(context);
    final gap = canvas.scaled(SpacingTokens.space3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HighlightRow(
          icon: Icons.play_circle_outline,
          label: l10n.onboardingWelcomeHighlightEngine,
        ),
        SizedBox(height: gap),
        _HighlightRow(
          icon: Icons.account_tree_outlined,
          label: l10n.onboardingWelcomeHighlightDiagrams,
        ),
        SizedBox(height: gap),
        _HighlightRow(
          icon: Icons.route_outlined,
          label: l10n.onboardingWelcomeHighlightRoute,
        ),
      ],
    );
  }
}

final class _HighlightRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HighlightRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: IconMetricsTokens.iconSm,
          color: theme.colors.actions.primary.bgDefault,
        ),
        const SizedBox(width: SpacingTokens.space3),
        Expanded(
          child: AppText(
            label,
            variant: AppTextVariant.bodySmall,
            color: theme.colors.text.primary,
          ),
        ),
      ],
    );
  }
}
