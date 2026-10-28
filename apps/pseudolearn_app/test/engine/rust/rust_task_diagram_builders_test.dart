import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_scene.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/rust/rust_flowchart_builder.dart';
import 'package:pseudolearn_app/engine/rust/rust_structogram_builder.dart';

import '../../fakes/fake_rust_transport.dart';

const _source =
    'Algoritmo P\n'
    'Tareas\n'
    'Lanzar Work();\n'
    'FinTareas\n'
    'FinAlgoritmo\n';

Map<String, Object?> _span(int startLine, int startColumn, int endLine, int endColumn) => {
  'start': {'line': startLine, 'column': startColumn},
  'end': {'line': endLine, 'column': endColumn},
};

Map<String, Object?> _node(
  String id,
  String kind,
  String syntaxKind,
  Map<String, Object?> span, [
  Map<String, String> roles = const {},
]) => {
  'node_id': id,
  'kind': kind,
  'syntax_kind': syntaxKind,
  'span': span,
  'child_node_ids': roles.keys.toList(),
  'child_roles': [
    for (final entry in roles.entries) {'node_id': entry.key, 'role': entry.value},
  ],
};

FakeRustTransport _transport() => FakeRustTransport({
  'create_analysis': (_) => {'resource': 2, 'document': 1},
  'analysis': (_) => {'tree': true, 'diagnostics': <Object?>[]},
  'program_view': (_) => {
    'revision_id': 'r1',
    'units': [
      {'kind': 'algorithm', 'name': 'P', 'order': 0, 'node_id': 'r1.n0', 'span': _span(1, 1, 5, 13)},
    ],
    'nodes': [
      _node('r1.n0', 'declaration', 'algorithm_unit', _span(1, 1, 5, 13), {'r1.n1': 'body'}),
      _node('r1.n1', 'statement', 'body', _span(2, 1, 4, 10), {'r1.n2': 'statement'}),
      _node('r1.n2', 'statement', 'statement', _span(2, 1, 4, 10), {'r1.n3': 'statement'}),
      _node('r1.n3', 'statement', 'task_scope', _span(2, 1, 4, 10), {'r1.n4': 'body'}),
      _node('r1.n4', 'statement', 'body', _span(3, 1, 3, 15), {'r1.n5': 'statement'}),
      _node('r1.n5', 'statement', 'statement', _span(3, 1, 3, 15), {'r1.n6': 'statement'}),
      _node('r1.n6', 'statement', 'spawn_statement', _span(3, 1, 3, 15)),
    ],
    'members': <Object?>[],
    'inheritance': <Object?>[],
  },
  'editor_vocabulary': (_) => {'keywords': <Object?>[]},
  'release': (_) => null,
});

void main() {
  test('flowchart draws a task scope and a spawn as explicit non-process nodes', () {
    final program = RustFlowchartBuilder(_transport()).buildDiagram(
      sourceCode: _source,
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
    );
    final scene = program.sceneFor(program.defaultUnit?.id);
    final shapes = scene.nodes.map((node) => node.shape).toList();
    expect(shapes, contains(DiagramShape.preparation));
    expect(shapes, contains(DiagramShape.subprogram));
    expect(shapes, isNot(contains(DiagramShape.process)));
  });

  test('structogram draws a task scope as a block and a spawn as a call cell', () {
    final program = RustStructogramBuilder(_transport()).buildDiagram(
      sourceCode: _source,
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
    );
    final scene = program.sceneFor(program.defaultUnit?.id);
    final shapes = scene.nodes.map((node) => node.shape).toList();
    expect(shapes, contains(DiagramShape.cellCall));
    expect(shapes, isNot(contains(DiagramShape.cellProcess)));
  });
}
