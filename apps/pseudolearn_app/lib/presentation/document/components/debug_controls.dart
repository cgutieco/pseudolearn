import 'package:flutter/material.dart';
import '../../../application/execution/step_pace.dart';
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
  final void Function(StepPace) onPace;

  const DebugControls({
    super.key,
    required this.canStepOverBlock,
    required this.canStepOutOfBlock,
    required this.isPaused,
    required this.onPace,
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
    );
    return deviceClass == DeviceClass.expanded
        ? _LabeledDebugControls(specs: specs)
        : _IconDebugControls(specs: specs);
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
}) {
  VoidCallback? command(StepPace pace, {bool isEnabled = true}) =>
      onPace == null || !isEnabled ? null : () => onPace(pace);

  return [
    _PaceSpec(
      icon: Icons.arrow_downward,
      label: l10n.actionStepInto,
      onPressed: command(StepPace.nextStatement),
      variant: AppButtonVariant.primary,
    ),
    _PaceSpec(
      icon: Icons.redo,
      label: l10n.actionStepOverBlock,
      onPressed: command(StepPace.overBlock, isEnabled: canStepOverBlock),
      variant: AppButtonVariant.secondary,
    ),
    if (includeOutOfBlock)
      _PaceSpec(
        icon: Icons.arrow_upward,
        label: l10n.actionStepOutOfBlock,
        onPressed: command(StepPace.outOfBlock, isEnabled: canStepOutOfBlock),
        variant: AppButtonVariant.secondary,
      ),
    _PaceSpec(
      icon: Icons.play_arrow,
      label: l10n.actionContinue,
      onPressed: command(StepPace.toEnd),
      variant: AppButtonVariant.secondary,
    ),
  ];
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
