import '../../domain/model/analysis/program_node_id.dart';
import '../../domain/model/analysis/program_view_static_data.dart';
import '../../domain/model/diagram/class_model.dart';
import 'rust_member_signature.dart';
import 'rust_program_view.dart';

final class RustTypeContractProjection {
  static const String invalidCode = 'invalid';

  final RustProgramView _view;
  final List<ClassBox> _classBoxes;
  final Map<int, String> _namesByNode;
  final Map<int, List<ClassMemberRow>> _issues = {};
  final Map<int, List<String>> _contracts = {};
  final List<ClassRelation> _relations = [];

  RustTypeContractProjection(RustProgramView view, List<ClassBox> classBoxes)
    : _view = view,
      _classBoxes = classBoxes,
      _namesByNode = {for (final box in classBoxes) box.nodeId.value: box.name};

  ClassModel project({required List<ClassRelation> relations}) {
    final boxes = _boxes();
    return ClassModel(classes: boxes, relations: [...relations, ..._relations]);
  }

  List<ClassBox> _boxes() {
    final interfaces = _interfaceBoxes();
    for (final box in interfaces) {
      _namesByNode[box.nodeId.value] = box.name;
    }
    final subprograms = _subprogramBoxes();
    _projectRealizations();
    _projectConstraints(subprograms);
    return [
      for (final box in [..._classBoxes, ...interfaces, ...subprograms.values])
        _withContracts(box),
    ];
  }

  ClassBox _withContracts(ClassBox box) => ClassBox(
    name: box.name,
    superclassName: box.superclassName,
    attributes: box.attributes,
    methods: [...box.methods, ...?_issues[box.nodeId.value]],
    nodeId: box.nodeId,
    sourceLine: box.sourceLine,
    kind: box.kind,
    contractNames: _contracts[box.nodeId.value] ?? const [],
  );

  List<ClassBox> _interfaceBoxes() => [
    for (final node in _view.nodes)
      if (node.syntaxKind == 'interface_unit') _interfaceBox(node),
  ];

  ClassBox _interfaceBox(RustViewNode node) {
    final signature = RustMemberSignature(_view);
    final rows = [
      for (final child in rustChildrenForRole(_view, node, 'method_signature'))
        ClassMemberRow(
          text: signature.of(_identifierOf(child), child),
          visibility: ClassMemberVisibility.public,
          nodeId: child.id,
          sourceLine: child.range.startLine,
        ),
    ];
    return ClassBox(
      name: _identifierOf(node, role: 'name'),
      attributes: const [],
      methods: rows,
      nodeId: node.id,
      sourceLine: node.range.startLine,
      kind: ClassBoxKind.interfaceContract,
    );
  }

  String _identifierOf(RustViewNode node, {String? role}) {
    final children = role == null
        ? rustChildrenOf(_view, node)
        : rustChildrenForRole(_view, node, role);
    return children
            .where((child) => child.syntaxKind == 'identifier')
            .firstOrNull
            ?.text ??
        node.text.trim();
  }

  Map<int, ClassBox> _subprogramBoxes() {
    final owners = _constraintOwners();
    final boxes = <int, ClassBox>{};
    for (final unit in _view.units.where((u) => u.kind == 'subprogram')) {
      if (!owners.values.contains(unit.nodeId.value)) continue;
      final node = _view.nodeById(unit.nodeId);
      boxes[unit.nodeId.value] = ClassBox(
        name: unit.name,
        attributes: const [],
        methods: [
          ClassMemberRow(
            text: RustMemberSignature(_view).of(unit.name, node),
            visibility: ClassMemberVisibility.public,
            nodeId: unit.nodeId,
            sourceLine: node?.range.startLine ?? unit.range.startLine,
          ),
        ],
        nodeId: unit.nodeId,
        sourceLine: node?.range.startLine ?? unit.range.startLine,
        kind: ClassBoxKind.constrainedSubprogram,
      );
      _namesByNode[unit.nodeId.value] = unit.name;
    }
    return boxes;
  }

