final class ExecutionValueEntry {
  final String name;
  final Map<String, Object?> value;

  ExecutionValueEntry({required this.name, required Map<String, Object?> value})
    : value = Map.unmodifiable(value);
}

final class ExecutionValuePage {
  final List<ExecutionValueEntry> entries;
  final int total;
  final int valuesRead;
  final bool truncated;
  final String? nextCursor;

  ExecutionValuePage({
    required List<ExecutionValueEntry> entries,
    required this.total,
    required this.valuesRead,
    required this.truncated,
    required this.nextCursor,
  }) : entries = List.unmodifiable(entries);
}
