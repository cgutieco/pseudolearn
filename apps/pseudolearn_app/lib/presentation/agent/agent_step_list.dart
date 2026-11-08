import 'package:flutter/material.dart';
import '../../domain/model/agent/agent_turn_step.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import 'agent_labels.dart';

final class AgentStepList extends StatelessWidget {
  final List<AgentTurnStep> steps;

  const AgentStepList({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      type: MaterialType.transparency,
      child: ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: AppText(l10n.agentStepsTitle(steps.length), variant: AppTextVariant.caption),
      children: [
        for (final step in steps)
          ListTile(
            dense: true,
            leading: Icon(_iconOf(step.status)),
            title: AppText(agentStepText(l10n, step.label), variant: AppTextVariant.bodySmall),
            subtitle: step.status == AgentStepStatus.succeeded ? null : _StepStatus(status: step.status),
          ),
      ],
      ),
    );
  }

  IconData _iconOf(AgentStepStatus status) => switch (status) {
    AgentStepStatus.succeeded => Icons.check_circle_outline_rounded,
    AgentStepStatus.failed => Icons.error_outline_rounded,
    AgentStepStatus.declined => Icons.block_rounded,
  };
}

final class _StepStatus extends StatelessWidget {
  final AgentStepStatus status;

  const _StepStatus({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final text = status == AgentStepStatus.declined ? l10n.agentStepDeclined : l10n.agentStepFailed;
    return AppText(text, variant: AppTextVariant.caption);
  }
}
