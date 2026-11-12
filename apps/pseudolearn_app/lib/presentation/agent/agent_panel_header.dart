import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/agent/agent_session_cubit.dart';
import '../components/button/app_button.dart';
import '../components/button/app_icon_button.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/spacing.dart';
import 'agent_glyph.dart';
import 'agent_glyph_painter.dart';

final class AgentPanelHeader extends StatelessWidget {
  const AgentPanelHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    return Padding(
      padding: const EdgeInsets.all(SpacingTokens.space3),
      child: Row(
        children: [
          AgentGlyph(state: AgentGlyphState.idle, color: theme.colors.actions.primary.bgDefault),
          const SizedBox(width: SpacingTokens.space2),
          Expanded(
            child: AppText('${l10n.agentName} · ${l10n.agentAiBadge}', variant: AppTextVariant.heading4),
          ),
          AppIconButton(
            icon: Icons.refresh_rounded,
            semanticLabel: l10n.agentNewConversation,
            variant: AppButtonVariant.tertiary,
            onPressed: () => context.read<AgentSessionCubit>().startOver(),
          ),
          AppIconButton(
            icon: Icons.close_rounded,
            semanticLabel: l10n.agentClose,
            variant: AppButtonVariant.tertiary,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }
}
