import '../analysis/program_node_id.dart';

enum ClassMemberVisibility { public, private }

enum ClassRelationKind { generalization, association }

final class ClassMemberRow {
  final String text;
  final ClassMemberVisibility visibility;
  final ProgramNodeId nodeId;
  final int sourceLine;

  const ClassMemberRow({
    required this.text,
    required this.visibility,
    required this.nodeId,
    required this.sourceLine,
  });
}

final class ClassBox {
  final String name;
  final String? superclassName;
  final List<ClassMemberRow> attributes;
  final List<ClassMemberRow> methods;
  final ProgramNodeId nodeId;
  final int sourceLine;

  const ClassBox({
    required this.name,
    this.superclassName,
    required this.attributes,
    required this.methods,
    required this.nodeId,
    required this.sourceLine,
  });
}

final class ClassRelation {
  final String fromClassName;
  final String toClassName;
  final ClassRelationKind kind;
  final String? label;

  const ClassRelation({
    required this.fromClassName,
    required this.toClassName,
    required this.kind,
    this.label,
  });
}

final class ClassModel {
  final List<ClassBox> classes;
  final List<ClassRelation> relations;

  const ClassModel({required this.classes, required this.relations});

  const ClassModel.empty()
      : classes = const [],
        relations = const [];

  bool get isEmpty => classes.isEmpty;

  bool get isNotEmpty => classes.isNotEmpty;
}
