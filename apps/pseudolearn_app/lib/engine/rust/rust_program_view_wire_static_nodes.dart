part of 'rust_program_view.dart';

extension _RustProgramViewStaticNodeValidator on _RustProgramViewWireValidator {
  bool _validateRealizations(
    Map<String, Object?> node,
    String path,
    String identifier,
  ) {
    final entries = _optionalObjects(node, 'interface_realizations', path);
    if (entries == null) return _failure == null;
    for (var index = 0; index < entries.length; index++) {
      final entry = entries[index];
      final entryPath = '$path.interface_realizations[$index]';
      if (!_validateRealizationEntry(entry, entryPath, identifier)) {
        return false;
      }
    }
    return true;
  }

  bool _validateRealizationEntry(
    Map<String, Object?> entry,
    String entryPath,
    String identifier,
  ) {
    return _validateRealizationLinks(entry, entryPath, identifier) &&
        _validateRealizationState(entry, entryPath);
  }

  bool _validateRealizationLinks(
    Map<String, Object?> entry,
    String entryPath,
    String identifier,
  ) {
    return _validateRequiredLink(
          entry,
          'class_node_id',
          owner: identifier,
          path: entryPath,
        ) &&
        _validateRequiredLink(
          entry,
          'origin_node_id',
          owner: identifier,
          path: entryPath,
        ) &&
        _optionalReference(
          entry,
          'interface_node_id',
          owner: identifier,
          path: entryPath,
        ) &&
        _optionalReference(
          entry,
          'target_node_id',
          owner: identifier,
          path: entryPath,
        );
  }

  bool _validateRealizationState(Map<String, Object?> entry, String entryPath) {
    final valid =
        _enumValue(entry, 'origin', const {
          'explicit',
          'inherited',
        }, path: entryPath) &&
        _enumValue(entry, 'status', const {
          'valid',
          'invalid',
        }, path: entryPath) &&
        _optionalStrings(entry, 'diagnostics', entryPath);
    if (!valid) return false;
    if (entry['interface_node_id'] == null && entry['status'] != 'invalid') {
      return _malformed('$entryPath.status');
    }
    return true;
  }

  bool _validateConstraints(
    Map<String, Object?> node,
    String path,
    String identifier,
  ) {
    final entries = _optionalObjects(node, 'constraints', path);
    if (entries != null) {
      for (var index = 0; index < entries.length; index++) {
        final entry = entries[index];
        final entryPath = '$path.constraints[$index]';
        if (!_optionalReference(
              entry,
              'interface_node_id',
              owner: identifier,
              path: entryPath,
            ) ||
            !_optionalReference(
              entry,
              'target_node_id',
              owner: identifier,
              path: entryPath,
            ) ||
            !_enumValue(entry, 'status', const {
              'valid',
              'invalid',
            }, path: entryPath) ||
            !_optionalStrings(entry, 'diagnostics', entryPath)) {
          return false;
        }
      }
    } else if (_failure != null) {
      return false;
    }
    return _optionalReference(
      node,
      'constraint_interface',
      owner: identifier,
      path: path,
    );
  }

  bool _validateCaptures(
    Map<String, Object?> node,
    String path,
    String identifier,
  ) {
    final entries = _optionalObjects(node, 'captures', path);
    if (entries == null) return _failure == null;
    for (var index = 0; index < entries.length; index++) {
      final entry = entries[index];
      final entryPath = '$path.captures[$index]';
      if (!_validateRequiredLink(
            entry,
            'origin_node_id',
            owner: identifier,
            path: entryPath,
          ) ||
          !_validateRequiredLink(
            entry,
            'binding_node_id',
            owner: identifier,
            path: entryPath,
          ) ||
          !_enumValue(entry, 'mode', const {'value'}, path: entryPath)) {
        return false;
      }
    }
    return true;
  }

  bool _validateIteration(
    Map<String, Object?> node,
    String path,
    String identifier,
  ) {
    if (!_optionalReference(
      node,
      'scope_owner_node_id',
      owner: identifier,
      path: path,
    )) {
      return false;
    }
    if (!node.containsKey('iteration')) return true;
    final iteration = _requiredMap(node['iteration'], '$path.iteration');
    if (iteration == null) return false;
    for (final key in [
      'collection_node_id',
      'bindings_node_id',
      'body_node_id',
      'scope_owner_node_id',
    ]) {
      if (!_validateRequiredLink(
        iteration,
        key,
        owner: identifier,
        path: '$path.iteration',
      )) {
        return false;
      }
    }
    return true;
  }
}
