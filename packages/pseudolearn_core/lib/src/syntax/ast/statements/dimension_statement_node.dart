part of '../ast_node.dart';

final class ArrayDeclaratorNode extends AstNode {
  final String name;
  final Span nameSpan;
  final List<ExpressionNode> dimensions;

  const ArrayDeclaratorNode({
    required super.id,
    required super.span,
    required this.name,
    required this.nameSpan,
    required this.dimensions,
  });
}

final class DimensionStatementNode extends StatementNode {
  final List<ArrayDeclaratorNode> arrays;
  final PrimitiveType? elementType;
  final String? customElementTypeName;
  final Span typeSpan;

  const DimensionStatementNode({
    required super.id,
    required super.span,
    required this.arrays,
    this.elementType,
    this.customElementTypeName,
    required this.typeSpan,
  });
}
