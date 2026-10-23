import 'package:flutter/material.dart';
import '../../components/button/app_button.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../shell/device_class.dart';
import '../../theme/tokens/spacing.dart';

final class EditorHelpDock extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? panel;

  const EditorHelpDock({super.key, required this.onPressed, this.panel});

  @override
  Widget build(BuildContext context) {
    final explain = onPressed;
    final canvas = DesignCanvasScope.of(context);
    final crampedByKeyboard =
        canvas.deviceClass == DeviceClass.compact && canvas.isKeyboardVisible;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (explain != null && !crampedByKeyboard)
          _ExplainButton(onPressed: explain),
        ?panel,
      ],
    );
  }
}

final class _ExplainButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ExplainButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.space2),
        child: Semantics(
          label: l10n.helpExplainSemantic,
          excludeSemantics: true,
          button: true,
          onTap: onPressed,
          child: AppButton(
            label: l10n.helpExplainAction,
            icon: Icons.help_outline,
            variant: AppButtonVariant.tertiary,
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}
