import 'package:material_ui/material_ui.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/tokens/spacing.dart';
import 'agent_top_up_button.dart';

final class AgentCreditsExhausted extends StatelessWidget {
  const AgentCreditsExhausted({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      key: const ValueKey('agent-exhausted'),
      padding: const EdgeInsets.all(SpacingTokens.space3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(l10n.agentCreditsExhaustedTitle, variant: AppTextVariant.label),
          AppText(l10n.agentFailureCreditsExhausted, variant: AppTextVariant.bodySmall),
          const SizedBox(height: SpacingTokens.space2),
          const AgentTopUpButton(keyPrefix: 'agent-top-up'),
        ],
      ),
    );
  }
}
