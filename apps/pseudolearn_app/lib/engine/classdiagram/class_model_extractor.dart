import 'package:pseudolearn_core/pseudolearn_core.dart';

import '../../domain/model/analysis/program_node_id.dart';
import '../../domain/model/diagram/class_model.dart';
import 'class_attribute_reader.dart';
import 'member_signature_printer.dart';

final class ClassModelExtractor {
  final MemberSignaturePrinter _signatures;
  final ClassAttributeReader _attributes;

  const ClassModelExtractor(
    this._signatures, {
    ClassAttributeReader attributes = const ClassAttributeReader(),
  }) : _attributes = attributes;

  ClassModel of(SourceUnitNode? unit) {
    if (unit == null || unit.classes.isEmpty) return const ClassModel.empty();
    final declaredNames = {for (final node in unit.classes) node.name};
    final classes = <ClassBox>[];
    final relations = <ClassRelation>[];
    for (final node in unit.classes) {
      classes.add(_boxOf(node));
      _collectRelations(node, declaredNames, relations);
    }
    return ClassModel(
      classes: List.unmodifiable(classes),
      relations: List.unmodifiable(relations),
    );
  }

  ClassBox _boxOf(ClassNode node) {
    final attributes = <ClassMemberRow>[];
    final methods = <ClassMemberRow>[];
    for (final member in node.members) {
      _appendMember(member, attributes, methods);
    }
    return ClassBox(
      name: node.name,
      superclassName: node.superclassName,
      attributes: List.unmodifiable(attributes),
      methods: List.unmodifiable(methods),
      nodeId: ProgramNodeId(node.id.value),
      sourceLine: node.span.start.line,
    );
  }

  void _appendMember(
    ClassMemberNode member,
    List<ClassMemberRow> attributes,
    List<ClassMemberRow> methods,
  ) {
    switch (member) {
      case final ClassFieldNode field:
        attributes.addAll(_attributeRowsOf(field));
      case final MethodDeclarationNode declaration:
        methods.add(_methodRowOf(declaration));
      case final ConstructorDeclarationNode declaration:
        methods.add(_constructorRowOf(declaration));
    }
  }

  List<ClassMemberRow> _attributeRowsOf(ClassFieldNode field) {
    return [
      for (final attribute in _attributes.of(field))
        ClassMemberRow(
          text: _signatures.attribute(
            name: attribute.name,
            type: attribute.type,
            customTypeName: attribute.customTypeName,
            dimensionCount: attribute.dimensionCount,
          ),
          visibility: attribute.visibility,
          nodeId: attribute.nodeId,
          sourceLine: attribute.sourceLine,
        ),
    ];
  }

  ClassMemberRow _methodRowOf(MethodDeclarationNode declaration) =>
      ClassMemberRow(
        text: _signatures.method(declaration),
        visibility: switch (declaration.visibility) {
          Visibility.public => ClassMemberVisibility.public,
          Visibility.private => ClassMemberVisibility.private,
        },
        nodeId: ProgramNodeId(declaration.id.value),
        sourceLine: declaration.span.start.line,
      );

  ClassMemberRow _constructorRowOf(ConstructorDeclarationNode declaration) =>
      ClassMemberRow(
        text: _signatures.constructor(declaration),
        visibility: ClassMemberVisibility.public,
        nodeId: ProgramNodeId(declaration.id.value),
        sourceLine: declaration.span.start.line,
      );

  void _collectRelations(
    ClassNode node,
    Set<String> declaredNames,
    List<ClassRelation> relations,
  ) {
    final superclassName = node.superclassName;
    if (superclassName != null && declaredNames.contains(superclassName)) {
      relations.add(ClassRelation(
        fromClassName: node.name,
        toClassName: superclassName,
        kind: ClassRelationKind.generalization,
      ));
    }
    for (final member in node.members) {
      if (member is! ClassFieldNode) continue;
      _appendAssociations(
        member,
        ownerName: node.name,
        declaredNames: declaredNames,
        relations: relations,
      );
    }
  }

  void _appendAssociations(
    ClassFieldNode field, {
    required String ownerName,
    required Set<String> declaredNames,
    required List<ClassRelation> relations,
  }) {
    for (final attribute in _attributes.of(field)) {
      final targetName = attribute.customTypeName;
      if (targetName == null || !declaredNames.contains(targetName)) continue;
      relations.add(ClassRelation(
        fromClassName: ownerName,
        toClassName: targetName,
        kind: ClassRelationKind.association,
        label: '${attribute.name} ${attribute.isCollection ? '*' : '1'}',
      ));
    }
  }
}
