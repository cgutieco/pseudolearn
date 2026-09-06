import 'package:flutter/material.dart';
import '../../domain/model/diagram/diagram_scene.dart';
import '../../domain/model/diagram/structogram_metrics.dart';

final class StructogramShapes {
  const StructogramShapes._();

  static Path outlineOf(DiagramShape shape, Rect rect) => Path()..addRect(rect);

  static List<Path> decorationsOf(DiagramShape shape, Rect rect) {
    if (shape != DiagramShape.cellCall) return const [];
    const inset = StructogramMetrics.callBarInset;
    return [
      Path()
        ..moveTo(rect.left + inset, rect.top)
        ..lineTo(rect.left + inset, rect.bottom),
      Path()
        ..moveTo(rect.right - inset, rect.top)
        ..lineTo(rect.right - inset, rect.bottom),
    ];
  }

  static Path exitMarker(Rect rect) {
    const size = StructogramMetrics.exitMarkerSize;
    final right = rect.right - StructogramMetrics.cellPadding;
    return Path()
      ..moveTo(right, rect.center.dy)
      ..lineTo(right - size, rect.center.dy - size / 2)
      ..lineTo(right - size, rect.center.dy + size / 2)
      ..close();
  }

  static List<Path> headerDividers(
    Rect header, {
    required List<double> boundaries,
    required bool isBinary,
  }) {
    if (boundaries.isEmpty) return [_bandLine(header)];
    if (isBinary) return _wedge(header, boundaries.first);
    return _caseFan(header, boundaries);
  }

  static Path _bandLine(Rect header) {
    final top = header.bottom - StructogramMetrics.branchLabelBand;
    return Path()
      ..moveTo(header.left, top)
      ..lineTo(header.right, top);
  }

  static List<Path> _wedge(Rect header, double apex) => [
        Path()
          ..moveTo(header.left, header.top)
          ..lineTo(apex, header.bottom),
        Path()
          ..moveTo(header.right, header.top)
          ..lineTo(apex, header.bottom),
      ];

  static List<Path> _caseFan(Rect header, List<double> boundaries) {
    final last = boundaries.last;
    final span = last - header.left;
    if (span <= 0) return [_bandLine(header)];
    final paths = <Path>[
      Path()
        ..moveTo(header.left, header.top)
        ..lineTo(last, header.bottom),
    ];
    for (var index = 0; index < boundaries.length - 1; index++) {
      final x = boundaries[index];
      final y = header.top + header.height * (x - header.left) / span;
      paths.add(Path()
        ..moveTo(x, y)
        ..lineTo(x, header.bottom));
    }
    return paths;
  }
}
