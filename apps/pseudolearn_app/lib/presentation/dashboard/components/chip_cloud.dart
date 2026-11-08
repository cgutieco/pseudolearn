import 'package:flutter/widgets.dart';
import '../../shell/design_canvas.dart';
import '../../theme/tokens/spacing.dart';

final class ChipCloud extends StatelessWidget {
  final List<Widget> chips;

  const ChipCloud({super.key, required this.chips});

  @override
  Widget build(BuildContext context) {
    final gap = DesignCanvasScope.of(context).scaled(SpacingTokens.space2);

    return Wrap(spacing: gap, runSpacing: gap, children: chips);
  }
}
