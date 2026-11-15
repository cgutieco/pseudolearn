import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/dashboard/charts/radar_painter.dart';

const Color _grid = Color(0xFF999999);
const Color _fill = Color(0xFF117788);

RadarPainter _painter(List<double> ratios, {double progress = 1}) => RadarPainter(
  ratios: ratios,
  inset: 10,
  rings: 4,
  gridColor: _grid,
  fillColor: _fill,
  progress: progress,
);

void _paint(RadarPainter painter, Size size) {
  final recorder = PictureRecorder();
  painter.paint(Canvas(recorder), size);
  recorder.endRecording().dispose();
}

void main() {
  group('radarPointOf', () {
    test('the first axis points straight up', () {
      final point = radarPointOf(center: const Offset(50, 50), radius: 40, index: 0, count: 4);

      expect(point.dx, closeTo(50, 1e-9));
      expect(point.dy, closeTo(10, 1e-9));
    });

    test('axes are spread evenly clockwise', () {
      final point = radarPointOf(center: Offset.zero, radius: 10, index: 1, count: 4);

      expect(point.dx, closeTo(10, 1e-9));
      expect(point.dy, closeTo(0, 1e-9));
    });

    test('a zero radius collapses every axis onto the center', () {
      final point = radarPointOf(center: const Offset(3, 4), radius: 0, index: 2, count: 11);

      expect(point, const Offset(3, 4));
    });
  });

  group('RadarPainter', () {
    test('paints eleven axes with ratios outside the unit range', () {
      expect(
        () => _paint(_painter([for (var index = 0; index < 11; index++) index / 5 - 0.5]), const Size(300, 300)),
        returnsNormally,
      );
    });

    test('fewer than three axes paint nothing and do not fail', () {
      expect(() => _paint(_painter(const [0.5, 1]), const Size(300, 300)), returnsNormally);
      expect(() => _paint(_painter(const []), const Size(300, 300)), returnsNormally);
    });

    test('a canvas smaller than the label inset does not fail', () {
      expect(() => _paint(_painter(const [1, 1, 1]), const Size(4, 4)), returnsNormally);
    });

    test('repaints when the animation advances and not otherwise', () {
      final ratios = const [0.1, 0.2, 0.3];

      expect(_painter(ratios, progress: 0.5).shouldRepaint(_painter(ratios)), isTrue);
      expect(_painter(ratios).shouldRepaint(_painter(ratios)), isFalse);
    });
  });
}
