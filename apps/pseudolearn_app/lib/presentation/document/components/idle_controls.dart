import 'package:flutter/material.dart';
import '../../../application/execution/step_pace.dart';
import '../../components/button/app_button.dart';
import '../../components/button/app_icon_button.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../shell/device_class.dart';
import '../../theme/tokens/spacing.dart';

final class IdleControls extends StatelessWidget {
  final bool canExecute;
  final void Function(StepPace) onPace;

  const IdleControls({
    super.key,
    required this.canExecute,
    required this.onPace,
  });

  @override
  Widget build(BuildContext context) {
    final isCompact = DesignCanvasScope.of(context).deviceClass == DeviceClass.compact;
    return isCompact
        ? _CompactIdleControls(canExecute: canExecute, onPace: onPace)
        : _LabeledIdleControls(canExecute: canExecute, onPace: onPace);
  }
}

final class _CompactIdleControls extends StatelessWidget {
  final bool canExecute;
  final void Function(StepPace) onPace;

  const _CompactIdleControls({required this.canExecute, required this.onPace});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        AppIconButton(
          icon: Icons.skip_next,
          semanticLabel: l10n.actionStep,
          variant: AppButtonVariant.secondary,
          onPressed: canExecute ? () => onPace(StepPace.nextStatement) : null,
        ),
        const SizedBox(width: SpacingTokens.space2),
        AppIconButton(
          icon: Icons.play_arrow,
          semanticLabel: l10n.actionRun,
          variant: AppButtonVariant.primary,
          onPressed: canExecute ? () => onPace(StepPace.toEnd) : null,
        ),
      ],
    );
  }
}

final class _LabeledIdleControls extends StatelessWidget {
  final bool canExecute;
  final void Function(StepPace) onPace;

  const _LabeledIdleControls({required this.canExecute, required this.onPace});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        AppButton(
          label: l10n.actionStep,
          icon: Icons.skip_next,
          variant: AppButtonVariant.secondary,
          onPressed: canExecute ? () => onPace(StepPace.nextStatement) : null,
        ),
        const SizedBox(width: SpacingTokens.space2),
        AppButton(
          label: l10n.actionRun,
          icon: Icons.play_arrow,
          variant: AppButtonVariant.primary,
          onPressed: canExecute ? () => onPace(StepPace.toEnd) : null,
        ),
      ],
    );
  }
}
