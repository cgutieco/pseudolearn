part of '../ast_node.dart';

final class SubroutineDeclarationNode extends AstNode {
  final String name;
  final Span nameSpan;
  final List<ParameterNode> parameters;
  final PrimitiveType? returnType;
  final String? customReturnType;
  final Span? returnTypeSpan;
  final List<StatementNode> body;

  const SubroutineDeclarationNode({
    required super.id,
    required super.span,
    required this.name,
    required this.nameSpan,
    required this.parameters,
    this.returnType,
    this.customReturnType,
    this.returnTypeSpan,
    required this.body,
  });
}
