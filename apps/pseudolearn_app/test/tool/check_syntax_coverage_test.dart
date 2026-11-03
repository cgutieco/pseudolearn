import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/diagram/coverage/coverage_cell.dart';
import 'package:pseudolearn_app/domain/model/diagram/coverage/syntax_view_coverage_matrix.dart';
import 'package:pseudolearn_app/domain/model/diagram/coverage/syntax_view_coverage_row.dart';

import '../../tool/syntax_coverage/coverage_check.dart';
import '../../tool/syntax_coverage/engine_inventory.dart';
import '../../tool/syntax_coverage/help_catalog.dart';

const Map<String, String> _inventory = {
  'while_loop': 'statement',
  'literal': 'expression',
};

SyntaxViewCoverageRow _row({
  String construct = 'loop',
  CoveragePublicRole role = CoveragePublicRole.statement,
  CoverageFamily family = CoverageFamily.control,
  List<String> kinds = const ['while_loop'],
  CoverageCell flowchart = const CoverageCell.exact(),
  CoverageCell help = const CoverageCell.help('help.present'),
  String rule = 'LANG.CONTROL.WHILE@1.0.0#R1',
  String evidence = 'present.dart',
}) => SyntaxViewCoverageRow(
  construct: construct,
  role: role,
  family: family,
  syntaxKinds: kinds,
  rule: rule,
  flowchart: flowchart,
  structogram: const CoverageCell.exact(),
  structure: const CoverageCell.notApplicable('not a class'),
  help: help,
  evidence: evidence,
);

SyntaxViewCoverageRow get _literalRow => _row(
  construct: 'operand',
  role: CoveragePublicRole.expression,
  family: CoverageFamily.expression,
  kinds: const ['literal'],
  flowchart: const CoverageCell.notApplicable('inside a caption'),
);

List<String> _check(
  List<SyntaxViewCoverageRow> rows, {
  Map<String, String> inventory = _inventory,
  bool ruleKnown = true,
}) => checkSyntaxCoverage(
  rows: rows,
  inventory: inventory,
  ruleExists: (id, version, rule) => ruleKnown,
  evidenceExists: (path) => path == 'present.dart',
  helpExists: (entry) => entry == 'help.present',
);

