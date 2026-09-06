import '../values/runtime_value.dart';

final class VariableCell {
  RuntimeValue? _value;

  VariableCell();

  bool get hasValue => _value != null;

  RuntimeValue get value {
    final current = _value;
    if (current == null) {
      throw StateError(
        'Read of an uninitialized VariableCell: callers must check '
        'hasValue and emit a diagnostic instead of reading directly.',
      );
    }
    return current;
  }

  void assign(RuntimeValue newValue) {
    _value = newValue;
  }
}
