import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_program.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_scene.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/rust/rust_class_diagram_builder.dart';
import 'package:pseudolearn_app/engine/rust/rust_flowchart_builder.dart';
import 'package:pseudolearn_app/engine/rust/rust_structogram_builder.dart';

import '../../fakes/fake_rust_transport.dart';

const _source =
    'Algoritmo P\n'
    'Si verdadero Entonces\n'
    'Escribir 1;\n'
    'Sino\n'
    'Escribir 2;\n'
    'FinSi\n'
    'FinAlgoritmo\n';
const _classSource =
    'Clase Base\n'
    'FinClase\n'
    'Clase Caja Hereda De Base\n'
    'Privado Dimension elementos[2,3] Como Base;\n'
    'Publico Metodo tamano(indice[,,] Como Entero) Como Entero\n'
    'FinMetodo\n'
    'FinClase\n'
    'Algoritmo P\n'
    'FinAlgoritmo\n';

Map<String, Object?> _position(int line, int column) => {
  'line': line,
  'column': column,
};

Map<String, Object?> _span(
  int startLine,
  int startColumn,
  int endLine,
  int endColumn,
) => {
  'start': _position(startLine, startColumn),
  'end': _position(endLine, endColumn),
};

Map<String, Object?> _spanOf(
  String source,
  int line,
  String fragment, [
  int occurrence = 0,
]) {
  final lineText = source.split('\n')[line - 1];
  var start = -1;
  var searchFrom = 0;
  for (var index = 0; index <= occurrence; index++) {
    start = lineText.indexOf(fragment, searchFrom);
    searchFrom = start + fragment.length;
  }
  return _span(line, start + 1, line, start + fragment.length + 1);
}

Map<String, Object?> _node({
  required String id,
  required String kind,
  required String syntaxKind,
  required Map<String, Object?> span,
  List<String> children = const [],
  Map<String, String> roles = const {},
  int? dimensions,
}) => {
  'node_id': id,
  'kind': kind,
  'syntax_kind': syntaxKind,
  'span': span,
  'child_node_ids': children,
  'child_roles': [
    for (final child in children) {'node_id': child, 'role': roles[child]},
  ],
  'dimensions': ?dimensions,
};

FakeRustTransport _transport({bool valid = true}) => FakeRustTransport({
  'create_analysis': (_) => {'resource': 2, 'document': 1},
  'analysis': (_) => {
    'tree': true,
    'diagnostics': valid
        ? <Object?>[]
        : [
            {
              'severity': 'error',
              'message': 'invalid',
              'code': 'invalid',
              'span': {'start': _position(1, 1), 'end': _position(1, 1)},
              'related': <Object?>[],
            },
          ],
  },
  'program_view': (_) => {
    'revision_id': 'r1',
    'units': [
      {
        'kind': 'algorithm',
        'name': 'P',
        'order': 0,
        'node_id': 'r1.n0',
        'span': _span(1, 1, 7, 13),
      },
    ],
    'nodes': [
      _node(
        id: 'r1.n0',
        kind: 'declaration',
        syntaxKind: 'algorithm_unit',
        span: _span(1, 1, 7, 13),
        children: ['r1.n1'],
        roles: const {'r1.n1': 'body'},
      ),
      _node(
        id: 'r1.n1',
        kind: 'statement',
        syntaxKind: 'body',
        span: _span(2, 1, 6, 6),
        children: ['r1.n2'],
        roles: const {'r1.n2': 'statement'},
      ),
      _node(
        id: 'r1.n2',
        kind: 'statement',
        syntaxKind: 'statement',
        span: _span(2, 1, 6, 6),
        children: ['r1.n3'],
        roles: const {'r1.n3': 'statement'},
      ),
      _node(
        id: 'r1.n3',
        kind: 'statement',
        syntaxKind: 'conditional',
        span: _span(2, 1, 6, 6),
        children: ['r1.n4', 'r1.n5', 'r1.n8'],
        roles: const {
          'r1.n4': 'condition',
          'r1.n5': 'then_body',
          'r1.n8': 'else_body',
        },
      ),
      _node(
        id: 'r1.n4',
        kind: 'expression',
        syntaxKind: 'expression',
        span: _span(2, 4, 2, 13),
      ),
      _node(
        id: 'r1.n5',
        kind: 'statement',
        syntaxKind: 'body',
        span: _span(3, 1, 3, 12),
        children: ['r1.n6'],
        roles: const {'r1.n6': 'statement'},
      ),
      _node(
        id: 'r1.n6',
        kind: 'statement',
        syntaxKind: 'statement',
        span: _span(3, 1, 3, 12),
        children: ['r1.n7'],
        roles: const {'r1.n7': 'statement'},
      ),
      _node(
        id: 'r1.n7',
        kind: 'statement',
        syntaxKind: 'output',
        span: _span(3, 1, 3, 12),
      ),
      _node(
        id: 'r1.n8',
        kind: 'statement',
        syntaxKind: 'body',
        span: _span(5, 1, 5, 12),
        children: ['r1.n9'],
        roles: const {'r1.n9': 'statement'},
      ),
      _node(
        id: 'r1.n9',
        kind: 'statement',
        syntaxKind: 'statement',
        span: _span(5, 1, 5, 12),
        children: ['r1.n10'],
        roles: const {'r1.n10': 'statement'},
      ),
      _node(
        id: 'r1.n10',
        kind: 'statement',
        syntaxKind: 'output',
        span: _span(5, 1, 5, 12),
      ),
    ],
    'members': <Object?>[],
    'inheritance': <Object?>[],
  },
  'editor_vocabulary': (_) => {
    'keywords': [
      ['assignment', '<-'],
      ['to', 'Hasta'],
      ['step', 'Con Paso'],
      ['switchKeyword', 'Segun'],
    ],
  },
  'release': (_) => null,
});

