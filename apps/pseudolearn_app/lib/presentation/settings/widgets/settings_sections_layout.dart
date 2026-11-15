import 'package:flutter/widgets.dart';
import '../../shell/design_canvas.dart';
import '../../shell/device_class.dart';
import '../../theme/tokens/grid_metrics.dart';

final class SettingsSectionsLayout extends StatelessWidget {
  final Widget primary;
  final Widget secondary;

  const SettingsSectionsLayout({
    super.key,
    required this.primary,
    required this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final gap = canvas.scaled(GridMetricsTokens.cardGap);

    return switch (canvas.deviceClass) {
      DeviceClass.compact || DeviceClass.medium => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [primary, SizedBox(height: gap), secondary],
        ),
      DeviceClass.expanded => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: primary),
            SizedBox(width: gap),
            Expanded(child: secondary),
          ],
        ),
    };
  }
}
