import 'package:equatable/equatable.dart';

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
}

final class EditorKey extends Equatable {
  final String label;
  final String insertion;
  final int? caretOffset;
  final EditorKeyKind kind;

  const EditorKey({
    required this.label,
    required this.insertion,
    required this.kind,
    this.caretOffset,
  });

  const EditorKey.template({
    required this.label,
    required this.insertion,
    required this.caretOffset,
  }) : kind = EditorKeyKind.template;

  const EditorKey.indent()
      : label = '',
        insertion = '',
        caretOffset = null,
        kind = EditorKeyKind.indent;

  const EditorKey.dedent()
      : label = '',
        insertion = '',
        caretOffset = null,
        kind = EditorKeyKind.dedent;

  @override
  List<Object?> get props => [label, insertion, caretOffset, kind];
}
