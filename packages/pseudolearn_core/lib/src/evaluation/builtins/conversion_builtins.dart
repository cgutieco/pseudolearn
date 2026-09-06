import '../../domain/pseudo_integer.dart';
import '../values/runtime_value.dart';
import '../values/value_formatter.dart';

final class ConversionBuiltins {
  final ValueFormatter formatter;

  const ConversionBuiltins(this.formatter);

  String toText(RuntimeValue value) => formatter.format(value);

  PseudoInteger? textToInteger(String text) => PseudoInteger.tryParse(text);

  double? textToReal(String text) {
    final parsed = double.tryParse(text);
    return (parsed != null && parsed.isFinite) ? parsed : null;
  }
}
