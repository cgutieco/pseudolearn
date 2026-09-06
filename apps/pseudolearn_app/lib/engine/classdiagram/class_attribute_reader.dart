import 'package:pseudolearn_core/pseudolearn_core.dart';

import '../../domain/model/analysis/program_node_id.dart';
import '../../domain/model/diagram/class_model.dart';

final class ClassAttributeDeclaration {
  final String name;
  final ClassMemberVisibility visibility;
  final PrimitiveType? type;
  final String? customTypeName;
  final int dimensionCount;
  final ProgramNodeId nodeId;
  final int sourceLine;

  const ClassAttributeDeclaration({
    required this.name,
    required this.visibility,
    this.type,
    this.customTypeName,
    required this.dimensionCount,
    required this.nodeId,
    required this.sourceLine,
  });

  bool get isCollection => dimensionCount > 0;
}

final class ClassAttributeReader {
  const ClassAttributeReader();

  List<ClassAttributeDeclaration> of(ClassFieldNode field) {
    final visibility = _visibilityOf(field.visibility);
    final nodeId = ProgramNodeId(field.id.value);
    final line = field.span.start.line;
    return switch (field.declaration) {
      final VariableDeclarationNode declaration =>
        _fromVariables(declaration, visibility: visibility, nodeId: nodeId, sourceLine: line),
      final DimensionStatementNode declaration =>
        _fromArrays(declaration, visibility: visibility, nodeId: nodeId, sourceLine: line),
      _ => const [],
    };
  }

  List<ClassAttributeDeclaration> _fromVariables(
    VariableDeclarationNode declaration, {
    required ClassMemberVisibility visibility,
    required ProgramNodeId nodeId,
    required int sourceLine,
  }) {
    return [
      for (final variable in declaration.variables)
        ClassAttributeDeclaration(
          name: variable.name,
          visibility: visibility,
          type: declaration.type,
          customTypeName: declaration.customTypeName,
          dimensionCount: 0,
          nodeId: nodeId,
          sourceLine: sourceLine,
        ),
    ];
  }

  List<ClassAttributeDeclaration> _fromArrays(
    DimensionStatementNode declaration, {
    required ClassMemberVisibility visibility,
    required ProgramNodeId nodeId,
    required int sourceLine,
  }) {
    return [
      for (final array in declaration.arrays)
        ClassAttributeDeclaration(
          name: array.name,
          visibility: visibility,
          type: declaration.elementType,
          customTypeName: declaration.customElementTypeName,
          dimensionCount: array.dimensions.length,
          nodeId: nodeId,
          sourceLine: sourceLine,
        ),
    ];
  }

  static ClassMemberVisibility _visibilityOf(Visibility visibility) {
    return switch (visibility) {
      Visibility.public => ClassMemberVisibility.public,
      Visibility.private => ClassMemberVisibility.private,
    };
  }
}
