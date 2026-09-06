import '../../domain/profile/language_profile.dart';
import '../../domain/token_type.dart';
import 'runtime_value.dart';

final class ValueFormatter {
  final LanguageProfile profile;

  const ValueFormatter(this.profile);

  String format(RuntimeValue value) => switch (value) {
        IntegerValue(:final value) => value.toString(),
        RealValue(:final value) => _formatReal(value),
        BooleanValue(:final value) => _formatBoolean(value),
        CharacterValue(:final value) => value,
        StringValue(:final value) => value,
        ObjectValue(:final instance) =>
          'Instancia #${instance.id} de ${instance.classSymbol.name}',
      };

  String _formatBoolean(bool value) {
    final tokenType = value ? TokenType.booleanTrue : TokenType.booleanFalse;
    return profile.reservedLexemes[tokenType]!.canonicalLexeme;
  }

  String _formatReal(double value) {
    if (value == 0.0) return '0.0';
    final negative = value.isNegative;
    final exponential = value.abs().toStringAsExponential();
    final eIndex = exponential.indexOf('e');
    final mantissa = exponential.substring(0, eIndex);
    final exponent = int.parse(exponential.substring(eIndex + 1));
    final digits = mantissa.replaceAll('.', '');
    final positional = _positionalDigits(digits, 1 + exponent);
    return negative ? '-$positional' : positional;
  }

  String _positionalDigits(String digits, int pointPosition) {
    if (pointPosition <= 0) {
      return '0.${'0' * (-pointPosition)}$digits';
    }
    if (pointPosition >= digits.length) {
      final trailingZeros = '0' * (pointPosition - digits.length);
      return '$digits$trailingZeros.0';
    }
    return '${digits.substring(0, pointPosition)}.${digits.substring(pointPosition)}';
  }
}
