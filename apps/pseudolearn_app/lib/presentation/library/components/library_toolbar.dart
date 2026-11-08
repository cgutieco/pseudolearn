import 'package:flutter/material.dart';
import '../../components/button/app_button.dart';
import '../../components/button/app_icon_button.dart';
import '../../shell/design_canvas.dart';
import '../../shell/device_class.dart';
import '../../theme/tokens/spacing.dart';

final class LibraryToolbar extends StatelessWidget {
  final Widget leading;
  final Widget action;

  const LibraryToolbar({super.key, required this.leading, required this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: leading),
        const SizedBox(width: SpacingTokens.space3),
        action,
      ],
    );
  }
}

final class LibraryCreateAction extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const LibraryCreateAction({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return switch (DesignCanvasScope.of(context).deviceClass) {
      DeviceClass.compact => AppIconButton(
          icon: Icons.add,
          semanticLabel: label,
          variant: AppButtonVariant.primary,
          onPressed: onPressed,
        ),
      DeviceClass.medium || DeviceClass.expanded => AppButton(
          label: label,
          icon: Icons.add,
          variant: AppButtonVariant.primary,
          onPressed: onPressed,
        ),
    };
  }
}
