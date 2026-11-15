import 'package:flutter/widgets.dart';
import '../../shell/design_canvas.dart';
import '../../theme/tokens/grid_metrics.dart';

final class AppCardGrid extends StatelessWidget {
  final int itemCount;
  final double cardExtent;
  final NullableIndexedWidgetBuilder itemBuilder;
  final EdgeInsets padding;

  const AppCardGrid({
    super.key,
    required this.itemCount,
    required this.cardExtent,
    required this.itemBuilder,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final gap = canvas.scaled(GridMetricsTokens.cardGap);

    return GridView.builder(
      padding: padding,
      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: canvas.metrics.cardColumns,
        crossAxisSpacing: gap,
        mainAxisSpacing: gap,
        mainAxisExtent: canvas.scaled(cardExtent),
      ),
      itemBuilder: itemBuilder,
    );
  }
}
