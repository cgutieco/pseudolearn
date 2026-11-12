import 'package:flutter/material.dart';
import '../components/card/app_card_surface.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/icon_metrics.dart';
import '../theme/tokens/radii.dart';
import '../theme/tokens/spacing.dart';
import 'agent_glyph.dart';
import 'agent_glyph_painter.dart';

final class AgentIntroductionHero extends StatelessWidget {
  const AgentIntroductionHero({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(color: theme.colors.actions.primary.bgDefault, borderRadius: const BorderRadius.all(Radius.circular(RadiusTokens.radiusFull))),
          child: Padding(
            padding: const EdgeInsets.all(SpacingTokens.space3),
            child: AgentGlyph(state: AgentGlyphState.idle, color: theme.colors.text.onBrand, size: IconMetricsTokens.iconLg),
          ),
        ),
        const SizedBox(height: SpacingTokens.space4),
        AppText(l10n.agentIntroHeadline, variant: AppTextVariant.heading2),
        const SizedBox(height: SpacingTokens.space2),
        AppText(l10n.agentIntroBody, variant: AppTextVariant.bodyLarge, color: theme.colors.text.secondary),
      ],
    );
  }
}

final class AgentIntroductionBenefits extends StatelessWidget {
  const AgentIntroductionBenefits({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Benefit(icon: Icons.fact_check_outlined, text: l10n.agentIntroExplain),
        _Benefit(icon: Icons.lightbulb_outline, text: l10n.agentIntroTutor),
        _Benefit(icon: Icons.edit_note, text: l10n.agentIntroEdit),
      ],
    );
  }
}

final class _Benefit extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Benefit({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.space2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: IconMetricsTokens.iconMd, color: theme.colors.actions.primary.bgDefault),
          const SizedBox(width: SpacingTokens.space3),
          Expanded(child: AppText(text, variant: AppTextVariant.bodyDefault)),
        ],
      ),
    );
  }
}

final class AgentIntroductionCredits extends StatelessWidget {
  const AgentIntroductionCredits({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    return AppCardSurface(
      key: const ValueKey('agent-introduction-credits'),
      padding: const EdgeInsets.all(SpacingTokens.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(l10n.agentPlanOverline, variant: AppTextVariant.overline, color: theme.colors.text.secondary),
          const SizedBox(height: SpacingTokens.space2),
          AppText(l10n.agentIntroCreditsMonthly, variant: AppTextVariant.heading3),
          const SizedBox(height: SpacingTokens.space1),
          AppText(l10n.agentIntroCreditsTopUp, key: const ValueKey('agent-introduction-top-up'), variant: AppTextVariant.bodySmall, color: theme.colors.text.secondary),
        ],
      ),
    );
  }
}
