import 'coverage_cell.dart';
import 'syntax_view_coverage_row.dart';

const String _flowTests =
    'test/engine/rust/rust_flowchart_builder_contract_test.dart';
const String _classTests =
    'test/engine/rust/rust_class_diagram_builder_contract_test.dart';
const String _contractTests =
    'test/engine/rust/rust_type_contract_diagram_test.dart';
const String _coverageTests =
    'test/engine/rust/rust_syntax_coverage_behavior_test.dart';
const String _valueTypeTests =
    'test/engine/rust/rust_value_type_diagram_test.dart';

const CoverageCell _exact = CoverageCell.exact();

const List<SyntaxViewCoverageRow> syntaxViewCoverageDeclarations = [
  SyntaxViewCoverageRow(
    construct: 'unit.entry_subprogram',
    role: CoveragePublicRole.declaration,
    family: CoverageFamily.unit,
    syntaxKinds: ['algorithm_unit', 'subroutine'],
    rule: 'LANG.SUBPROGRAM.DECLARATION@1.0.0#R1',
    flowchart: _exact,
    structogram: _exact,
    structure: CoverageCell.notApplicable(
      'subprogram contracts are represented by their own structural rows',
    ),
    help: CoverageCell.help('help.subprogram'),
    evidence: _flowTests,
  ),
  SyntaxViewCoverageRow(
    construct: 'unit.class_member',
    role: CoveragePublicRole.declaration,
    family: CoverageFamily.unit,
    syntaxKinds: ['method_member', 'constructor_member'],
    rule: 'LANG.CLASS.METHODS@1.0.0#R1',
    flowchart: _exact,
    structogram: _exact,
    structure: _exact,
    help: CoverageCell.help('help.method'),
    evidence: _flowTests,
  ),
  SyntaxViewCoverageRow(
    construct: 'class.declaration',
    role: CoveragePublicRole.declaration,
    family: CoverageFamily.unit,
    syntaxKinds: ['class_unit'],
    rule: 'LANG.CLASS.DECLARATION@1.0.0#R1',
    flowchart: CoverageCell.notApplicable(
      'a class has no execution; its members are units',
    ),
    structogram: CoverageCell.notApplicable(
      'a class has no execution; its members are units',
    ),
    structure: _exact,
    help: CoverageCell.help('help.class'),
    evidence: _classTests,
  ),
  SyntaxViewCoverageRow(
    construct: 'class.field',
    role: CoveragePublicRole.declaration,
    family: CoverageFamily.valueDeclaration,
    syntaxKinds: ['field_declaration'],
    rule: 'LANG.CLASS.FIELDS@1.0.0#R1',
    flowchart: CoverageCell.notApplicable('a field is not a step'),
    structogram: CoverageCell.notApplicable('a field is not a step'),
    structure: _exact,
    help: CoverageCell.help('help.class'),
    evidence: _classTests,
  ),
  SyntaxViewCoverageRow(
    construct: 'decl.variable',
    role: CoveragePublicRole.declaration,
    family: CoverageFamily.simpleStep,
    syntaxKinds: ['declaration', 'dimension_declaration'],
    rule: 'LANG.DECL.VARIABLE@1.0.0#R1',
    flowchart: _exact,
    structogram: _exact,
    structure: CoverageCell.notApplicable(
      'a local declaration is not part of the class structure',
    ),
    help: CoverageCell.help('help.variables'),
    evidence: _flowTests,
  ),
  SyntaxViewCoverageRow(
    construct: 'decl.dimensioned',
    role: CoveragePublicRole.declaration,
    family: CoverageFamily.structuralWrapper,
    syntaxKinds: ['dimensioned'],
    rule: 'LANG.ARRAY.DIMENSION@1.0.0#R1',
    flowchart: CoverageCell.notApplicable(
      'rendered inside the caption of its declaration',
    ),
    structogram: CoverageCell.notApplicable(
      'rendered inside the caption of its declaration',
    ),
    structure: CoverageCell.notApplicable(
      'rendered inside the row of its owner',
    ),
    focus: CoverageCell.notApplicable('focus targets the owning declaration'),
    help: CoverageCell.help('help.arrays'),
    evidence: _flowTests,
  ),
  SyntaxViewCoverageRow(
    construct: 'contract.interface',
    role: CoveragePublicRole.declaration,
    family: CoverageFamily.contract,
    syntaxKinds: ['interface_unit', 'interface_signature', 'realization'],
    rule: 'LANG.TYPES.INTERFACE@1.0.0#R1',
    flowchart: CoverageCell.notApplicable('a contract has no execution'),
    structogram: CoverageCell.notApplicable('a contract has no execution'),
    structure: _exact,
    help: CoverageCell.help('construction.interface'),
    evidence: _contractTests,
  ),
  SyntaxViewCoverageRow(
    construct: 'generic.parameters',
    role: CoveragePublicRole.declaration,
    family: CoverageFamily.contract,
    syntaxKinds: ['type_parameters', 'type_parameter'],
    rule: 'LANG.TYPES.GENERIC@1.0.0#R1',
    flowchart: CoverageCell.notApplicable('a type parameter has no execution'),
    structogram: CoverageCell.notApplicable(
      'a type parameter has no execution',
    ),
    structure: _exact,
    help: CoverageCell.help('construction.interface'),
    evidence: _valueTypeTests,
  ),
  SyntaxViewCoverageRow(
    construct: 'value.record',
    role: CoveragePublicRole.declaration,
    family: CoverageFamily.valueDeclaration,
    syntaxKinds: ['record_unit', 'record_field'],
    rule: 'LANG.TYPES.RECORD@1.0.0#R1',
    flowchart: CoverageCell.notApplicable(
      'a record declaration has no execution',
    ),
    structogram: CoverageCell.notApplicable(
      'a record declaration has no execution',
    ),
    structure: _exact,
    help: CoverageCell.help('help.record'),
    evidence: _valueTypeTests,
  ),
  SyntaxViewCoverageRow(
    construct: 'value.enum',
    role: CoveragePublicRole.declaration,
    family: CoverageFamily.valueDeclaration,
    syntaxKinds: ['enum_unit', 'enum_members'],
    rule: 'LANG.TYPES.ENUM@1.0.0#R1',
    flowchart: CoverageCell.notApplicable(
      'an enum declaration has no execution',
    ),
    structogram: CoverageCell.notApplicable(
      'an enum declaration has no execution',
    ),
    structure: _exact,
    help: CoverageCell.help('help.enum'),
    evidence: _valueTypeTests,
  ),
  SyntaxViewCoverageRow(
    construct: 'closure.function_literal',
    role: CoveragePublicRole.declaration,
    family: CoverageFamily.closure,
    syntaxKinds: ['function_literal'],
    rule: 'LANG.TYPES.FUNCTION@1.0.0#R1',
    flowchart: _exact,
    structogram: _exact,
    structure: CoverageCell.notApplicable(
      'a function literal is not part of the class structure',
    ),
    help: CoverageCell.help('help.function-literal'),
    evidence: _coverageTests,
  ),
  SyntaxViewCoverageRow(
    construct: 'pattern.variant',
    role: CoveragePublicRole.declaration,
    family: CoverageFamily.pattern,
    syntaxKinds: ['variant_pattern'],
    rule: 'LANG.CONTROL.SWITCH@1.0.0#R1',
    flowchart: _exact,
    structogram: _exact,
    structure: CoverageCell.notApplicable(
      'a pattern is not part of the class structure',
    ),
    help: CoverageCell.help('help.variants'),
    evidence: _coverageTests,
  ),
  SyntaxViewCoverageRow(
    construct: 'signature.parameters',
    role: CoveragePublicRole.declaration,
    family: CoverageFamily.structuralWrapper,
    syntaxKinds: ['parameters', 'parameter'],
    rule: 'LANG.SUBPROGRAM.PARAMETERS@1.0.0#R1',
    flowchart: CoverageCell.notApplicable(
      'rendered inside the caption of its call or unit title',
    ),
    structogram: CoverageCell.notApplicable(
      'rendered inside the caption of its call or unit title',
    ),
    structure: _exact,
    focus: CoverageCell.notApplicable('focus targets the owning signature'),
    help: CoverageCell.help('help.parameter-mode'),
    evidence: _classTests,
  ),
];
