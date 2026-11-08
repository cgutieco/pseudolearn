import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/agent/agent_session_cubit.dart';
import '../../application/agent/agent_session_state.dart';
import '../../domain/model/agent/tool_definition.dart';
import '../components/button/app_button.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/spacing.dart';
import 'agent_labels.dart';

final class AgentConfirmationBar extends StatelessWidget {
  final PendingConfirmation confirmation;

  const AgentConfirmationBar({super.key, required this.confirmation});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    final cubit = context.read<AgentSessionCubit>();
    return Container(
      key: const ValueKey('agent-confirmation'),
      color: theme.colors.surfaces.raised,
      padding: const EdgeInsets.all(SpacingTokens.space3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(l10n.agentConfirmTitle(agentStepText(l10n, confirmation.label)), variant: AppTextVariant.label),
          if (confirmation.risk == ToolRisk.destructive)
            AppText(l10n.agentConfirmDestructive, variant: AppTextVariant.caption, color: theme.colors.severities.error.fg),
          _Preview(arguments: confirmation.arguments),
          Wrap(
            spacing: SpacingTokens.space2,
            children: [
              AppButton(key: const ValueKey('agent-approve'), label: l10n.agentConfirmApprove, variant: AppButtonVariant.primary, destructive: confirmation.risk == ToolRisk.destructive, onPressed: () => cubit.answerConfirmation(approved: true)),
              AppButton(key: const ValueKey('agent-decline'), label: l10n.agentConfirmDecline, variant: AppButtonVariant.tertiary, onPressed: () => cubit.answerConfirmation(approved: false)),
            ],
          ),
        ],
      ),
    );
  }
}

final class _Preview extends StatelessWidget {
  final Map<String, Object?> arguments;

  const _Preview({required this.arguments});

  @override
  Widget build(BuildContext context) {
    final preview = const JsonEncoder.withIndent('  ').convert(arguments);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: SpacingTokens.space20 * 2),
      child: SingleChildScrollView(
        child: SelectableText(preview, style: resolveAppTextStyle(context, AppTextVariant.codeEditor)),
      ),
    );
  }
}
