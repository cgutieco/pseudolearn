import 'syntax_view_coverage_declarations.dart';
import 'syntax_view_coverage_expressions.dart';
import 'syntax_view_coverage_row.dart';
import 'syntax_view_coverage_statements.dart';
import 'syntax_view_coverage_tasks.dart';

const List<SyntaxViewCoverageRow> syntaxViewCoverageMatrix = [
  ...syntaxViewCoverageStatements,
  ...syntaxViewCoverageTasks,
  ...syntaxViewCoverageDeclarations,
  ...syntaxViewCoverageExpressions,
];
