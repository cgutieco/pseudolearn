String? readRejectionMessageOf(List<Map<String, Object?>> diagnostics) {
  for (final diagnostic in diagnostics.reversed) {
    if (diagnostic['code'] != 'readValueTypeMismatch') continue;
    final message = diagnostic['message'];
    return message is String ? message : null;
  }
  return null;
}
