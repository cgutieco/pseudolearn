import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_view_control_exit.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_program.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_scene.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/rust/rust_flowchart_builder.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_view.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_view_source.dart';
import 'package:pseudolearn_app/engine/rust/rust_structogram_builder.dart';
import 'package:pseudolearn_app/engine/rust/rust_transport.dart';

const Map<ProgramViewExitKind, String> _exitNames = {
  ProgramViewExitKind.breakLoop: 'break',
  ProgramViewExitKind.returnUnit: 'return',
  ProgramViewExitKind.propagation: 'propagation',
};

const Set<DiagramEdgeKind> _exitEdges = {
  DiagramEdgeKind.breakExit,
  DiagramEdgeKind.propagationExit,
  DiagramEdgeKind.cleanupRegistration,
};

Future<Map<String, Object?>> runControlFlowScenario(
  RustTransport transport,
  Map<String, Object?> input,
) async {
  final program = input['program'] as String;
  final english = input['profile'] == 'en';
  final profile = english
      ? SyntaxProfileId.english
      : SyntaxProfileId.classicSpanish;
  final language = english ? UiLanguageId.english : UiLanguageId.spanish;
  final view = RustProgramViewSource(
    transport,
  ).loadStructure(sourceCode: program, profileId: profile);
  final diagram = input['notation'] == 'structogram'
      ? RustStructogramBuilder(transport).buildDiagram(
          sourceCode: program,
          profileId: profile,
          languageId: language,
        )
      : RustFlowchartBuilder(transport).buildDiagram(
          sourceCode: program,
          profileId: profile,
          languageId: language,
        );
  final scene = _sceneOf(diagram, input['unit'] as String);
  return {
    if (view != null) ..._exitData(view),
    'nodes': [
      for (final node in scene.nodes)
        if (node.lines.isNotEmpty)
          {'shape': node.shape.name, 'text': node.lines.join(' ')},
    ],
    'edges': [
      for (final edge in scene.edges)
        if (_exitEdges.contains(edge.kind))
          {
            'kind': edge.kind.name,
            'from': _textOf(scene, edge.fromId),
            'to': _textOf(scene, edge.toId),
          },
    ],
    'unsupported': diagram.unsupportedKinds,
  };
}

DiagramScene _sceneOf(DiagramProgram diagram, String unitName) {
  for (final unit in diagram.units) {
    if (unit.name == unitName) return diagram.sceneFor(unit.id);
  }
  return const DiagramScene.empty();
}

Map<String, Object?> _exitData(RustProgramView view) => {
  'exits': [
    for (final exit in view.staticData.exits)
      {
        'kind': _exitNames[exit.kind],
        'target': exit.targetNodeId == null
            ? null
            : view.nodeById(exit.targetNodeId!)?.syntaxKind,
        'cleanup_lines': _lines(view, exit.cleanupNodeIds),
      },
  ],
  'normal_cleanups': [
    for (final scope in view.staticData.cleanupScopes)
      {'lines': _lines(view, scope.cleanupNodeIds)},
  ],
};

List<int> _lines(RustProgramView view, List<ProgramNodeId> nodeIds) => [
  for (final nodeId in nodeIds)
    if (view.nodeById(nodeId) case final RustViewNode node)
      node.range.startLine,
];

String? _textOf(DiagramScene scene, String id) {
  for (final node in scene.nodes) {
    if (node.id == id) return node.lines.join(' ');
  }
  return null;
}
