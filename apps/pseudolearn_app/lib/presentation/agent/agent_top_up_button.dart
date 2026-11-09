import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/credits/credits_cubit.dart';
import '../../application/credits/purchase_cubit.dart';
import '../../application/credits/purchase_state.dart';
import '../../domain/model/credits/agent_product.dart';
import '../components/button/app_button.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';

final class AgentTopUpButton extends StatelessWidget {
  final String keyPrefix;

  const AgentTopUpButton({super.key, required this.keyPrefix});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topUpNeedsPlan = context.select<CreditsCubit, bool>((cubit) => cubit.state.topUpNeedsPlan);
    final price = context.select<PurchaseCubit, String?>((cubit) => cubit.state.priceOf(AgentProduct.topUp));
    final busy = context.select<PurchaseCubit, bool>((cubit) => cubit.state.status == PurchaseStatus.purchasing);
    if (topUpNeedsPlan) {
      return AppText(l10n.agentCreditsTopUpNeedsPlan, key: ValueKey('$keyPrefix-needs-plan'), variant: AppTextVariant.caption);
    }
    return AppButton(
      key: ValueKey(keyPrefix),
      label: price == null ? l10n.agentCreditsTopUp : l10n.agentCreditsTopUpPrice(price),
      variant: AppButtonVariant.primary,
      onPressed: busy ? null : () => context.read<PurchaseCubit>().buy(AgentProduct.topUp),
    );
  }
}
