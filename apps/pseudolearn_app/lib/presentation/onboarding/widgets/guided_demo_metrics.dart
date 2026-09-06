import '../../shell/design_canvas.dart';
import '../../shell/device_class.dart';
import '../../theme/tokens/component_metrics.dart';

final class GuidedDemoMetrics {
  final double codeHeight;
  final double surfaceHeight;

  const GuidedDemoMetrics({
    required this.codeHeight,
    required this.surfaceHeight,
  });

  factory GuidedDemoMetrics.of(DesignCanvasData canvas) {
    return switch (canvas.deviceClass) {
      DeviceClass.compact => const GuidedDemoMetrics(
          codeHeight: ComponentMetricsTokens.onboardingLabCodeHeightCompact,
          surfaceHeight:
              ComponentMetricsTokens.onboardingLabSurfaceHeightCompact,
        ),
      DeviceClass.medium => const GuidedDemoMetrics(
          codeHeight: ComponentMetricsTokens.onboardingLabCodeHeightMedium,
          surfaceHeight:
              ComponentMetricsTokens.onboardingLabSurfaceHeightMedium,
        ),
      DeviceClass.expanded => const GuidedDemoMetrics(
          codeHeight: ComponentMetricsTokens.onboardingLabCodeHeightMedium,
          surfaceHeight:
              ComponentMetricsTokens.onboardingLabSurfaceHeightExpanded,
        ),
    };
  }
}
