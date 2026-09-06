import '../../domain/pseudo_integer.dart';
import '../environment/object_instance.dart';

sealed class RuntimeValue {
  const RuntimeValue();
}

final class IntegerValue extends RuntimeValue {
  final PseudoInteger value;

  const IntegerValue(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IntegerValue &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'IntegerValue($value)';
}

final class RealValue extends RuntimeValue {
  final double value;

  const RealValue(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealValue &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'RealValue($value)';
}

final class BooleanValue extends RuntimeValue {
  final bool value;

  const BooleanValue(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BooleanValue &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'BooleanValue($value)';
}

final class CharacterValue extends RuntimeValue {
  final String value;

  const CharacterValue(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CharacterValue &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'CharacterValue($value)';
}

final class StringValue extends RuntimeValue {
  final String value;

  const StringValue(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StringValue &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'StringValue($value)';
}

final class ObjectValue extends RuntimeValue {
  final ObjectInstance instance;

  const ObjectValue(this.instance);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ObjectValue &&
          runtimeType == other.runtimeType &&
          instance.id == other.instance.id;

  @override
  int get hashCode => instance.id.hashCode;

  @override
  String toString() =>
      'ObjectValue(${instance.classSymbol.name}#${instance.id})';
}

extension RuntimeValueWidening on RuntimeValue {
  RuntimeValue widenedToReal() => switch (this) {
        IntegerValue(:final value) => RealValue(value.value.toDouble()),
        final other => other,
      };
}
