import '../../domain/model/completion/assist_result.dart';
import '../../domain/model/editor/caret_range.dart';
import '../../domain/model/editor/editor_key.dart';
import '../../domain/model/editor/source_edit.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/ports/edit_assist_source.dart';
import '../../domain/ports/source_editor.dart';

const String _tabIndent = '\t';
const String _spaceIndent = '  ';

final class RustSourceEditor implements SourceEditor {
  final EditAssistSource _assist;

  const RustSourceEditor(this._assist);

  @override
  SourceEdit applyKey({
    required String sourceCode,
    required CaretRange caret,
    required EditorKey key,
    required SyntaxProfileId profileId,
    required int revision,
  }) {
    final range = caret.clampedTo(sourceCode.length);
    final assisted = _assisted(
      sourceCode: sourceCode,
      range: range,
      key: key,
      profileId: profileId,
    );
    if (assisted != null) {
      return SourceEdit(
        sourceCode: assisted.sourceCode,
        caret: assisted.selection,
        revision: revision,
        templateActive: assisted.templateActive,
      );
    }
    return _withoutAssistance(
      sourceCode: sourceCode,
      range: range,
      key: key,
      revision: revision,
    );
  }

  SourceEdit _withoutAssistance({
    required String sourceCode,
    required CaretRange range,
    required EditorKey key,
    required int revision,
  }) {
    return switch (key.kind) {
      EditorKeyKind.completion => _replaceRange(sourceCode, key, revision),
      EditorKeyKind.dedent => _dedent(sourceCode, range, revision),
      EditorKeyKind.stopNext ||
      EditorKeyKind.stopPrevious ||
      EditorKeyKind.stopExit => SourceEdit(
        sourceCode: sourceCode,
        caret: range,
        revision: revision,
      ),
      _ => _insert(
        sourceCode: sourceCode,
        range: range,
        key: key,
        revision: revision,
      ),
    };
  }

  @override
  SourceEdit? afterTyping({
    required String sourceCode,
    required int cursorUtf16,
    required String character,
    required SyntaxProfileId profileId,
    required int revision,
  }) {
    final result = _assist.afterTyping(
      sourceCode: sourceCode,
      profileId: profileId,
      cursorUtf16: cursorUtf16,
      character: character,
    );
    if (result == null) return null;
    return SourceEdit(
      sourceCode: result.sourceCode,
      caret: result.selection,
      revision: revision,
      templateActive: result.templateActive,
    );
  }

  AssistResult? _assisted({
    required String sourceCode,
    required CaretRange range,
    required EditorKey key,
    required SyntaxProfileId profileId,
  }) {
    final replacement = key.replacementRange?.clampedTo(sourceCode.length);
    final construction = key.construction;
    return switch (key.kind) {
      EditorKeyKind.completion when replacement != null => _assist.accept(
        sourceCode: sourceCode,
        profileId: profileId,
        replacement: replacement,
        label: key.label,
      ),
      EditorKeyKind.template when construction != null =>
        _assist.insertTemplate(
          sourceCode: sourceCode,
          profileId: profileId,
          construction: construction,
          replacement: range,
        ),
      EditorKeyKind.stopNext => _navigate(
        sourceCode,
        profileId,
        StopDirection.next,
      ),
      EditorKeyKind.stopPrevious => _navigate(
        sourceCode,
        profileId,
        StopDirection.previous,
      ),
      EditorKeyKind.stopExit => _navigate(
        sourceCode,
        profileId,
        StopDirection.exit,
      ),
      _ => null,
    };
  }

  AssistResult? _navigate(
    String sourceCode,
    SyntaxProfileId profileId,
    StopDirection direction,
  ) => _assist.navigate(
    sourceCode: sourceCode,
    profileId: profileId,
    direction: direction,
  );

  SourceEdit _replaceRange(String sourceCode, EditorKey key, int revision) {
    final replacement = key.replacementRange;
    if (replacement == null) {
      return SourceEdit(
        sourceCode: sourceCode,
        caret: CaretRange.collapsed(0),
        revision: revision,
      );
    }
    final range = replacement.clampedTo(sourceCode.length);
    return SourceEdit(
      sourceCode: sourceCode.replaceRange(
        range.lower,
        range.upper,
        key.insertion,
      ),
      caret: CaretRange.collapsed(range.lower + key.insertion.length),
      revision: revision,
    );
  }

  SourceEdit _insert({
    required String sourceCode,
    required CaretRange range,
    required EditorKey key,
    required int revision,
  }) {
    final body = key.kind == EditorKeyKind.indent
        ? _unitOf(sourceCode)
        : key.insertion;
    final shift = key.kind == EditorKeyKind.indent
        ? body.length
        : (key.caretOffset ?? body.length).clamp(0, body.length);
    return SourceEdit(
      sourceCode: sourceCode.replaceRange(range.lower, range.upper, body),
      caret: CaretRange.collapsed(range.lower + shift),
      revision: revision,
    );
  }

  SourceEdit _dedent(String sourceCode, CaretRange range, int revision) {
    final lineStart = _lineStartAt(sourceCode, range.lower);
    final removed = _removableIndent(
      _leadingWhitespace(sourceCode, lineStart),
      _unitOf(sourceCode),
    );
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

  String _unitOf(String sourceCode) =>
      sourceCode.contains(_tabIndent) ? _tabIndent : _spaceIndent;

  String _removableIndent(String indent, String unit) {
    if (indent.startsWith(unit)) return unit;
    if (indent.startsWith(_tabIndent)) return _tabIndent;
    if (indent.startsWith(' ')) return ' ';
    return '';
  }

  int _lineStartAt(String source, int offset) {
    var index = offset;
    while (index > 0 && source[index - 1] != '\n') {
      index--;
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
