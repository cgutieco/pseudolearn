import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../application/agent/agent_session_cubit.dart';
import '../../application/agent/agent_session_state.dart';
import '../../application/credits/credits_cubit.dart';
import '../l10n/generated/app_localizations.dart';
import '../shell/design_canvas.dart';
import '../shell/device_class.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/radii.dart';
import '../theme/tokens/spacing.dart';
import 'agent_chat_panel.dart';
import 'agent_glyph.dart';
import 'agent_glyph_painter.dart';

const String _editorRoutePrefix = '/biblioteca/documento/';

AgentGlyphState glyphStateOf(AgentSessionState state) => switch (state) {
  AgentSessionState(isBusy: true) => AgentGlyphState.thinking,
  AgentSessionState(blocksComposer: true) => AgentGlyphState.noCredits,
  AgentSessionState(hasUnseenReply: true) => AgentGlyphState.newReply,
  _ => AgentGlyphState.idle,
};

final class AgentLauncher extends StatelessWidget {
  const AgentLauncher({super.key});

  void _open(BuildContext context) {
    context.read<AgentSessionCubit>().markSeen();
    context.read<CreditsCubit>().refresh();
    openAgentChat(context);
  }

  @override
  Widget build(BuildContext context) {
    final delegate = GoRouter.of(context).routerDelegate;
    return ListenableBuilder(
      listenable: delegate,
      builder: (context, _) => _PlacedLauncher(
        aboveFooter: delegate.currentConfiguration.uri.path.startsWith(_editorRoutePrefix),
        onOpen: () => _open(context),
      ),
    );
  }
}

final class _PlacedLauncher extends StatelessWidget {
  final bool aboveFooter;
  final VoidCallback onOpen;

  const _PlacedLauncher({required this.aboveFooter, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    if (canvas.isKeyboardVisible) return const SizedBox.shrink();
    return Positioned(
      right: canvas.scaled(SpacingTokens.space4),
      bottom: canvas.scaled(aboveFooter ? SpacingTokens.space20 : SpacingTokens.space4),
      child: BlocBuilder<AgentSessionCubit, AgentSessionState>(
        builder: (context, state) => _LauncherButton(
          compact: canvas.deviceClass == DeviceClass.compact,
          glyph: glyphStateOf(state),
          onPressed: onOpen,
        ),
      ),
    );
  }
}

final class _LauncherButton extends StatelessWidget {
  final bool compact;
  final AgentGlyphState glyph;
  final VoidCallback onPressed;

  const _LauncherButton({required this.compact, required this.glyph, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extent = compact ? SpacingTokens.space12 + SpacingTokens.space2 : SpacingTokens.space12;
    return Semantics(
      key: const ValueKey('feature:agent'),
      button: true,
      label: l10n.agentOpen,
      child: Material(
        color: theme.colors.actions.primary.bgDefault,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(RadiusTokens.radiusFull))),
        elevation: 3,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox.square(
            dimension: extent,
            child: Center(child: AgentGlyph(state: glyph, color: theme.colors.text.onBrand)),
          ),
        ),
      ),
    );
  }
}
