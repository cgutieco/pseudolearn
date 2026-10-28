import 'rust_program_view.dart';

const Set<String> rustTaskStatementKinds = {
  'task_scope',
  'spawn_statement',
  'select_statement',
};

bool rustNodeSuspends(RustProgramView view, RustViewNode node) =>
    node.syntaxKind == 'await_expression' ||
    rustChildrenOf(view, node).any((child) => rustNodeSuspends(view, child));

bool rustNodeIsTaskOperation(RustProgramView view, RustViewNode node) =>
    node.syntaxKind == 'spawn_statement' || rustNodeSuspends(view, node);

String rustHeaderLine(RustViewNode node) {
  final first = node.text.split('\n').first.trim();
  return first.endsWith(':') ? first.substring(0, first.length - 1) : first;
}
