import 'lexer_profile.dart';
import 'parser_profile.dart';
import 'semantic_profile.dart';
import 'syntax_lexicon.dart';

abstract interface class LanguageProfile
    implements LexerProfile, ParserProfile, SemanticProfile, SyntaxLexicon {
  String get name;
}
