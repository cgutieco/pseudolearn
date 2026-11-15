import 'package:flutter/widgets.dart';
import '../../shell/design_canvas.dart';
import '../../theme/tokens/motion.dart';

typedef RevealBuilder = Widget Function(BuildContext context, double progress);

final class ChartReveal extends StatelessWidget {
  final RevealBuilder builder;

  const ChartReveal({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final duration = DesignCanvasScope.of(context).motion(MotionSpeed.chart);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: duration == Duration.zero ? 1 : 0, end: 1),
      duration: duration,
      curve: MotionTokens.easeEnter,
      builder: (context, progress, _) => builder(context, progress),
    );
  }
}
