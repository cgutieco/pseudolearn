import 'package:markdown/markdown.dart' as md;
import '../../../domain/model/agent/reply_run.dart';

final RegExp _lineBreakTag = RegExp(r'<br\s*/?>', caseSensitive: false);
final RegExp _presentationTag = RegExp(
  r'</?(kbd|sub|sup|b|i|u|em|strong|span|small|mark|ins|del|s|p|div|center|font|details|summary)'
  r'(\s+[\w-]+=("[^"]*"' "|'[^']*'" r'))*\s*>',
  caseSensitive: false,
);

const Map<String, ReplyMark> _marksByTag = {
  'strong': ReplyMark.strong,
  'b': ReplyMark.strong,
  'em': ReplyMark.emphasis,
  'i': ReplyMark.emphasis,
  'del': ReplyMark.strikethrough,
  's': ReplyMark.strikethrough,
};

final class _InlineContext {
  final Set<ReplyMark> marks;
  final String? target;

  const _InlineContext({this.marks = const {}, this.target});

  _InlineContext marked(ReplyMark mark) => _InlineContext(marks: {...marks, mark}, target: target);

  _InlineContext linked(String? destination) => _InlineContext(marks: marks, target: destination);
}

List<ReplyRun> inlineRuns(List<md.Node> nodes) {
  final runs = <ReplyRun>[];
  for (final node in nodes) {
    _collect(node, const _InlineContext(), runs);
  }
  return _trimmed(runs);
}

void _collect(md.Node node, _InlineContext context, List<ReplyRun> runs) {
  if (node is md.Element) {
    _collectElement(node, context, runs);
    return;
  }
  final text = _visibleText(node.textContent);
  if (text.isNotEmpty) runs.add(ReplyRun(text, marks: context.marks, target: context.target));
}

void _collectElement(md.Element element, _InlineContext context, List<ReplyRun> runs) {
  final leaf = _leafRun(element, context);
  if (leaf != null) {
    runs.add(leaf);
    return;
  }
  if (element.tag == 'input') return;
  final inner = _innerContext(element, context);
  for (final child in element.children ?? const <md.Node>[]) {
    _collect(child, inner, runs);
  }
}

ReplyRun? _leafRun(md.Element element, _InlineContext context) => switch (element.tag) {
  'br' => ReplyRun('\n', marks: context.marks, target: context.target),
  'img' => _imageRun(element, context),
  'code' => ReplyRun(element.textContent, marks: {...context.marks, ReplyMark.code}, target: context.target),
  _ => null,
};

ReplyRun _imageRun(md.Element element, _InlineContext context) {
  final alt = element.attributes['alt'] ?? '';
  final source = element.attributes['src'] ?? '';
  return ReplyRun(alt.isEmpty ? source : alt, marks: context.marks, target: source);
}

_InlineContext _innerContext(md.Element element, _InlineContext context) {
  final mark = _marksByTag[element.tag];
  if (mark != null) return context.marked(mark);
  if (element.tag == 'a') return context.linked(element.attributes['href']);
  return context;
}

String _visibleText(String raw) => raw.replaceAll(_lineBreakTag, '\n').replaceAll(_presentationTag, '');

List<ReplyRun> _trimmed(List<ReplyRun> runs) {
  while (runs.isNotEmpty && runs.last.text.trim().isEmpty) {
    runs.removeLast();
  }
  while (runs.isNotEmpty && runs.first.text.trim().isEmpty) {
    runs.removeAt(0);
  }
  return runs;
}
