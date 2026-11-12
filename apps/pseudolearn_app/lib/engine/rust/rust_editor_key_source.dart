import '../../domain/model/editor/editor_key.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/ports/editor_key_source.dart';
import 'rust_editor_vocabulary.dart';

const String _indentLabel = 'TAB';

final class RustEditorKeySource implements EditorKeySource {
  final RustEditorVocabulary _vocabulary;

  const RustEditorKeySource(this._vocabulary);

  @override
  List<EditorKey> keysFor(SyntaxProfileId profileId) {
    final response = _vocabulary.forProfile(profileId);
    final symbols = response['symbols'] as Map<String, Object?>;
    return [
      const EditorKey(
        label: _indentLabel,
        insertion: '',
        kind: EditorKeyKind.indent,
      ),
      ..._symbolKeys(symbols),
    ];
  }

  List<EditorKey> _symbolKeys(Map<String, Object?> symbols) => [
    _key(symbols, 'assignment', EditorKeyKind.assignment),
    _key(symbols, 'quote', EditorKeyKind.quote, insertsPair: true),
    _key(symbols, 'left_parenthesis', EditorKeyKind.openParenthesis),
    _key(symbols, 'right_parenthesis', EditorKeyKind.closeParenthesis),
    _key(symbols, 'greater_equal', EditorKeyKind.greaterOrEqual),
    _key(symbols, 'less_equal', EditorKeyKind.lessOrEqual),
  ];

  EditorKey _key(
    Map<String, Object?> symbols,
    String name,
    EditorKeyKind kind, {
    bool insertsPair = false,
  }) {
    final symbol = symbols[name] as String;
    return EditorKey(
      label: symbol,
      insertion: insertsPair ? '$symbol$symbol' : symbol,
      caretOffset: insertsPair ? symbol.length : null,
      kind: kind,
    );
  }
}
