part of 'rust_program_view.dart';

extension _RustProgramViewWireValueValidator on _RustProgramViewWireValidator {
  bool _validateSpan(Object? value, String path) {
    final span = _requiredMap(value, path);
    if (span == null) return false;
    final start = _requiredMap(span['start'], '$path.start');
    final end = _requiredMap(span['end'], '$path.end');
    if (start == null || end == null) return false;
    final startLine = _requiredInt(start, 'line', '$path.start.line');
    final startColumn = _requiredInt(start, 'column', '$path.start.column');
    final endLine = _requiredInt(end, 'line', '$path.end.line');
    final endColumn = _requiredInt(end, 'column', '$path.end.column');
    final startByte = _decimal(span['start_byte'], '$path.start_byte');
    final endByte = _decimal(span['end_byte'], '$path.end_byte');
    if (_failure != null ||
        !startLine ||
        !startColumn ||
        !endLine ||
        !endColumn) {
      return false;
    }
    if (startByte == null || endByte == null || startByte > endByte) {
      return _invalidSpan(path);
    }
    return _spanOffsetsMatch(
      start: start,
      end: end,
      startByte: startByte,
      endByte: endByte,
      path: path,
    );
  }

  bool _spanOffsetsMatch({
    required Map<String, Object?> start,
    required Map<String, Object?> end,
    required int startByte,
    required int endByte,
    required String path,
  }) {
    final startOffset = _offsets.offsetOf(
      start['line'] as int,
      start['column'] as int,
    );
    final endOffset = _offsets.offsetOf(
      end['line'] as int,
      end['column'] as int,
    );
    final validPositions =
        _offsets.isValidPosition(
          start['line'] as int,
          start['column'] as int,
        ) &&
        _offsets.isValidPosition(end['line'] as int, end['column'] as int);
    if (!validPositions ||
        _offsets.utf8OffsetAtUtf16(startOffset) != startByte ||
        _offsets.utf8OffsetAtUtf16(endOffset) != endByte ||
        startOffset > endOffset) {
      return _invalidSpan(path);
    }
    return true;
  }

  bool _optionalStrings(Map<String, Object?> row, String key, String path) {
    if (!row.containsKey(key)) return true;
    final value = row[key];
    if (value is! List<Object?> || value.any((item) => item is! String)) {
      return _malformed('$path.$key');
    }
    return true;
  }

  List<Map<String, Object?>>? _requiredObjects(
    Map<String, Object?> row,
    String key,
    String path,
  ) {
    if (!row.containsKey(key) || row[key] is! List<Object?>) {
      _missingOrMalformed(row, key, path);
      return null;
    }
    return _objectList(row[key] as List<Object?>, '$path.$key');
  }

  List<Map<String, Object?>>? _optionalObjects(
    Map<String, Object?> row,
    String key,
    String path,
  ) {
    if (!row.containsKey(key)) return null;
    if (row[key] is! List<Object?>) {
      _malformed('$path.$key');
      return null;
    }
    return _objectList(row[key] as List<Object?>, '$path.$key');
  }

  List<Map<String, Object?>>? _objectList(List<Object?> values, String path) {
    final result = <Map<String, Object?>>[];
    for (var index = 0; index < values.length; index++) {
      final value = _requiredMap(values[index], '$path[$index]');
      if (value == null) return null;
      result.add(value);
    }
    return result;
  }

  List<String>? _requiredStrings(
    Map<String, Object?> row,
    String key,
    String path,
  ) {
    final value = row[key];
    if (value is! List<Object?> || value.any((item) => item is! String)) {
      _malformed('$path.$key');
      return null;
    }
    return value.cast<String>();
  }

  String? _requiredString(Map<String, Object?> row, String key, String path) {
    final value = row[key];
    if (value is String && value.isNotEmpty) return value;
    _missingOrMalformed(row, key, path);
    return null;
  }

  Map<String, Object?>? _requiredMap(Object? value, String path) {
    if (value is Map<String, Object?>) return value;
    _malformed(path);
    return null;
  }

  bool _requiredInt(Map<String, Object?> row, String key, String path) {
    final value = row[key];
    if (value is int && value >= 0) return true;
    _malformed(path);
    return false;
  }

  int? _decimal(Object? value, String path) {
    if (value is! String || !_isCanonicalDecimal(value)) {
      _malformed(path);
      return null;
    }
    final parsed = int.tryParse(value);
    if (parsed == null) _malformed(path);
    return parsed;
  }

  void _missingOrMalformed(Map<String, Object?> row, String key, String path) {
    _failure = RustProgramViewReadFailure(
      kind: row.containsKey(key)
          ? RustProgramViewReadFailureKind.malformedField
          : RustProgramViewReadFailureKind.missingField,
      path: path,
    );
  }

  bool _malformed(String path) {
    _failure = _malformedFailure(path);
    return false;
  }

  RustProgramViewReadFailure _malformedFailure(String path) =>
      RustProgramViewReadFailure(
        kind: RustProgramViewReadFailureKind.malformedField,
        path: path,
      );

  bool _invalidSpan(String path) {
    _failure = RustProgramViewReadFailure(
      kind: RustProgramViewReadFailureKind.invalidSpan,
      path: path,
    );
    return false;
  }

  bool _missingReference(String path) {
    _failure = RustProgramViewReadFailure(
      kind: RustProgramViewReadFailureKind.missingReference,
      path: path,
    );
    return false;
  }

  bool _foreign(String path) {
    _failure = RustProgramViewReadFailure(
      kind: RustProgramViewReadFailureKind.foreignReference,
      path: path,
    );
    return false;
  }
}

bool _isCanonicalDecimal(String value) {
  if (value.isEmpty || (value.length > 1 && value.startsWith('0'))) {
    return false;
  }
  for (final codeUnit in value.codeUnits) {
    if (codeUnit < 0x30 || codeUnit > 0x39) return false;
  }
  return true;
}
