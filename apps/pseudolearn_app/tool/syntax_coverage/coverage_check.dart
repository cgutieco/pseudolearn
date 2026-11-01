import 'package:pseudolearn_app/domain/model/diagram/coverage/syntax_view_coverage_row.dart';

const Set<CoverageFamily> _executableFamilies = {
  CoverageFamily.control,
  CoverageFamily.exit,
  CoverageFamily.simpleStep,
  CoverageFamily.task,
};

final RegExp _anchorPattern = RegExp(r'^([A-Z][A-Z0-9.\-]*)@(\d+\.\d+\.\d+)#(R\d+)$');

List<String> checkSyntaxCoverage({
  required List<SyntaxViewCoverageRow> rows,
  required Map<String, String> inventory,
  required bool Function(String id, String version, String rule) ruleExists,
  required bool Function(String path) evidenceExists,
  required bool Function(String entry) helpExists,
}) {
  final violations = <String>[];
  final owners = <String, String>{};
  final constructs = <String>{};
  for (final row in rows) {
    if (!constructs.add(row.construct)) {
      violations.add('COV-DUPLICATE: construct ${row.construct} is repeated');
    }
    _checkRow(row, inventory, ruleExists, evidenceExists, violations);
    _checkHelp(row, helpExists, violations);
    for (final kind in row.syntaxKinds) {
      final previous = owners[kind];
      if (previous != null) {
        violations.add(
          'COV-DUPLICATE: $kind is claimed by $previous and ${row.construct}',
        );
      }
      owners[kind] = row.construct;
    }
  }
  for (final kind in inventory.keys) {
    if (!owners.containsKey(kind)) {
      violations.add('COV-MISSING-ROW: public form $kind has no row');
    }
  }
  return violations;
}

void _checkRow(
  SyntaxViewCoverageRow row,
  Map<String, String> inventory,
  bool Function(String, String, String) ruleExists,
  bool Function(String) evidenceExists,
  List<String> violations,
) {
  for (final kind in row.syntaxKinds) {
    final role = inventory[kind];
    if (role == null) {
      violations.add('COV-STALE-ROW: ${row.construct} lists unknown form $kind');
    } else if (role != row.role.name) {
      violations.add(
        'COV-ROLE: ${row.construct} declares ${row.role.name} but $kind is $role',
      );
    }
  }
  if (row.cells.any((cell) => cell.needsReason && cell.reason.trim().isEmpty)) {
    violations.add('COV-NO-REASON: ${row.construct} has a cell without reason');
  }
  if (_executableFamilies.contains(row.family) &&
      (row.flowchart.isNotApplicable || row.structogram.isNotApplicable)) {
    violations.add(
      'COV-HIDDEN-CONTROL: ${row.construct} is executable but hidden in a view',
    );
  }
  final anchor = _anchorPattern.firstMatch(row.rule);
  if (anchor == null ||
      !ruleExists(anchor.group(1)!, anchor.group(2)!, anchor.group(3)!)) {
    violations.add('COV-RULE: ${row.construct} cites ${row.rule}, which does not exist');
  }
  if (!evidenceExists(row.evidence)) {
    violations.add('COV-EVIDENCE: ${row.construct} cites missing ${row.evidence}');
  }
}

void _checkHelp(
  SyntaxViewCoverageRow row,
  bool Function(String) helpExists,
  List<String> violations,
) {
  final entry = row.help.helpEntry;
  if (!row.help.isExact || (entry.isNotEmpty && helpExists(entry))) return;
  violations.add(
    'COV-HELP: ${row.construct} declares exact help without an existing card ($entry)',
  );
}
