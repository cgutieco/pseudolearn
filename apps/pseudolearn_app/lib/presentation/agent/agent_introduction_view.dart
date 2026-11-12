import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../components/button/app_button.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/spacing.dart';
import 'agent_introduction_parts.dart';
import 'agent_offer_products.dart';

final class AgentIntroductionView extends StatelessWidget {
  final bool signedIn;

  const AgentIntroductionView({super.key, required this.signedIn});

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('agent-introduction'),
      padding: const EdgeInsets.only(bottom: SpacingTokens.space20),
      children: [
        const AgentIntroductionHero(),
        const SizedBox(height: SpacingTokens.space6),
        const AgentIntroductionBenefits(),
        const SizedBox(height: SpacingTokens.space6),
        const AgentIntroductionCredits(),
        const SizedBox(height: SpacingTokens.space6),
        if (signedIn) const AgentOfferProducts() else const _SignInCall(),
      ],
    );
  }
}

final class _SignInCall extends StatelessWidget {
  const _SignInCall();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton(
          key: const ValueKey('agent-sign-in'),
          label: l10n.agentOfferSignIn,
          variant: AppButtonVariant.primary,
          onPressed: () => context.push('/ajustes/cuenta'),
        ),
        const SizedBox(height: SpacingTokens.space2),
        AppText(l10n.agentIntroSignInNote, variant: AppTextVariant.caption, color: theme.colors.text.secondary, textAlign: TextAlign.center),
      ],
    );
  }
}
