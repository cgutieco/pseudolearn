import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/editor/components/keyword_help_geometry.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/component_metrics.dart';

const _size = ComponentMetricsTokens.keywordHelpChipSize;
const _gap = ComponentMetricsTokens.keywordHelpChipGap;
const _area = Size(360, 640);

void main() {
  group('keywordChipSpot', () {
    test('sits centred just above a keyword with room above', () {
      const keyword = Rect.fromLTWH(100, 80, 60, 20);
      final spot = keywordChipSpot(keyword, _area);
      expect(spot.dy, 80 - _size - _gap);
      expect(spot.dx, 130 - _size / 2);
    });

    test('drops below a keyword on the first line', () {
      const keyword = Rect.fromLTWH(40, 4, 60, 20);
      final spot = keywordChipSpot(keyword, _area);
      expect(spot.dy, 24 + _gap);
    });

    test('never leaves the left edge', () {
      const keyword = Rect.fromLTWH(0, 80, 4, 20);
      expect(keywordChipSpot(keyword, _area).dx, 0);
    });

    test('never leaves the right edge', () {
      const keyword = Rect.fromLTWH(350, 80, 10, 20);
      expect(keywordChipSpot(keyword, _area).dx, 360 - _size);
    });

    test('an area narrower than the chip pins it to the left', () {
      const keyword = Rect.fromLTWH(5, 80, 10, 20);
      expect(keywordChipSpot(keyword, const Size(10, 100)).dx, 0);
    });
  });
}
