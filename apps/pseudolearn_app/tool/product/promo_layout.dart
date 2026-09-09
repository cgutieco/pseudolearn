import 'dart:math';
import 'dart:ui';

import 'package:pseudolearn_app/presentation/theme/tokens/typography.dart';

const double _marginToShortestSide = 0.06;
const double _headlineToDiagonal = 0.032;

final AppTextStyleSpec _headlineSpec = const AppTypography.expanded().display;

final class PromoLayout {
  final Size frameSize;
  final Size appLogicalSize;

  const PromoLayout({required this.frameSize, required this.appLogicalSize});

  bool get isPortrait => frameSize.height >= frameSize.width;

  double get margin => frameSize.shortestSide * _marginToShortestSide;

  int get headlineMaxLines => isPortrait ? 2 : 1;

  double get headlineFontSize {
    final diagonal = sqrt(
      frameSize.width * frameSize.width + frameSize.height * frameSize.height,
    );
    return _headlineToDiagonal * diagonal;
  }

  double get headlineLineHeight =>
      headlineFontSize * _headlineSpec.lineHeight / _headlineSpec.fontSize;

  double get headlineLetterSpacing =>
      headlineFontSize * _headlineSpec.letterSpacing / _headlineSpec.fontSize;

  FontWeight get headlineWeight => _headlineSpec.fontWeight;

  double get headlineWidth => frameSize.width - margin * 2;

  double get headlineBandHeight => headlineLineHeight * headlineMaxLines;

  Size get cardSize {
    final slotWidth = frameSize.width - margin * 2;
    final slotHeight = frameSize.height - margin * 3 - headlineBandHeight;
    final scale = min(
      slotWidth / appLogicalSize.width,
      slotHeight / appLogicalSize.height,
    );
    return Size(appLogicalSize.width * scale, appLogicalSize.height * scale);
  }
}
