import '../../domain/pseudo_integer.dart';

final class IntegerDivision {
  const IntegerDivision();

  PseudoInteger? quotient(PseudoInteger dividend, PseudoInteger divisor) =>
      PseudoInteger.fromBigInt(dividend.value ~/ divisor.value);

  PseudoInteger? remainder(PseudoInteger dividend, PseudoInteger divisor) =>
      PseudoInteger.fromBigInt(dividend.value.remainder(divisor.value));
}
