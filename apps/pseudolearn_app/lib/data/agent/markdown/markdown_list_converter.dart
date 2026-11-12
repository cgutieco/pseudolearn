import 'package:markdown/markdown.dart' as md;
import '../../../domain/model/agent/reply_block.dart';

typedef BlockConversion = List<ReplyBlock> Function(List<md.Node> nodes);

ReplyList listOf(md.Element list, BlockConversion convert) => ReplyList(
  ordered: list.tag == 'ol',
  start: int.tryParse(list.attributes['start'] ?? '') ?? 1,
  items: [
    for (final item in (list.children ?? const <md.Node>[]).whereType<md.Element>())
      ReplyListItem(task: _taskOf(item), blocks: convert(item.children ?? const [])),
  ],
);

ReplyTask _taskOf(md.Element item) {
  final checkbox = _checkboxIn(item.children ?? const []);
  if (checkbox == null) return ReplyTask.none;
  return checkbox.attributes.containsKey('checked') ? ReplyTask.done : ReplyTask.open;
}

md.Element? _checkboxIn(List<md.Node> nodes) {
  for (final node in nodes.whereType<md.Element>()) {
    if (node.tag == 'input') return node;
    if (node.tag == 'p') return _checkboxIn(node.children ?? const []);
  }
  return null;
}
