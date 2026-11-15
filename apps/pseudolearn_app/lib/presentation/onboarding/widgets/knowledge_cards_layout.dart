import 'package:flutter/widgets.dart';
import '../../shell/design_canvas.dart';
import '../../shell/device_class.dart';
import '../../theme/tokens/grid_metrics.dart';

final class KnowledgeCardsLayout extends StatelessWidget {
  final List<Widget> cards;

  const KnowledgeCardsLayout({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final gap = canvas.scaled(GridMetricsTokens.cardGap);

    return switch (canvas.deviceClass) {
      DeviceClass.compact || DeviceClass.medium => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _stacked(gap),
        ),
      DeviceClass.expanded => IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _sideBySide(gap),
          ),
        ),
    };
  }

  List<Widget> _stacked(double gap) {
    final children = <Widget>[];
    for (var index = 0; index < cards.length; index++) {
      if (index > 0) children.add(SizedBox(height: gap));
      children.add(cards[index]);
    }
    return children;
  }

  List<Widget> _sideBySide(double gap) {
    final children = <Widget>[];
    for (var index = 0; index < cards.length; index++) {
      if (index > 0) children.add(SizedBox(width: gap));
      children.add(Expanded(child: cards[index]));
    }
    return children;
  }
}
