import 'package:flutter/material.dart';
import '../components/button/app_button.dart';
import '../components/button/app_icon_button.dart';
import '../components/field/app_text_field.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/tokens/spacing.dart';

final class AgentComposer extends StatefulWidget {
  final bool enabled;
  final ValueChanged<String> onSend;

  const AgentComposer({super.key, required this.enabled, required this.onSend});

  @override
  State<AgentComposer> createState() => _AgentComposerState();
}

final class _AgentComposerState extends State<AgentComposer> {
  final TextEditingController _controller = TextEditingController();

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty || !widget.enabled) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(SpacingTokens.space3),
      child: Row(
        children: [
          Expanded(
            child: AppTextField(
              key: const ValueKey('agent-composer'),
              controller: _controller,
              placeholder: l10n.agentComposerHint,
              semanticLabel: l10n.agentComposerHint,
              enabled: widget.enabled,
              onSubmitted: (_) => _send(),
            ),
          ),
          const SizedBox(width: SpacingTokens.space2),
          AppIconButton(
            key: const ValueKey('agent-send'),
            icon: Icons.arrow_upward_rounded,
            semanticLabel: l10n.agentSend,
            variant: AppButtonVariant.primary,
            onPressed: widget.enabled ? _send : null,
          ),
        ],
      ),
    );
  }
}
