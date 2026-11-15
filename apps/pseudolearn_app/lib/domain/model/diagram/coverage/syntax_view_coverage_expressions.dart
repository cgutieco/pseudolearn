import 'coverage_cell.dart';
import 'syntax_view_coverage_row.dart';

const String _flowTests =
    'test/engine/rust/rust_flowchart_builder_contract_test.dart';
const String _classTests =
    'test/engine/rust/rust_class_diagram_builder_contract_test.dart';
const String _coverageTests =
    'test/engine/rust/rust_syntax_coverage_behavior_test.dart';
const String _exitTests =
    'test/engine/rust/rust_control_exit_diagram_test.dart';

const CoverageCell _exact = CoverageCell.exact();

const CoverageCell _inCaption = CoverageCell.notApplicable(
  'an expression is rendered inside the caption of its statement',
);

const CoverageCell _notStructure = CoverageCell.notApplicable(
  'an expression is not part of the class structure',
);

const CoverageCell _focusOwner = CoverageCell.notApplicable(
  'focus targets the owning statement',
);

const List<SyntaxViewCoverageRow> syntaxViewCoverageExpressions = [
  SyntaxViewCoverageRow(
    construct: 'expression.operator',
    role: CoveragePublicRole.expression,
    family: CoverageFamily.expression,
    syntaxKinds: [
      'addition',
      'minus',
      'multiplication',
      'divide',
      'integer_divide',
      'modulo',
      'power',
      'power_expression',
      'and',
      'or',
      'not',
      'conjunction',
      'disjunction',
      'equality',
      'ordering',
      'unary',
    ],
    rule: 'LANG.OPS.PRECEDENCE@1.0.0#R1',
    flowchart: _inCaption,
    structogram: _inCaption,
    structure: _notStructure,
    focus: _focusOwner,
    help: CoverageCell.help('help.arithmetic'),
    evidence: _flowTests,
  ),
  SyntaxViewCoverageRow(
    construct: 'expression.operand',
    role: CoveragePublicRole.expression,
    family: CoverageFamily.expression,
    syntaxKinds: [
      'literal',
      'designator',
      'primary',
      'postfix',
      'expression',
      'expressions',
      'arguments',
      'labels',
      'this_object',
    ],
    rule: 'LANG.OPS.PRECEDENCE@1.0.0#R1',
    flowchart: _inCaption,
    structogram: _inCaption,
    structure: _notStructure,
    focus: _focusOwner,
    help: CoverageCell.help('help.literal'),
    evidence: _flowTests,
  ),
  SyntaxViewCoverageRow(
    construct: 'expression.instance',
    role: CoveragePublicRole.expression,
    family: CoverageFamily.expression,
    syntaxKinds: ['new_instance', 'instantiation'],
    rule: 'LANG.CLASS.INSTANTIATION@1.0.0#R1',
    flowchart: _inCaption,
    structogram: _inCaption,
    structure: _notStructure,
    focus: _focusOwner,
    help: CoverageCell.help('help.instantiation'),
    evidence: _flowTests,
  ),
  SyntaxViewCoverageRow(
    construct: 'expression.propagation',
    role: CoveragePublicRole.expression,
    family: CoverageFamily.expression,
    syntaxKinds: ['propagation'],
    rule: 'LANG.TYPES.RELATIONS@1.0.0#R4',
    flowchart: _exact,
    structogram: _exact,
    structure: _notStructure,
    focus: _focusOwner,
    help: CoverageCell.help('help.variants'),
    evidence: _exitTests,
  ),
  SyntaxViewCoverageRow(
    construct: 'expression.variant_construction',
    role: CoveragePublicRole.expression,
    family: CoverageFamily.expression,
    syntaxKinds: ['variant_construction'],
    rule: 'LANG.TYPES.RELATIONS@1.0.0#R1',
    flowchart: _inCaption,
    structogram: _inCaption,
    structure: _notStructure,
    focus: _focusOwner,
    help: CoverageCell.help('help.variants'),
    evidence: _coverageTests,
  ),
  SyntaxViewCoverageRow(
    construct: 'type.reference',
    role: CoveragePublicRole.type,
    family: CoverageFamily.type,
    syntaxKinds: ['type', 'type_arguments'],
    rule: 'LANG.TYPES.GENERIC@1.0.0#R1',
    flowchart: CoverageCell.notApplicable('a type is part of a caption'),
    structogram: CoverageCell.notApplicable('a type is part of a caption'),
    structure: _exact,
    focus: CoverageCell.notApplicable('focus targets the owning declaration'),
    help: CoverageCell.help('help.variables'),
    evidence: _classTests,
  ),
  SyntaxViewCoverageRow(
    construct: 'symbol.identifier',
    role: CoveragePublicRole.symbol,
    family: CoverageFamily.symbol,
    syntaxKinds: ['identifier'],
    rule: 'LANG.LEXICAL.IDENTIFIER@1.0.0#R1',
    flowchart: CoverageCell.notApplicable('a name is part of a caption'),
    structogram: CoverageCell.notApplicable('a name is part of a caption'),
    structure: CoverageCell.notApplicable('a name is part of a row'),
    focus: CoverageCell.notApplicable('focus targets the owning declaration'),
    help: CoverageCell.help('help.variables'),
    evidence: _flowTests,
  ),
];
