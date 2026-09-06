final class WatchRow {
  final String name;
  final String formattedValue;
  final int? identityBadge;
  final String scopeName;
  final bool isAbsent;

  const WatchRow({
    required this.name,
    required this.formattedValue,
    this.identityBadge,
    required this.scopeName,
    this.isAbsent = false,
  });
}
