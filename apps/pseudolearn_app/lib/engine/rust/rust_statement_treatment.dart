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
  call,
  inputOutput,
  process,
  unsupported,
}

final class UnsupportedSyntaxView implements Exception {
  final String syntaxKind;

  const UnsupportedSyntaxView(this.syntaxKind);
}

const Set<String> _unsupportedInsideLeaf = {'propagation'};

StatementTreatment rustStatementTreatment(
  RustProgramView view,
  RustViewNode node,
) {
  final treatment = _treatmentOfKind(node.syntaxKind);
  if (!_isLeaf(treatment)) return treatment;
  return _containsUnsupported(view, node)
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
  StatementTreatment.call ||
  StatementTreatment.inputOutput ||
  StatementTreatment.process => true,
  _ => false,
};

String rustUnsupportedKind(RustProgramView view, RustViewNode node) =>
    _firstUnsupportedInside(view, node) ?? node.syntaxKind;

bool _containsUnsupported(RustProgramView view, RustViewNode node) =>
    _firstUnsupportedInside(view, node) != null;

String? _firstUnsupportedInside(RustProgramView view, RustViewNode node) {
  if (_unsupportedInsideLeaf.contains(node.syntaxKind)) return node.syntaxKind;
  for (final child in rustChildrenOf(view, node)) {
    final found = _firstUnsupportedInside(view, child);
    if (found != null) return found;
  }
  return null;
}
