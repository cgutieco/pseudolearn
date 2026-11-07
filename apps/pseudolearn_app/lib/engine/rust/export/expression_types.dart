import '../rust_program_view.dart';

const Set<String> _scopeKinds = {
  'algorithm_unit',
  'subroutine',
  'constructor_member',
  'method_member',
};

const Set<String> _arithmeticKinds = {'addition', 'multiplication'};

const Set<String> _booleanKinds = {
  'conjunction',
  'disjunction',
  'equality',
  'ordering',
};

const Map<String, String> _builtinTypes = {
  'length': 'integer',
  'toText': 'string',
};

/// Primitive type of the variables and expressions of each unit, inferred
/// from its declarations, parameters, dimensions and loops and from the
/// signatures of the subroutines it calls. What cannot be inferred stays null.
final class ExpressionTypes {
  final Map<int, String> _byNode;
  final Map<String, SubroutineSignature> _signatures;

  const ExpressionTypes._(this._byNode, this._signatures);

  factory ExpressionTypes.of(RustProgramView view) {
    final signatures = Map<String, SubroutineSignature>.fromEntries([
      for (final node in view.nodes)
        if (node.syntaxKind == 'subroutine') ?_signature(view, node),
    ]);
    final byNode = <int, String>{};
    for (final node in view.nodes) {
      if (_scopeKinds.contains(node.syntaxKind)) {
        _Scope(view, signatures).resolve(node, byNode);
      }
    }
    return ExpressionTypes._(byNode, signatures);
  }

  String? of(RustViewNode node) => _byNode[node.id.value];

  SubroutineSignature? signatureOf(String name) => _signatures[name];

  static MapEntry<String, SubroutineSignature>? _signature(
    RustProgramView view,
    RustViewNode node,
  ) {
    final parts = rustChildrenOf(view, node);
    if (parts.isEmpty || parts.first.syntaxKind != 'identifier') return null;
    final parameters = <String?>[];
    String? returns;
    for (final part in parts) {
      if (part.syntaxKind == 'parameters') {
        for (final parameter in rustChildrenOf(view, part)) {
          parameters.add(
            rustChildrenOf(view, parameter).last.semantics.primitive,
          );
        }
      } else if (part.syntaxKind == 'type' &&
          node.childRoles[part.id.value] == 'signature') {
        returns = part.semantics.primitive;
      }
    }
    return MapEntry(parts.first.text, SubroutineSignature(parameters, returns));
  }
}

final class SubroutineSignature {
  final List<String?> parameters;
  final String? returns;

  const SubroutineSignature(this.parameters, this.returns);
}

final class _Scope {
  final RustProgramView _view;
  final Map<String, SubroutineSignature> _signatures;
  final Map<String, String> _scalars = {};
  final Map<String, String> _arrays = {};
  final List<RustViewNode> _nodes = [];

  _Scope(this._view, this._signatures);

  void resolve(RustViewNode unit, Map<int, String> byNode) {
    for (final child in rustChildrenOf(_view, unit)) {
      _collect(child);
    }
    final memo = <int, String?>{};
    for (final node in _nodes) {
      final primitive = _typeOf(node, memo);
      if (primitive != null) byNode[node.id.value] = primitive;
    }
  }

  void _collect(RustViewNode node) {
    if (_scopeKinds.contains(node.syntaxKind)) return;
    _nodes.add(node);
    switch (node.syntaxKind) {
      case 'declaration':
        _declaration(node);
      case 'parameter':
        _parameter(node);
      case 'dimension_declaration':
        _dimension(node);
      case 'for_loop':
        final header = rustChildrenForRole(_view, node, 'loop_header');
        if (header.isNotEmpty && header.first.syntaxKind == 'identifier') {
          _scalars.putIfAbsent(header.first.text, () => 'integer');
        }
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

  String? _typeOf(RustViewNode node, Map<int, String?> memo) {
    final key = node.id.value;
    if (memo.containsKey(key)) return memo[key];
    memo[key] = null;
    final primitive = _infer(node, memo);
    memo[key] = primitive;
    return primitive;
  }

  String? _infer(RustViewNode node, Map<int, String?> memo) {
    final children = rustChildrenOf(_view, node);
    final kind = node.syntaxKind;
    if (_booleanKinds.contains(kind)) return 'boolean';
    if (_arithmeticKinds.contains(kind)) return _arithmetic(node, memo);
    return switch (kind) {
      'literal' => node.semantics.literal?.type,
      'identifier' => _scalars[node.text],
      'primary' => children.isEmpty ? null : _typeOf(children.first, memo),
      'unary' =>
        node.semantics.operator == 'not'
            ? 'boolean'
            : children.isEmpty
            ? null
            : _typeOf(children.first, memo),
      'postfix' => _postfix(node, children),
      _ => null,
    };
  }

  String? _arithmetic(RustViewNode node, Map<int, String?> memo) {
    final types = [
      for (final operand in rustChildrenOf(_view, node)) _typeOf(operand, memo),
    ];
    if (types.contains(null)) return null;
    if (types.contains('string')) return 'string';
    if (node.semantics.operators.contains('divide')) return 'real';
    if (types.every((type) => type == 'integer')) return 'integer';
    if (types.every((type) => type == 'integer' || type == 'real')) {
      return 'real';
    }
    return null;
  }

  String? _postfix(RustViewNode node, List<RustViewNode> parts) {
    final builtin = node.semantics.builtin;
    if (builtin != null) return _builtinTypes[builtin];
    if (parts.length != 2 || parts.first.syntaxKind != 'identifier') {
      return null;
    }
    return switch (parts.last.syntaxKind) {
      'expressions' => _arrays[parts.first.text],
      'arguments' => _signatures[parts.first.text]?.returns,
      _ => null,
    };
  }
}
