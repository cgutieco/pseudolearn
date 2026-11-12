import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'agent_offer_terms.dart';

final class AgentOfferProducts extends StatelessWidget {
  const AgentOfferProducts({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final purchases = context.read<PurchaseCubit>();
    return BlocBuilder<PurchaseCubit, PurchaseState>(
      builder: (context, purchase) => BlocBuilder<CreditsCubit, CreditsState>(
        builder: (context, credits) {
          final ownTrial = purchase.channel.sellsOwnTrial && !credits.trialUsed;
          final busy = purchase.status == PurchaseStatus.purchasing;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PlanPrice(purchase: purchase, trialAvailable: !credits.trialUsed),
              const SizedBox(height: SpacingTokens.space3),
              if (ownTrial)
                AppButton(key: const ValueKey('agent-buy-trial'), label: l10n.agentOfferTrial, variant: AppButtonVariant.primary, onPressed: busy ? null : () => purchases.buy(AgentProduct.trial)),
              const SizedBox(height: SpacingTokens.space2),
              AppButton(key: const ValueKey('agent-buy-monthly'), label: purchase.channel.sellsOwnTrial ? l10n.agentOfferMonthly : l10n.agentOfferSubscribe, variant: ownTrial ? AppButtonVariant.secondary : AppButtonVariant.primary, onPressed: busy ? null : () => purchases.buy(AgentProduct.monthly)),
              _PurchaseNotice(purchase: purchase),
              const AgentOfferTerms(),
            ],
          );
        },
      ),
    );
  }
}

final class _PlanPrice extends StatelessWidget {
  final PurchaseState purchase;
  final bool trialAvailable;

  const _PlanPrice({required this.purchase, required this.trialAvailable});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final price = purchase.priceOf(AgentProduct.monthly);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (price != null)
          AppText(l10n.agentOfferPriceMonthly(price), key: const ValueKey('agent-offer-price'), variant: AppTextVariant.heading2)
        else if (purchase.channel.quotesPriceAtCheckout)
          AppText(l10n.agentOfferPriceAtCheckout, key: const ValueKey('agent-offer-price-at-checkout'), variant: AppTextVariant.bodyDefault)
        else if (!purchase.channel.sellsOwnTrial)
          AppText(l10n.agentOfferPricePending, key: const ValueKey('agent-offer-price-pending'), variant: AppTextVariant.bodyDefault),
        if (trialAvailable && !purchase.channel.sellsOwnTrial)
          AppText(l10n.agentOfferTrialIncluded, key: const ValueKey('agent-offer-trial-included'), variant: AppTextVariant.bodySmall),
      ],
    );
  }
}

final class _PurchaseNotice extends StatelessWidget {
  final PurchaseState purchase;

  const _PurchaseNotice({required this.purchase});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final failure = purchase.failure;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (purchase.status == PurchaseStatus.continuesOutside) ...[
          AppText(l10n.agentPurchaseContinuesOutside, key: const ValueKey('agent-purchase-outside'), variant: AppTextVariant.caption),
          AppButton(label: l10n.agentCreditsRefresh, variant: AppButtonVariant.tertiary, onPressed: () => context.read<CreditsCubit>().refresh()),
        ],
        if (purchase.channel.sellsOwnTrial) AppText(l10n.agentOfferSimulated, variant: AppTextVariant.caption),
        if (failure != null) AppText(agentFailureText(l10n, failure), variant: AppTextVariant.caption),
      ],
    );
  }
}
