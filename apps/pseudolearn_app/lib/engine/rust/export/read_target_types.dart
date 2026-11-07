import '../rust_program_view.dart';

const Set<String> _scopeKinds = {
  'algorithm_unit',
  'subroutine',
  'constructor_member',
  'method_member',
};

/// Primitive type each `input` target expects, resolved from the declarations,
/// parameters and dimensions of its own unit. A target that is not a plain
/// variable or an indexed array element stays unresolved.
final class ReadTargetTypes {
  final Map<int, String> _byTarget;

  const ReadTargetTypes._(this._byTarget);

  factory ReadTargetTypes.of(RustProgramView view) {
    final byTarget = <int, String>{};
    for (final node in view.nodes) {
      if (_scopeKinds.contains(node.syntaxKind)) {
        _Scope(view).resolve(node, byTarget);
      }
    }
    return ReadTargetTypes._(byTarget);
  }

  String? of(RustViewNode target) => _byTarget[target.id.value];

  Set<String> get primitives => _byTarget.values.toSet();
}

final class _Scope {
  final RustProgramView _view;
  final Map<String, String> _scalars = {};
  final Map<String, String> _arrays = {};
  final List<RustViewNode> _inputs = [];

  _Scope(this._view);

  void resolve(RustViewNode unit, Map<int, String> byTarget) {
    for (final child in rustChildrenOf(_view, unit)) {
      _collect(child);
    }
    for (final input in _inputs) {
      for (final target in rustChildrenOf(_view, input)) {
        final primitive = _primitiveOf(target);
        if (primitive != null) byTarget[target.id.value] = primitive;
      }
    }
  }

  void _collect(RustViewNode node) {
    if (_scopeKinds.contains(node.syntaxKind)) return;
    switch (node.syntaxKind) {
      case 'declaration':
        _declaration(node);
      case 'parameter':
        _parameter(node);
      case 'dimension_declaration':
        _dimension(node);
      case 'input':
        _inputs.add(node);
    }
    for (final child in rustChildrenOf(_view, node)) {
      _collect(child);
    }
  }

  void _declaration(RustViewNode node) {
    final primitive = _view.childForRole(node, 'type')?.semantics.primitive;
    if (primitive == null) return;
    for (final part in rustChildrenOf(_view, node)) {
      if (node.childRoles[part.id.value] == 'binding' &&
          part.syntaxKind == 'identifier') {
        _scalars[part.text] = primitive;
      }
    }
  }

  void _parameter(RustViewNode node) {
    final parts = rustChildrenOf(_view, node);
    if (parts.length < 2 || parts.first.syntaxKind != 'identifier') return;
    final primitive = parts.last.semantics.primitive;
    if (primitive != null) _scalars[parts.first.text] = primitive;
  }

  void _dimension(RustViewNode node) {
    final parts = rustChildrenOf(_view, node);
    final types = parts.where((part) => part.syntaxKind == 'type');
    final primitive = types.isEmpty ? null : types.first.semantics.primitive;
    if (primitive == null) return;
    for (final part in parts) {
      if (part.syntaxKind != 'dimensioned') continue;
      final name = rustChildrenOf(_view, part).first;
      if (name.syntaxKind == 'identifier') _arrays[name.text] = primitive;
    }
  }

  String? _primitiveOf(RustViewNode target) {
    if (target.syntaxKind == 'identifier') return _scalars[target.text];
    if (target.syntaxKind != 'postfix') return null;
    final parts = rustChildrenOf(_view, target);
    if (parts.length != 2 ||
        parts.first.syntaxKind != 'identifier' ||
        parts.last.syntaxKind != 'expressions') {
      return null;
    }
    return _arrays[parts.first.text];
  }
}
