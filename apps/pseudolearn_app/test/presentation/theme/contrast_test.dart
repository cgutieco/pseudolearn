import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/color_primitives.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/color_semantic.dart';

double _linearizeChannel(double channel) {
  if (channel <= 0.04045) {
    return channel / 12.92;
  }
  return math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
}

double relativeLuminance(Color color) {
  final r = _linearizeChannel(color.r);
  final g = _linearizeChannel(color.g);
  final b = _linearizeChannel(color.b);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

double contrastRatio(Color c1, Color c2) {
  final l1 = relativeLuminance(c1);
  final l2 = relativeLuminance(c2);
  final lighter = math.max(l1, l2);
  final darker = math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('WCAG Contrast Ratio Verifications (RFC 001 §1.7)', () {
    test('Light mode semantic contrast pairs meet threshold', () {
      const colors = AppSemanticColors.light();

      expect(
        contrastRatio(colors.text.primary, colors.surfaces.canvas),
        greaterThanOrEqualTo(4.5),
      );

      expect(
        contrastRatio(colors.text.primary, colors.surfaces.defaultSurface),
        greaterThanOrEqualTo(4.5),
      );

      expect(
        contrastRatio(colors.text.secondary, colors.surfaces.canvas),
        greaterThanOrEqualTo(4.5),
      );

      expect(
        contrastRatio(colors.text.secondary, colors.surfaces.defaultSurface),
        greaterThanOrEqualTo(4.5),
      );

      expect(
        contrastRatio(colors.text.tertiary, colors.surfaces.canvas),
        greaterThanOrEqualTo(4.5),
      );

      expect(
        contrastRatio(colors.text.tertiary, colors.surfaces.defaultSurface),
        greaterThanOrEqualTo(4.5),
      );

      expect(
        contrastRatio(colors.text.link, colors.surfaces.defaultSurface),
        greaterThanOrEqualTo(4.5),
      );

      expect(
        contrastRatio(colors.text.inverse, colors.surfaces.inverse),
        greaterThanOrEqualTo(4.5),
      );

      expect(
        contrastRatio(colors.borders.strong, colors.surfaces.defaultSurface),
        greaterThanOrEqualTo(3.0),
      );

      expect(
        contrastRatio(colors.borders.focus, colors.surfaces.canvas),
        greaterThanOrEqualTo(3.0),
      );

      expect(
        contrastRatio(colors.borders.focus, colors.surfaces.defaultSurface),
        greaterThanOrEqualTo(3.0),
      );

      expect(
        contrastRatio(colors.text.onBrand, colors.actions.primary.bgDefault),
        greaterThanOrEqualTo(4.5),
      );

      expect(
        contrastRatio(
            colors.text.onBrand, colors.actions.destructive.bgDefault),
        greaterThanOrEqualTo(4.5),
      );

      expect(
        contrastRatio(
            colors.severities.error.fg, colors.severities.error.surface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrastRatio(
            colors.severities.warning.fg, colors.severities.warning.surface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrastRatio(
            colors.severities.info.fg, colors.severities.info.surface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrastRatio(
            colors.severities.hint.fg, colors.severities.hint.surface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrastRatio(
            colors.severities.success.fg, colors.severities.success.surface),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('Dark mode semantic contrast pairs meet threshold', () {
      const colors = AppSemanticColors.dark();

      expect(
        contrastRatio(colors.text.primary, colors.surfaces.canvas),
        greaterThanOrEqualTo(4.5),
      );

      expect(
        contrastRatio(colors.text.primary, colors.surfaces.defaultSurface),
        greaterThanOrEqualTo(4.5),
      );

      expect(
        contrastRatio(colors.text.secondary, colors.surfaces.canvas),
        greaterThanOrEqualTo(4.5),
      );

      expect(
        contrastRatio(colors.text.secondary, colors.surfaces.defaultSurface),
        greaterThanOrEqualTo(4.5),
      );

      expect(
        contrastRatio(colors.text.tertiary, colors.surfaces.canvas),
        greaterThanOrEqualTo(4.5),
      );

      expect(
        contrastRatio(colors.text.link, colors.surfaces.defaultSurface),
        greaterThanOrEqualTo(4.5),
      );

      expect(
        contrastRatio(colors.text.inverse, colors.surfaces.inverse),
        greaterThanOrEqualTo(4.5),
      );

      expect(
        contrastRatio(colors.borders.strong, colors.surfaces.defaultSurface),
        greaterThanOrEqualTo(3.0),
      );

      expect(
        contrastRatio(colors.borders.focus, colors.surfaces.canvas),
        greaterThanOrEqualTo(3.0),
      );

      expect(
        contrastRatio(colors.borders.focus, colors.surfaces.defaultSurface),
        greaterThanOrEqualTo(3.0),
      );

      expect(
        contrastRatio(colors.text.onBrand, colors.actions.primary.bgDefault),
        greaterThanOrEqualTo(4.5),
      );

      expect(
        contrastRatio(
            colors.text.onBrand, colors.actions.destructive.bgDefault),
        greaterThanOrEqualTo(4.5),
      );

      expect(
        contrastRatio(
            colors.severities.error.fg, colors.severities.error.surface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrastRatio(
            colors.severities.warning.fg, colors.severities.warning.surface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrastRatio(
            colors.severities.info.fg, colors.severities.info.surface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrastRatio(
            colors.severities.hint.fg, colors.severities.hint.surface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrastRatio(
            colors.severities.success.fg, colors.severities.success.surface),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('Negative fixture: adulterated low-contrast pair fails check', () {
      const adulteratedFg = ColorPrimitives.neutral200;
      const lightBg = ColorPrimitives.neutral0;
      final ratio = contrastRatio(adulteratedFg, lightBg);
      expect(ratio, lessThan(4.5));
    });
  });
}
