import 'package:pseudolearn_core/pseudolearn_core.dart';
import '../../domain/model/editor/editor_key.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/ports/editor_key_source.dart';
import '../mapping/profile_catalog.dart';

const String _indentKeyLabel = 'TAB';

final class ProfileKeySource implements EditorKeySource {
  const ProfileKeySource();

  @override
  List<EditorKey> keysFor(SyntaxProfileId profileId) {
    final lexicon = ProfileCatalog.toLanguageProfile(profileId);

    return [
      const EditorKey(
        label: _indentKeyLabel,
        insertion: '',
        kind: EditorKeyKind.indent,
      ),
      _symbol(lexicon, TokenType.assignment, EditorKeyKind.assignment),
      _pair(lexicon, TokenType.quote, EditorKeyKind.quote),
      _symbol(
          lexicon, TokenType.leftParenthesis, EditorKeyKind.openParenthesis),
      _symbol(
          lexicon, TokenType.rightParenthesis, EditorKeyKind.closeParenthesis),
      _symbol(
          lexicon, TokenType.greaterThanOrEqual, EditorKeyKind.greaterOrEqual),
      _symbol(lexicon, TokenType.lessThanOrEqual, EditorKeyKind.lessOrEqual),
    ];
  }

  EditorKey _symbol(
      SyntaxLexicon lexicon, TokenType token, EditorKeyKind kind) {
    final lexeme = lexicon.formatTokenType(token);
    return EditorKey(label: lexeme, insertion: lexeme, kind: kind);
  }

  EditorKey _pair(SyntaxLexicon lexicon, TokenType token, EditorKeyKind kind) {
    final lexeme = lexicon.formatTokenType(token);
    return EditorKey(
      label: lexeme,
      insertion: '$lexeme$lexeme',
      caretOffset: lexeme.length,
      kind: kind,
    );
  }
}
