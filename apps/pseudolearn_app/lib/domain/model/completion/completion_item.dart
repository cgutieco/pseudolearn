import '../editor/caret_range.dart';

enum CompletionFamily { structured, procedural, oop }

enum CompletionKind {
  keyword,
  type,
  variable,
  function,
  method,
  field,
  classType,
  snippet,
}

final class CompletionItem {
  final String label;
  final String template;
  final int caretOffset;
  final CompletionFamily family;
  final CompletionKind? kind;
  final String? detail;
  final String? bilingualOrigin;
  final String? detailKey;
  final List<String> detailArguments;
  final bool isInline;
  final String? construction;
  final CaretRange? replacementRange;
  final int? revision;

  const CompletionItem({
    required this.label,
    required this.template,
    required this.caretOffset,
    required this.family,
    this.kind,
    this.detail,
    this.bilingualOrigin,
    this.detailKey,
    this.detailArguments = const [],
    this.isInline = false,
    this.construction,
    this.replacementRange,
    this.revision,
  });
}
