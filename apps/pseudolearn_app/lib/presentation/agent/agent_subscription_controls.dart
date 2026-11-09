import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/credits/credits_cubit.dart';
import '../../application/credits/credits_state.dart';
import '../../application/credits/purchase_cubit.dart';
import '../../application/credits/purchase_state.dart';
import '../components/button/app_button.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/tokens/spacing.dart';
import 'agent_labels.dart';

final class AgentSubscriptionControls extends StatelessWidget {
  const AgentSubscriptionControls({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final purchases = context.read<PurchaseCubit>();
    return BlocBuilder<PurchaseCubit, PurchaseState>(
      builder: (context, purchase) => BlocBuilder<CreditsCubit, CreditsState>(
        builder: (context, credits) {
          final managedBy = credits.balance?.managedBy;
          final elsewhere = managedBy != null && managedBy != purchase.channel;
          final manageable = credits.periodActive && !elsewhere && purchase.channel.managesSubscriptions;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (elsewhere)
                AppText(l10n.agentCreditsManagedElsewhere(agentStoreName(l10n, managedBy)), key: const ValueKey('agent-managed-elsewhere'), variant: AppTextVariant.caption),
              if (manageable)
                AppButton(key: const ValueKey('agent-manage-subscription'), label: l10n.agentCreditsManage, variant: AppButtonVariant.secondary, onPressed: purchases.manageSubscription),
              if (purchase.channel.restoresPurchases) ...[
                const SizedBox(height: SpacingTokens.space2),
                AppButton(key: const ValueKey('agent-restore-purchases'), label: l10n.agentCreditsRestore, variant: AppButtonVariant.tertiary, onPressed: purchases.restore),
              ],
            ],
          );
        },
      ),
    );
  }
}
