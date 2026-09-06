import 'package:flutter/material.dart';
import '../../domain/model/diagram/diagram_notation.dart';
import '../../domain/model/diagram/diagram_scene.dart';
import '../theme/tokens/color_semantic.dart';
import 'class_box_painter.dart';
import 'flowchart_painter.dart';
import 'structogram_painter.dart';

CustomPainter structurePainterFor(
  DiagramNotation notation,
  DiagramScene scene,
  AppSemanticColors colors,
) {
  return switch (notation) {
    DiagramNotation.flowchart => FlowchartPainter(scene: scene, colors: colors),
    DiagramNotation.structogram => StructogramPainter(scene: scene, colors: colors),
    DiagramNotation.classDiagram => ClassBoxPainter(scene: scene, colors: colors),
  };
}
