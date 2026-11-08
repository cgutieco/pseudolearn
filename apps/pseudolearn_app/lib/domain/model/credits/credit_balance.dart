final class CreditBalance {
  final int remaining;
  final int allowance;
  final int topUp;
  final DateTime? renewsAt;
  final bool trial;

  const CreditBalance({
    required this.remaining,
    required this.allowance,
    required this.topUp,
    this.renewsAt,
    this.trial = false,
  });

  const CreditBalance.empty()
    : remaining = 0,
      allowance = 0,
      topUp = 0,
      renewsAt = null,
      trial = false;

  bool get isExhausted => remaining <= 0;

  int spentSince(CreditBalance? before) {
    if (before == null) return 0;
    final spent = before.remaining - remaining;
    return spent < 0 ? 0 : spent;
  }

  @override
  bool operator ==(Object other) =>
      other is CreditBalance &&
      other.remaining == remaining &&
      other.allowance == allowance &&
      other.topUp == topUp &&
      other.renewsAt == renewsAt &&
      other.trial == trial;

  @override
  int get hashCode => Object.hash(remaining, allowance, topUp, renewsAt, trial);
}
