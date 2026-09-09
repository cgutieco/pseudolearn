import 'package:flutter/material.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/color_semantic.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/elevation.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/radii.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/typography.dart';

import 'promo_layout.dart';

final class PromoFrame extends StatelessWidget {
  final PromoLayout layout;
  final AppSemanticColors colors;
  final AppElevation elevation;
  final String headline;
  final Widget appRender;

  const PromoFrame({
    super.key,
    required this.layout,
    required this.colors,
    required this.elevation,
    required this.headline,
    required this.appRender,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: PromoBackground(
        colors: colors,
        size: layout.frameSize,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: layout.margin),
            _HeadlineBand(layout: layout, colors: colors, headline: headline),
            Expanded(
              child: Center(
                child: _AppCard(
                  layout: layout,
                  colors: colors,
                  elevation: elevation,
                  child: appRender,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class PromoBackground extends StatelessWidget {
  final AppSemanticColors colors;
  final Size size;
  final Widget child;

  const PromoBackground({
    super.key,
    required this.colors,
    required this.size,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            colors.surfaces.canvas,
            colors.surfaces.brandSubtle,
          ],
        ),
      ),
      child: child,
    );
  }
}

final class _HeadlineBand extends StatelessWidget {
  final PromoLayout layout;
  final AppSemanticColors colors;
  final String headline;

  const _HeadlineBand({
    required this.layout,
    required this.colors,
    required this.headline,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: layout.headlineWidth,
      height: layout.headlineBandHeight,
      child: Center(
        child: Text(
          headline,
          textAlign: TextAlign.center,
          maxLines: layout.headlineMaxLines,
          style: headlineStyleOf(layout, colors),
        ),
      ),
    );
  }
}

TextStyle headlineStyleOf(PromoLayout layout, AppSemanticColors colors) {
  return TextStyle(
    fontFamily: TypographyTokens.familyFor(AppFontRole.ui),
    fontFamilyFallback: TypographyTokens.fallbacksFor(AppFontRole.ui),
    fontSize: layout.headlineFontSize,
    height: layout.headlineLineHeight / layout.headlineFontSize,
    fontWeight: layout.headlineWeight,
    letterSpacing: layout.headlineLetterSpacing,
    color: colors.text.primary,
  );
}

final class _AppCard extends StatelessWidget {
  final PromoLayout layout;
  final AppSemanticColors colors;
  final AppElevation elevation;
  final Widget child;

  const _AppCard({
    required this.layout,
    required this.colors,
    required this.elevation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(RadiusTokens.radiusLg);
    return Container(
      width: layout.cardSize.width,
      height: layout.cardSize.height,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: elevation.level3,
        border: Border.all(color: colors.borders.subtle),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: FittedBox(
          fit: BoxFit.fill,
          child: SizedBox.fromSize(size: layout.appLogicalSize, child: child),
        ),
      ),
    );
  }
}
