import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/dashboard/charts/ring_painter.dart';

const Color _track = Color(0xFFDDDDDD);
const Color _ink = Color(0xFF117788);

ConcentricRingsPainter _painter(List<RingTrack> rings, {double progress = 1}) => ConcentricRingsPainter(
  rings: rings,
  trackColor: _track,
  stroke: 10,
  gap: 4,
  progress: progress,
);

void _paint(ConcentricRingsPainter painter, Size size) {
  final recorder = PictureRecorder();
  painter.paint(Canvas(recorder), size);
  recorder.endRecording().dispose();
}

void main() {
  group('ConcentricRingsPainter', () {
    test('paints three rings, full and partial', () {
      final rings = const [
        RingTrack(ratio: 1, color: _ink),
        RingTrack(ratio: 0.4, color: _ink),
        RingTrack(ratio: 0, color: _ink),
      ];

      expect(() => _paint(_painter(rings), const Size(184, 184)), returnsNormally);
    });

    test('ratios beyond the unit range are clamped instead of failing', () {
      final rings = const [RingTrack(ratio: 3, color: _ink), RingTrack(ratio: -1, color: _ink)];

      expect(() => _paint(_painter(rings), const Size(100, 100)), returnsNormally);
    });

    test('no rings and a degenerate canvas paint nothing without failing', () {
      expect(() => _paint(_painter(const []), const Size(100, 100)), returnsNormally);
      expect(() => _paint(_painter(const [RingTrack(ratio: 1, color: _ink)]), Size.zero), returnsNormally);
    });

    test('repaints only when progress or rings change', () {
      final rings = const [RingTrack(ratio: 0.5, color: _ink)];

      expect(_painter(rings, progress: 0).shouldRepaint(_painter(rings)), isTrue);
      expect(_painter(rings).shouldRepaint(_painter(rings)), isFalse);
    });
  });
}
