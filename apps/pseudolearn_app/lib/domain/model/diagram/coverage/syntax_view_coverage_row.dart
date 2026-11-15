import 'coverage_cell.dart';

enum CoveragePublicRole { statement, declaration, expression, symbol, type }

enum CoverageFamily {
  control,
  exit,
  simpleStep,
  structuralWrapper,
  task,
  unit,
  contract,
  valueDeclaration,
  closure,
  pattern,
  expression,
  type,
  symbol,
}

final class SyntaxViewCoverageRow {
  final String construct;
  final CoveragePublicRole role;
  final CoverageFamily family;
  final List<String> syntaxKinds;
  final String rule;
  final CoverageCell flowchart;
  final CoverageCell structogram;
  final CoverageCell structure;
  final CoverageCell focus;
  final CoverageCell state;
  final CoverageCell help;
  final String evidence;

  const SyntaxViewCoverageRow({
    required this.construct,
    required this.role,
    required this.family,
    required this.syntaxKinds,
    required this.rule,
    required this.flowchart,
    required this.structogram,
    required this.structure,
    this.focus = const CoverageCell.exact(),
    this.state = const CoverageCell.notApplicable(
      'the execution table shows values, never syntax',
    ),
    required this.help,
    required this.evidence,
  });

  List<CoverageCell> get cells => [
    flowchart,
    structogram,
    structure,
    focus,
    state,
    help,
  ];
}
