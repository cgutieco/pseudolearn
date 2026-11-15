import 'package:flutter/widgets.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/tokens/brand_metrics.dart';
import '../theme/tokens/typography.dart';

final class BrandWordmark extends StatelessWidget {
  final double typeSize;
  final Color color;

  const BrandWordmark({super.key, required this.typeSize, required this.color});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      label: l10n.appTitle,
      excludeSemantics: true,
      child: CustomPaint(
        size: Size(
          BrandMetricsTokens.wordmarkInkWidth * typeSize,
          BrandMetricsTokens.wordmarkInkHeight * typeSize,
        ),
        painter: BrandWordmarkPainter(typeSize: typeSize, color: color),
      ),
    );
  }
}

final class BrandWordmarkPainter extends CustomPainter {
  final double typeSize;
  final Color color;

  const BrandWordmarkPainter({required this.typeSize, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final text = TextPainter(
      text: _wordmarkSpan(typeSize: typeSize, color: color),
      textDirection: TextDirection.ltr,
    )..layout();
    final baseline = text.computeDistanceToActualBaseline(TextBaseline.alphabetic);
    final inkTop = BrandMetricsTokens.wordmarkInkTop * typeSize;
    text.paint(
      canvas,
      Offset(
        -BrandMetricsTokens.wordmarkInkLeft * typeSize,
        BrandMetricsTokens.wordmarkCapBaseline * typeSize - inkTop - baseline,
      ),
    );
  }

  @override
  bool shouldRepaint(BrandWordmarkPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.typeSize != typeSize;
}

TextSpan _wordmarkSpan({required double typeSize, required Color color}) {
  final mono = TextStyle(
    fontFamily: TypographyTokens.familyFor(AppFontRole.code),
    fontFamilyFallback: TypographyTokens.fallbacksFor(AppFontRole.code),
    fontSize: typeSize,
    fontWeight: TypographyTokens.weightMedium,
    color: color,
  );
  final sans = TextStyle(
    fontFamily: TypographyTokens.familyFor(AppFontRole.ui),
    fontFamilyFallback: TypographyTokens.fallbacksFor(AppFontRole.ui),
    fontSize: typeSize,
    fontWeight: TypographyTokens.weightBold,
    letterSpacing: BrandMetricsTokens.wordmarkTracking * typeSize,
    color: color,
  );
  return TextSpan(children: <TextSpan>[
    TextSpan(text: 'Pseud', style: mono),
    TextSpan(
      text: 'o',
      style: mono.copyWith(letterSpacing: BrandMetricsTokens.wordmarkSeam * typeSize),
    ),
    TextSpan(text: 'Learn', style: sans),
  ]);
}
