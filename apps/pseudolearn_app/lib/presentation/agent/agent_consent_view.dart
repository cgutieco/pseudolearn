import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/agent/agent_session_cubit.dart';
import '../../application/credits/agent_consent_cubit.dart';
import '../components/button/app_button.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/tokens/spacing.dart';

final class AgentConsentView extends StatelessWidget {
  const AgentConsentView({super.key});

  void _accept(BuildContext context) {
    final session = context.read<AgentSessionCubit>();
    context.read<AgentConsentCubit>().grant().then((_) => session.resumeAfterConsent());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      key: const ValueKey('agent-consent'),
      padding: const EdgeInsets.all(SpacingTokens.space4),
      children: [
        AppText(l10n.agentConsentTitle, variant: AppTextVariant.heading3),
        const SizedBox(height: SpacingTokens.space2),
        AppText(l10n.agentConsentBody, variant: AppTextVariant.bodyDefault),
        const SizedBox(height: SpacingTokens.space2),
        AppText(l10n.agentConsentAge, variant: AppTextVariant.bodySmall),
        const SizedBox(height: SpacingTokens.space4),
        AppButton(key: const ValueKey('agent-consent-accept'), label: l10n.agentConsentAccept, variant: AppButtonVariant.primary, onPressed: () => _accept(context)),
        const SizedBox(height: SpacingTokens.space2),
        AppButton(label: l10n.agentConsentDecline, variant: AppButtonVariant.tertiary, onPressed: () => Navigator.of(context).maybePop()),
      ],
    );
  }
}
