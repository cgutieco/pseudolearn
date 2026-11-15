import 'package:flutter/widgets.dart';
import 'brand_symbol_geometry.dart';

final class BrandSymbol extends StatelessWidget {
  final double size;
  final Color color;

  const BrandSymbol({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(size),
        painter: BrandSymbolPainter(color: color),
      ),
    );
  }
}

final class BrandSymbolPainter extends CustomPainter {
  final Color color;

  const BrandSymbolPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final ink = brandSymbolInkBox();
    final scale = size.shortestSide / ink.width;
    canvas.save();
    canvas.translate(-ink.left * scale, -ink.top * scale);
    canvas.scale(scale);
    canvas.drawPath(buildBrandSymbolPath(), Paint()..color = color);
    canvas.restore();
  }

  @override
  bool shouldRepaint(BrandSymbolPainter oldDelegate) => oldDelegate.color != color;
}
