part of 'ast_node.dart';

final class SourceUnitNode extends AstNode {
  final AlgorithmNode? algorithm;
  final List<SubroutineDeclarationNode> subroutines;
  final List<ClassNode> classes;
  final List<AstNode> declarations;

  const SourceUnitNode({
    required super.id,
    required super.span,
    required this.algorithm,
    required this.subroutines,
    this.classes = const [],
    required this.declarations,
  });
}

final class AlgorithmNode extends AstNode {
  final String name;
  final Span nameSpan;
  final List<StatementNode> body;

  const AlgorithmNode({
    required super.id,
    required super.span,
    required this.name,
    required this.nameSpan,
    required this.body,
  });
}
