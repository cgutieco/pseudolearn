final class SimulatedCapabilities {
  static const SimulatedCapabilities none = SimulatedCapabilities();

  final Set<String> permissions;
  final Map<String, List<int>> files;
  final List<String> arguments;
  final int clockStartNanos;

  const SimulatedCapabilities({
    this.permissions = const {},
    this.files = const {},
    this.arguments = const [],
    this.clockStartNanos = 0,
  });

  bool get isEmpty => permissions.isEmpty;
}
