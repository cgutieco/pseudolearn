import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../application/agent/agent_session_cubit.dart';
import '../../application/agent/agent_session_state.dart';
import '../../application/credits/agent_consent_cubit.dart';
import '../../application/credits/credits_cubit.dart';
import '../../application/credits/credits_state.dart';
import '../../application/credits/purchase_cubit.dart';
import '../../domain/model/credits/agent_product.dart';
import '../components/button/app_button.dart';
import '../components/layout/app_page.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/spacing.dart';
import 'agent_labels.dart';

final class AgentSettingsPage extends StatefulWidget {
  const AgentSettingsPage({super.key});

  @override
  State<AgentSettingsPage> createState() => _AgentSettingsPageState();
}

final class _AgentSettingsPageState extends State<AgentSettingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<CreditsCubit>().refresh();
    context.read<AgentConsentCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    return Scaffold(
      backgroundColor: theme.colors.surfaces.canvas,
      body: AppPage(
        title: l10n.agentCreditsTitle,
        measure: ContentMeasure.form,
        onBack: () => context.pop(),
        backSemanticLabel: l10n.settingsBack,
        body: BlocBuilder<CreditsCubit, CreditsState>(
          builder: (context, credits) => BlocBuilder<AgentSessionCubit, AgentSessionState>(
            builder: (context, session) => _CreditsBody(credits: credits, lastSpent: session.lastRequestSpent),
          ),
        ),
      ),
    );
  }
}

final class _CreditsBody extends StatelessWidget {
  final CreditsState credits;
  final int lastSpent;

  const _CreditsBody({required this.credits, required this.lastSpent});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final balance = credits.balance;
    final renewsAt = balance?.renewsAt;
    final failure = credits.failure;
    return ListView(
      children: [
        AppText(balance == null ? l10n.agentCreditsUnknown : l10n.agentCreditsRemaining(balance.remaining), variant: AppTextVariant.heading3),
        if (balance != null && balance.trial) AppText(l10n.agentCreditsTrial, variant: AppTextVariant.label),
        if (renewsAt != null) AppText(l10n.agentCreditsRenews(MaterialLocalizations.of(context).formatMediumDate(renewsAt.toLocal())), variant: AppTextVariant.bodySmall),
        AppText(l10n.agentCreditsLastSpend(credits.lastRequestSpent > 0 ? credits.lastRequestSpent : lastSpent), variant: AppTextVariant.bodySmall),
        if (failure != null) AppText(agentFailureText(l10n, failure), variant: AppTextVariant.caption),
        const SizedBox(height: SpacingTokens.space4),
        AppButton(key: const ValueKey('agent-settings-top-up'), label: l10n.agentCreditsTopUp, variant: AppButtonVariant.primary, onPressed: () => context.read<PurchaseCubit>().buy(AgentProduct.topUp)),
        const SizedBox(height: SpacingTokens.space2),
        AppButton(label: l10n.agentCreditsRefresh, variant: AppButtonVariant.secondary, onPressed: () => context.read<CreditsCubit>().refresh()),
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
