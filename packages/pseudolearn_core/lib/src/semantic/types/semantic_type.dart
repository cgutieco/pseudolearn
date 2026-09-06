import '../../domain/primitive_type.dart';
import '../symbols/symbol.dart';

sealed class SemanticType {
  const SemanticType();

  bool get isNumeric => isInteger || isReal;
  bool get isInteger =>
      this == const PrimitiveSemanticType(PrimitiveType.integer);
  bool get isReal => this == const PrimitiveSemanticType(PrimitiveType.real);
  bool get isBoolean =>
      this == const PrimitiveSemanticType(PrimitiveType.boolean);
  bool get isCharacter =>
      this == const PrimitiveSemanticType(PrimitiveType.character);
  bool get isString =>
      this == const PrimitiveSemanticType(PrimitiveType.string);
  bool get isClass => this is ClassSemanticType;
  bool get isArray => this is ArraySemanticType;
  bool get isVoid => this is VoidSemanticType;
  bool get isIndeterminate => this is IndeterminateSemanticType;
  bool get isError => this is ErrorSemanticType;

  String get displayName;

  static SemanticType fromPrimitive(PrimitiveType primitive) =>
      PrimitiveSemanticType(primitive);
}

final class PrimitiveSemanticType extends SemanticType {
  final PrimitiveType primitive;

  const PrimitiveSemanticType(this.primitive);

  @override
  String get displayName => primitive.name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrimitiveSemanticType && other.primitive == primitive);

  @override
  int get hashCode => primitive.hashCode;

  @override
  String toString() => 'PrimitiveType($displayName)';
}

final class ClassSemanticType extends SemanticType {
  final String className;
  final ClassSymbol? classSymbol;

  const ClassSemanticType(this.className, [this.classSymbol]);

  @override
  String get displayName => className;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClassSemanticType && other.className == className);

  @override
  int get hashCode => className.hashCode;

  @override
  String toString() => 'ClassType($className)';
}

final class ArraySemanticType extends SemanticType {
  final SemanticType elementType;
  final int dimensions;

  const ArraySemanticType(this.elementType, this.dimensions);

  @override
  String get displayName =>
      '${elementType.displayName}[${"," * (dimensions - 1)}]';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArraySemanticType &&
          other.dimensions == dimensions &&
          other.elementType == elementType);

  @override
  int get hashCode => Object.hash(elementType, dimensions);

  @override
  String toString() => 'ArrayType($displayName)';
}

final class VoidSemanticType extends SemanticType {
  const VoidSemanticType();

  @override
  String get displayName => 'void';

  @override
  bool operator ==(Object other) => other is VoidSemanticType;

  @override
  int get hashCode => 0;

  @override
  String toString() => 'Void';
}

final class IndeterminateSemanticType extends SemanticType {
  const IndeterminateSemanticType();

  @override
  String get displayName => 'indeterminate';

  @override
  bool operator ==(Object other) => other is IndeterminateSemanticType;

  @override
  int get hashCode => 1;

  @override
  String toString() => 'Indeterminate';
}

final class ErrorSemanticType extends SemanticType {
  const ErrorSemanticType();

  @override
  String get displayName => 'error';

  @override
  bool operator ==(Object other) => other is ErrorSemanticType;

  @override
  int get hashCode => 2;

  @override
  String toString() => 'Error';
}
