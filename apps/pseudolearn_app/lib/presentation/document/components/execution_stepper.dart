import 'package:flutter/material.dart';
import '../../../application/execution/execution_state.dart';
import '../../../application/execution/step_pace.dart';
import '../../components/button/app_button.dart';
import '../../components/button/app_icon_button.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../shell/device_class.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import 'debug_controls.dart';
import 'idle_controls.dart';
import 'run_options_button.dart';

final class ExecutionStepper extends StatelessWidget {
  final ExecutionState state;
  final bool isExecutable;
  final void Function(StepPace) onPace;
  final void Function(int) onTaskStep;
  final VoidCallback onStop;
  final bool hasArguments;
  final VoidCallback onOpenOptions;

  const ExecutionStepper({
    super.key,
    required this.state,
    required this.isExecutable,
    required this.onPace,
    required this.onTaskStep,
    required this.onStop,
    this.hasArguments = false,
    required this.onOpenOptions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.space4,
        vertical: SpacingTokens.space2,
      ),
      decoration: BoxDecoration(
        color: theme.colors.surfaces.raised,
        boxShadow: theme.elevation.level2,
      ),
      child: _StepperRow(stepper: this),
    );
  }
}

final class _StepperRow extends StatelessWidget {
  final ExecutionStepper stepper;

  const _StepperRow({required this.stepper});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Align(
          alignment: Alignment.centerLeft,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: _CommandCluster(stepper: stepper),
          ),
        ),
      ),
      const SizedBox(width: SpacingTokens.space2),
      RunOptionsButton(
        hasArguments: stepper.hasArguments,
        onPressed: stepper.onOpenOptions,
      ),
    ],
  );
}

final class _CommandCluster extends StatelessWidget {
  final ExecutionStepper stepper;

  const _CommandCluster({required this.stepper});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _PaceControls(
        state: stepper.state,
        isExecutable: stepper.isExecutable,
        onPace: stepper.onPace,
        onTaskStep: stepper.onTaskStep,
      ),
      const SizedBox(width: SpacingTokens.space2),
      _StopControl(isActive: stepper.state.isInFlight, onStop: stepper.onStop),
    ],
  );
}

final class _PaceControls extends StatelessWidget {
  final ExecutionState state;
  final bool isExecutable;
  final void Function(StepPace) onPace;
  final void Function(int) onTaskStep;

  const _PaceControls({
    required this.state,
    required this.isExecutable,
    required this.onPace,
    required this.onTaskStep,
  });

  @override
  Widget build(BuildContext context) {
    if (!state.isInFlight) {
      return IdleControls(
        canExecute: isExecutable && state.canStart,
        onPace: onPace,
      );
    }
    return DebugControls(
      canStepOverBlock: state.canStepOverBlock,
      canStepOutOfBlock: state.canStepOutOfBlock,
      isPaused: state.status == ExecutionStatus.pausedAtStatement,
      taskContexts: state.currentStep.taskContexts,
      onPace: onPace,
      onTaskStep: onTaskStep,
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
    final isCompact =
        DesignCanvasScope.of(context).deviceClass == DeviceClass.compact;

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
