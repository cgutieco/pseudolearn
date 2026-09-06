import '../../domain/pseudo_integer.dart';

final class IntegerArithmetic {
  const IntegerArithmetic();

  PseudoInteger? add(PseudoInteger a, PseudoInteger b) =>
      PseudoInteger.fromBigInt(a.value + b.value);

  PseudoInteger? subtract(PseudoInteger a, PseudoInteger b) =>
      PseudoInteger.fromBigInt(a.value - b.value);

  PseudoInteger? multiply(PseudoInteger a, PseudoInteger b) =>
      PseudoInteger.fromBigInt(a.value * b.value);

  PseudoInteger? negate(PseudoInteger a) => PseudoInteger.fromBigInt(-a.value);

  PseudoInteger? power(PseudoInteger base, PseudoInteger exponent) {
    if (exponent.isNegative) return null;
    if (exponent.value == BigInt.zero) return PseudoInteger.one;
    if (base.value == BigInt.zero) return PseudoInteger.zero;
    if (base.value == BigInt.one) return PseudoInteger.one;
    if (base.value == -BigInt.one) {
      return exponent.value.isEven
          ? PseudoInteger.one
          : PseudoInteger.fromBigInt(-BigInt.one);
    }
    if (exponent.value > BigInt.from(64)) return null;
    return _repeatedMultiplication(base.value, exponent.value.toInt());
  }

  PseudoInteger? _repeatedMultiplication(BigInt base, int exponent) {
    var result = BigInt.one;
    for (var i = 0; i < exponent; i++) {
      result *= base;
      if (PseudoInteger.fromBigInt(result) == null) return null;
    }
    return PseudoInteger.fromBigInt(result);
  }
}
