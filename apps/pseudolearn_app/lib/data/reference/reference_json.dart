Map<String, Object?> objectOf(Object? value) {
  if (value is Map<String, Object?>) return value;
  throw FormatException('expected an object, found $value');
}

List<Object?> listOf(Object? value) {
  if (value is List<Object?>) return value;
  throw FormatException('expected a list, found $value');
}

String textOf(Map<String, Object?> source, String key) {
  final value = source[key];
  if (value is String) return value;
  throw FormatException('expected text at $key');
}

String optionalTextOf(Map<String, Object?> source, String key) {
  final value = source[key];
  return value is String ? value : '';
}

int numberOf(Map<String, Object?> source, String key) {
  final value = source[key];
  if (value is int) return value;
  throw FormatException('expected a number at $key');
}

bool flagOf(Map<String, Object?> source, String key) => source[key] == true;

List<T> mappedList<T>(Object? value, T Function(Object? element) convert) =>
    listOf(value).map(convert).toList();
