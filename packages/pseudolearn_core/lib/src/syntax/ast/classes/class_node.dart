part of '../ast_node.dart';

final class ClassNode extends AstNode {
  final String name;
  final Span nameSpan;
  final String? superclassName;
  final Span? superclassSpan;
  final List<ClassMemberNode> members;

  const ClassNode({
    required super.id,
    required super.span,
    required this.name,
    required this.nameSpan,
    this.superclassName,
    this.superclassSpan,
    required this.members,
  });
}
