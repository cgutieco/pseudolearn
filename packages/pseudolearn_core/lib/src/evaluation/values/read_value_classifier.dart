import '../../domain/primitive_type.dart';
import '../../domain/profile/language_profile.dart';
import '../../domain/profile/profile_normalizer.dart';
import '../../domain/pseudo_integer.dart';
import '../../domain/token_type.dart';
import 'runtime_value.dart';

final class ReadValueClassifier {
  static final RegExp _integerPattern = RegExp(r'^-?[0-9]+$');
  static final RegExp _realPattern = RegExp(r'^-?[0-9]+\.[0-9]+$');

  final LanguageProfile profile;
  final ProfileNormalizer _normalizer;

  ReadValueClassifier(this.profile)
      : _normalizer = ProfileNormalizer(
          casePolicy: profile.casePolicy,
          accentPolicy: profile.accentPolicy,
        );

  RuntimeValue classify(String text) {
    final integer = _tryInteger(text);
    if (integer != null) return integer;
    final real = _tryReal(text);
    if (real != null) return real;
    final booleanValue = _matchBoolean(text);
    if (booleanValue != null) return BooleanValue(booleanValue);
    return StringValue(text);
  }

  RuntimeValue? parseAs(String text, PrimitiveType expectedType) =>
      switch (expectedType) {
        PrimitiveType.integer => _tryInteger(text),
        PrimitiveType.real => _tryReal(text) ?? _tryIntegerWidenedToReal(text),
        PrimitiveType.boolean => switch (_matchBoolean(text)) {
            final bool value => BooleanValue(value),
            null => null,
          },
        PrimitiveType.character =>
          text.runes.length == 1 ? CharacterValue(text) : null,
        PrimitiveType.string => StringValue(text),
      };

  IntegerValue? _tryInteger(String text) {
    if (!_integerPattern.hasMatch(text)) return null;
    final parsed = PseudoInteger.tryParse(text);
    return parsed == null ? null : IntegerValue(parsed);
  }

  RealValue? _tryReal(String text) {
    if (!_realPattern.hasMatch(text)) return null;
    final parsed = double.tryParse(text);
    return (parsed != null && parsed.isFinite) ? RealValue(parsed) : null;
  }

  RealValue? _tryIntegerWidenedToReal(String text) {
    final integer = _tryInteger(text);
    return integer == null ? null : RealValue(integer.value.value.toDouble());
  }

  bool? _matchBoolean(String text) {
    final normalized = _normalizer.normalize(text);
    if (_matchesToken(TokenType.booleanTrue, normalized)) return true;
    if (_matchesToken(TokenType.booleanFalse, normalized)) return false;
    return null;
  }

  bool _matchesToken(TokenType tokenType, String normalized) {
    final entry = profile.reservedLexemes[tokenType];
    if (entry == null) return false;
    return entry.allForms
        .any((form) => _normalizer.normalize(form) == normalized);
  }
}
