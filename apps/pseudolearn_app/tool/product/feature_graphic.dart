import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pseudolearn_app/presentation/brand/brand_lockup.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/color_semantic.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/spacing.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/typography.dart';

const double _lockupTypeToHeight = 0.18;
const double _taglineToHeight = 0.072;

final class FeatureGraphic extends StatelessWidget {
  final Size frameSize;
  final AppSemanticColors colors;
  final ThemeData theme;
  final Locale locale;
  final String tagline;

  const FeatureGraphic({
    super.key,
    required this.frameSize,
    required this.colors,
    required this.theme,
    required this.locale,
    required this.tagline,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Localizations(
        locale: locale,
        delegates: const <LocalizationsDelegate<Object>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        child: Theme(
          data: theme,
          child: _FeatureGraphicBody(
            frameSize: frameSize,
            colors: colors,
            tagline: tagline,
          ),
        ),
      ),
    );
  }
}

final class _FeatureGraphicBody extends StatelessWidget {
  final Size frameSize;
  final AppSemanticColors colors;
  final String tagline;

  const _FeatureGraphicBody({
    required this.frameSize,
    required this.colors,
    required this.tagline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: frameSize.width,
      height: frameSize.height,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BrandLockup(typeSize: frameSize.height * _lockupTypeToHeight),
          const SizedBox(height: SpacingTokens.space3),
          Text(
            tagline,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: taglineStyleOf(frameSize, colors),
          ),
        ],
      ),
    );
  }
}

TextStyle taglineStyleOf(Size frameSize, AppSemanticColors colors) {
  return TextStyle(
    fontFamily: TypographyTokens.familyFor(AppFontRole.ui),
    fontFamilyFallback: TypographyTokens.fallbacksFor(AppFontRole.ui),
    fontSize: frameSize.height * _taglineToHeight,
    fontWeight: TypographyTokens.weightMedium,
    color: colors.text.secondary,
  );
}
