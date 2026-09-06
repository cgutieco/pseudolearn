import '../../domain/model/diagram/diagram_notation.dart';

const String diagramArgumentSeparator = '#';

const Map<String, DiagramNotation> _notations = {
  'ordinograma': DiagramNotation.flowchart,
  'estructograma': DiagramNotation.structogram,
  'clases': DiagramNotation.classDiagram,
};

final class DiagramMarkerArgument {
  final String exampleId;
  final DiagramNotation notation;

  const DiagramMarkerArgument({
    required this.exampleId,
    required this.notation,
  });

  static DiagramMarkerArgument? parse(String argument) {
    final separator = argument.indexOf(diagramArgumentSeparator);
    if (separator <= 0 || separator == argument.length - 1) return null;
    final notation = _notations[argument.substring(separator + 1)];
    if (notation == null) return null;
    return DiagramMarkerArgument(
      exampleId: argument.substring(0, separator),
      notation: notation,
    );
  }
}
