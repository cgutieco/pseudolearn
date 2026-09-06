import 'package:flutter/widgets.dart';
import '../../shell/design_canvas.dart';
import '../../theme/tokens/spacing.dart';

final class AppContentColumn extends StatelessWidget {
  final Widget child;
  final ContentMeasure measure;

  const AppContentColumn({
    super.key,
    required this.child,
    this.measure = ContentMeasure.wide,
  });

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final margin = canvas.scaled(canvas.metrics.screenMargin);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: canvas.maxWidthFor(measure) + margin * 2),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: margin),
          child: child,
        ),
      ),
    );
  }
}
