import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/agent/agent_session_cubit.dart';
import '../../application/agent/agent_session_state.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/spacing.dart';
import 'agent_composer.dart';
import 'agent_confirmation_bar.dart';
import 'agent_credits_exhausted.dart';
import 'agent_labels.dart';
import 'agent_message_bubble.dart';
import 'agent_step_list.dart';

final class AgentConversation extends StatelessWidget {
  final AgentSessionState session;
  final bool composerBlocked;

  const AgentConversation({super.key, required this.session, required this.composerBlocked});

  @override
  Widget build(BuildContext context) {
    final confirmation = session.confirmation;
    return Column(
      children: [
        Expanded(child: _Messages(session: session)),
        if (confirmation != null) AgentConfirmationBar(confirmation: confirmation),
        if (composerBlocked)
          const AgentCreditsExhausted()
        else
          AgentComposer(
            enabled: !session.isBusy && confirmation == null,
            onSend: context.read<AgentSessionCubit>().send,
          ),
      ],
    );
  }
}

final class _Messages extends StatelessWidget {
  final AgentSessionState session;

  const _Messages({required this.session});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final failure = session.failure;
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(SpacingTokens.space3),
      children: [
        if (session.messages.isEmpty) const _EmptyConversation(),
        for (final message in session.messages) AgentMessageBubble(message: message),
        if (session.liveSteps.isNotEmpty) AgentStepList(steps: session.liveSteps),
        if (session.isBusy) _Notice(text: l10n.agentThinking, live: true),
        if (failure != null) _Notice(text: agentFailureText(l10n, failure), live: true),
        if (session.status == AgentSessionStatus.exhausted) _Notice(text: l10n.agentExhausted, live: true),
      ],
    );
  }
}

final class _EmptyConversation extends StatelessWidget {
  const _EmptyConversation();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(l10n.agentEmptyTitle, variant: AppTextVariant.heading4),
        const SizedBox(height: SpacingTokens.space2),
        AppText(l10n.agentEmptyBody, variant: AppTextVariant.bodySmall),
      ],
    );
  }
}

final class _Notice extends StatelessWidget {
  final String text;
  final bool live;

  const _Notice({required this.text, this.live = false});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.space2),
      child: Semantics(
        liveRegion: live,
        child: AppText(text, variant: AppTextVariant.bodySmall, color: theme.colors.text.secondary),
      ),
    );
  }
}
