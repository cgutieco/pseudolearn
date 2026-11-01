part of 'rust_program_view.dart';

final class _RustProgramViewWireValidator {
  final Map<String, Object?> _json;
  final SourceOffsetIndex _offsets;
  RustProgramViewReadFailure? _failure;
  List<Map<String, Object?>> _nodes = const [];
  Set<String> _identifiers = const {};

  _RustProgramViewWireValidator(this._json, this._offsets);

  RustProgramViewReadFailure? validate() {
    if (_requiredString(_json, 'revision_id', 'revision_id') == null) {
      return _failure;
    }
    if (_requiredString(_json, 'child_order', 'child_order') != 'source') {
      return _malformedFailure('child_order');
    }
    _nodes = _requiredObjects(_json, 'nodes', 'nodes') ?? const [];
    if (_failure != null) return _failure;
    final identifiers = <String>{};
    for (var index = 0; index < _nodes.length; index++) {
      final identifier = _requiredString(
        _nodes[index],
        'node_id',
        'nodes[$index].node_id',
      );
      if (identifier == null) return _failure;
      if (!identifiers.add(identifier)) {
        return RustProgramViewReadFailure(
          kind: RustProgramViewReadFailureKind.duplicateNodeId,
          path: 'nodes[$index].node_id',
        );
      }
    }
    _identifiers = identifiers;
    if (!_validateNodeRows() ||
        !_validateUnitRows() ||
        !_validateRelationRows() ||
        !_validateStaticRows()) {
      return _failure;
    }
    return null;
  }
}
