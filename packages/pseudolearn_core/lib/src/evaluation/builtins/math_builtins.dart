import 'dart:math' as math;

final class MathBuiltins {
  const MathBuiltins();

  double? squareRoot(double x) => _finiteOrNull(math.sqrt(x));

  double? absoluteValue(double x) => _finiteOrNull(x.abs());

  double? naturalLogarithm(double x) => _finiteOrNull(math.log(x));

  double? exponential(double x) => _finiteOrNull(math.exp(x));

  double? sine(double x) => _finiteOrNull(math.sin(x));

  double? cosine(double x) => _finiteOrNull(math.cos(x));

  double? arcTangent(double x) => _finiteOrNull(math.atan(x));

  double? _finiteOrNull(double value) => value.isFinite ? value : null;
}
