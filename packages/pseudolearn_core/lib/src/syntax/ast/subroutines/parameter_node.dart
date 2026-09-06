part of '../ast_node.dart';

enum ParameterPassingMode {
  byValue,
  byReference,
}

final class ParameterNode extends AstNode {
  final String name;
  final Span nameSpan;
  final int dimensionCount;
  final PrimitiveType? type;
  final String? customTypeName;
  final Span? typeSpan;
  final ParameterPassingMode passingMode;
  final Span? passingModeSpan;

  const ParameterNode({
    required super.id,
    required super.span,
    required this.name,
    required this.nameSpan,
    this.dimensionCount = 0,
    this.type,
    this.customTypeName,
    this.typeSpan,
    this.passingMode = ParameterPassingMode.byValue,
    this.passingModeSpan,
  });
}
