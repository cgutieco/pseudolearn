import 'rust_program_view.dart';

enum StatementTreatment {
  conditional,
  selection,
  whileLoop,
  repeatLoop,
  countedLoop,
  iteration,
  taskScope,
  receiveSelection,
  returnExit,
  breakExit,
  deferral,
  call,
  inputOutput,
  process,
  unsupported,
}

final class UnsupportedSyntaxView implements Exception {
  final String syntaxKind;

  const UnsupportedSyntaxView(this.syntaxKind);
}

const String _propagationKind = 'propagation';

const Set<String> _bodyRoles = {
  'body',
  'then_body',
  'else_body',
  'case',
  'default_case',
  'branch',
};

StatementTreatment rustStatementTreatment(
  RustProgramView view,
  RustViewNode node,
) {
  final treatment = _treatmentOfKind(node.syntaxKind);
  if (_isLeaf(treatment)) return treatment;
  return _headerPropagates(view, node)
      ? StatementTreatment.unsupported
      : treatment;
}

StatementTreatment _treatmentOfKind(String syntaxKind) => switch (syntaxKind) {
  'conditional' => StatementTreatment.conditional,
  'switch' => StatementTreatment.selection,
  'while_loop' => StatementTreatment.whileLoop,
  'repeat_loop' => StatementTreatment.repeatLoop,
  'for_loop' => StatementTreatment.countedLoop,
  'for_each_loop' => StatementTreatment.iteration,
  'task_scope' => StatementTreatment.taskScope,
  'select_statement' => StatementTreatment.receiveSelection,
  'return_statement' => StatementTreatment.returnExit,
  'break_statement' => StatementTreatment.breakExit,
  'defer_statement' => StatementTreatment.deferral,
  'call_statement' || 'spawn_statement' => StatementTreatment.call,
  'input' || 'output' => StatementTreatment.inputOutput,
  'assignment_statement' ||
  'declaration' ||
  'dimension_declaration' ||
  'discard_statement' => StatementTreatment.process,
  _ => StatementTreatment.unsupported,
};

bool _isLeaf(StatementTreatment treatment) => switch (treatment) {
  StatementTreatment.returnExit ||
  StatementTreatment.breakExit ||
  StatementTreatment.deferral ||
  StatementTreatment.call ||
  StatementTreatment.inputOutput ||
  StatementTreatment.process ||
  StatementTreatment.unsupported => true,
  _ => false,
};

String rustUnsupportedKind(RustProgramView view, RustViewNode node) =>
    _headerPropagates(view, node) ? _propagationKind : node.syntaxKind;

bool _headerPropagates(RustProgramView view, RustViewNode node) {
  for (final child in rustChildrenOf(view, node)) {
    if (_bodyRoles.contains(node.childRoles[child.id.value])) continue;
    if (rustFirstPropagation(view, child) != null) return true;
  }
  return false;
}

RustViewNode? rustFirstPropagation(RustProgramView view, RustViewNode node) {
  if (node.syntaxKind == _propagationKind) return node;
  if (node.syntaxKind == 'function_literal') return null;
  for (final child in rustChildrenOf(view, node)) {
    final found = rustFirstPropagation(view, child);
    if (found != null) return found;
  }
  return null;
}
