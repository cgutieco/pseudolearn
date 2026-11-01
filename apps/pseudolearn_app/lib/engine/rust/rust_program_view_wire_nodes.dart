part of 'rust_program_view.dart';

extension _RustProgramViewNodeValidator on _RustProgramViewWireValidator {
  bool _validateNodeRows() {
    for (var index = 0; index < _nodes.length; index++) {
      final node = _nodes[index];
      final path = 'nodes[$index]';
      if (_requiredString(node, 'kind', '$path.kind') == null ||
          _requiredString(node, 'syntax_kind', '$path.syntax_kind') == null) {
        return false;
      }
      final identifier = node['node_id'] as String;
      if (!_validateSpan(node['span'], '$path.span')) return false;
      final children = _requiredStrings(node, 'child_node_ids', path);
      final roles = _requiredObjects(node, 'child_roles', '$path.child_roles');
      if (children == null || roles == null) return false;
      if (!_validateChildren(
        children,
        roles,
        identifier: identifier,
        path: path,
      )) {
        return false;
      }
      if (!_optionalReference(
        node,
        'parent_node_id',
        owner: identifier,
        path: path,
      )) {
        return false;
      }
      if (node['dimensions'] case final Object? value
          when value != null && (value is! int || value < 0)) {
        _malformed('$path.dimensions');
        return false;
      }
      if (!_validateNodeAttributes(node, path, identifier)) return false;
    }
    return true;
  }

  bool _validateChildren(
    List<String> children,
    List<Map<String, Object?>> roles, {
    required String identifier,
    required String path,
  }) {
    if (children.length != roles.length) {
      return _malformed('$path.child_roles');
    }
    for (var child = 0; child < children.length; child++) {
      if (!_reference(
        children[child],
        identifier,
        '$path.child_node_ids[$child]',
      )) {
        return false;
      }
    }
    for (var role = 0; role < roles.length; role++) {
      final relation = roles[role];
      final target = _requiredString(
        relation,
        'node_id',
        '$path.child_roles[$role].node_id',
      );
      if (target == null ||
          target != children[role] ||
          _requiredString(relation, 'role', '$path.child_roles[$role].role') ==
              null ||
          !_reference(target, identifier, '$path.child_roles[$role].node_id')) {
        return false;
      }
    }
    return true;
  }

  bool _validateNodeAttributes(
    Map<String, Object?> node,
    String path,
    String identifier,
  ) {
    for (final key in [
      'realized_interfaces',
      'captured_bindings',
      'record_fields',
    ]) {
      if (node.containsKey(key) &&
          !_validateReferenceList(node[key], identifier, '$path.$key')) {
        return false;
      }
    }
    for (final key in [
      'enum_identity',
      'record_identity',
      'closure_identity',
    ]) {
      if (!_optionalReference(node, key, owner: identifier, path: path)) {
        return false;
      }
    }
    return _validateRealizations(node, path, identifier) &&
        _validateConstraints(node, path, identifier) &&
        _validateCaptures(node, path, identifier) &&
        _validateIteration(node, path, identifier) &&
        _validateSemantics(node, path);
  }
}
