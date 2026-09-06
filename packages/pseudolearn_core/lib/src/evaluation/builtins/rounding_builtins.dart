import '../../domain/pseudo_integer.dart';
import '../values/random_source.dart';

final class RoundingBuiltins {
  const RoundingBuiltins();

  PseudoInteger? truncate(double x) =>
      PseudoInteger.fromBigInt(BigInt.from(x.truncateToDouble()));

  PseudoInteger? round(double x) =>
      PseudoInteger.fromBigInt(BigInt.from(x.roundToDouble()));

  double random(RandomSource source) => source.nextUnitInterval();
}
