import '../../domain/model/knowledge/ast_construct.dart';

AstConstruct? rustConstructOf(String syntaxKind) => switch (syntaxKind) {
  'conditional' => AstConstruct.conditional,
  'switch' => AstConstruct.multipleSelection,
  'while_loop' => AstConstruct.conditionalLoop,
  'repeat_loop' => AstConstruct.postConditionalLoop,
  'for_loop' => AstConstruct.countedLoop,
  'dimension_declaration' => AstConstruct.arrayDeclaration,
  'subroutine' => AstConstruct.subprogram,
  'class_unit' => AstConstruct.classDeclaration,
  _ => null,
};
