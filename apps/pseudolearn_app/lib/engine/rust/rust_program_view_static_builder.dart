part of 'rust_program_view.dart';

final class _RustProgramViewStaticBuilder {
  final Map<String, Object?> _json;
  final List<Map<String, Object?>> _nodes;
  final Map<String, int> _ordinals;

  const _RustProgramViewStaticBuilder(this._json, this._nodes, this._ordinals);

  ProgramViewStaticData build() => ProgramViewStaticData(
    realizations: _realizations(),
    constraints: _constraints(),
    variants: _variants(),
    captures: _captures(),
    iterations: _iterations(),
    scopes: _scopes(),
  );

  List<ProgramViewRealization> _realizations() {
    final rows = _json['realizations'];
    if (rows is List<Object?>) return rows.map(_realization).toList();
    final result = <ProgramViewRealization>[];
    for (final node in _nodes) {
      final entries = node['interface_realizations'];
      if (entries is List<Object?>) {
        result.addAll(entries.map(_realization));
      } else {
        result.addAll(_legacyRealizations(node));
      }
    }
    return result;
  }

  ProgramViewRealization _realization(Object? value) {
    final row = value as Map<String, Object?>;
    return ProgramViewRealization(
      classNodeId: _id(row['class_node_id'] as String),
      interfaceNodeId: _optionalId(row['interface_node_id']),
      originNodeId: _id(row['origin_node_id'] as String),
      targetNodeId: _optionalId(row['target_node_id']),
      origin: ProgramViewRealizationOrigin.values.byName(
        row['origin'] as String,
      ),
      status: ProgramViewLinkStatus.values.byName(row['status'] as String),
      diagnostics: _strings(row['diagnostics']),
    );
  }

  List<ProgramViewRealization> _legacyRealizations(Map<String, Object?> node) {
    final identities = node['realized_interfaces'];
    if (identities is! List<Object?>) return const [];
    final classIdentity = node['node_id'] as String;
    return identities
        .whereType<String>()
        .map(
          (identity) => ProgramViewRealization(
            classNodeId: _id(classIdentity),
            interfaceNodeId: _id(identity),
            originNodeId: _id(classIdentity),
            targetNodeId: _id(identity),
            origin: ProgramViewRealizationOrigin.explicit,
            status: ProgramViewLinkStatus.valid,
            diagnostics: const [],
          ),
        )
        .toList();
  }

  List<ProgramViewConstraint> _constraints() {
    final result = <ProgramViewConstraint>[];
    for (final node in _nodes) {
      final entries = node['constraints'];
      if (entries is List<Object?>) {
        result.addAll(entries.map((entry) => _constraint(node, entry)));
      } else if (node['constraint_interface'] is String) {
        result.add(
          ProgramViewConstraint(
            parameterNodeId: _id(node['node_id'] as String),
            interfaceNodeId: _id(node['constraint_interface'] as String),
            targetNodeId: null,
            status: ProgramViewLinkStatus.valid,
            diagnostics: const [],
          ),
        );
      }
    }
    return result;
  }

  ProgramViewConstraint _constraint(Map<String, Object?> node, Object? value) {
    final row = value as Map<String, Object?>;
    return ProgramViewConstraint(
      parameterNodeId: _id(node['node_id'] as String),
      interfaceNodeId: _optionalId(row['interface_node_id']),
      targetNodeId: _optionalId(row['target_node_id']),
      status: ProgramViewLinkStatus.values.byName(row['status'] as String),
      diagnostics: _strings(row['diagnostics']),
    );
  }

  List<ProgramViewVariant> _variants() => [
    for (final node in _nodes)
      if (node['variant'] is String)
        ProgramViewVariant(
          nodeId: _id(node['node_id'] as String),
          discriminant: node['variant'] as String,
          payloadNodeIds: _relatedIds(node, 'payload'),
          bindingNodeIds: _relatedIds(node, 'binding'),
        ),
  ];

  List<ProgramViewCapture> _captures() {
    final result = <ProgramViewCapture>[];
    for (final node in _nodes) {
      final entries = node['captures'];
      if (entries is List<Object?>) {
        result.addAll(entries.map((entry) => _capture(node, entry)));
      } else {
        result.addAll(_legacyCaptures(node));
      }
    }
    return result;
  }

