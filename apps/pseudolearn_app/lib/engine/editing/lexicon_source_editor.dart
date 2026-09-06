import 'package:pseudolearn_core/pseudolearn_core.dart';
import '../../domain/model/editor/caret_range.dart';
import '../../domain/model/editor/editor_key.dart';
import '../../domain/model/editor/source_edit.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/ports/source_editor.dart';
import '../mapping/profile_catalog.dart';

const Set<TokenType> _blockOpeningTokens = <TokenType>{
  TokenType.algorithm,
  TokenType.ifKeyword,
  TokenType.elseKeyword,
  TokenType.switchKeyword,
  TokenType.whileKeyword,
  TokenType.repeat,
  TokenType.forKeyword,
  TokenType.subroutine,
  TokenType.classKeyword,
  TokenType.method,
};

const String _tabIndent = '\t';
const String _spaceIndent = '  ';

final class LexiconSourceEditor implements SourceEditor {
  const LexiconSourceEditor();

  @override
  SourceEdit applyKey({
    required String sourceCode,
    required CaretRange caret,
    required EditorKey key,
    required SyntaxProfileId profileId,
    required int revision,
  }) {
    final range = caret.clampedTo(sourceCode.length);
    final lineStart = _lineStartAt(sourceCode, range.lower);
    final unit = sourceCode.contains(_tabIndent) ? _tabIndent : _spaceIndent;

    if (key.kind == EditorKeyKind.dedent) {
      return _dedent(
        sourceCode: sourceCode,
        range: range,
        lineStart: lineStart,
        unit: unit,
        revision: revision,
      );
    }
    return _insert(
      sourceCode: sourceCode,
      range: range,
      lineStart: lineStart,
      unit: unit,
      key: key,
      profileId: profileId,
      revision: revision,
    );
  }

  SourceEdit _insert({
    required String sourceCode,
    required CaretRange range,
    required int lineStart,
    required String unit,
    required EditorKey key,
    required SyntaxProfileId profileId,
    required int revision,
  }) {
    final indent = _indentForInsertion(
      sourceCode: sourceCode,
      lineStart: lineStart,
      unit: unit,
      key: key,
      profileId: profileId,
    );
    final opening = _openingBreak(
      sourceCode: sourceCode,
      caretOffset: range.lower,
      lineStart: lineStart,
      key: key,
      indent: indent,
    );
    final body = key.kind == EditorKeyKind.indent
        ? unit
        : key.insertion.replaceAll('\n', '\n$indent');
    final shift = key.kind == EditorKeyKind.indent
        ? body.length
        : _shiftedOffset(key: key, indent: indent);

    return SourceEdit(
      sourceCode:
          sourceCode.replaceRange(range.lower, range.upper, '$opening$body'),
      caret: CaretRange.collapsed(range.lower + opening.length + shift),
      revision: revision,
    );
  }

  SourceEdit _dedent({
    required String sourceCode,
    required CaretRange range,
    required int lineStart,
    required String unit,
    required int revision,
  }) {
    final indent = _leadingWhitespace(sourceCode, lineStart);
    final removed = _removableIndent(indent, unit);
    if (removed.isEmpty) {
      return SourceEdit(
          sourceCode: sourceCode, caret: range, revision: revision);
    }
    final cut = lineStart + removed.length;
    final caret = range.lower < cut ? lineStart : range.lower - removed.length;
    return SourceEdit(
      sourceCode: sourceCode.replaceRange(lineStart, cut, ''),
      caret: CaretRange.collapsed(caret),
      revision: revision,
    );
  }

  String _removableIndent(String indent, String unit) {
    if (indent.startsWith(unit)) return unit;
    if (indent.startsWith(_tabIndent)) return _tabIndent;
    if (indent.startsWith(' ')) return ' ';
    return '';
  }

  String _indentForInsertion({
    required String sourceCode,
    required int lineStart,
    required String unit,
    required EditorKey key,
    required SyntaxProfileId profileId,
  }) {
    final indent = _leadingWhitespace(sourceCode, lineStart);
    if (key.kind != EditorKeyKind.template) return indent;
    final profile = ProfileCatalog.toLanguageProfile(profileId);
    final line =
        sourceCode.substring(lineStart, _lineEndAt(sourceCode, lineStart));
    return _opensBlock(line, profile) ? '$indent$unit' : indent;
  }

  String _openingBreak({
    required String sourceCode,
    required int caretOffset,
    required int lineStart,
    required EditorKey key,
    required String indent,
  }) {
    if (key.kind != EditorKeyKind.template) return '';
    final written = sourceCode.substring(lineStart, caretOffset);
    return written.trim().isEmpty ? '' : '\n$indent';
  }

  int _shiftedOffset({required EditorKey key, required String indent}) {
    final raw = (key.caretOffset ?? key.insertion.length)
        .clamp(0, key.insertion.length);
    final head = key.insertion.substring(0, raw);
    return raw + '\n'.allMatches(head).length * indent.length;
  }

  bool _opensBlock(String line, LanguageProfile profile) {
    final word = _firstWord(line).toLowerCase();
    if (word.isEmpty) return false;
    for (final token in _blockOpeningTokens) {
      if (_firstWord(profile.formatTokenType(token)).toLowerCase() == word) {
        return true;
      }
    }
    return false;
  }

  String _firstWord(String text) {
    final trimmed = text.trimLeft();
    for (var index = 0; index < trimmed.length; index++) {
      if (trimmed[index] == ' ' || trimmed[index] == '\t') {
        return trimmed.substring(0, index);
      }
    }
    return trimmed;
  }

  int _lineStartAt(String source, int offset) {
    var index = offset;
    while (index > 0 && source[index - 1] != '\n') {
      index--;
    }
    return index;
  }

  int _lineEndAt(String source, int offset) {
    var index = offset;
    while (index < source.length && source[index] != '\n') {
      index++;
    }
    return index;
  }

  String _leadingWhitespace(String source, int lineStart) {
    var index = lineStart;
    while (index < source.length &&
        (source[index] == ' ' || source[index] == _tabIndent)) {
      index++;
    }
    return source.substring(lineStart, index);
  }
}
