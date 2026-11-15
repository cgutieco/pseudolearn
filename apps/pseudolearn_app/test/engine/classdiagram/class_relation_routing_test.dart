import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/domain/model/diagram/class_model.dart';
import 'package:pseudolearn_app/engine/classdiagram/class_diagram_layout.dart';
import 'diagram_scene_validators.dart';

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

void main() {
  group('ClassRelationRouting · RFC 007 Battery', () {
    test('Case 1: Five classes with two hierarchies and three associations has zero defects', () {
      final model = ClassModel(
        classes: [
          _box('A', id: 1),
          _box('B', superclassName: 'A', id: 2),
          _box('C', superclassName: 'A', id: 3),
          _box('D', id: 4),
          _box('E', superclassName: 'D', id: 5),
        ],
        relations: const [
          ClassRelation(fromClassName: 'B', toClassName: 'A', kind: ClassRelationKind.generalization),
          ClassRelation(fromClassName: 'C', toClassName: 'A', kind: ClassRelationKind.generalization),
          ClassRelation(fromClassName: 'E', toClassName: 'D', kind: ClassRelationKind.generalization),
          ClassRelation(fromClassName: 'A', toClassName: 'D', kind: ClassRelationKind.association, label: 'd 1'),
          ClassRelation(fromClassName: 'B', toClassName: 'E', kind: ClassRelationKind.association, label: 'e 1'),
          ClassRelation(fromClassName: 'E', toClassName: 'C', kind: ClassRelationKind.association, label: 'c 1'),
        ],
      );

      final scene = _layout.of(model);

      expectZeroLineBoxCrossings(scene);
      expectZeroOverlappingLabels(scene);
      expectZeroCollinearOverlap(scene);
    });

    test('Case 2: Cyclic inheritance A <-> B produces zero crossings and terminates', () {
      final model = ClassModel(
        classes: [
          _box('Uno', superclassName: 'Dos', id: 1),
          _box('Dos', superclassName: 'Uno', id: 2),
        ],
        relations: const [
          ClassRelation(fromClassName: 'Uno', toClassName: 'Dos', kind: ClassRelationKind.generalization),
          ClassRelation(fromClassName: 'Dos', toClassName: 'Uno', kind: ClassRelationKind.generalization),
        ],
      );

      final scene = _layout.of(model);

      expectZeroLineBoxCrossings(scene);
      expectZeroCollinearOverlap(scene);
    });

    test('Case 3: Self-association (linked list node) routes cleanly around the box', () {
      final model = ClassModel(
        classes: [
          _box('Node', id: 1, attributes: [_row('next: Node', 2)]),
        ],
        relations: const [
          ClassRelation(fromClassName: 'Node', toClassName: 'Node', kind: ClassRelationKind.association, label: 'next 1'),
        ],
      );

      final scene = _layout.of(model);

      expectZeroLineBoxCrossings(scene);
      expect(scene.edges.length, 1);
    });

    test('Case 4: Wide level with six root classes in association ring has zero crossings', () {
      final model = ClassModel(
        classes: [
          for (var i = 0; i < 6; i++) _box('R$i', id: i + 1),
        ],
        relations: [
          for (var i = 0; i < 6; i++)
            ClassRelation(
              fromClassName: 'R$i',
              toClassName: 'R${(i + 1) % 6}',
              kind: ClassRelationKind.association,
              label: 'ref$i 1',
            ),
        ],
      );

      final scene = _layout.of(model);

      expectZeroLineBoxCrossings(scene);
      expectZeroOverlappingLabels(scene);
      expectZeroCollinearOverlap(scene);
    });

    test('Case 5: Deep hierarchy of five levels with association to root has zero crossings', () {
      final model = ClassModel(
        classes: [
          _box('L0', id: 1),
          _box('L1', superclassName: 'L0', id: 2),
          _box('L2', superclassName: 'L1', id: 3),
          _box('L3', superclassName: 'L2', id: 4),
          _box('L4', superclassName: 'L3', id: 5),
        ],
        relations: const [
          ClassRelation(fromClassName: 'L1', toClassName: 'L0', kind: ClassRelationKind.generalization),
          ClassRelation(fromClassName: 'L2', toClassName: 'L1', kind: ClassRelationKind.generalization),
          ClassRelation(fromClassName: 'L3', toClassName: 'L2', kind: ClassRelationKind.generalization),
          ClassRelation(fromClassName: 'L4', toClassName: 'L3', kind: ClassRelationKind.generalization),
          ClassRelation(fromClassName: 'L4', toClassName: 'L0', kind: ClassRelationKind.association, label: 'rootRef 1'),
        ],
      );

      final scene = _layout.of(model);

      expectZeroLineBoxCrossings(scene);
      expectZeroOverlappingLabels(scene);
    });

    test('Case 6: Single isolated class produces no relations and clean layout', () {
      final model = ClassModel(
        classes: [_box('Solo', id: 1)],
        relations: const [],
      );

      final scene = _layout.of(model);

      expect(scene.edges, isEmpty);
      expectZeroLineBoxCrossings(scene);
    });

    test('Unhappy path: relation referencing missing class is safely ignored without throwing', () {
      final model = ClassModel(
        classes: [_box('A', id: 1)],
        relations: const [
          ClassRelation(fromClassName: 'A', toClassName: 'Missing', kind: ClassRelationKind.association),
          ClassRelation(fromClassName: 'Missing', toClassName: 'A', kind: ClassRelationKind.generalization),
        ],
      );

      final scene = _layout.of(model);

      expect(scene.edges, isEmpty);
    });

    test('Deterministic routing gives identical edge points on consecutive calls', () {
      final model = ClassModel(
        classes: [
          _box('A', id: 1),
          _box('B', superclassName: 'A', id: 2),
          _box('C', id: 3),
        ],
        relations: const [
          ClassRelation(fromClassName: 'B', toClassName: 'A', kind: ClassRelationKind.generalization),
          ClassRelation(fromClassName: 'B', toClassName: 'C', kind: ClassRelationKind.association, label: 'c 1'),
        ],
      );

      final s1 = _layout.of(model);
      final s2 = _layout.of(model);

      expect(s1.edges.length, s2.edges.length);
      for (var i = 0; i < s1.edges.length; i++) {
        final e1 = s1.edges[i];
        final e2 = s2.edges[i];
        expect(e1.points.length, e2.points.length);
        for (var p = 0; p < e1.points.length; p++) {
          expect(e1.points[p].x, e2.points[p].x);
          expect(e1.points[p].y, e2.points[p].y);
        }
      }
    });
  });
}
