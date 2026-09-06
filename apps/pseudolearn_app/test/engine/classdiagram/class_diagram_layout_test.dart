import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/domain/model/diagram/class_diagram_metrics.dart';
import 'package:pseudolearn_app/domain/model/diagram/class_model.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_scene.dart';
import 'package:pseudolearn_app/engine/classdiagram/class_diagram_layout.dart';

ClassMemberRow _row(String text, int id) => ClassMemberRow(
      text: text,
      visibility: ClassMemberVisibility.public,
      nodeId: ProgramNodeId(id),
      sourceLine: id,
    );

ClassBox _box(
  String name, {
  String? superclassName,
  List<ClassMemberRow> attributes = const [],
  List<ClassMemberRow> methods = const [],
  int id = 1,
}) =>
    ClassBox(
      name: name,
      superclassName: superclassName,
      attributes: attributes,
      methods: methods,
      nodeId: ProgramNodeId(id),
      sourceLine: id,
    );

const ClassDiagramLayout _layout = ClassDiagramLayout();

List<DiagramNode> _framesOf(DiagramScene scene) => [
      for (final node in scene.nodes)
        if (node.shape == DiagramShape.classFrame) node,
    ];

DiagramNode _frameNamed(DiagramScene scene, String name) {
  for (var index = 0; index < scene.nodes.length; index++) {
    final node = scene.nodes[index];
    if (node.shape != DiagramShape.classHeader) continue;
    if (node.lines.first != name) continue;
    return scene.nodes[index - 1];
  }
  throw StateError('no box named $name');
}

bool _overlap(DiagramNode a, DiagramNode b) =>
    a.x < b.x + b.width &&
    b.x < a.x + a.width &&
    a.y < b.y + b.height &&
    b.y < a.y + a.height;

