import 'rust_program_view.dart';
import 'rust_wire_models.dart';
import 'source_offset_index.dart';
import 'source_offset_text.dart';

bool rustEventRequiresEnvironment(String eventClass) => const {
  'statement_entered',
  'statement_exited',
  'decision',
  'call',
  'return',
  'task_resumed',
  'task_suspended',
}.contains(eventClass);

bool isExecutableReport(Map<String, Object?> report) {
  final diagnostics = (report['diagnostics'] as List<Object?>)
      .cast<Map<String, Object?>>();
  return report['tree'] as bool &&
      !diagnostics.any((item) => item['severity'] == 'error');
}

String readStatementSourceOf(
  RustProgramView view,
  SourceOffsetIndex offsets,
  RustEvent event,
) {
  final node = view.node(event.nodeId);
  if (node == null) return '';
  return offsets.textBetween(node.range);
}
