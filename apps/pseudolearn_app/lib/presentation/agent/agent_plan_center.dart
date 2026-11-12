import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/agent/agent_session_cubit.dart';
import '../../application/agent/agent_session_state.dart';
import '../../application/credits/credits_cubit.dart';
import '../../application/credits/credits_state.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/spacing.dart';
import 'agent_labels.dart';
import 'agent_launcher_preference.dart';
import 'agent_offer_products.dart';
import 'agent_plan_account_controls.dart';
import 'agent_plan_status_card.dart';
import 'agent_plan_top_up.dart';

final class AgentPlanCenter extends StatelessWidget {
  const AgentPlanCenter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreditsCubit, CreditsState>(
      builder: (context, credits) => BlocBuilder<AgentSessionCubit, AgentSessionState>(
        builder: (context, session) => _PlanCenterBody(
          credits: credits,
          lastSpent: credits.lastRequestSpent > 0 ? credits.lastRequestSpent : session.lastRequestSpent,
        ),
      ),
    );
  }
}

final class _PlanCenterBody extends StatelessWidget {
  final CreditsState credits;
  final int lastSpent;

  const _PlanCenterBody({required this.credits, required this.lastSpent});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    final plan = credits.plan;
    final failure = credits.failure;
    return RefreshIndicator(
      key: const ValueKey('agent-plan-refresh'),
      color: theme.colors.actions.primary.bgDefault,
      onRefresh: context.read<CreditsCubit>().refresh,
      child: ListView(
        key: const ValueKey('agent-plan-center'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: SpacingTokens.space20),
        children: [
          if (plan != null) AgentPlanStatusCard(plan: plan, lastSpent: lastSpent),
          if (failure != null) ...[
            const SizedBox(height: SpacingTokens.space2),
            AppText(agentFailureText(l10n, failure), variant: AppTextVariant.caption),
          ],
          const SizedBox(height: SpacingTokens.space6),
          if (credits.topUpNeedsPlan) const _LapsedOffer() else const AgentPlanTopUp(),
          const SizedBox(height: SpacingTokens.space6),
          const AgentLauncherPreference(),
          const SizedBox(height: SpacingTokens.space6),
          const AgentPlanAccountControls(),
        ],
      ),
    );
  }
}

final class _LapsedOffer extends StatelessWidget {
  const _LapsedOffer();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      key: const ValueKey('agent-plan-lapsed'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(l10n.agentPlanLapsed, variant: AppTextVariant.bodyDefault),
        const SizedBox(height: SpacingTokens.space4),
        const AgentOfferProducts(),
      ],
    );
  }
}
