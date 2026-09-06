import '../values/runtime_value.dart';
import 'variable_cell.dart';

final class ReferenceBinding {
  final VariableCell cell;

  const ReferenceBinding(this.cell);

  bool get hasValue => cell.hasValue;

  RuntimeValue get value => cell.value;

  void write(RuntimeValue newValue) => cell.assign(newValue);
}
