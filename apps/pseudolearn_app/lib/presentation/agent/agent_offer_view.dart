import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../application/credits/credits_cubit.dart';
import '../../application/credits/credits_state.dart';
import '../../application/credits/purchase_cubit.dart';
import '../../application/credits/purchase_state.dart';
import '../../domain/model/credits/agent_product.dart';
import '../components/button/app_button.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/tokens/spacing.dart';
import 'agent_labels.dart';

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
          const _Products(),
      ],
    );
  }
}

final class _Products extends StatelessWidget {
  const _Products();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final purchases = context.read<PurchaseCubit>();
    return BlocBuilder<PurchaseCubit, PurchaseState>(
      builder: (context, purchase) => BlocBuilder<CreditsCubit, CreditsState>(
        builder: (context, credits) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!credits.trialUsed)
              AppButton(key: const ValueKey('agent-buy-trial'), label: l10n.agentOfferTrial, variant: AppButtonVariant.primary, onPressed: () => purchases.buy(AgentProduct.trial)),
            const SizedBox(height: SpacingTokens.space2),
            AppButton(key: const ValueKey('agent-buy-monthly'), label: l10n.agentOfferMonthly, variant: AppButtonVariant.secondary, onPressed: () => purchases.buy(AgentProduct.monthly)),
            const SizedBox(height: SpacingTokens.space2),
            AppText(l10n.agentOfferSimulated, variant: AppTextVariant.caption),
            if (purchase.failure != null) AppText(agentFailureText(l10n, purchase.failure!), variant: AppTextVariant.caption),
          ],
        ),
      ),
    );
  }
}
