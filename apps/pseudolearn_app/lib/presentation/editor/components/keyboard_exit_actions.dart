import 'package:flutter/material.dart';
import '../../components/button/app_icon_button.dart';
import '../../components/button/button_palette.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/tokens/spacing.dart';

final class KeyboardExitActions extends StatelessWidget {
  final bool canRun;
  final VoidCallback onRun;
  final VoidCallback onHideKeyboard;

  const KeyboardExitActions({
    super.key,
    required this.canRun,
    required this.onRun,
    required this.onHideKeyboard,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIconButton(
          icon: Icons.play_arrow,
          semanticLabel: l10n.actionRun,
          variant: AppButtonVariant.primary,
          onPressed: canRun ? onRun : null,
        ),
        const SizedBox(width: SpacingTokens.space2),
        AppIconButton(
          icon: Icons.keyboard_hide,
          semanticLabel: l10n.editorActionHideKeyboard,
          variant: AppButtonVariant.tertiary,
          onPressed: onHideKeyboard,
        ),
      ],
    );
  }
}
