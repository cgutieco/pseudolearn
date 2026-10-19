import '../../domain/model/editor/caret_range.dart';
import '../../domain/model/editor/editor_key.dart';
import '../../domain/model/editor/source_edit.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/ports/source_editor.dart';
import 'rust_editor_vocabulary.dart';

const String _tabIndent = '\t';
const String _spaceIndent = '  ';

final class RustSourceEditor implements SourceEditor {
  final RustEditorVocabulary _vocabulary;

  const RustSourceEditor(this._vocabulary);

  @override
  SourceEdit applyKey({
    required String sourceCode,
    required CaretRange caret,
    required EditorKey key,
    required SyntaxProfileId profileId,
    required int revision,
  }) {
    if (key.kind == EditorKeyKind.completion) {
      return _applyCompletion(sourceCode, key, revision);
    }
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

  SourceEdit _applyCompletion(String sourceCode, EditorKey key, int revision) {
    final replacementRange = key.replacementRange;
    if (replacementRange == null) {
      return SourceEdit(
        sourceCode: sourceCode,
        caret: CaretRange.collapsed(0),
        revision: revision,
      );
    }
    final range = replacementRange.clampedTo(sourceCode.length);
    final updated = sourceCode.replaceRange(
      range.lower,
      range.upper,
      key.insertion,
    );
    return SourceEdit(
      sourceCode: updated,
      caret: CaretRange.collapsed(range.lower + key.insertion.length),
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
        : _shiftedOffset(key, indent);
    return SourceEdit(
      sourceCode: sourceCode.replaceRange(
        range.lower,
        range.upper,
        '$opening$body',
      ),
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
        sourceCode: sourceCode,
        caret: range,
        revision: revision,
      );
    }
    final cut = lineStart + removed.length;
    final caret = range.lower < cut ? lineStart : range.lower - removed.length;
    return SourceEdit(
      sourceCode: sourceCode.replaceRange(lineStart, cut, ''),
      caret: CaretRange.collapsed(caret),
      revision: revision,
    );
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
    final line = sourceCode.substring(
      lineStart,
      _lineEndAt(sourceCode, lineStart),
    );
    final response = _vocabulary.forProfile(profileId);
    final openers = (response['block_openers'] as List<Object?>).cast<String>();
    return openers.any(
          (opener) => _firstWord(line).toLowerCase() == opener.toLowerCase(),
        )
        ? '$indent$unit'
        : indent;
  }

  String _openingBreak({
    required String sourceCode,
    required int caretOffset,
    required int lineStart,
    required EditorKey key,
    required String indent,
  }) {
    if (key.kind != EditorKeyKind.template) return '';
    return sourceCode.substring(lineStart, caretOffset).trim().isEmpty
        ? ''
        : '\n$indent';
  }

  int _shiftedOffset(EditorKey key, String indent) {
    final raw = (key.caretOffset ?? key.insertion.length).clamp(
      0,
      key.insertion.length,
    );
    final head = key.insertion.substring(0, raw);
    return raw + '\n'.allMatches(head).length * indent.length;
  }

  String _removableIndent(String indent, String unit) {
    if (indent.startsWith(unit)) return unit;
    if (indent.startsWith(_tabIndent)) return _tabIndent;
    if (indent.startsWith(' ')) return ' ';
    return '';
  }

  String _firstWord(String text) {
    final trimmed = text.trimLeft();
    for (var index = 0; index < trimmed.length; index++) {
      if (trimmed[index] == ' ' || trimmed[index] == _tabIndent) {
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
