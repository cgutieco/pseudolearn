import '../ast/ast_node.dart';

final class DesignatorValidator {
  const DesignatorValidator._();

  static bool isDesignator(ExpressionNode node) => switch (node) {
        VariableExpressionNode() ||
        ArrayAccessExpressionNode() ||
        MemberAccessExpressionNode() =>
          true,
        _ => false,
      };
}
