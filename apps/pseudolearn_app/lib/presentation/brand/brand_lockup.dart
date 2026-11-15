import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/brand_metrics.dart';
import 'brand_lockup_layout.dart';
import 'brand_symbol.dart';
import 'brand_symbol_geometry.dart';
import 'brand_wordmark.dart';

export 'brand_lockup_layout.dart' show BrandLockupOrientation;

final class BrandLockup extends StatelessWidget {
  final double typeSize;
  final BrandLockupOrientation orientation;

  const BrandLockup({
    super.key,
    required this.typeSize,
    this.orientation = BrandLockupOrientation.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeExtension.of(context).colors;
    final layout = BrandLockupLayout.of(orientation: orientation, typeSize: typeSize);
    return Padding(
      padding: EdgeInsets.all(layout.clearSpace),
      child: SizedBox.fromSize(
        size: layout.size,
        child: Stack(
          children: [
            Positioned.fromRect(rect: layout.plate, child: _BrandPlate(side: layout.plate.width)),
            Positioned(
              left: layout.wordmark.dx,
              top: layout.wordmark.dy,
              child: BrandWordmark(typeSize: typeSize, color: colors.brandInk.wordmark),
            ),
          ],
        ),
      ),
    );
  }
}

final class _BrandPlate extends StatelessWidget {
  final double side;

  const _BrandPlate({required this.side});

  @override
  Widget build(BuildContext context) {
    final plate = AppThemeExtension.of(context).colors.brandPlate;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(side * BrandMetricsTokens.plateCornerRatio),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[plate.groundTop, plate.groundBottom],
        ),
      ),
      child: Center(
        child: BrandSymbol(size: _inscribedSide(side), color: plate.ink),
      ),
    );
  }
}

double _inscribedSide(double plateSide) {
  final ink = brandSymbolInkBox();
  final scale = math.min(
    plateSide * BrandMetricsTokens.plateInscribedWidth / ink.width,
    plateSide * BrandMetricsTokens.plateInscribedHeight / ink.height,
  );
  return ink.width * scale;
}
