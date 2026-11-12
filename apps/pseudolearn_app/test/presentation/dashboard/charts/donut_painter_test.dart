import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/dashboard/charts/donut_painter.dart';

const Color _track = Color(0xFFDDDDDD);
const Color _ink = Color(0xFF117788);

DonutPainter _painter(List<DonutSlice> slices) =>
    DonutPainter(slices: slices, trackColor: _track, stroke: 16, progress: 1);

void _paint(DonutPainter painter, Size size) {
  final recorder = PictureRecorder();
  painter.paint(Canvas(recorder), size);
  recorder.endRecording().dispose();
}

void main() {
  group('DonutPainter', () {
    test('paints one slice per value', () {
      final slices = const [DonutSlice(value: 2, color: _ink), DonutSlice(value: 1, color: _track)];

      expect(() => _paint(_painter(slices), const Size(112, 112)), returnsNormally);
    });

    test('an empty library only paints the track and never divides by zero', () {
      final slices = const [DonutSlice(value: 0, color: _ink), DonutSlice(value: 0, color: _ink)];

      expect(() => _paint(_painter(slices), const Size(112, 112)), returnsNormally);
      expect(() => _paint(_painter(const []), const Size(112, 112)), returnsNormally);
    });

    test('repaints only when its inputs change', () {
      final slices = const [DonutSlice(value: 1, color: _ink)];

      expect(_painter(slices).shouldRepaint(_painter(slices)), isFalse);
      expect(_painter(slices).shouldRepaint(_painter(const [])), isTrue);
    });
  });
}
