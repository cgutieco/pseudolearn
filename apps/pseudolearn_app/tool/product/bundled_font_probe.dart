import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/typography.dart';

void expectBundledFontsRasterized() {
  expect(
    _advanceWidthOf('iiii'),
    lessThan(_advanceWidthOf('MMMM')),
    reason: 'Every glyph has the same advance, so the test placeholder font is '
        'still in place and the artwork would be rows of blocks',
  );
}

double _advanceWidthOf(String text) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontFamily: TypographyTokens.familyFor(AppFontRole.ui),
        fontSize: 32,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  return painter.width;
}
