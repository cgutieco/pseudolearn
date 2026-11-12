part of 'rust_program_view.dart';

extension _RustProgramViewDependencyValidator
    on _RustProgramViewWireValidator {
  bool _validateDependencyRows() {
    final rows = _optionalObjects(_json, 'dependencies', 'view');
    if (rows == null) return _failure == null;
    for (var index = 0; index < rows.length; index++) {
      if (!_validateDependency(rows[index], 'dependencies[$index]')) {
        return false;
      }
    }
    return true;
  }

  bool _validateDependency(Map<String, Object?> row, String path) {
    return _requiredString(row, 'dependency_id', '$path.dependency_id') !=
            null &&
        _enumValue(row, 'kind', const {'import', 'export'}, path: path) &&
        _enumValue(row, 'status', const {'unlinked'}, path: path) &&
        _requiredString(row, 'diagnostic', '$path.diagnostic') != null &&
        _requiredStrings(row, 'path', path) != null &&
        _validateAlias(row, path) &&
        _validateSpan(row['span'], '$path.span');
  }

  bool _validateAlias(Map<String, Object?> row, String path) {
    final alias = row['alias'];
    return alias == null || alias is String ? true : _malformed('$path.alias');
  }
}

List<ProgramDependency> _dependenciesFor(
  Map<String, Object?> json,
  SourceOffsetIndex offsets,
) => [
  for (final row
      in (json['dependencies'] as List<Object?>? ?? const [])
          .cast<Map<String, Object?>>())
    ProgramDependency(
      id: row['dependency_id'] as String,
      kind: row['kind'] == 'import'
          ? ProgramDependencyKind.importation
          : ProgramDependencyKind.exportation,
      path: (row['path'] as List<Object?>).cast<String>(),
      alias: row['alias'] as String?,
      status: ProgramDependencyStatus.unlinked,
      diagnosticCode: row['diagnostic'] as String,
      range: RustProgramView._rangeOf(
        row['span'] as Map<String, Object?>,
        offsets,
      ),
    ),
];
