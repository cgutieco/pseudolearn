import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/credits/purchase_cubit.dart';
import '../../domain/model/credits/legal_document.dart';
import '../components/button/app_button.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/tokens/spacing.dart';

final class AgentOfferTerms extends StatelessWidget {
  const AgentOfferTerms({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final purchases = context.read<PurchaseCubit>();
    final language = Localizations.localeOf(context).languageCode;
    return Padding(
      padding: const EdgeInsets.only(top: SpacingTokens.space3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(l10n.agentOfferLegal, key: const ValueKey('agent-offer-legal'), variant: AppTextVariant.caption),
          Wrap(
            spacing: SpacingTokens.space2,
            children: [
              AppButton(key: const ValueKey('agent-offer-terms'), label: l10n.agentOfferTerms, variant: AppButtonVariant.tertiary, onPressed: () => purchases.openLegal(LegalDocument.terms, language)),
              AppButton(key: const ValueKey('agent-offer-privacy'), label: l10n.agentOfferPrivacy, variant: AppButtonVariant.tertiary, onPressed: () => purchases.openLegal(LegalDocument.privacy, language)),
              if (purchases.state.channel.restoresPurchases)
                AppButton(key: const ValueKey('agent-offer-restore'), label: l10n.agentCreditsRestore, variant: AppButtonVariant.tertiary, onPressed: purchases.restore),
            ],
          ),
        ],
      ),
    );
  }
}