  Map<int, int> _constraintOwners() {
    final wanted = {
      for (final constraint in _view.staticData.constraints)
        constraint.parameterNodeId.value,
    };
    final owners = <int, int>{};
    for (final unit in _view.units.where((u) => u.kind == 'subprogram')) {
      final root = _view.nodeById(unit.nodeId);
      if (root == null) continue;
      _collectOwners(root, owner: unit.nodeId.value, wanted: wanted, into: owners);
    }
    return owners;
  }

  void _collectOwners(
    RustViewNode node, {
    required int owner,
    required Set<int> wanted,
    required Map<int, int> into,
  }) {
    if (wanted.contains(node.id.value)) into[node.id.value] = owner;
    for (final child in rustChildrenOf(_view, node)) {
      _collectOwners(child, owner: owner, wanted: wanted, into: into);
    }
  }

  void _projectRealizations() {
    for (final realization in _view.staticData.realizations) {
      if (realization.origin != ProgramViewRealizationOrigin.explicit) continue;
      final owner = _namesByNode[realization.classNodeId.value];
      if (owner == null) continue;
      final interfaceId = realization.interfaceNodeId;
      final target = interfaceId == null ? null : _namesByNode[interfaceId.value];
      if (target == null) {
        _issue(realization.classNodeId, realization.targetNodeId,
            realization.diagnostics);
        continue;
      }
      _link(
        ClassRelationKind.realization,
        from: realization.classNodeId,
        to: interfaceId!,
        origin: realization.originNodeId,
        diagnostics: _diagnosticsOf(
          realization.status,
          realization.diagnostics,
        ),
      );
    }
  }

  void _projectConstraints(Map<int, ClassBox> subprograms) {
    final owners = _constraintOwners();
    for (final constraint in _view.staticData.constraints) {
      final ownerValue = owners[constraint.parameterNodeId.value];
      if (ownerValue == null || !subprograms.containsKey(ownerValue)) continue;
      final owner = ProgramNodeId(ownerValue);
      final interfaceId = constraint.interfaceNodeId;
      final target = interfaceId == null ? null : _namesByNode[interfaceId.value];
      if (target == null) {
        _issue(owner, constraint.parameterNodeId, constraint.diagnostics);
        continue;
      }
      _link(
        ClassRelationKind.usage,
        from: owner,
        to: interfaceId!,
        origin: constraint.parameterNodeId,
        diagnostics: _diagnosticsOf(constraint.status, constraint.diagnostics),
        label: _parameterLabel(constraint.parameterNodeId),
      );
    }
  }

  String? _parameterLabel(ProgramNodeId parameter) {
    final text = _view.nodeById(parameter)?.text;
    if (text == null) return null;
    return text.split(':').first.trim();
  }

  List<String> _diagnosticsOf(
    ProgramViewLinkStatus status,
    List<String> diagnostics,
  ) {
    if (status == ProgramViewLinkStatus.valid) return const [];
    return diagnostics.isEmpty ? const [invalidCode] : diagnostics;
  }

  void _link(
    ClassRelationKind kind, {
    required ProgramNodeId from,
    required ProgramNodeId to,
    required ProgramNodeId origin,
    required List<String> diagnostics,
    String? label,
  }) {
    final marker = diagnostics.isEmpty ? '' : '! ${diagnostics.join(', ')}';
    final text = [?label, if (marker.isNotEmpty) marker].join(' ');
    _relations.add(
      ClassRelation(
        fromClassName: _namesByNode[from.value]!,
        toClassName: _namesByNode[to.value]!,
        kind: kind,
        label: text.isEmpty ? null : text,
        fromNodeId: from,
        toNodeId: to,
        originNodeId: origin,
        diagnostics: diagnostics,
      ),
    );
    _contracts.putIfAbsent(from.value, () => []).add(_namesByNode[to.value]!);
  }

  void _issue(ProgramNodeId owner, ProgramNodeId? target, List<String> codes) {
    final node = target == null ? null : _view.nodeById(target);
    final reference = node?.text.trim() ?? '?';
    final detail = codes.isEmpty ? invalidCode : codes.join(', ');
    _issues.putIfAbsent(owner.value, () => []).add(
      ClassMemberRow(
        text: '! $reference ($detail)',
        visibility: ClassMemberVisibility.public,
        nodeId: target ?? owner,
        sourceLine: node?.range.startLine ?? 0,
        role: ClassRowRole.contractIssue,
      ),
    );
  }
}
