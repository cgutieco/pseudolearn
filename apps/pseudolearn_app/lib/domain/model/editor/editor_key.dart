import 'package:equatable/equatable.dart';
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
}

final class EditorKey extends Equatable {
  final String label;
  final String insertion;
  final int? caretOffset;
  final EditorKeyKind kind;
  final CaretRange? replacementRange;
  final int? revision;

  const EditorKey({
    required this.label,
    required this.insertion,
    required this.kind,
    this.caretOffset,
    this.replacementRange,
    this.revision,
  });

  const EditorKey.template({
    required this.label,
    required this.insertion,
    required this.caretOffset,
  }) : kind = EditorKeyKind.template,
       replacementRange = null,
       revision = null;

  const EditorKey.completion({
    required this.label,
    required this.insertion,
    required this.replacementRange,
    required this.revision,
  }) : caretOffset = null,
       kind = EditorKeyKind.completion;

  const EditorKey.indent()
    : label = '',
      insertion = '',
      caretOffset = null,
      kind = EditorKeyKind.indent,
      replacementRange = null,
      revision = null;

  const EditorKey.dedent()
    : label = '',
      insertion = '',
      caretOffset = null,
      kind = EditorKeyKind.dedent,
      replacementRange = null,
      revision = null;

  @override
  List<Object?> get props => [
    label,
    insertion,
    caretOffset,
    kind,
    replacementRange,
    revision,
  ];
}
