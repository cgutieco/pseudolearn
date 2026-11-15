import 'package:material_ui/material_ui.dart';
import '../../../application/execution/step_pace.dart';
import '../../../domain/model/execution/execution_task_context.dart';
import '../../components/button/app_button.dart';
import '../../components/button/app_icon_button.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../shell/device_class.dart';
import '../../theme/tokens/spacing.dart';

final class DebugControls extends StatelessWidget {
  final bool canStepOverBlock;
  final bool canStepOutOfBlock;
  final bool isPaused;
  final List<ExecutionTaskContext> taskContexts;
  final void Function(StepPace) onPace;
  final void Function(int) onTaskStep;

  const DebugControls({
    super.key,
    required this.canStepOverBlock,
    required this.canStepOutOfBlock,
    required this.isPaused,
    required this.taskContexts,
    required this.onPace,
    required this.onTaskStep,
  });

  @override
  Widget build(BuildContext context) {
    final deviceClass = DesignCanvasScope.of(context).deviceClass;
    final specs = _specsFor(
      AppLocalizations.of(context)!,
      onPace: isPaused ? onPace : null,
      canStepOverBlock: canStepOverBlock,
      canStepOutOfBlock: canStepOutOfBlock,
      includeOutOfBlock: deviceClass != DeviceClass.compact,
      includeGlobalEvent: deviceClass != DeviceClass.compact,
    );
    final controls = deviceClass == DeviceClass.expanded
        ? _LabeledDebugControls(specs: specs)
        : _IconDebugControls(specs: specs);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        controls,
        const SizedBox(width: SpacingTokens.space2),
        _TaskStepMenu(
          taskContexts: taskContexts,
          enabled: isPaused,
          includesGlobalEvent: deviceClass == DeviceClass.compact,
          onPace: onPace,
          onTaskStep: onTaskStep,
        ),
      ],
    );
  }
}

final class _PaceSpec {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;

  const _PaceSpec({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.variant,
  });
}

List<_PaceSpec> _specsFor(
  AppLocalizations l10n, {
  required void Function(StepPace)? onPace,
  required bool canStepOverBlock,
  required bool canStepOutOfBlock,
  required bool includeOutOfBlock,
  required bool includeGlobalEvent,
}) => [
  if (includeGlobalEvent) _globalEventSpec(l10n, onPace),
  _stepIntoSpec(l10n, onPace),
  _stepOverSpec(l10n, onPace, canStepOverBlock),
  if (includeOutOfBlock) _stepOutSpec(l10n, onPace, canStepOutOfBlock),
  _continueSpec(l10n, onPace),
];

_PaceSpec _globalEventSpec(
  AppLocalizations l10n,
  void Function(StepPace)? onPace,
) => _paceSpec(
  icon: Icons.skip_next,
  label: l10n.actionStepEvent,
  pace: StepPace.nextEvent,
  onPace: onPace,
);

_PaceSpec _stepIntoSpec(
  AppLocalizations l10n,
  void Function(StepPace)? onPace,
) => _paceSpec(
  icon: Icons.arrow_downward,
  label: l10n.actionStepInto,
  pace: StepPace.nextStatement,
  onPace: onPace,
  variant: AppButtonVariant.primary,
);

_PaceSpec _stepOverSpec(
  AppLocalizations l10n,
  void Function(StepPace)? onPace,
  bool isEnabled,
) => _paceSpec(
  icon: Icons.redo,
  label: l10n.actionStepOverBlock,
  pace: StepPace.overBlock,
  onPace: onPace,
  isEnabled: isEnabled,
);

_PaceSpec _stepOutSpec(
  AppLocalizations l10n,
  void Function(StepPace)? onPace,
  bool isEnabled,
) => _paceSpec(
  icon: Icons.arrow_upward,
  label: l10n.actionStepOutOfBlock,
  pace: StepPace.outOfBlock,
  onPace: onPace,
  isEnabled: isEnabled,
);

_PaceSpec _continueSpec(
  AppLocalizations l10n,
  void Function(StepPace)? onPace,
) => _paceSpec(
  icon: Icons.play_arrow,
  label: l10n.actionContinue,
  pace: StepPace.toEnd,
  onPace: onPace,
);

_PaceSpec _paceSpec({
  required IconData icon,
  required String label,
  required StepPace pace,
  required void Function(StepPace)? onPace,
  bool isEnabled = true,
  AppButtonVariant variant = AppButtonVariant.secondary,
}) => _PaceSpec(
  icon: icon,
  label: label,
  onPressed: onPace == null || !isEnabled ? null : () => onPace(pace),
  variant: variant,
);

final class _TaskStepMenu extends StatelessWidget {
  final List<ExecutionTaskContext> taskContexts;
  final bool enabled;
  final bool includesGlobalEvent;
  final void Function(StepPace) onPace;
  final void Function(int) onTaskStep;

  const _TaskStepMenu({
    required this.taskContexts,
    required this.enabled,
    required this.includesGlobalEvent,
    required this.onPace,
    required this.onTaskStep,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopupMenuButton<int?>(
      tooltip: l10n.actionStepTask,
      enabled: enabled && (includesGlobalEvent || taskContexts.isNotEmpty),
      icon: const Icon(Icons.play_for_work),
      onSelected: (target) {
        if (target == null) {
          onPace(StepPace.nextEvent);
          return;
        }
        onTaskStep(target);
      },
      itemBuilder: (context) => [
        if (includesGlobalEvent)
          PopupMenuItem(value: null, child: Text(l10n.actionStepEvent)),
        for (final task in taskContexts)
          PopupMenuItem(
            value: task.taskId,
            enabled: task.status != ExecutionTaskStatus.completed,
            child: Text(l10n.executionStepTask(task.taskId)),
          ),
      ],
    );
  }
}

final class _IconDebugControls extends StatelessWidget {
  final List<_PaceSpec> specs;

  const _IconDebugControls({required this.specs});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < specs.length; index++) ...[
          if (index > 0) const SizedBox(width: SpacingTokens.space2),
          AppIconButton(
            icon: specs[index].icon,
            semanticLabel: specs[index].label,
            variant: specs[index].variant,
            onPressed: specs[index].onPressed,
          ),
        ],
      ],
    );
  }
}

final class _LabeledDebugControls extends StatelessWidget {
  final List<_PaceSpec> specs;

  const _LabeledDebugControls({required this.specs});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < specs.length; index++) ...[
          if (index > 0) const SizedBox(width: SpacingTokens.space2),
          AppButton(
            label: specs[index].label,
            icon: specs[index].icon,
            variant: specs[index].variant,
            onPressed: specs[index].onPressed,
          ),
        ],
      ],
    );
  }
}
