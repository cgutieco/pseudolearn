import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/credits/credits_cubit.dart';
import '../../application/credits/purchase_cubit.dart';
import '../../domain/model/credits/agent_product.dart';
import '../components/button/app_button.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/tokens/spacing.dart';

final class AgentCreditsExhausted extends StatelessWidget {
  const AgentCreditsExhausted({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topUpNeedsPlan = context.select<CreditsCubit, bool>((cubit) => cubit.state.topUpNeedsPlan);
    return Padding(
      key: const ValueKey('agent-exhausted'),
      padding: const EdgeInsets.all(SpacingTokens.space3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(l10n.agentCreditsExhaustedTitle, variant: AppTextVariant.label),
          AppText(l10n.agentFailureCreditsExhausted, variant: AppTextVariant.bodySmall),
          const SizedBox(height: SpacingTokens.space2),
          if (topUpNeedsPlan)
            AppText(l10n.agentCreditsTopUpNeedsPlan, key: const ValueKey('agent-top-up-needs-plan'), variant: AppTextVariant.caption)
          else
            AppButton(
              key: const ValueKey('agent-top-up'),
              label: l10n.agentCreditsTopUp,
              variant: AppButtonVariant.primary,
              onPressed: () => context.read<PurchaseCubit>().buy(AgentProduct.topUp),
            ),
        ],
      ),
    );
  }
}
