import '../token_type.dart';
import 'accent_policy.dart';
import 'builtin_function.dart';
import 'builtin_function_entry.dart';
import 'case_policy.dart';
import 'identifier_alphabet.dart';
import 'lexeme_entry.dart';

abstract interface class LexerProfile {
  Map<TokenType, LexemeEntry> get reservedLexemes;

  AccentPolicy get accentPolicy;

  CasePolicy get casePolicy;

  IdentifierAlphabet get identifierAlphabet;

  String get commentMarker;

  String get quoteDelimiter;

  Map<BuiltinFunction, BuiltinFunctionEntry> get builtinFunctions;
}
