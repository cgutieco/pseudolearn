import 'reference_run.dart';

final class ReferenceFigureLayer {
  final int fromStep;
  final int? untilStep;
  final String svg;

  const ReferenceFigureLayer({
    required this.fromStep,
    required this.svg,
    this.untilStep,
  });

  bool visibleAt(int step) =>
      fromStep <= step && (untilStep == null || untilStep! >= step);
}

final class ReferenceFigurePanel {
  final String zone;
  final int fromStep;
  final List<ReferenceRun> runs;

  const ReferenceFigurePanel({
    required this.zone,
    required this.fromStep,
    required this.runs,
  });
}

final class ReferenceFigure {
  final String id;
  final String number;
  final String alt;
  final String description;
  final List<ReferenceRun> caption;
  final String svg;
  final List<ReferenceFigureLayer> layers;
  final List<List<ReferenceRun>> steps;
  final List<ReferenceFigurePanel> panels;

  const ReferenceFigure({
    required this.id,
    required this.number,
    required this.alt,
    required this.description,
    required this.caption,
    required this.svg,
    this.layers = const [],
    this.steps = const [],
    this.panels = const [],
  });

  int get stepCount => steps.length;

  String svgAt(int step) {
    final visible = layers
        .where((layer) => layer.visibleAt(step))
        .map((layer) => layer.svg)
        .join();
    final closing = svg.lastIndexOf('</svg>');
    if (closing < 0 || visible.isEmpty) return svg;
    return '${svg.substring(0, closing)}$visible${svg.substring(closing)}';
  }

  List<ReferenceFigurePanel> panelsAt(int step) =>
      panels.where((panel) => panel.fromStep <= step).toList();

  List<String> zonesAt(int step) {
    final zones = <String>[];
    for (final panel in panelsAt(step)) {
      if (!zones.contains(panel.zone)) zones.add(panel.zone);
    }
    return zones;
  }
}

double svgAspectRatio(String svg) {
  const marker = 'viewBox="';
  final start = svg.indexOf(marker);
  if (start < 0) return 1;
  final end = svg.indexOf('"', start + marker.length);
  if (end < 0) return 1;
  final numbers = svg
      .substring(start + marker.length, end)
      .split(' ')
      .map(double.tryParse)
      .toList();
  if (numbers.length != 4) return 1;
  final width = numbers[2];
  final height = numbers[3];
  if (width == null || height == null || width <= 0 || height <= 0) return 1;
  return width / height;
}
