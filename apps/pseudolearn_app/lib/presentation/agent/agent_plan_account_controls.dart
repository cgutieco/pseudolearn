import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/credits/agent_consent_cubit.dart';
import '../components/button/app_button.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/spacing.dart';
import 'agent_subscription_controls.dart';

final class AgentPlanAccountControls extends StatelessWidget {
  const AgentPlanAccountControls({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(l10n.agentPlanSubscriptionTitle, variant: AppTextVariant.label, color: theme.colors.text.secondary),
        const SizedBox(height: SpacingTokens.space2),
        const AgentSubscriptionControls(),
        const SizedBox(height: SpacingTokens.space2),
        const _ConsentControl(),
      ],
    );
  }
}

final class _ConsentControl extends StatelessWidget {
  const _ConsentControl();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<AgentConsentCubit, AgentConsentStatus>(
      builder: (context, status) => status == AgentConsentStatus.granted
          ? AppButton(
              key: const ValueKey('agent-withdraw-consent'),
              label: l10n.agentCreditsWithdrawConsent,
              variant: AppButtonVariant.tertiary,
              onPressed: () => context.read<AgentConsentCubit>().withdraw(),
            )
          : AppText(l10n.agentCreditsConsentWithdrawn, variant: AppTextVariant.caption),
    );
  }
}
