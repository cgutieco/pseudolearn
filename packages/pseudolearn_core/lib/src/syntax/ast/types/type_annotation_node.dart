part of '../ast_node.dart';

sealed class TypeAnnotationNode extends AstNode {
  const TypeAnnotationNode({
    required super.id,
    required super.span,
  });
}

final class PrimitiveTypeAnnotationNode extends TypeAnnotationNode {
  final PrimitiveType primitiveType;

  const PrimitiveTypeAnnotationNode({
    required super.id,
    required super.span,
    required this.primitiveType,
  });
}

final class CustomTypeAnnotationNode extends TypeAnnotationNode {
  final String name;

  const CustomTypeAnnotationNode({
    required super.id,
    required super.span,
    required this.name,
  });
}
