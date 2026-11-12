part of 'rust_program_view.dart';

extension _RustProgramViewWireExitValidator on _RustProgramViewWireValidator {
  bool _validateExitRows() {
    for (var index = 0; index < _nodes.length; index++) {
      final node = _nodes[index];
      final path = 'nodes[$index]';
      final identifier = node['node_id'] as String;
      if (!_validateControlExit(node, path, identifier) ||
          !_validateCleanupLinks(node, path, identifier)) {
        return false;
      }
    }
    return true;
  }

  bool _validateControlExit(
    Map<String, Object?> node,
    String path,
    String identifier,
  ) {
    if (!node.containsKey('control_exit')) return true;
    final exit = _requiredMap(node['control_exit'], '$path.control_exit');
    if (exit == null) return false;
    final exitPath = '$path.control_exit';
    return _enumValue(exit, 'kind', const {
          'break',
          'return',
          'propagation',
        }, path: exitPath) &&
        _optionalReference(
          exit,
          'target_node_id',
          owner: identifier,
          path: exitPath,
        ) &&
        _validateReferenceList(
          exit['cleanups'],
          identifier,
          '$exitPath.cleanups',
        );
  }

  bool _validateCleanupLinks(
    Map<String, Object?> node,
    String path,
    String identifier,
  ) {
    if (node.containsKey('normal_cleanups') &&
        !_validateReferenceList(
          node['normal_cleanups'],
          identifier,
          '$path.normal_cleanups',
        )) {
      return false;
    }
    return _optionalReference(
      node,
      'cleanup_scope_node_id',
      owner: identifier,
      path: path,
    );
  }
}
