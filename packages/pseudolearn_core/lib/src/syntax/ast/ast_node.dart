import '../../domain/node_id.dart';
import '../../domain/primitive_type.dart';
import '../../domain/span.dart';
import '../../domain/visibility.dart';
import 'operators.dart';

part 'program_node.dart';
part 'statements/variable_declarator_node.dart';
part 'statements/variable_declaration_node.dart';
part 'statements/dimension_statement_node.dart';
part 'statements/simple_statement_nodes.dart';
part 'statements/control_statement_nodes.dart';
part 'statements/procedural_statement_nodes.dart';
part 'subroutines/parameter_node.dart';
part 'subroutines/subroutine_declaration_node.dart';
part 'classes/class_node.dart';
part 'classes/class_member_nodes.dart';
part 'types/type_annotation_node.dart';
part 'expressions/variable_expression_node.dart';
part 'expressions/literal_expression_node.dart';
part 'expressions/operator_expression_nodes.dart';
part 'expressions/access_and_call_nodes.dart';
part 'expressions/oop_expression_nodes.dart';

sealed class AstNode {
  final NodeId id;
  final Span span;

  const AstNode({
    required this.id,
    required this.span,
  });
}

sealed class StatementNode extends AstNode {
  const StatementNode({
    required super.id,
    required super.span,
  });
}

sealed class ExpressionNode extends AstNode {
  const ExpressionNode({
    required super.id,
    required super.span,
  });
}
