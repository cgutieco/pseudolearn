import 'rust_program_view.dart';
import 'rust_wire_models.dart';
import 'source_offset_index.dart';

bool isExecutableReport(Map<String, Object?> report) {
  final diagnostics = (report['diagnostics'] as List<Object?>)
      .cast<Map<String, Object?>>();
  return report['tree'] as bool &&
      !diagnostics.any((item) => item['severity'] == 'error');
}

String? inputPromptOf(
  RustProgramView view,
  SourceOffsetIndex offsets,
  RustEvent event,
) {
  final node = view.node(event.nodeId);
  if (node == null) return null;
  final text = offsets.textBetween(node.range).replaceAll(';', '').trim();
  final separator = text.indexOf(' ');
  return separator < 0 ? text : text.substring(separator + 1).trim();
}
