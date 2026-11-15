abstract interface class RustTransport {
  Object? call(String operation, Map<String, Object?> arguments);

  void close();
}

final class RustBridgeFailure implements Exception {
  final String family;
  final String detail;

  const RustBridgeFailure({required this.family, required this.detail});

  bool get isUsage => family == 'usage';

  @override
  String toString() => 'RustBridgeFailure($family): $detail';
}
