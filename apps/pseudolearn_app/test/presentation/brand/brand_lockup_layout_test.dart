import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/brand/brand_lockup_layout.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/brand_metrics.dart';

void main() {
  group('Brand lockup layout', () {
    test('the horizontal composition matches the master vector', () {
      final layout = BrandLockupLayout.horizontal(100);

      expect(layout.size.width, closeTo(749.866, 0.001));
      expect(layout.size.height, closeTo(122.150, 0.001));
      expect(layout.plate.width, closeTo(122.150, 0.001));
      expect(layout.plate.top, closeTo(0, 0.001));
      expect(layout.wordmark.dx, closeTo(151.466, 0.001));
      expect(layout.wordmark.dy, closeTo(21.975, 0.001));
    });

    test('the vertical composition matches the master vector', () {
      final layout = BrandLockupLayout.vertical(100);

      expect(layout.size.width, closeTo(598.400, 0.001));
      expect(layout.size.height, closeTo(292.126, 0.001));
      expect(layout.plate.width, closeTo(167.520, 0.001));
      expect(layout.plate.left, closeTo(215.440, 0.001));
      expect(layout.wordmark.dy, closeTo(216.926, 0.001));
    });

    test('the plate is centred on the cap line, not on the ink box', () {
      final layout = BrandLockupLayout.horizontal(100);
      const capCenter =
          (BrandMetricsTokens.wordmarkCapTop + BrandMetricsTokens.wordmarkCapBaseline) / 2 * 100;
      final boxTop = BrandMetricsTokens.wordmarkInkTop * 100 - layout.wordmark.dy;

      expect(layout.plate.center.dy + boxTop, closeTo(capCenter, 0.001));
    });

    test('the clear space is the width of the mast at the size in use', () {
      final layout = BrandLockupLayout.horizontal(100);

      expect(
        layout.clearSpace,
        closeTo(layout.plate.width * BrandMetricsTokens.lockupClearSpace, 0.001),
      );
    });

    test('every measure scales with the type size and none is negative', () {
      final small = BrandLockupLayout.vertical(10);
      final large = BrandLockupLayout.vertical(200);

      expect(large.size.width, closeTo(small.size.width * 20, 0.001));
      expect(large.size.height, closeTo(small.size.height * 20, 0.001));
      expect(small.wordmark.dy, greaterThan(0));
      expect(small.plate.left, greaterThanOrEqualTo(0));
    });

    test('a type size of zero collapses without producing a broken box', () {
      final layout = BrandLockupLayout.horizontal(0);

      expect(layout.size, Size.zero);
      expect(layout.plate, Rect.zero);
      expect(layout.clearSpace, 0);
    });
  });
}
