final class LogicalEvaluator {
  const LogicalEvaluator();

  bool not(bool operand) => !operand;

  bool and(bool left, bool right) => left && right;

  bool or(bool left, bool right) => left || right;
}
