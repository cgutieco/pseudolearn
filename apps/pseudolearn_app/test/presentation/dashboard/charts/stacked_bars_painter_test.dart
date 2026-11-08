import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/dashboard/charts/stacked_bars_painter.dart';

const List<Color> _series = [Color(0xFF117788), Color(0xFF22AA44), Color(0xFFCC8800)];
const Color _baseline = Color(0xFFDDDDDD);

StackedBarsPainter _painter(List<StackedColumn> columns, {required int peak}) => StackedBarsPainter(
  columns: columns,
  colors: _series,
  baselineColor: _baseline,
  peak: peak,
  progress: 1,
);

void _paint(StackedBarsPainter painter, Size size) {
  final recorder = PictureRecorder();
  painter.paint(Canvas(recorder), size);
  recorder.endRecording().dispose();
}

void main() {
  group('StackedBarsPainter', () {
    test('stacks every series of an eight week window', () {
      final columns = [for (var week = 0; week < 8; week++) StackedColumn([week, 1, week % 2])];

      expect(() => _paint(_painter(columns, peak: 9), const Size(320, 120)), returnsNormally);
    });

    test('a window without activity has a zero peak and does not divide by it', () {
      final columns = [for (var week = 0; week < 8; week++) const StackedColumn([0, 0, 0])];

      expect(() => _paint(_painter(columns, peak: 0), const Size(320, 120)), returnsNormally);
    });

    test('more series than colors reuse the palette and no columns paint nothing', () {
      expect(
        () => _paint(_painter(const [StackedColumn([1, 1, 1, 1, 1])], peak: 5), const Size(40, 120)),
        returnsNormally,
      );
      expect(() => _paint(_painter(const [], peak: 0), const Size(40, 120)), returnsNormally);
    });

    test('repaints when the peak changes', () {
      const columns = [StackedColumn([1])];

      expect(_painter(columns, peak: 1).shouldRepaint(_painter(columns, peak: 2)), isTrue);
      expect(_painter(columns, peak: 1).shouldRepaint(_painter(columns, peak: 1)), isFalse);
    });
  });
}
