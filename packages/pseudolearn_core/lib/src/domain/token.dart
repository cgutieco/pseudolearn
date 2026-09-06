import 'span.dart';
import 'token_type.dart';

final class Token {
  final TokenType type;
  final Span span;
  final String lexeme;
  final Object? literalValue;

  Token({
    required this.type,
    required this.span,
    required this.lexeme,
    this.literalValue,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Token &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          span == other.span &&
          lexeme == other.lexeme &&
          literalValue == other.literalValue;

  @override
  int get hashCode => Object.hash(type, span, lexeme, literalValue);

  @override
  String toString() => 'Token($type, "$lexeme", $span)';
}
