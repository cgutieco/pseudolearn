import 'dart:math' as math;

final class RealArithmetic {
  const RealArithmetic();

  double add(double a, double b) => a + b;

  double subtract(double a, double b) => a - b;

  double multiply(double a, double b) => a * b;

  double divide(double a, double b) => a / b;

  double power(double base, double exponent) =>
      math.pow(base, exponent).toDouble();

  bool isFiniteResult(double value) => value.isFinite;
}