FakeRustTransport _classTransport() => FakeRustTransport({
  'create_analysis': (_) => {'resource': 2, 'document': 1},
  'analysis': (_) => {'tree': true, 'diagnostics': <Object?>[]},
  'program_view': (_) => {
    'revision_id': 'r1',
    'units': [
      {
        'kind': 'class',
        'name': 'Base',
        'order': 0,
        'node_id': 'r1.n0',
        'span': _span(1, 1, 2, 9),
      },
      {
        'kind': 'class',
        'name': 'Caja',
        'order': 1,
        'node_id': 'r1.n1',
        'span': _span(3, 1, 7, 9),
      },
      {
        'kind': 'algorithm',
        'name': 'P',
        'order': 2,
        'node_id': 'r1.n9',
        'span': _span(8, 1, 9, 13),
      },
    ],
    'nodes': [
      _node(
        id: 'r1.n0',
        kind: 'declaration',
        syntaxKind: 'class_unit',
        span: _span(1, 1, 2, 9),
      ),
      _node(
        id: 'r1.n1',
        kind: 'declaration',
        syntaxKind: 'class_unit',
        span: _span(3, 1, 7, 9),
        children: ['r1.n2', 'r1.n3'],
        roles: const {'r1.n2': 'member', 'r1.n3': 'member'},
      ),
      _node(
        id: 'r1.n2',
        kind: 'declaration',
        syntaxKind: 'field_declaration',
        span: _spanOf(
          _classSource,
          4,
          'Privado Dimension elementos[2,3] Como Base;',
        ),
      ),
      _node(
        id: 'r1.n3',
        kind: 'declaration',
        syntaxKind: 'method_member',
        span: _span(5, 1, 6, 9),
        children: ['r1.n4', 'r1.n8'],
        roles: const {'r1.n4': 'parameters', 'r1.n8': 'signature'},
      ),
      _node(
        id: 'r1.n4',
        kind: 'declaration',
        syntaxKind: 'parameters',
        span: _spanOf(_classSource, 5, 'indice[,,] Como Entero'),
        children: ['r1.n5'],
        roles: const {'r1.n5': 'parameter'},
      ),
      _node(
        id: 'r1.n5',
        kind: 'declaration',
        syntaxKind: 'parameter',
        span: _spanOf(_classSource, 5, 'indice[,,] Como Entero'),
        children: ['r1.n6', 'r1.n7'],
        roles: const {'r1.n6': 'child', 'r1.n7': 'child'},
        dimensions: 3,
      ),
      _node(
        id: 'r1.n6',
        kind: 'symbol',
        syntaxKind: 'identifier',
        span: _spanOf(_classSource, 5, 'indice'),
      ),
      _node(
        id: 'r1.n7',
        kind: 'type',
        syntaxKind: 'type',
        span: _spanOf(_classSource, 5, 'Entero'),
      ),
      _node(
        id: 'r1.n8',
        kind: 'type',
        syntaxKind: 'type',
        span: _spanOf(_classSource, 5, 'Entero', 1),
      ),
      _node(
        id: 'r1.n9',
        kind: 'declaration',
        syntaxKind: 'algorithm_unit',
        span: _span(8, 1, 9, 13),
      ),
    ],
    'inheritance': [
      {'class': 'Caja', 'base': 'Base'},
    ],
    'members': [
      {
        'class': 'Caja',
        'name': 'elementos',
        'kind': 'field',
        'visibility': 'private',
        'type': 'Base',
        'dimensions': 2,
        'node_id': 'r1.n2',
      },
      {
        'class': 'Caja',
        'name': 'tamano',
        'kind': 'method',
        'visibility': 'public',
        'arity': 1,
        'node_id': 'r1.n3',
      },
    ],
  },
  'release': (_) => null,
});

