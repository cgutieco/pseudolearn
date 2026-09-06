import 'package:flutter/widgets.dart';
import '../theme/tokens/motion.dart';
import '../theme/tokens/spacing.dart';
import '../theme/tokens/typography.dart';
import 'device_class.dart';

const Map<DeviceClass, LayoutMetrics> _canvasMetricsByClass = <DeviceClass, LayoutMetrics>{
  DeviceClass.compact: LayoutMetrics.compact(),
  DeviceClass.medium: LayoutMetrics.medium(),
  DeviceClass.expanded: LayoutMetrics.expanded(),
};

final class DesignCanvasData {
  final DeviceClass deviceClass;
  final Size size;
  final LayoutMetrics metrics;
  final bool reduceMotion;
  final bool isKeyboardVisible;

  const DesignCanvasData({
    required this.deviceClass,
    required this.size,
    required this.metrics,
    required this.reduceMotion,
    this.isKeyboardVisible = false,
  });

  double scaled(double value) => value * metrics.densityScale;

  double maxWidthFor(ContentMeasure measure) => metrics.maxWidthFor(measure);

  Duration motion(MotionSpeed speed) => MotionTokens.resolve(speed, reduced: reduceMotion);

  bool sameValues(DesignCanvasData other) =>
      deviceClass == other.deviceClass &&
      size == other.size &&
      reduceMotion == other.reduceMotion &&
      isKeyboardVisible == other.isKeyboardVisible;
}

final class DesignCanvasScope extends InheritedWidget {
  final DesignCanvasData data;

  const DesignCanvasScope({
    super.key,
    required this.data,
    required super.child,
  });

  static DesignCanvasData of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<DesignCanvasScope>();
    assert(scope != null, 'DesignCanvasScope.of() called with no ancestor scope');
    return scope!.data;
  }

  @override
  bool updateShouldNotify(DesignCanvasScope oldWidget) => !oldWidget.data.sameValues(data);
}

final class DesignCanvas extends StatelessWidget {
  final Widget child;

  const DesignCanvas({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    assert(
      context.getInheritedWidgetOfExactType<DesignCanvasScope>() == null,
      'DesignCanvas must not be nested: the inner canvas would measure the window '
      'instead of the space it was given and subtract the margins twice.',
    );

    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final deviceClass = DeviceClass.fromWidth(size.width);
    final clampedTextScaler = mediaQuery.textScaler.clamp(
      minScaleFactor: TypographyTokens.textScaleMin,
      maxScaleFactor: TypographyTokens.textScaleMax,
    );

    return DesignCanvasScope(
      data: DesignCanvasData(
        deviceClass: deviceClass,
        size: size,
        metrics: _canvasMetricsByClass[deviceClass]!,
        reduceMotion: mediaQuery.disableAnimations,
        isKeyboardVisible: mediaQuery.viewInsets.bottom > 0,
      ),
      child: MediaQuery(
        data: mediaQuery.copyWith(textScaler: clampedTextScaler, size: size),
        child: child,
      ),
    );
  }
}

