import 'coverage_cell.dart';
import 'syntax_view_coverage_row.dart';

const CoverageCell _exact = CoverageCell.exact();
const CoverageCell _notDrawn = CoverageCell.notApplicable(
  'a statement is never part of the class structure',
);

const List<SyntaxViewCoverageRow> syntaxViewCoverageTasks = [
  SyntaxViewCoverageRow(
    construct: 'task.scope_select',
    role: CoveragePublicRole.statement,
    family: CoverageFamily.task,
    syntaxKinds: ['task_scope', 'select_statement'],
    rule: 'LANG.TASK.SCOPE@1.0.0#R1',
    flowchart: _exact,
    structogram: _exact,
    structure: _notDrawn,
    help: CoverageCell.help('help.task-scope'),
    evidence: 'test/engine/rust/rust_task_diagram_builders_test.dart',
  ),
  SyntaxViewCoverageRow(
    construct: 'task.spawn',
    role: CoveragePublicRole.statement,
    family: CoverageFamily.task,
    syntaxKinds: ['spawn_statement'],
    rule: 'LANG.TASK.SCOPE@1.0.0#R1',
    flowchart: _exact,
    structogram: _exact,
    structure: _notDrawn,
    help: CoverageCell.help('help.task-scope'),
    evidence: 'test/engine/rust/rust_task_diagram_builders_test.dart',
  ),
  SyntaxViewCoverageRow(
    construct: 'task.receive_branch',
    role: CoveragePublicRole.statement,
    family: CoverageFamily.structuralWrapper,
    syntaxKinds: ['receive_branch'],
    rule: 'LANG.TASK.CHANNEL@1.0.0#R1',
    flowchart: CoverageCell.notApplicable(
      'drawn as a column of the owning select',
    ),
    structogram: CoverageCell.notApplicable(
      'drawn as a column of the owning select',
    ),
    structure: _notDrawn,
    focus: CoverageCell.notApplicable('focus targets the owning select'),
    help: CoverageCell.help('help.task-scope'),
    evidence: 'test/engine/rust/rust_task_diagram_builders_test.dart',
  ),
  SyntaxViewCoverageRow(
    construct: 'task.await',
    role: CoveragePublicRole.expression,
    family: CoverageFamily.expression,
    syntaxKinds: ['await_expression', 'spawn_expression'],
    rule: 'LANG.TASK.SUSPENSION@1.0.0#R1',
    flowchart: CoverageCell.notApplicable(
      'rendered inside the caption of the statement that suspends',
    ),
    structogram: CoverageCell.notApplicable(
      'rendered inside the caption of the statement that suspends',
    ),
    structure: _notDrawn,
    focus: CoverageCell.notApplicable('focus targets the owning statement'),
    help: CoverageCell.help('help.task-scope'),
    evidence: 'test/engine/rust/rust_task_diagram_builders_test.dart',
  ),
];
