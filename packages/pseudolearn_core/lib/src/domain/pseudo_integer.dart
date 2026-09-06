final class PseudoInteger implements Comparable<PseudoInteger> {
  static final BigInt _minValue = BigInt.parse('-9223372036854775808');
  static final BigInt _maxValue = BigInt.parse('9223372036854775807');

  static final PseudoInteger zero = PseudoInteger._(BigInt.zero);
  static final PseudoInteger one = PseudoInteger._(BigInt.one);
  static final PseudoInteger minValue = PseudoInteger._(_minValue);
  static final PseudoInteger maxValue = PseudoInteger._(_maxValue);

  final BigInt value;

  PseudoInteger._(this.value);

  static bool _isInRange(BigInt candidate) =>
      candidate >= _minValue && candidate <= _maxValue;

  static PseudoInteger? fromBigInt(BigInt candidate) =>
      _isInRange(candidate) ? PseudoInteger._(candidate) : null;

  factory PseudoInteger.fromInt(int hostValue) =>
      PseudoInteger._(BigInt.from(hostValue));

  static PseudoInteger? tryParse(String lexeme) {
    final parsed = BigInt.tryParse(lexeme);
    if (parsed == null) return null;
    return fromBigInt(parsed);
  }

  bool get isNegative => value.isNegative;

  int toHostInt() => value.toInt();

  @override
  int compareTo(PseudoInteger other) => value.compareTo(other.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PseudoInteger &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}
