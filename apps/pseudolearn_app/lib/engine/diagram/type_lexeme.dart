import 'package:pseudolearn_core/pseudolearn_core.dart';

final class TypeLexeme {
  final SyntaxLexicon _lexicon;

  const TypeLexeme(this._lexicon);

  String of(PrimitiveType? type, String? customTypeName) {
    if (type == null) return customTypeName ?? '';
    return _lexicon.formatTokenType(switch (type) {
      PrimitiveType.integer => TokenType.integerType,
      PrimitiveType.real => TokenType.realType,
      PrimitiveType.boolean => TokenType.booleanType,
      PrimitiveType.character => TokenType.characterType,
      PrimitiveType.string => TokenType.stringType,
    });
  }
}
