import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/credits/credits_cubit.dart';
import '../../application/credits/purchase_cubit.dart';
import '../../application/credits/purchase_state.dart';
import '../../domain/model/credits/agent_product.dart';
import '../../domain/model/credits/credit_failure.dart';
import '../components/button/app_button.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/tokens/spacing.dart';
import 'agent_labels.dart';

final class AgentTopUpButton extends StatelessWidget {
  final String keyPrefix;

  const AgentTopUpButton({super.key, required this.keyPrefix});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topUpNeedsPlan = context.select<CreditsCubit, bool>((cubit) => cubit.state.topUpNeedsPlan);
    final sells = context.select<PurchaseCubit, bool>((cubit) => cubit.state.channel.sells);
    final price = context.select<PurchaseCubit, String?>((cubit) => cubit.state.priceOf(AgentProduct.topUp));
    final busy = context.select<PurchaseCubit, bool>((cubit) => cubit.state.status == PurchaseStatus.purchasing);
    if (!sells) {
      return AppText(l10n.agentCreditsTopUpUnavailable, key: ValueKey('$keyPrefix-unavailable'), variant: AppTextVariant.caption);
    }
    if (topUpNeedsPlan) {
      return AppText(l10n.agentCreditsTopUpNeedsPlan, key: ValueKey('$keyPrefix-needs-plan'), variant: AppTextVariant.caption);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton(
          key: ValueKey(keyPrefix),
          label: price == null ? l10n.agentCreditsTopUp : l10n.agentCreditsTopUpPrice(price),
          variant: AppButtonVariant.primary,
          onPressed: busy ? null : () => context.read<PurchaseCubit>().buy(AgentProduct.topUp),
        ),
        _TopUpNotice(keyPrefix: keyPrefix),
      ],
    );
  }
}

final class _TopUpNotice extends StatelessWidget {
  final String keyPrefix;

  const _TopUpNotice({required this.keyPrefix});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final failure = context.select<PurchaseCubit, CreditFailure?>((cubit) => cubit.state.topUpFailure);
    final awaiting = context.select<PurchaseCubit, bool>((cubit) => cubit.state.awaitsStorePayment(AgentProduct.topUp));
    final text = failure != null ? agentFailureText(l10n, failure) : (awaiting ? l10n.agentPurchaseAwaitingStorePayment : null);
    if (text == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: SpacingTokens.space2),
      child: AppText(text, key: ValueKey(failure != null ? '$keyPrefix-failure' : '$keyPrefix-awaiting-store'), variant: AppTextVariant.caption),
    );
  }
}
