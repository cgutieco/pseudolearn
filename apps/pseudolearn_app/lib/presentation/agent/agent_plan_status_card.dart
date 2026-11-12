import 'package:flutter/material.dart';
import '../../application/credits/credit_plan_summary.dart';
import '../components/card/app_card_surface.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/radii.dart';
import '../theme/tokens/spacing.dart';

String _kindLabel(AppLocalizations l10n, CreditPlanKind kind) => switch (kind) {
  CreditPlanKind.trial => l10n.agentPlanKindTrial,
  CreditPlanKind.monthly => l10n.agentPlanKindMonthly,
  CreditPlanKind.topUpOnly => l10n.agentPlanKindTopUpOnly,
};

final class AgentPlanStatusCard extends StatelessWidget {
  final CreditPlanSummary plan;
  final int lastSpent;

  const AgentPlanStatusCard({super.key, required this.plan, required this.lastSpent});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    return AppCardSurface(
      key: const ValueKey('agent-plan-status'),
      padding: const EdgeInsets.all(SpacingTokens.space5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StatusHeader(label: l10n.agentPlanOverline, kind: _kindLabel(l10n, plan.kind)),
          const SizedBox(height: SpacingTokens.space3),
          _Remaining(count: plan.remaining),
          if (plan.hasMonthlyAllowance) ...[
            const SizedBox(height: SpacingTokens.space4),
            _MonthlyMeter(plan: plan),
          ],
          const SizedBox(height: SpacingTokens.space4),
          _PlanFooter(plan: plan),
          AppText(l10n.agentPlanLastSpend(lastSpent), variant: AppTextVariant.caption, color: theme.colors.text.tertiary),
        ],
      ),
    );
  }
}

final class _StatusHeader extends StatelessWidget {
  final String label;
  final String kind;

  const _StatusHeader({required this.label, required this.kind});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Row(
      children: [
        Expanded(child: AppText(label, variant: AppTextVariant.overline, color: theme.colors.text.secondary)),
        DecoratedBox(
          decoration: BoxDecoration(color: theme.colors.surfaces.brandSubtle, borderRadius: const BorderRadius.all(Radius.circular(RadiusTokens.radiusFull))),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.space3, vertical: SpacingTokens.space1),
            child: AppText(kind, key: const ValueKey('agent-plan-kind'), variant: AppTextVariant.label),
          ),
        ),
      ],
    );
  }
}

final class _Remaining extends StatelessWidget {
  final int count;

  const _Remaining({required this.count});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: SpacingTokens.space2,
      children: [
        AppText('$count', key: const ValueKey('agent-plan-remaining'), variant: AppTextVariant.display),
        Padding(
          padding: const EdgeInsets.only(bottom: SpacingTokens.space2),
          child: AppText(l10n.agentPlanAvailable(count), variant: AppTextVariant.bodyLarge, color: theme.colors.text.secondary),
        ),
      ],
    );
  }
}

final class _MonthlyMeter extends StatelessWidget {
  final CreditPlanSummary plan;

  const _MonthlyMeter({required this.plan});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    return Semantics(
      label: l10n.agentPlanMeter,
      value: l10n.agentPlanMonthlyLeft(plan.monthlyRemaining, plan.allowance),
      child: ExcludeSemantics(
        child: LinearProgressIndicator(
          key: const ValueKey('agent-plan-meter'),
          value: plan.monthlyFraction,
          minHeight: SpacingTokens.space2,
          color: theme.colors.actions.primary.bgDefault,
          backgroundColor: theme.colors.surfaces.subtle,
          borderRadius: const BorderRadius.all(Radius.circular(RadiusTokens.radiusFull)),
        ),
      ),
    );
  }
}

final class _PlanFooter extends StatelessWidget {
  final CreditPlanSummary plan;

  const _PlanFooter({required this.plan});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final renewsAt = plan.renewsAt;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (plan.hasMonthlyAllowance) AppText(l10n.agentPlanMonthlyLeft(plan.monthlyRemaining, plan.allowance), variant: AppTextVariant.bodySmall),
        if (plan.hasTopUp) AppText(l10n.agentPlanTopUpLeft(plan.topUp), key: const ValueKey('agent-plan-top-up-left'), variant: AppTextVariant.bodySmall),
        if (renewsAt != null)
          AppText(l10n.agentCreditsRenews(MaterialLocalizations.of(context).formatMediumDate(renewsAt.toLocal())), key: const ValueKey('agent-plan-renews'), variant: AppTextVariant.bodySmall),
        const SizedBox(height: SpacingTokens.space2),
      ],
    );
  }
}