void main() {
  group('checkSyntaxCoverage', () {
    test('unfinished extensions are rejected even with a reason', () {
      expect(
        _check([
          _row(flowchart: const CoverageCell.extension('unfinished')),
          _literalRow,
        ]),
        contains(startsWith('COV-EXTENSION')),
      );
    });
    test('a complete valid set passes', () {
      expect(_check([_row(), _literalRow]), isEmpty);
    });

    test('a removed row is reported as a missing public form', () {
      expect(_check([_row()]), [
        'COV-MISSING-ROW: public form literal has no row',
      ]);
    });

    test('an active construct added to the inventory needs a row', () {
      final violations = _check(
        [_row(), _literalRow],
        inventory: {..._inventory, 'for_each_loop': 'statement'},
      );

      expect(violations, [
        'COV-MISSING-ROW: public form for_each_loop has no row',
      ]);
    });

    test('a row for a form that no longer exists is stale', () {
      final violations = _check([
        _row(),
        _literalRow,
        _row(construct: 'old', kinds: ['gone']),
      ]);

      expect(violations.any((v) => v.startsWith('COV-STALE-ROW')), isTrue);
    });

    test('a changed role is reported', () {
      final violations = _check([
        _row(role: CoveragePublicRole.declaration),
        _literalRow,
      ]);

      expect(violations.single, startsWith('COV-ROLE'));
    });

    test('a repeated identity is reported', () {
      final violations = _check([
        _row(),
        _literalRow,
        _row(construct: 'again'),
      ]);

      expect(violations.single, startsWith('COV-DUPLICATE'));
    });

    test('a repeated construct is reported', () {
      final violations = _check([_row(), _literalRow, _row(kinds: [])]);

      expect(violations.single, startsWith('COV-DUPLICATE'));
    });

    test('not applicable without an explanation is reported', () {
      final violations = _check([
        _row(),
        _row(
          construct: 'operand',
          role: CoveragePublicRole.expression,
          family: CoverageFamily.expression,
          kinds: const ['literal'],
          flowchart: const CoverageCell.notApplicable(' '),
        ),
      ]);

      expect(violations.single, startsWith('COV-NO-REASON'));
    });

    test('an executable construct hidden in a view is reported', () {
      final violations = _check([
        _row(flowchart: const CoverageCell.notApplicable('fallback')),
        _literalRow,
      ]);

      expect(violations.single, startsWith('COV-HIDDEN-CONTROL'));
    });

    test('an unknown rule anchor and a malformed one are reported', () {
      const single = {'while_loop': 'statement'};
      expect(
        _check([_row()], inventory: single, ruleKnown: false).single,
        startsWith('COV-RULE'),
      );
      expect(
        _check([_row(rule: 'nonsense')], inventory: single).single,
        startsWith('COV-RULE'),
      );
    });

    test('a missing evidence file is reported', () {
      expect(
        _check([_row(evidence: 'absent.dart'), _literalRow]).single,
        startsWith('COV-EVIDENCE'),
      );
    });

    test('an empty inventory with no rows is vacuously valid', () {
      expect(_check(const [], inventory: const {}), isEmpty);
    });

    test('exact help naming a card that does not exist is rejected', () {
      final violations = _check([
        _row(help: const CoverageCell.help('help.missing')),
        _literalRow,
      ]);

      expect(violations, [
        'COV-HELP: loop declares exact help without an existing card (help.missing)',
      ]);
    });

    test('exact help without a card is rejected', () {
      final violations = _check([
        _row(help: const CoverageCell.exact()),
        _literalRow,
      ]);

      expect(
        violations.where((item) => item.startsWith('COV-HELP:')),
        hasLength(1),
      );
    });

    test('declared help extensions are rejected', () {
      final violations = _check([
        _row(help: const CoverageCell.extension('audited later')),
        _literalRow,
      ]);

      expect(violations.single, startsWith('COV-EXTENSION'));
    });

    test('the help catalog lists every card of the corpus export', () {
      final cards = readHelpCardIds();

      expect(cards, contains('help.snapshot_builtin'));
      expect(cards, isNot(contains('help.missing')));
    });
  });

  group('inventoryOf', () {
    test('reads names and roles from the engine classification', () {
      const source = '''
pub(crate) fn classify(kind: NodeKind) -> Option<ViewKind> {
    match kind {
        NodeKind::WhileLoop | NodeKind::Switch => Some(ViewKind::Statement),
        _ => None,
    }
}
fn expression_name(kind: NodeKind) -> Option<&'static str> {
    Some(match kind {
        NodeKind::WhileLoop => "while_loop",
        NodeKind::Switch => "switch",
        NodeKind::Literal => "literal",
        _ => return None,
    })
}
fn is_expression(kind: NodeKind) -> bool {
    matches!(
        kind,
        NodeKind::Literal
    )
}
''';

      expect(inventoryOf([source]), {
        'while_loop': 'statement',
        'switch': 'statement',
        'literal': 'expression',
      });
    });

    test('a source without classification yields no forms', () {
      expect(inventoryOf(['']), isEmpty);
    });
  });

  group('the real matrix', () {
    test('covers the current public inventory of the engine', () {
      final violations = checkSyntaxCoverage(
        rows: syntaxViewCoverageMatrix,
        inventory: readEngineInventory(),
        ruleExists: (id, version, rule) => true,
        evidenceExists: (path) => File(path).existsSync(),
        helpExists: readHelpCardIds().contains,
      );

      expect(violations, isEmpty);
    });
  });
}
