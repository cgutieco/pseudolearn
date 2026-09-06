import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/typography.dart';

void main() {
  group('Typography Scale Pure Data Tests (RFC 001 §2.2)', () {
    test('Typography table returns expected scale for compact class (360)', () {
      const typo = AppTypography.compact();
      expect(typo.display.fontSize, 30.0);
      expect(typo.heading1.fontSize, 24.0);
      expect(typo.heading2.fontSize, 20.0);
      expect(typo.heading3.fontSize, 17.0);
      expect(typo.heading4.fontSize, 15.0);
      expect(typo.bodyDefault.fontSize, 15.0);
      expect(typo.codeEditor.fontSize, 14.0);
      expect(typo.label.fontSize, 13.0);
      expect(typo.caption.fontSize, 12.0);
    });

    test('Typography table returns expected scale for medium class (600)', () {
      const typo = AppTypography.medium();
      expect(typo.display.fontSize, 32.0);
      expect(typo.heading1.fontSize, 25.0);
      expect(typo.heading2.fontSize, 21.0);
      expect(typo.heading3.fontSize, 18.0);
      expect(typo.heading4.fontSize, 16.0);
      expect(typo.bodyDefault.fontSize, 15.0);
      expect(typo.codeEditor.fontSize, 14.0);
      expect(typo.label.fontSize, 13.0);
      expect(typo.caption.fontSize, 12.0);
    });

    test('Typography table returns expected scale for expanded class (960)', () {
      const typo = AppTypography.expanded();
      expect(typo.display.fontSize, 32.0);
      expect(typo.heading1.fontSize, 22.0);
      expect(typo.heading2.fontSize, 19.0);
      expect(typo.heading3.fontSize, 16.0);
      expect(typo.heading4.fontSize, 14.0);
      expect(typo.bodyDefault.fontSize, 14.0);
      expect(typo.codeEditor.fontSize, 13.0);
      expect(typo.label.fontSize, 13.0);
      expect(typo.caption.fontSize, 12.0);
    });

    test('Typography scales are distinct across classes but consistent within each class', () {
      const c1 = AppTypography.compact();
      const c2 = AppTypography.compact();
      const m = AppTypography.medium();
      const e = AppTypography.expanded();

      expect(c1.heading1.fontSize, equals(c2.heading1.fontSize));
      expect(c1.heading1.fontSize, isNot(equals(m.heading1.fontSize)));
      expect(m.heading1.fontSize, isNot(equals(e.heading1.fontSize)));
    });
  });
}
