import 'dart:math' as math;

import '../../domain/model/diagram/class_diagram_metrics.dart';
import '../../domain/model/diagram/class_model.dart';
import '../../domain/model/diagram/diagram_metrics.dart';
import '../diagram/text_metrics.dart';

final class ClassBoxSize {
  final double width;
  final double headerHeight;
  final double attributesHeight;
  final double methodsHeight;

  const ClassBoxSize({
    required this.width,
    required this.headerHeight,
    required this.attributesHeight,
    required this.methodsHeight,
  });

  double get height => headerHeight + attributesHeight + methodsHeight;
}

final class ClassBoxSizing {
  final TextMetrics _text;

  const ClassBoxSizing([this._text = const TextMetrics()]);

  ClassBoxSize of(ClassBox box) => ClassBoxSize(
        width: _widthOf(box),
        headerHeight: ClassDiagramMetrics.headerHeight,
        attributesHeight: compartmentHeightOf(box.attributes.length),
        methodsHeight: compartmentHeightOf(box.methods.length),
      );

  static double compartmentHeightOf(int rowCount) => rowCount == 0
      ? ClassDiagramMetrics.emptyCompartmentHeight
      : rowCount * ClassDiagramMetrics.rowHeight +
          ClassDiagramMetrics.boxPadding;

  double _widthOf(ClassBox box) {
    var widest = _headerWidthOf(box.name);
    for (final row in box.attributes) {
      widest = math.max(widest, _rowWidthOf(row));
    }
    for (final row in box.methods) {
      widest = math.max(widest, _rowWidthOf(row));
    }
    return widest.clamp(
      ClassDiagramMetrics.boxMinWidth,
      ClassDiagramMetrics.boxMaxWidth,
    );
  }

  double _headerWidthOf(String name) =>
      _text.advanceUnits(name) * DiagramMetrics.fontSize +
      ClassDiagramMetrics.boxPadding * 2;

  double _rowWidthOf(ClassMemberRow row) =>
      _text.advanceUnits(row.text) * DiagramMetrics.fontSize +
      ClassDiagramMetrics.boxPadding * 2 +
      ClassDiagramMetrics.visibilityColumn;
}
