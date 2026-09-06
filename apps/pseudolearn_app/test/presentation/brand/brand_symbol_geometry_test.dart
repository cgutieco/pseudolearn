import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/brand/brand_symbol_geometry.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/brand_metrics.dart';

void main() {
  group('Brand symbol geometry', () {
    test('the route leaves the terminal node and ends where the pennant hangs', () {
      final turns = brandSymbolTurns();

      expect(turns.length, BrandMetricsTokens.symbolTurnCount + 1);
      expect(turns.first, const Offset(10, 86));
      expect(turns.last, const Offset(88, 8));
    });

    test('every run measures the same, so the turns read as equal steps', () {
      final turns = brandSymbolTurns();

      for (var index = 0; index + 1 < turns.length; index++) {
        expect(
          (turns[index + 1] - turns[index]).distance,
          closeTo(BrandMetricsTokens.symbolRun, 1e-9),
        );
      }
    });

    test('the runs alternate right and up, with no diagonal', () {
      final turns = brandSymbolTurns();

      for (var index = 0; index + 1 < turns.length; index++) {
        final step = turns[index + 1] - turns[index];
        expect(step.dx == 0 || step.dy == 0, isTrue);
      }
    });

    test('the ink box is the square the master vector declares', () {
      final ink = brandSymbolInkBox();

      expect(ink, const Rect.fromLTRB(0, 1, 95, 96));
      expect(ink.width, ink.height);
    });

    test('the path covers the route and leaves the rest of the box empty', () {
      final path = buildBrandSymbolPath();
      final bounds = path.getBounds();

      expect(bounds.left, closeTo(0, 0.5));
      expect(bounds.top, closeTo(1, 0.5));
      expect(bounds.right, closeTo(95, 0.5));
      expect(bounds.bottom, closeTo(96, 0.5));
      expect(path.contains(const Offset(10, 86)), isTrue);
      expect(path.contains(const Offset(70, 14)), isTrue);
      expect(path.contains(const Offset(70, 80)), isFalse);
      expect(path.contains(const Offset(94, 94)), isFalse);
    });

    test('the pennant narrows towards its point, which is the only diagonal', () {
      final path = buildBrandSymbolPath();

      expect(path.contains(const Offset(85, 5)), isTrue);
      expect(path.contains(const Offset(70, 5)), isFalse);
      expect(path.contains(const Offset(85, 23)), isTrue);
      expect(path.contains(const Offset(70, 23)), isFalse);
    });
  });
}
