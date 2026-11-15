import 'dart:convert';

import 'rust_wire_models.dart';

String rustEventSignature(RustEvent event) =>
    '${event.eventClass}|task=${event.taskId ?? '-'}'
    '|node=${_nodeWithoutRevision(event)}|line=${event.line}'
    '|depth=${event.depth}|${jsonEncode(event.data)}';

String _nodeWithoutRevision(RustEvent event) {
  final node = event.nodeId;
  final revision = event.sourceRevisionId;
  if (node == null) return '-';
  if (revision != null && node.startsWith('$revision.')) {
    return node.substring(revision.length + 1);
  }
  return node;
}
