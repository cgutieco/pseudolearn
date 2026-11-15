import 'package:equatable/equatable.dart';
import '../completion/completion_item.dart';
import 'caret_range.dart';

enum EditorKeyKind {
  indent,
  dedent,
  assignment,
  quote,
  openParenthesis,
  closeParenthesis,
  greaterOrEqual,
  lessOrEqual,
  template,
  completion,
  stopNext,
  stopPrevious,
  stopExit,
}

final class EditorKey extends Equatable {
  final String label;
  final String insertion;
  final int? caretOffset;
  final EditorKeyKind kind;
  final CaretRange? replacementRange;
  final int? revision;
  final String? construction;

  const EditorKey({
    required this.label,
    required this.insertion,
    required this.kind,
    this.caretOffset,
    this.replacementRange,
    this.revision,
    this.construction,
  });

  const EditorKey.template({
    required this.label,
    required this.insertion,
    required this.caretOffset,
    this.construction,
  }) : kind = EditorKeyKind.template,
       replacementRange = null,
       revision = null;

  const EditorKey.stop(this.kind)
    : label = '',
      insertion = '',
      caretOffset = null,
      replacementRange = null,
      revision = null,
      construction = null;

  const EditorKey.completion({
    required this.label,
    required this.insertion,
    required this.replacementRange,
    required this.revision,
  }) : caretOffset = null,
       construction = null,
       kind = EditorKeyKind.completion;

  const EditorKey.indent()
    : label = '',
      insertion = '',
      caretOffset = null,
      kind = EditorKeyKind.indent,
      replacementRange = null,
      construction = null,
      revision = null;

  const EditorKey.dedent()
    : label = '',
      insertion = '',
      caretOffset = null,
      kind = EditorKeyKind.dedent,
      replacementRange = null,
      construction = null,
      revision = null;

  static EditorKey ofCompletion(CompletionItem item) {
    final replacementRange = item.replacementRange;
    final revision = item.revision;
    if (replacementRange != null && revision != null) {
      return EditorKey.completion(
        label: item.label,
        insertion: item.template,
        replacementRange: replacementRange,
        revision: revision,
      );
    }
    return EditorKey.template(
      label: item.label,
      insertion: item.template,
      caretOffset: item.caretOffset,
      construction: item.construction,
    );
  }

  @override
  List<Object?> get props => [
    label,
    insertion,
    caretOffset,
    kind,
    replacementRange,
    revision,
    construction,
  ];
}