  ProgramViewCapture _capture(Map<String, Object?> node, Object? value) {
    final row = value as Map<String, Object?>;
    return ProgramViewCapture(
      closureNodeId: _id(node['node_id'] as String),
      originNodeId: _id(row['origin_node_id'] as String),
      bindingNodeId: _id(row['binding_node_id'] as String),
      mode: ProgramViewCaptureMode.values.byName(row['mode'] as String),
    );
  }

  List<ProgramViewCapture> _legacyCaptures(Map<String, Object?> node) {
    final identities = node['captured_bindings'];
    if (identities is! List<Object?>) return const [];
    final closureIdentity = node['node_id'] as String;
    return identities
        .whereType<String>()
        .map(
          (identity) => ProgramViewCapture(
            closureNodeId: _id(closureIdentity),
            originNodeId: _id(identity),
            bindingNodeId: _id(identity),
            mode: ProgramViewCaptureMode.value,
          ),
        )
        .toList();
  }

  List<ProgramViewIteration> _iterations() => [
    for (final node in _nodes)
      if (node['syntax_kind'] == 'for_each_loop') _iteration(node),
  ];

  List<ProgramViewScope> _scopes() => [
    for (final node in _nodes)
      if (node['syntax_kind'] == 'for_each_loop') _scope(node),
  ];

  ProgramViewScope _scope(Map<String, Object?> node) {
    final iteration = node['iteration'] as Map<String, Object?>?;
    final roles = node['child_roles'] as List<Object?>;
    final bindingsIdentifier =
        (iteration?['bindings_node_id'] as String?) ??
        _roleId(roles, 'bindings');
    final bodyIdentifier =
        (iteration?['body_node_id'] as String?) ?? _roleId(roles, 'body');
    final bindingsNode = _nodes[_ordinals[bindingsIdentifier]!];
    final bindingIdentifiers = (bindingsNode['child_roles'] as List<Object?>)
        .cast<Map<String, Object?>>()
        .where((entry) => entry['role'] == 'binding')
        .map((entry) => entry['node_id'] as String)
        .toList();
    return ProgramViewScope(
      ownerNodeId: _id(node['node_id'] as String),
      bindingsNodeId: _id(bindingsIdentifier),
      bodyNodeId: _id(bodyIdentifier),
      bindingNodeIds: bindingIdentifiers.map(_id).toList(),
    );
  }

  ProgramViewIteration _iteration(Map<String, Object?> node) {
    final links = node['iteration'] as Map<String, Object?>?;
    final owner = node['node_id'] as String;
    final children = node['child_roles'] as List<Object?>;
    return ProgramViewIteration(
      loopNodeId: _id(owner),
      collectionNodeId: _id(
        (links?['collection_node_id'] as String?) ??
            _roleId(children, 'collection'),
      ),
      bindingsNodeId: _id(
        (links?['bindings_node_id'] as String?) ??
            _roleId(children, 'bindings'),
      ),
      bodyNodeId: _id(
        (links?['body_node_id'] as String?) ?? _roleId(children, 'body'),
      ),
      scopeOwnerNodeId: _id(
        (links?['scope_owner_node_id'] as String?) ?? owner,
      ),
    );
  }

  List<ProgramNodeId> _relatedIds(Map<String, Object?> node, String role) => [
    for (final entry in node['child_roles'] as List<Object?>)
      if ((entry as Map<String, Object?>)['role'] == role)
        _id(entry['node_id'] as String),
  ];

  String _roleId(List<Object?> roles, String role) =>
      roles.cast<Map<String, Object?>>().firstWhere(
            (entry) => entry['role'] == role,
          )['node_id']
          as String;

  ProgramNodeId _id(String identifier) => ProgramNodeId(_ordinals[identifier]!);

  ProgramNodeId? _optionalId(Object? identifier) =>
      identifier is String ? _id(identifier) : null;

  List<String> _strings(Object? values) =>
      values is List<Object?> ? values.whereType<String>().toList() : const [];
}
