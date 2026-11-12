import 'package:flutter/material.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/spacing.dart';
import 'agent_top_up_button.dart';

final class AgentPlanTopUp extends StatelessWidget {
  const AgentPlanTopUp({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(l10n.agentPlanTopUpTitle, variant: AppTextVariant.heading4),
        const SizedBox(height: SpacingTokens.space1),
        AppText(l10n.agentPlanTopUpBody, variant: AppTextVariant.bodySmall, color: theme.colors.text.secondary),
        const SizedBox(height: SpacingTokens.space3),
        const AgentTopUpButton(keyPrefix: 'agent-settings-top-up'),
      ],
    );
  }
}
