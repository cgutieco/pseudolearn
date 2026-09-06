import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/typography.dart';

double _advanceWidthOf(String text, String family) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: TextStyle(fontFamily: family, fontSize: 32)),
    textDirection: TextDirection.ltr,
  )..layout();
  return painter.width;
}

void main() {
  group('Bundled families are the ones the suite rasterizes with', () {
    test('the proportional family advances narrow glyphs less than wide ones', () {
      final family = TypographyTokens.familyFor(AppFontRole.ui)!;

      expect(
        _advanceWidthOf('iiii', family),
        lessThan(_advanceWidthOf('MMMM', family)),
        reason: 'Both advances match, so the placeholder font of the test engine is '
            'still in place and no golden in this suite verifies typography',
      );
    });

    test('the code family advances narrow and wide glyphs alike', () {
      final family = TypographyTokens.familyFor(AppFontRole.code)!;

      expect(
        _advanceWidthOf('iiii', family),
        closeTo(_advanceWidthOf('MMMM', family), 0.01),
        reason: 'A monospaced family that stops being monospaced destroys the column '
            'grid the editor and the trace table are laid out on',
      );
    });

    test('a family the package does not bundle falls back to a different metric', () {
      final bundled = TypographyTokens.familyFor(AppFontRole.ui)!;

      expect(
        _advanceWidthOf('MMMM', 'FamiliaQueNoExiste'),
        isNot(closeTo(_advanceWidthOf('MMMM', bundled), 0.01)),
        reason: 'Every family resolves to the same glyphs, so the loader registered '
            'nothing and the two positive cases above would pass vacuously',
      );
    });
  });
}