void main() {
  group('ClassDiagramLayout', () {
    test('an empty model produces an empty scene', () {
      expect(_layout.of(const ClassModel.empty()).isEmpty, isTrue);
    });

    test('a single class produces its four nodes and no relation', () {
      final scene = _layout.of(ClassModel(
        classes: [_box('Sola')],
        relations: const [],
      ));

      expect(_framesOf(scene).length, 1);
      expect(scene.edges, isEmpty);
      expect(scene.nodes.length, 4);
    });

    test('a class emits one node per member row', () {
      final scene = _layout.of(ClassModel(
        classes: [
          _box(
            'C',
            attributes: [_row('a: Entero', 2), _row('b: Entero', 3)],
            methods: [_row('m()', 4)],
          ),
        ],
        relations: const [],
      ));
      final rows = [
        for (final node in scene.nodes)
          if (node.shape == DiagramShape.classRow) node,
      ];

      expect(rows.length, 3);
      expect(rows[0].lines.single, '+ a: Entero');
      expect(rows[2].lines.single, '+ m()');
      expect(rows[2].nodeId, const ProgramNodeId(4));
    });

    test('the frame of a class carries the identifier of the class', () {
      final scene = _layout.of(ClassModel(
        classes: [_box('C', id: 7)],
        relations: const [],
      ));

      expect(_framesOf(scene).single.nodeId, const ProgramNodeId(7));
      expect(_framesOf(scene).single.sourceLine, 7);
    });

    test('the superclass of a hierarchy sits above its subclasses', () {
      final scene = _layout.of(ClassModel(
        classes: [
          _box('A', id: 1),
          _box('B', superclassName: 'A', id: 2),
          _box('C', superclassName: 'B', id: 3),
        ],
        relations: const [
          ClassRelation(
            fromClassName: 'B',
            toClassName: 'A',
            kind: ClassRelationKind.generalization,
          ),
          ClassRelation(
            fromClassName: 'C',
            toClassName: 'B',
            kind: ClassRelationKind.generalization,
          ),
        ],
      ));

      final a = _frameNamed(scene, 'A');
      final b = _frameNamed(scene, 'B');
      final c = _frameNamed(scene, 'C');
      expect(a.y + a.height, lessThan(b.y));
      expect(b.y + b.height, lessThan(c.y));
      expect(scene.edges.length, 2);
      expect(scene.edges.first.kind, DiagramEdgeKind.generalization);
    });

    test('no frame overlaps another one across the whole scene', () {
      final scene = _layout.of(ClassModel(
        classes: [
          _box('A', id: 1),
          _box('B', superclassName: 'A', id: 2),
          _box('C', superclassName: 'A', id: 3),
          _box('D', id: 4),
          _box('E', superclassName: 'D', id: 5),
        ],
        relations: const [],
      ));
      final frames = _framesOf(scene);

      for (var i = 0; i < frames.length; i++) {
        for (var j = i + 1; j < frames.length; j++) {
          expect(_overlap(frames[i], frames[j]), isFalse);
        }
      }
    });

    test('two independent hierarchies do not overlap', () {
      final scene = _layout.of(ClassModel(
        classes: [
          _box('A', id: 1),
          _box('X', id: 2),
          _box('B', superclassName: 'A', id: 3),
          _box('Y', superclassName: 'X', id: 4),
        ],
        relations: const [],
      ));
      final frames = _framesOf(scene);

      expect(frames.length, 4);
      expect(_overlap(frames[0], frames[1]), isFalse);
    });

    test('an association between two classes of the same level is routed', () {
      final scene = _layout.of(ClassModel(
        classes: [_box('A', id: 1), _box('B', id: 2)],
        relations: const [
          ClassRelation(
            fromClassName: 'A',
            toClassName: 'B',
            kind: ClassRelationKind.association,
            label: 'b 1',
          ),
        ],
      ));

      expect(scene.edges.single.kind, DiagramEdgeKind.association);
      expect(scene.edges.single.label, 'b 1');
      expect(scene.edges.single.labelAnchor, isNotNull);
      expect(scene.edges.single.points.length, greaterThanOrEqualTo(2));
    });

    test('an association between different levels is routed', () {
      final scene = _layout.of(ClassModel(
        classes: [_box('A', id: 1), _box('B', superclassName: 'A', id: 2)],
        relations: const [
          ClassRelation(
            fromClassName: 'B',
            toClassName: 'A',
            kind: ClassRelationKind.association,
            label: 'padre 1',
          ),
        ],
      ));

      expect(scene.edges.single.points.first.y,
          isNot(scene.edges.single.points.last.y));
    });

    test('an association of a class with itself is routed and stays inside', () {
      final scene = _layout.of(ClassModel(
        classes: [_box('Nodo', id: 1)],
        relations: const [
          ClassRelation(
            fromClassName: 'Nodo',
            toClassName: 'Nodo',
            kind: ClassRelationKind.association,
            label: 'siguiente 1',
          ),
        ],
      ));

      for (final point in scene.edges.single.points) {
        expect(point.x, inInclusiveRange(0, scene.width));
        expect(point.y, inInclusiveRange(0, scene.height));
      }
    });

    test('cyclic inheritance produces a scene and terminates', () {
      final scene = _layout.of(ClassModel(
        classes: [
          _box('Uno', superclassName: 'Dos', id: 1),
          _box('Dos', superclassName: 'Uno', id: 2),
        ],
        relations: const [
          ClassRelation(
            fromClassName: 'Uno',
            toClassName: 'Dos',
            kind: ClassRelationKind.generalization,
          ),
          ClassRelation(
            fromClassName: 'Dos',
            toClassName: 'Uno',
            kind: ClassRelationKind.generalization,
          ),
        ],
      ));

      expect(_framesOf(scene).length, 2);
      expect(scene.edges.length, 2);
      expect(_frameNamed(scene, 'Uno').y, _frameNamed(scene, 'Dos').y);
    });

    test('twenty classes produce one scene with the expected width', () {
      final scene = _layout.of(ClassModel(
        classes: [for (var index = 0; index < 20; index++) _box('C$index', id: index + 1)],
        relations: const [],
      ));

      expect(_framesOf(scene).length, 20);
      expect(
        scene.width,
        20 * ClassDiagramMetrics.boxMinWidth +
            19 * ClassDiagramMetrics.boxGapFloor +
            2 * ClassDiagramMetrics.canvasMargin,
      );
    });

    test('two layouts of the same model give the same coordinates', () {
      final model = ClassModel(
        classes: [_box('A', id: 1), _box('B', superclassName: 'A', id: 2)],
        relations: const [
          ClassRelation(
            fromClassName: 'B',
            toClassName: 'A',
            kind: ClassRelationKind.generalization,
          ),
        ],
      );
      final first = _layout.of(model);
      final second = _layout.of(model);

      for (var index = 0; index < first.nodes.length; index++) {
        expect(first.nodes[index].x, second.nodes[index].x);
        expect(first.nodes[index].y, second.nodes[index].y);
      }
      expect(first.width, second.width);
    });

    test('the scene keeps a margin around the drawing', () {
      final scene = _layout.of(ClassModel(
        classes: [_box('A')],
        relations: const [],
      ));

      expect(_framesOf(scene).single.x, ClassDiagramMetrics.canvasMargin);
      expect(_framesOf(scene).single.y, ClassDiagramMetrics.canvasMargin);
    });

    test('a wide association label expands boxGap beyond boxGapFloor', () {
      final modelSmall = ClassModel(
        classes: [_box('A', id: 1), _box('B', id: 2)],
        relations: const [
          ClassRelation(
            fromClassName: 'A',
            toClassName: 'B',
            kind: ClassRelationKind.association,
            label: 'x 1',
          ),
        ],
      );
      final modelWide = ClassModel(
        classes: [_box('A', id: 1), _box('B', id: 2)],
        relations: const [
          ClassRelation(
            fromClassName: 'A',
            toClassName: 'B',
            kind: ClassRelationKind.association,
            label: 'anExtremelyLongAssociationAttributeNameWithManyCharacters 1',
          ),
        ],
      );

      final sceneSmall = _layout.of(modelSmall);
      final sceneWide = _layout.of(modelWide);

      expect(sceneWide.width, greaterThan(sceneSmall.width));
    });
  });
}
