import 'package:flutter/widgets.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/card_metrics.dart';
import '../../theme/tokens/grid_metrics.dart';
import '../../theme/tokens/motion.dart';

const int _placeholderCount = 4;
const double _restingOpacity = 0.45;

final class AppSkeletonList extends StatefulWidget {
  final double itemExtent;

  const AppSkeletonList({super.key, required this.itemExtent});

  @override
  State<AppSkeletonList> createState() => _AppSkeletonListState();
}

final class _AppSkeletonListState extends State<AppSkeletonList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: MotionTokens.motionScreen * 3);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (DesignCanvasScope.of(context).reduceMotion) {
      _controller.stop();
      _controller.value = 1.0;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final gap = canvas.scaled(GridMetricsTokens.cardGap);

    return FadeTransition(
      opacity:
          _controller.drive(Tween<double>(begin: _restingOpacity, end: 1.0)),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _placeholderCount,
        separatorBuilder: (_, __) => SizedBox(height: gap),
        itemBuilder: (_, __) =>
            _SkeletonBlock(height: canvas.scaled(widget.itemExtent)),
      ),
    );
  }
}

final class _SkeletonBlock extends StatelessWidget {
  final double height;

  const _SkeletonBlock({required this.height});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: theme.colors.surfaces.subtle,
        borderRadius: BorderRadius.circular(CardMetricsTokens.radius),
      ),
    );
  }
}
