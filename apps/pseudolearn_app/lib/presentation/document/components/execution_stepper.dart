import 'package:flutter/material.dart';
import '../../../application/execution/execution_state.dart';
import '../../../application/execution/step_pace.dart';
import '../../components/button/app_button.dart';
import '../../components/button/app_icon_button.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../shell/device_class.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import 'debug_controls.dart';
import 'idle_controls.dart';

final class ExecutionStepper extends StatelessWidget {
  final ExecutionState state;
  final bool isExecutable;
  final void Function(StepPace) onPace;
  final VoidCallback onStop;

  const ExecutionStepper({
    super.key,
    required this.state,
    required this.isExecutable,
    required this.onPace,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.space4, vertical: SpacingTokens.space2),
      decoration: BoxDecoration(color: theme.colors.surfaces.raised, boxShadow: theme.elevation.level2),
      child: Row(
        children: [
          _PaceControls(state: state, isExecutable: isExecutable, onPace: onPace),
          const SizedBox(width: SpacingTokens.space2),
          _StopControl(isActive: state.isInFlight, onStop: onStop),
          const SizedBox(width: SpacingTokens.space2),
          Expanded(child: _StatusReadout(state: state)),
        ],
      ),
    );
  }
}

final class _PaceControls extends StatelessWidget {
  final ExecutionState state;
  final bool isExecutable;
  final void Function(StepPace) onPace;

  const _PaceControls({
    required this.state,
    required this.isExecutable,
    required this.onPace,
  });

  @override
  Widget build(BuildContext context) {
    if (!state.isInFlight) {
      return IdleControls(canExecute: isExecutable && state.canStart, onPace: onPace);
    }
    return DebugControls(
      canStepOverBlock: state.canStepOverBlock,
      canStepOutOfBlock: state.canStepOutOfBlock,
      isPaused: state.status == ExecutionStatus.pausedAtStatement,
      onPace: onPace,
    );
  }
}

final class _StopControl extends StatelessWidget {
  final bool isActive;
  final VoidCallback onStop;

  const _StopControl({required this.isActive, required this.onStop});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isCompact = DesignCanvasScope.of(context).deviceClass == DeviceClass.compact;

    if (isCompact) {
      return AppIconButton(
        icon: Icons.stop,
        semanticLabel: l10n.actionStop,
        variant: AppButtonVariant.tertiary,
        destructive: isActive,
        onPressed: isActive ? onStop : null,
      );
    }
    return AppButton(
      label: l10n.actionStop,
      icon: Icons.stop,
      variant: AppButtonVariant.tertiary,
      destructive: isActive,
      onPressed: isActive ? onStop : null,
    );
  }
}

final class _StatusReadout extends StatelessWidget {
  final ExecutionState state;

  const _StatusReadout({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    final color = state.isNearStepLimit ? theme.colors.severities.warning.fg : theme.colors.text.secondary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: AppText(
            _statusLabel(state, l10n),
            variant: AppTextVariant.caption,
            color: theme.colors.text.tertiary,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: SpacingTokens.space3),
        _StatementCounter(number: state.statementNumber, color: color),
      ],
    );
  }
}

final class _StatementCounter extends StatelessWidget {
  final int number;
  final Color color;

  const _StatementCounter({required this.number, required this.color});

  @override
  Widget build(BuildContext context) {
    return AppText(
      AppLocalizations.of(context)!.statementCounter(number),
      variant: AppTextVariant.codeCaption,
      color: color,
      textAlign: TextAlign.end,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

String _statusLabel(ExecutionState state, AppLocalizations l10n) {
  final line = state.currentStep.currentLine;
  return switch (state.status) {
    ExecutionStatus.idle => l10n.executionStatusIdle,
    ExecutionStatus.running => l10n.executionStatusRunning,
    ExecutionStatus.pausedAwaitingInput => l10n.executionStatusAwaitingInput,
    ExecutionStatus.finishedSuccess => l10n.executionStatusFinished,
    ExecutionStatus.haltedWithError => l10n.executionStatusFinished,
    ExecutionStatus.stepLimitReached => l10n.executionStatusFinished,
    ExecutionStatus.pausedAtStatement =>
      line == null ? l10n.executionStatusRunning : l10n.executionStatusPaused(line),
  };
}
