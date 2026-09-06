part of '../ast_node.dart';

sealed class ClassMemberNode extends AstNode {
  const ClassMemberNode({
    required super.id,
    required super.span,
  });
}

final class ClassFieldNode extends ClassMemberNode {
  final Visibility visibility;
  final StatementNode declaration;

  const ClassFieldNode({
    required super.id,
    required super.span,
    this.visibility = Visibility.public,
    required this.declaration,
  });
}

final class MethodDeclarationNode extends ClassMemberNode {
  final Visibility visibility;
  final String name;
  final Span nameSpan;
  final List<ParameterNode> parameters;
  final PrimitiveType? returnType;
  final String? customReturnType;
  final Span? returnTypeSpan;
  final List<StatementNode> body;

  const MethodDeclarationNode({
    required super.id,
    required super.span,
    this.visibility = Visibility.public,
    required this.name,
    required this.nameSpan,
    required this.parameters,
    this.returnType,
    this.customReturnType,
    this.returnTypeSpan,
    required this.body,
  });
}

final class ConstructorDeclarationNode extends ClassMemberNode {
  final List<ParameterNode> parameters;
  final List<StatementNode> body;

  const ConstructorDeclarationNode({
    required super.id,
    required super.span,
    required this.parameters,
    required this.body,
  });
}
