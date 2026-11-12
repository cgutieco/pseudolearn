import '../../domain/model/diagram/class_model.dart';
import '../../domain/model/diagram/diagram_scene.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/ports/class_diagram_builder.dart';
import '../classdiagram/class_diagram_layout.dart';
import 'rust_program_view.dart';
import 'rust_member_signature.dart';
import 'rust_program_view_source.dart';
import 'rust_type_contract_projection.dart';
import 'rust_type_parameter_text.dart';
import 'rust_transport.dart';

final class RustClassDiagramBuilder implements ClassDiagramBuilder {
  final RustProgramViewSource _views;
  final ClassDiagramLayout _layout;

  RustClassDiagramBuilder(
    RustTransport transport, {
    this._layout = const ClassDiagramLayout(),
  }) : _views = RustProgramViewSource(transport);

  @override
  DiagramScene buildDiagram({
    required String sourceCode,
    required SyntaxProfileId profileId,
  }) {
    final view = _views.loadStructure(
      sourceCode: sourceCode,
      profileId: profileId,
    );
    if (view == null) return const DiagramScene.empty();
    return _withRanges(_layout.of(_model(view)), view);
  }

  DiagramScene _withRanges(DiagramScene scene, RustProgramView view) =>
      DiagramScene(
        nodes: scene.nodes,
        edges: scene.edges,
        width: scene.width,
        height: scene.height,
        sourceRanges: {
          for (final nodeId in [
            for (final node in scene.nodes) node.nodeId,
            for (final edge in scene.edges) edge.originNodeId,
          ])
            if (nodeId != null)
              if (view.nodeById(nodeId) case final RustViewNode node)
                nodeId.value: node.signatureRange ?? node.range,
        },
      );

  ClassModel _model(RustProgramView view) {
    final classUnits = view.units
        .where((unit) => unit.kind == 'class')
        .toList();
    final classNames = {for (final unit in classUnits) unit.name};
    final classes = [
      for (final unit in classUnits) _classBox(view, unit, classNames),
    ];
    final relations = _relations(view, classUnits, classNames);
    return RustTypeContractProjection(
      view,
      classes,
    ).project(relations: relations);
  }

  ClassBox _classBox(
    RustProgramView view,
    RustViewUnit unit,
    Set<String> classNames,
  ) {
    final node = view.nodeById(unit.nodeId);
    final attributes = <ClassMemberRow>[];
    final methods = <ClassMemberRow>[];
    for (final member in view.members.where(
      (item) => item.className == unit.name,
    )) {
      final row = _memberRow(view, unit, member);
      if (row == null) continue;
      if (member.kind == 'field') {
        attributes.add(row);
      } else {
        methods.add(row);
      }
    }
    final superclass = view.superclasses[unit.name];
    return ClassBox(
      name: unit.name,
      superclassName: superclass != null && classNames.contains(superclass)
          ? superclass
          : null,
      attributes: attributes,
      methods: methods,
      nodeId: node?.id ?? unit.nodeId,
      sourceLine: node?.range.startLine ?? unit.range.startLine,
      typeParameters: RustTypeParameterText(view).of(node),
    );
  }

  ClassMemberRow? _memberRow(
    RustProgramView view,
    RustViewUnit unit,
    RustViewMember member,
  ) {
    final memberNodeId = member.nodeId;
    if (memberNodeId == null) return null;
    final memberNode = view.nodeById(memberNodeId);
    return ClassMemberRow(
      text: member.kind == 'field'
          ? _attributeSignature(member)
          : RustMemberSignature(view).of(member.name, memberNode),
      visibility: _visibility(member.visibility),
      nodeId: memberNodeId,
      sourceLine: memberNode?.range.startLine ?? unit.range.startLine,
    );
  }

  List<ClassRelation> _relations(
    RustProgramView view,
    List<RustViewUnit> classes,
    Set<String> classNames,
  ) {
    final relations = <ClassRelation>[];
    for (final unit in classes) {
      final superclass = view.superclasses[unit.name];
      if (superclass != null && classNames.contains(superclass)) {
        final arguments = RustTypeParameterText(
          view,
        ).argumentsAfter(view.nodeById(unit.nodeId), superclass);
        relations.add(
          ClassRelation(
            fromClassName: unit.name,
            toClassName: superclass,
            kind: ClassRelationKind.generalization,
            label: arguments.isEmpty ? null : arguments,
          ),
        );
      }
      for (final member in view.members.where(
        (item) => item.className == unit.name && item.kind == 'field',
      )) {
        final target = member.typeName;
        if (target == null || !classNames.contains(target)) continue;
        relations.add(
          ClassRelation(
            fromClassName: unit.name,
            toClassName: target,
            kind: ClassRelationKind.association,
            label: '${member.name} ${member.dimensions > 0 ? '*' : '1'}',
          ),
        );
      }
    }
    return relations;
  }

  String _attributeSignature(RustViewMember member) {
    final typeName = member.typeName;
    if (typeName == null) return member.name;
    final type = typeName + List.filled(member.dimensions, '[]').join();
    return '${member.name}: $type';
  }

  ClassMemberVisibility _visibility(String visibility) => switch (visibility) {
    'private' => ClassMemberVisibility.private,
    _ => ClassMemberVisibility.public,
  };
}
