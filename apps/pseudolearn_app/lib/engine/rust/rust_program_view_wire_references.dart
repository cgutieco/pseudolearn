part of 'rust_program_view.dart';

extension _RustProgramViewWireReferenceValidator
    on _RustProgramViewWireValidator {
  bool _validateReferenceList(Object? value, String owner, String path) {
    if (value is! List<Object?>) return _malformed(path);
    for (var index = 0; index < value.length; index++) {
      final target = value[index];
      if (target is! String || !_reference(target, owner, '$path[$index]')) {
        return false;
      }
    }
    return true;
  }

  bool _validateRequiredLink(
    Map<String, Object?> row,
    String key, {
    required String owner,
    required String path,
  }) {
    final value = _requiredString(row, key, '$path.$key');
    return value != null && _reference(value, owner, '$path.$key');
  }

  bool _optionalReference(
    Map<String, Object?> row,
    String key, {
    required String owner,
    required String path,
  }) {
    if (!row.containsKey(key) || row[key] == null) return true;
    final value = _requiredString(row, key, '$path.$key');
    return value != null && _reference(value, owner, '$path.$key');
  }

  bool _reference(String target, String owner, String path) {
    if (_identifiers.contains(target)) {
      return _sourcePrefix(target) == _sourcePrefix(owner)
          ? true
          : _foreign(path);
    }
    return _sourcePrefix(target) == _sourcePrefix(owner)
        ? _missingReference(path)
        : _foreign(path);
  }

  bool _enumValue(
    Map<String, Object?> row,
    String key,
    Set<String> allowed, {
    required String path,
  }) {
    final value = _requiredString(row, key, '$path.$key');
    if (value == null) return false;
    return allowed.contains(value) ? true : _malformed('$path.$key');
  }
}

String _sourcePrefix(String identifier) {
  final marker = identifier.lastIndexOf('.n');
  return marker < 0 ? identifier : identifier.substring(0, marker);
}
