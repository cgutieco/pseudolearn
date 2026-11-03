import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/diagram/coverage/coverage_cell.dart';
import 'package:pseudolearn_app/domain/model/diagram/coverage/syntax_view_coverage_matrix.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_program.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_scene.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';

import '../../fakes/native_test_engine.dart';

const String _iteration = '''
algorithm Main
define values as vector<integer> <- vector();
for each value in values do
write value;
endFor
endAlgorithm
''';

const String _emptyIteration = '''
algorithm Main
define values as vector<integer> <- vector();
for each value in values do
endFor
endAlgorithm
''';

const String _break = '''
algorithm Main
define values as vector<integer> <- vector();
for each value in values do
write value;
break;
endFor
endAlgorithm
''';

const String _defer = '''
algorithm Main
defer
write 1;
endDefer
write 3;
endAlgorithm
''';

const String _propagation = '''
subroutine First() as result<integer, string>
return failure("failed");
endSubroutine
subroutine Second() as result<integer, string>
define value as integer <- propagate First();
return success(value + 1);
endSubroutine
algorithm Main
endAlgorithm
''';

const String _headerPropagation = '''
subroutine First() as optional<integer>
return none;
endSubroutine
subroutine Second() as optional<integer>
if propagate First() > 0 then
write 1;
endIf
return some(1);
endSubroutine
algorithm Main
endAlgorithm
''';

const String _closurePropagation = '''
subroutine First() as optional<integer>
return none;
endSubroutine
subroutine make() as subroutine() as optional<integer>
return subroutine() as optional<integer>
define value as integer <- propagate First();
return some(value);
endSubroutine;
endSubroutine
algorithm Main
endAlgorithm
''';

DiagramProgram _flowchart(String source) =>
    nativeTestEngine.flowchartBuilder.buildDiagram(
      sourceCode: source,
      profileId: SyntaxProfileId.english,
      languageId: UiLanguageId.english,
    );

DiagramProgram _structogram(String source) =>
    nativeTestEngine.structogramBuilder.buildDiagram(
      sourceCode: source,
      profileId: SyntaxProfileId.english,
      languageId: UiLanguageId.english,
    );

List<DiagramNode> _nodes(DiagramProgram program) =>
    program.sceneFor(program.defaultUnit?.id).nodes;

void main() {
  test('function literal bodies are selectable units in both diagrams', () {
    for (final builder in [_flowchart, _structogram]) {
      final program = builder(_closurePropagation);
      final literal = program.units.singleWhere(
        (unit) => unit.name.startsWith('λ@'),
      );
      final scene = program.sceneFor(literal.id);
      expect(
        scene.nodes.any((node) => node.lines.join().contains('First()')),
        isTrue,
      );
      expect(
        scene.nodes.any((node) => node.lines.join().contains('some(value)')),
        isTrue,
      );
      expect(
        program.units.map((unit) => unit.id).toSet().length,
        program.units.length,
      );
    }
  });

  group('iteration is drawn as a loop, never as a generic process', () {
    test('the flowchart has a preparation header and a body step', () {
      final nodes = _nodes(_flowchart(_iteration));

      final header = nodes.singleWhere(
        (node) => node.shape == DiagramShape.preparation,
      );
      expect(header.lines.join(' '), startsWith('for each value'));
      expect(header.nodeId, isNotNull);
      expect(
        nodes.where((node) => node.shape == DiagramShape.inputOutput),
        hasLength(1),
      );
    });

    test('the structogram has a loop cell with the same header', () {
      final nodes = _nodes(_structogram(_iteration));

      expect(
        nodes.any(
          (node) =>
              node.shape == DiagramShape.cellLoopHeader &&
              node.lines.join(' ').startsWith('for each value'),
        ),
        isTrue,
      );
    });

    test('an iteration without statements is still a loop', () {
      final flowchart = _flowchart(_emptyIteration);

      expect(flowchart.isUnsupported, isFalse);
      expect(
        _nodes(
          flowchart,
        ).where((node) => node.shape == DiagramShape.preparation),
        hasLength(1),
      );
    });
  });

  group('forms without a faithful drawing are reported, not approximated', () {
    test(
      'a propagation inside a control header makes both diagrams unsupported',
      () {
        final flowchart = _flowchart(_headerPropagation);
        final structogram = _structogram(_headerPropagation);

        expect(flowchart.isUnsupported, isTrue);
        expect(flowchart.unsupportedKinds, ['propagation']);
        expect(flowchart.isEmpty, isTrue);
        expect(structogram.unsupportedKinds, ['propagation']);
      },
    );

    test(
      'a propagation inside a function literal is not an exit of the statement',
      () {
        final flowchart = _flowchart(_closurePropagation);
        final unit = flowchart.units.singleWhere((unit) => unit.name == 'make');

        expect(flowchart.isUnsupported, isFalse);
        expect(
          flowchart
              .sceneFor(unit.id)
              .edges
              .where((edge) => edge.kind == DiagramEdgeKind.propagationExit),
          isEmpty,
        );
      },
    );

    final drawn = {
      'break_statement': _break,
      'defer_statement': _defer,
      'propagation': _propagation,
    };

    for (final entry in drawn.entries) {
      test('${entry.key} is drawn in both diagrams instead of reported', () {
        expect(_flowchart(entry.value).isUnsupported, isFalse);
        expect(_structogram(entry.value).isUnsupported, isFalse);
      });
    }

    test('every drawn exit form is exact in both notations of the matrix', () {
      for (final kind in drawn.keys) {
        final row = syntaxViewCoverageMatrix.singleWhere(
          (row) => row.syntaxKinds.contains(kind),
        );

        expect(row.flowchart.representation, CoverageRepresentation.exact);
        expect(row.structogram.representation, CoverageRepresentation.exact);
      }
    });

    test('a supported program is never reported as unsupported', () {
      expect(_flowchart(_iteration).isUnsupported, isFalse);
      expect(_structogram(_iteration).isUnsupported, isFalse);
    });

    test('an empty document is empty, not unsupported', () {
      expect(_flowchart('').isUnsupported, isFalse);
      expect(_structogram('').isUnsupported, isFalse);
    });
  });
}
