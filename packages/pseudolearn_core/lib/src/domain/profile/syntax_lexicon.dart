import '../primitive_type.dart';
import '../token_type.dart';

abstract interface class SyntaxLexicon {
  String formatTokenType(TokenType tokenType);

  String formatPrimitiveType(PrimitiveType primitiveType);
}
