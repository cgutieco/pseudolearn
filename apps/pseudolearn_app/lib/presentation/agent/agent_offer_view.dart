import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../components/button/app_button.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/tokens/spacing.dart';
import 'agent_offer_products.dart';

final class AgentOfferView extends StatelessWidget {
  final bool signedIn;

  const AgentOfferView({super.key, required this.signedIn});

  void _signIn(BuildContext context) {
    Navigator.of(context).maybePop();
    context.go('/ajustes/cuenta');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      key: const ValueKey('agent-offer'),
      padding: const EdgeInsets.all(SpacingTokens.space4),
      children: [
        AppText(l10n.agentOfferTitle, variant: AppTextVariant.heading3),
        const SizedBox(height: SpacingTokens.space2),
        AppText(l10n.agentOfferBody, variant: AppTextVariant.bodyDefault),
        const SizedBox(height: SpacingTokens.space4),
        if (!signedIn)
          AppButton(key: const ValueKey('agent-sign-in'), label: l10n.agentOfferSignIn, variant: AppButtonVariant.primary, onPressed: () => _signIn(context))
        else
          const AgentOfferProducts(),
      ],
    );
  }
}
