import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_scene.dart';
import 'package:pseudolearn_app/domain/model/diagram/structogram_metrics.dart';
import 'package:pseudolearn_app/engine/structogram/structogram_cell.dart';
import 'package:pseudolearn_app/engine/structogram/structogram_scene.dart';

StructogramLeaf _leaf(
  String text, {
  StructogramLeafKind kind = StructogramLeafKind.process,
  int? id,
}) =>
    StructogramLeaf(
      kind: kind,
      lines: [text],
      nodeId: id == null ? null : ProgramNodeId(id),
      sourceLine: id == null ? null : 7,
    );

Iterable<DiagramNode> _shaped(DiagramScene scene, DiagramShape shape) sync* {
  for (final node in scene.nodes) {
    if (node.shape == shape) yield node;
  }
}

void main() {
  group('the flattened scene', () {
    test('carries no edges at all', () {
      final scene = StructogramScene.of(_leaf('x'));
      expect(scene.edges, isEmpty);
    });

    test('surrounds the drawing with the canvas margin on every side', () {
      final scene = StructogramScene.of(_leaf('x'));
      final node = scene.nodes.single;
      expect(node.x, StructogramMetrics.canvasMargin);
      expect(node.y, StructogramMetrics.canvasMargin);
      expect(scene.width, node.width + StructogramMetrics.canvasMargin * 2);
      expect(scene.height, node.height + StructogramMetrics.canvasMargin * 2);
    });

    test('keeps the program node identifier of every leaf intact', () {
      final scene = StructogramScene.of(StructogramStack([
        _leaf('n <- 5', id: 11),
        _leaf('f <- 1', id: 12),
      ]));
      expect(scene.nodes[0].nodeId, const ProgramNodeId(11));
      expect(scene.nodes[1].nodeId, const ProgramNodeId(12));
      expect(scene.nodes[0].sourceLine, 7);
    });

    test('gives every emitted node a distinct identifier', () {
      final scene = StructogramScene.of(StructogramStack([
        _leaf('uno'),
        _leaf('dos'),
        _leaf('tres'),
      ]));
      final ids = <String>{};
      for (final node in scene.nodes) {
        ids.add(node.id);
      }
      expect(ids, hasLength(scene.nodes.length));
    });

    test('emits no node of its own for a vertical stack', () {
      final scene = StructogramScene.of(StructogramStack([_leaf('uno'), _leaf('dos')]));
      expect(scene.nodes, hasLength(2));
    });

    test('maps each leaf kind to its own shape', () {
      final scene = StructogramScene.of(StructogramStack([
        _leaf('n <- 5'),
        _leaf('Sumar(n)', kind: StructogramLeafKind.call),
        _leaf('Retornar n', kind: StructogramLeafKind.exit),
        _leaf('Sin sentencias', kind: StructogramLeafKind.empty),
      ]));
      expect(_shaped(scene, DiagramShape.cellProcess), hasLength(1));
      expect(_shaped(scene, DiagramShape.cellCall), hasLength(1));
      expect(_shaped(scene, DiagramShape.cellExit), hasLength(1));
      expect(_shaped(scene, DiagramShape.cellEmpty), hasLength(1));
    });
  });

  group('a conditional', () {
    final scene = StructogramScene.of(StructogramBranch(
      headerLines: const ['a = b'],
      isBinary: true,
      nodeId: const ProgramNodeId(31),
      sourceLine: 3,
      columns: [
        StructogramColumn(label: 'SI', body: _leaf('iguales')),
        StructogramColumn(label: 'NO', body: _leaf('distintos')),
      ],
    ));

    test('emits its header before its columns, and only the header carries the node id', () {
      expect(scene.nodes.first.shape, DiagramShape.cellCondition);
      expect(scene.nodes.first.nodeId, const ProgramNodeId(31));
      var identified = 0;
      for (final node in scene.nodes) {
        if (node.nodeId != null) identified += 1;
      }
      expect(identified, 1);
    });

    test('emits one label per column, inside the label band of the header', () {
      final labels = _shaped(scene, DiagramShape.cellLabel).toList();
      expect(labels, hasLength(2));
      expect(labels[0].lines, ['SI']);
      expect(labels[1].lines, ['NO']);
      for (final label in labels) {
        expect(label.height, StructogramMetrics.branchLabelBand);
        expect(label.y + label.height, scene.nodes.first.y + scene.nodes.first.height);
      }
    });

    test('draws a multiple selection with the case shape instead of the wedge', () {
      final selection = StructogramScene.of(StructogramBranch(
        headerLines: const ['Segun opcion'],
        isBinary: false,
        columns: [
          StructogramColumn(label: '1', body: _leaf('uno')),
          StructogramColumn(label: '2', body: _leaf('dos')),
        ],
      ));
      expect(selection.nodes.first.shape, DiagramShape.cellCase);
    });
  });

  group('a loop', () {
    test('emits a header band on top and an indent strip down the body', () {
      final scene = StructogramScene.of(StructogramLoop(
        headerLines: const ['k < 10'],
        position: StructogramLoopPosition.header,
        nodeId: const ProgramNodeId(41),
        body: _leaf('k <- k + 1'),
      ));
      final header = _shaped(scene, DiagramShape.cellLoopHeader).single;
      final strip = _shaped(scene, DiagramShape.cellLoopStrip).single;
      expect(header.y, StructogramMetrics.canvasMargin);
      expect(header.nodeId, const ProgramNodeId(41));
      expect(strip.nodeId, isNull);
      expect(strip.width, StructogramMetrics.loopIndent);
      expect(strip.y, header.y + header.height);
    });

    test('puts the header band at the bottom for a test-last loop', () {
      final scene = StructogramScene.of(StructogramLoop(
        headerLines: const ['k = 0'],
        position: StructogramLoopPosition.footer,
        body: _leaf('k <- k - 1'),
      ));
      final header = _shaped(scene, DiagramShape.cellLoopHeader).single;
      final body = _shaped(scene, DiagramShape.cellProcess).single;
      expect(body.y, StructogramMetrics.canvasMargin);
      expect(header.y, body.y + body.height);
    });
  });

  test('flattening the same tree twice gives the same scene geometry', () {
    final tree = StructogramStack([_leaf('uno'), _leaf('dos')]);
    final first = StructogramScene.of(tree);
    final second = StructogramScene.of(tree);
    expect(first.width, second.width);
    expect(first.height, second.height);
    for (var index = 0; index < first.nodes.length; index++) {
      expect(first.nodes[index].x, second.nodes[index].x);
      expect(first.nodes[index].y, second.nodes[index].y);
    }
  });
}
