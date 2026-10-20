import '../../domain/model/diagram/class_model.dart';
import '../../domain/model/diagram/diagram_scene.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/ports/class_diagram_builder.dart';
import '../classdiagram/class_diagram_layout.dart';
import 'rust_program_view.dart';
import 'rust_program_view_source.dart';
import 'rust_transport.dart';

final class RustClassDiagramBuilder implements ClassDiagramBuilder {
  final RustProgramViewSource _views;
  final ClassDiagramLayout _layout;

  RustClassDiagramBuilder(
    RustTransport transport, {
    ClassDiagramLayout layout = const ClassDiagramLayout(),
  }) : _views = RustProgramViewSource(transport),
       _layout = layout;

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
    return _layout.of(_model(view));
  }

  ClassModel _model(RustProgramView view) {
    final classUnits = view.units
        .where((unit) => unit.kind == 'class')
        .toList();
    final classNames = {for (final unit in classUnits) unit.name};
    final classes = [
      for (final unit in classUnits) _classBox(view, unit, classNames),
    ];
    final relations = _relations(view, classUnits, classNames);
    return ClassModel(classes: classes, relations: relations);
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
      final memberNodeId = member.nodeId;
      if (memberNodeId == null) continue;
      final memberNode = view.nodeById(memberNodeId);
      final row = ClassMemberRow(
        text: member.kind == 'field'
            ? _attributeSignature(member)
            : _methodSignature(view, member, memberNode),
        visibility: _visibility(member.visibility),
        nodeId: memberNodeId,
        sourceLine: memberNode?.range.startLine ?? unit.range.startLine,
      );
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
        relations.add(
          ClassRelation(
            fromClassName: unit.name,
            toClassName: superclass,
            kind: ClassRelationKind.generalization,
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

  String _methodSignature(
    RustProgramView view,
    RustViewMember member,
    RustViewNode? node,
  ) {
    if (node == null) return member.name;
    final parameterGroup = view.childForRole(node, 'parameters');
    final parameters = parameterGroup == null
        ? const <String>[]
        : [
            for (final parameter in rustChildrenOf(view, parameterGroup))
              if (parameter.syntaxKind == 'parameter')
                _parameterSignature(view, parameter),
          ];
    final returnType = rustChildrenForRole(
      view,
      node,
      'signature',
    ).where((child) => child.syntaxKind == 'type');
    final signature = '${member.name}(${parameters.join(', ')})';
    if (returnType.isEmpty) return signature;
    return '$signature: ${returnType.first.text}';
  }

  String _parameterSignature(RustProgramView view, RustViewNode parameter) {
    final children = rustChildrenOf(view, parameter);
    final name = children
        .where((child) => child.syntaxKind == 'identifier')
        .firstOrNull
        ?.text;
    final type = children
        .where((child) => child.syntaxKind == 'type')
        .firstOrNull
        ?.text;
    final dimensions = parameter.dimensions ?? 0;
    if (name == null) return parameter.text.trim();
    if (type == null) return name;
    final typeName = type + List.filled(dimensions, '[]').join();
    return '$name: $typeName';
  }

  ClassMemberVisibility _visibility(String visibility) => switch (visibility) {
    'private' => ClassMemberVisibility.private,
    _ => ClassMemberVisibility.public,
  };
}
