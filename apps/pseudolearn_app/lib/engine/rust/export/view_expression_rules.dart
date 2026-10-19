import '../rust_view_semantics.dart';

abstract interface class ViewExpressionRules {
  String get thisText;

  String get superText;

  String literal(RustViewLiteral literal);

  String unary(String operatorIdentity, String operand);

  Map<String, String> get binaryOperators;

  String builtin(String identity, List<String> arguments);

  String instantiation(String className, List<String> arguments);

  String index(String position);
}
