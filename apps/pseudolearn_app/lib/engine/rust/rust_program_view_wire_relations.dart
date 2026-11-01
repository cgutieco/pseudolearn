part of 'rust_program_view.dart';

extension _RustProgramViewRelationValidator on _RustProgramViewWireValidator {
  bool _validateUnitRows() {
    final units = _requiredObjects(_json, 'units', 'units');
    if (units == null) return false;
    for (var index = 0; index < units.length; index++) {
      final unit = units[index];
      final path = 'units[$index]';
      final identifier = _requiredString(unit, 'node_id', '$path.node_id');
      if (identifier == null ||
          !_reference(identifier, identifier, '$path.node_id') ||
          _requiredString(unit, 'kind', '$path.kind') == null ||
          _requiredString(unit, 'name', '$path.name') == null ||
          !_requiredInt(unit, 'order', '$path.order') ||
          !_validateSpan(unit['span'], '$path.span')) {
        return false;
      }
    }
    return true;
  }

  bool _validateRelationRows() {
    final members = _requiredObjects(_json, 'members', 'members');
    final inheritance = _requiredObjects(_json, 'inheritance', 'inheritance');
    final methods = _requiredObjects(_json, 'methods', 'methods');
    if (members == null || inheritance == null || methods == null) return false;
    if (!_validateMembers(members) ||
        !_validateInheritance(inheritance) ||
        !_validateMethods(methods)) {
      return false;
    }
    return _validateRealizationRows();
  }

  bool _validateMembers(List<Map<String, Object?>> members) {
    for (var index = 0; index < members.length; index++) {
      final relation = members[index];
      final path = 'members[$index]';
      if (_requiredString(relation, 'class', '$path.class') == null ||
          _requiredString(relation, 'name', '$path.name') == null ||
          _requiredString(relation, 'kind', '$path.kind') == null ||
          _requiredString(relation, 'visibility', '$path.visibility') == null) {
        return false;
      }
      final owner = relation['class_node_id'];
      final target = relation['node_id'];
      if (owner != null &&
          (owner is! String ||
              !_reference(owner, owner, '$path.class_node_id'))) {
        return false;
      }
      if (target != null &&
          (target is! String ||
              !_reference(
                target,
                owner is String ? owner : target,
                '$path.node_id',
              ))) {
        return false;
      }
      if (relation['arity'] != null &&
          (relation['arity'] is! int || (relation['arity'] as int) < 0)) {
        return _malformed('$path.arity');
      }
      if (relation['dimensions'] != null &&
          (relation['dimensions'] is! int ||
              (relation['dimensions'] as int) < 0)) {
        return _malformed('$path.dimensions');
      }
      if (!_validateMemberType(relation, path)) return false;
    }
    return true;
  }

  bool _validateMemberType(Map<String, Object?> relation, String path) {
    if (relation['type'] != null && relation['type'] is! String) {
      return _malformed('$path.type');
    }
    return true;
  }

  bool _validateInheritance(List<Map<String, Object?>> rows) {
    for (var index = 0; index < rows.length; index++) {
      if (_requiredString(rows[index], 'class', 'inheritance[$index].class') ==
              null ||
          _requiredString(rows[index], 'base', 'inheritance[$index].base') ==
              null) {
        return false;
      }
    }
    return _validateOptionalRelationRows(rows, 'inheritance', const [
      'class_node_id',
      'base_node_id',
    ]);
  }

  bool _validateMethods(List<Map<String, Object?>> rows) {
    for (var index = 0; index < rows.length; index++) {
      if (_requiredString(rows[index], 'class', 'methods[$index].class') ==
              null ||
          _requiredString(rows[index], 'name', 'methods[$index].name') ==
              null ||
          _requiredString(
                rows[index],
                'overrides',
                'methods[$index].overrides',
              ) ==
              null) {
        return false;
      }
    }
    return _validateOptionalRelationRows(rows, 'methods', const [
      'class_node_id',
      'method_node_id',
      'overridden_method_node_id',
    ]);
  }

  bool _validateOptionalRelationRows(
    List<Map<String, Object?>> rows,
    String family,
    List<String> fields,
  ) {
    for (var index = 0; index < rows.length; index++) {
      final relation = rows[index];
      final owner = relation['class_node_id'];
      for (final field in fields) {
        final value = relation[field];
        if (field == 'class_node_id' && value == null) continue;
        if (value != null &&
            (value is! String ||
                !_reference(
                  value,
                  owner is String ? owner : value,
                  '$family[$index].$field',
                ))) {
          return false;
        }
      }
    }
    return true;
  }

  bool _validateRealizationRows() {
    final rows = _optionalObjects(_json, 'realizations', 'realizations');
    if (rows == null) return _failure == null;
    for (var index = 0; index < rows.length; index++) {
      final relation = rows[index];
      final owner = relation['class_node_id'];
      if (owner is! String ||
          !_validateRealizationRow(relation, owner, 'realizations[$index]')) {
        return false;
      }
    }
    return true;
  }

  bool _validateRealizationRow(
    Map<String, Object?> relation,
    String owner,
    String path,
  ) =>
      _validateRequiredLink(
        relation,
        'class_node_id',
        owner: owner,
        path: path,
      ) &&
      _validateRequiredLink(
        relation,
        'origin_node_id',
        owner: owner,
        path: path,
      ) &&
      _optionalReference(
        relation,
        'interface_node_id',
        owner: owner,
        path: path,
      ) &&
      _optionalReference(
        relation,
        'target_node_id',
        owner: owner,
        path: path,
      ) &&
      _enumValue(relation, 'origin', const {
        'explicit',
        'inherited',
      }, path: path) &&
      _enumValue(relation, 'status', const {'valid', 'invalid'}, path: path) &&
      _optionalStrings(relation, 'diagnostics', path);

  bool _validateStaticRows() {
    for (var index = 0; index < _nodes.length; index++) {
      final node = _nodes[index];
      final path = 'nodes[$index]';
      final syntaxKind = node['syntax_kind'] as String;
      final variant = node['variant'];
      if ((syntaxKind == 'variant_construction' ||
              syntaxKind == 'variant_pattern') &&
          variant is! String) {
        _missingOrMalformed(node, 'variant', path);
        return false;
      }
      if (variant != null &&
          (variant is! String ||
              !const {'some', 'none', 'success', 'error'}.contains(variant))) {
        return _malformed('nodes[$index].variant');
      }
      if (node['enum_members'] != null &&
          !_optionalStrings(node, 'enum_members', path)) {
        return false;
      }
      if (syntaxKind == 'for_each_loop' && !_hasIterationLinks(node, path)) {
        return false;
      }
    }
    return true;
  }

  bool _hasIterationLinks(Map<String, Object?> node, String path) {
    if (node['iteration'] is Map<String, Object?>) return true;
    final roles = (node['child_roles'] as List<Object?>)
        .cast<Map<String, Object?>>();
    for (final role in ['collection', 'bindings', 'body']) {
      final matches = roles.where((entry) => entry['role'] == role);
      if (matches.length != 1) return _malformed('$path.child_roles');
    }
    return true;
  }
}