void main() {
  test(
    'flowchart branches use public view roles and event node identities',
    () {
      final transport = _transport();
      final program = RustFlowchartBuilder(transport).buildDiagram(
        sourceCode: _source,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );
      final scene = program.sceneFor(program.defaultUnit?.id);
      final decision = scene.nodes.singleWhere(
        (node) => node.shape == DiagramShape.decision,
      );
      expect(program.units.single.name, 'P');
      expect(decision.nodeId, const ProgramNodeId(2));
      expect(
        scene.edges.map((edge) => edge.kind),
        containsAll([DiagramEdgeKind.branchTrue, DiagramEdgeKind.branchFalse]),
      );
      expect(transport.calls.last, 'release');
    },
  );

  test('structogram branches use the same public view hierarchy', () {
    final program = RustStructogramBuilder(_transport()).buildDiagram(
      sourceCode: _source,
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
    );
    final scene = program.sceneFor(program.defaultUnit?.id);
    expect(
      scene.nodes.where((node) => node.shape == DiagramShape.cellCondition),
      hasLength(1),
    );
    expect(
      scene.nodes.where((node) => node.shape == DiagramShape.cellProcess),
      hasLength(2),
    );
  });

  test('class diagram projects inheritance, arrays, and method signatures', () {
    final transport = _classTransport();
    final scene = RustClassDiagramBuilder(transport).buildDiagram(
      sourceCode: _classSource,
      profileId: SyntaxProfileId.classicSpanish,
    );
    final labels = scene.nodes.map((node) => node.lines.join()).join('|');
    expect(labels, contains('elementos: Base[][]'));
    expect(labels, contains('tamano(indice: Entero[][][]): Entero'));
    expect(
      scene.edges.map((edge) => edge.kind),
      contains(DiagramEdgeKind.generalization),
    );
    expect(
      scene.edges.map((edge) => edge.kind),
      contains(DiagramEdgeKind.association),
    );
    expect(transport.calls.last, 'release');
  });

  test('invalid programs produce empty diagrams', () {
    final flowchart = RustFlowchartBuilder(_transport(valid: false))
        .buildDiagram(
          sourceCode: _source,
          profileId: SyntaxProfileId.classicSpanish,
          languageId: UiLanguageId.spanish,
        );
    final structogram = RustStructogramBuilder(_transport(valid: false))
        .buildDiagram(
          sourceCode: _source,
          profileId: SyntaxProfileId.classicSpanish,
          languageId: UiLanguageId.spanish,
        );
    expect(flowchart, isA<DiagramProgram>());
    expect(flowchart.isEmpty, isTrue);
    expect(structogram.isEmpty, isTrue);
  });
}
