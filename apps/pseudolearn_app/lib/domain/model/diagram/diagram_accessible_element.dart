import '../analysis/source_range.dart';
import 'diagram_scene.dart';

enum DiagramAccessibleRole { box, row, relation }

final class DiagramAccessibleBounds {
  final double left;
  final double top;
  final double width;
  final double height;

  const DiagramAccessibleBounds({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });
}

final class DiagramAccessibleElement {
  final DiagramAccessibleRole role;
  final String text;
  final DiagramEdgeKind? relationKind;
  final String fromName;
  final String toName;
  final List<String> diagnostics;
  final DiagramAccessibleBounds bounds;
  final SourceRange? range;

  const DiagramAccessibleElement({
    required this.role,
    required this.text,
    required this.bounds,
    required this.range,
    this.relationKind,
    this.fromName = '',
    this.toName = '',
    this.diagnostics = const [],
  });

  bool get isValid => diagnostics.isEmpty;
}
