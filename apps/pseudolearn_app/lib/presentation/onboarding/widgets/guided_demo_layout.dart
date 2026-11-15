import 'package:flutter/widgets.dart';
import '../../shell/design_canvas.dart';
import '../../shell/device_class.dart';
import '../../theme/tokens/grid_metrics.dart';

final class GuidedDemoLayout extends StatelessWidget {
  final Widget reading;
  final Widget surface;

  const GuidedDemoLayout({
    super.key,
    required this.reading,
    required this.surface,
  });

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final gap = canvas.scaled(GridMetricsTokens.cardGap);

    return switch (canvas.deviceClass) {
      DeviceClass.compact || DeviceClass.medium => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [reading, SizedBox(height: gap), surface],
        ),
      DeviceClass.expanded => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: reading),
            SizedBox(width: gap),
            Expanded(child: surface),
          ],
        ),
    };
  }
}
