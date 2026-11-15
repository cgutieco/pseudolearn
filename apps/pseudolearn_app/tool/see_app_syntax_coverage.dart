import 'dart:io';

import 'package:pseudolearn_app/domain/model/diagram/coverage/coverage_cell.dart';
import 'package:pseudolearn_app/domain/model/diagram/coverage/syntax_view_coverage_matrix.dart';
import 'package:pseudolearn_app/domain/model/diagram/coverage/syntax_view_coverage_row.dart';

import 'syntax_coverage/coverage_check.dart';
import 'syntax_coverage/engine_inventory.dart';
import 'syntax_coverage/help_catalog.dart';

const String _target = 'selection.conditional';

Future<Map<String, Object?>> runSyntaxCoverageScenario(
  Map<String, Object?> input,
) async {
  final rows = _mutated(input['mutation'] as String);
  final violations = checkSyntaxCoverage(
    rows: rows,
    inventory: readEngineInventory(),
    ruleExists: (id, version, rule) => true,
    evidenceExists: (path) => File(path).existsSync(),
    helpExists: readHelpCardIds().contains,
  );
  final codes = {
    for (final violation in violations) violation.split(':').first,
  }.toList()..sort();
  return {'codes': codes};
}

List<SyntaxViewCoverageRow> _mutated(String mutation) {
  final target = syntaxViewCoverageMatrix.firstWhere(
    (row) => row.construct == _target,
  );
  final others = [
    for (final row in syntaxViewCoverageMatrix)
      if (row.construct != _target) row,
  ];
  return switch (mutation) {
    'remove_row' => others,
    'duplicate_row' => [...others, target, target],
    _ => [...others, _rebuilt(target, mutation)],
  };
}

SyntaxViewCoverageRow _rebuilt(SyntaxViewCoverageRow row, String mutation) =>
    SyntaxViewCoverageRow(
      construct: row.construct,
      role: mutation == 'change_role'
          ? CoveragePublicRole.declaration
          : row.role,
      family: row.family,
      syntaxKinds: mutation == 'unknown_form'
          ? [...row.syntaxKinds, 'unknown_public_form']
          : row.syntaxKinds,
      rule: row.rule,
      flowchart: mutation == 'hide_control'
          ? const CoverageCell.notApplicable('hidden on purpose')
          : row.flowchart,
      structogram: row.structogram,
      structure: mutation == 'drop_reason'
          ? const CoverageCell.notApplicable('')
          : row.structure,
      focus: row.focus,
      state: row.state,
      help: mutation == 'missing_help'
          ? const CoverageCell.help('help.missing')
          : row.help,
      evidence: row.evidence,
    );
