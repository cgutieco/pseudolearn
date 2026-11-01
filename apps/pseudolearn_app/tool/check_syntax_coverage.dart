import 'dart:io';

import 'package:pseudolearn_app/domain/model/diagram/coverage/syntax_view_coverage_matrix.dart';

import 'syntax_coverage/coverage_check.dart';
import 'syntax_coverage/engine_inventory.dart';
import 'syntax_coverage/help_catalog.dart';

const String _specificationsPath =
    '../../packages/pseudolearn_spec/specifications';

void main() {
  final inventory = readEngineInventory();
  final helpCards = readHelpCardIds();
  final violations = checkSyntaxCoverage(
    rows: syntaxViewCoverageMatrix,
    inventory: inventory,
    ruleExists: _ruleExists,
    evidenceExists: (path) => File(path).existsSync(),
    helpExists: helpCards.contains,
  );
  final covered = {
    for (final row in syntaxViewCoverageMatrix) ...row.syntaxKinds,
  };
  stdout.writeln(
    'Expected ${inventory.length} public forms, covered ${covered.length}.',
  );
  if (violations.isEmpty) {
    stdout.writeln('Syntax coverage checks passed.');
    return;
  }
  for (final violation in violations) {
    stderr.writeln('ERROR: $violation');
  }
  exit(1);
}

bool _ruleExists(String id, String version, String rule) {
  final domain = id.split('.').first.toLowerCase();
  final file = File('$_specificationsPath/$domain/${id.toLowerCase()}.md');
  if (!file.existsSync()) return false;
  final text = file.readAsStringSync();
  return text.contains('"id": "$id"') &&
      text.contains('"version": "$version"') &&
      text.contains('"id": "$rule"');
}
