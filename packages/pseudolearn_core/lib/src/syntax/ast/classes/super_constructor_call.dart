import '../ast_node.dart';

bool isSuperConstructorCall(StatementNode stmt) {
  if (stmt is MethodCallStatementNode &&
      stmt.target is SuperExpressionNode &&
      stmt.methodName.toLowerCase() == 'constructor') {
    return true;
  }
  return false;
}
