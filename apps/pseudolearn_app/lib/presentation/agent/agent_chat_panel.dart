import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/account/account_cubit.dart';
import '../../application/account/account_state.dart';
import '../../application/agent/agent_access.dart';
import '../../application/agent/agent_session_cubit.dart';
import '../../application/agent/agent_session_state.dart';
import '../../application/credits/credits_cubit.dart';
import '../../application/credits/credits_state.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/radii.dart';
import 'agent_consent_view.dart';
import 'agent_conversation.dart';
import 'agent_offer_view.dart';
import 'agent_panel_header.dart';

final class AgentChatPanel extends StatelessWidget {
  const AgentChatPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Material(
      key: const ValueKey('agent-chat-panel'),
      color: theme.colors.surfaces.defaultSurface,
      borderRadius: const BorderRadius.all(Radius.circular(RadiusTokens.radiusLg)),
      clipBehavior: Clip.antiAlias,
      child: const SafeArea(
        top: false,
        child: Column(
          children: [
            AgentPanelHeader(),
            Expanded(child: _AccessSwitch()),
          ],
        ),
      ),
    );
  }
}

final class _AccessSwitch extends StatelessWidget {
  const _AccessSwitch();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountCubit, AccountState>(
      builder: (context, account) => BlocBuilder<CreditsCubit, CreditsState>(
        builder: (context, credits) => BlocBuilder<AgentSessionCubit, AgentSessionState>(
          builder: (context, session) => switch (agentAccessOf(
            signedIn: account is AccountAuthenticated,
            credits: credits,
            session: session,
          )) {
            AgentAccessView.signIn => const AgentOfferView(signedIn: false),
            AgentAccessView.offer => const AgentOfferView(signedIn: true),
            AgentAccessView.consent => const AgentConsentView(),
            AgentAccessView.conversation => AgentConversation(
              session: session,
              composerBlocked: agentComposerBlocked(credits, session),
            ),
          },
        ),
      ),
    );
  }
}
