part of 'rust_program_view.dart';

const Map<String, ProgramViewExitKind> _exitKinds = {
  'break': ProgramViewExitKind.breakLoop,
  'return': ProgramViewExitKind.returnUnit,
  'propagation': ProgramViewExitKind.propagation,
};

final class _RustProgramViewExitBuilder {
  final List<Map<String, Object?>> _nodes;
  final Map<String, int> _ordinals;

  const _RustProgramViewExitBuilder(this._nodes, this._ordinals);

  List<ProgramViewControlExit> exits() => [
    for (final node in _nodes)
      if (node['control_exit'] case final Map<String, Object?> exit)
        ProgramViewControlExit(
          exitNodeId: _id(node['node_id'] as String),
          kind: _exitKinds[exit['kind'] as String]!,
          targetNodeId: exit['target_node_id'] is String
              ? _id(exit['target_node_id'] as String)
              : null,
          cleanupNodeIds: _ids(exit['cleanups']),
        ),
  ];

  List<ProgramViewCleanupScope> cleanupScopes() => [
    for (final node in _nodes)
      if (node['normal_cleanups'] case final List<Object?> cleanups)
        ProgramViewCleanupScope(
          bodyNodeId: _id(node['node_id'] as String),
          cleanupNodeIds: _ids(cleanups),
        ),
  ];

  List<ProgramNodeId> _ids(Object? values) => [
    for (final value in values as List<Object?>) _id(value as String),
  ];

  ProgramNodeId _id(String identifier) => ProgramNodeId(_ordinals[identifier]!);
}
