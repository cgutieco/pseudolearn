import 'runtime_value.dart';

final class ComparisonEvaluator {
  const ComparisonEvaluator();

  int compareOrdered(RuntimeValue a, RuntimeValue b) {
    if (a is IntegerValue && b is IntegerValue) {
      return a.value.compareTo(b.value);
    }
    if (a is CharacterValue && b is CharacterValue) {
      return a.value.runes.first.compareTo(b.value.runes.first);
    }
    if (a is StringValue && b is StringValue) {
      return a.value.compareTo(b.value);
    }
    return _asDouble(a).compareTo(_asDouble(b));
  }

  bool equalValues(RuntimeValue a, RuntimeValue b) {
    if (a is BooleanValue && b is BooleanValue) return a.value == b.value;
    if (a is CharacterValue && b is CharacterValue) return a.value == b.value;
    if (a is StringValue && b is StringValue) return a.value == b.value;
    if (a is IntegerValue && b is IntegerValue) return a.value == b.value;
    if (a is ObjectValue && b is ObjectValue) {
      return a.instance.id == b.instance.id;
    }
    return _asDouble(a) == _asDouble(b);
  }

  double _asDouble(RuntimeValue runtimeValue) => switch (runtimeValue) {
        IntegerValue(:final value) => value.value.toDouble(),
        RealValue(:final value) => value,
        _ => throw StateError(
            'Non-numeric value reached numeric comparison: $runtimeValue',
          ),
      };
}
