import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/domain/model/diagram/class_diagram_metrics.dart';
import 'package:pseudolearn_app/domain/model/diagram/class_model.dart';
import 'package:pseudolearn_app/engine/classdiagram/class_box_placement.dart';

ClassMemberRow _row(String text) => ClassMemberRow(
      text: text,
      visibility: ClassMemberVisibility.public,
      nodeId: const ProgramNodeId(1),
      sourceLine: 1,
    );

ClassBox _box(
  String name, {
  String? superclassName,
  List<ClassMemberRow> attributes = const [],
  List<ClassMemberRow> methods = const [],
}) =>
    ClassBox(
      name: name,
      superclassName: superclassName,
      attributes: attributes,
      methods: methods,
      nodeId: ProgramNodeId(name.hashCode),
      sourceLine: 1,
    );

const ClassBoxPlacement _placement = ClassBoxPlacement();

void main() {
  group('ClassBoxPlacement', () {
    test('empty class list produces no placed boxes', () {
      expect(_placement.of(const []), isEmpty);
    });

    test('a single class is placed at origin (0, 0)', () {
      final placed = _placement.of([_box('A')]);

      expect(placed.length, 1);
      expect(placed.single.left, 0.0);
      expect(placed.single.top, 0.0);
      expect(placed.single.columnIndex, 0);
      expect(placed.single.levelIndex, 0);
    });

    test('a child under a single parent stacks with levelGap and shares column', () {
      final parent = _box('Parent');
      final child = _box('Child', superclassName: 'Parent');
      final placed = _placement.of([parent, child]);

      expect(placed.length, 2);
      final p = placed.firstWhere((b) => b.box.name == 'Parent');
      final c = placed.firstWhere((b) => b.box.name == 'Child');

      expect(p.columnIndex, 0);
      expect(c.columnIndex, 0);
      expect(p.levelIndex, 0);
      expect(c.levelIndex, 1);
      expect(c.top, p.bottom + ClassDiagramMetrics.levelGap);
    });

    test('a parent centered over two children sits in the central column area', () {
      final parent = _box('Parent');
      final childA = _box('ChildA', superclassName: 'Parent');
      final childB = _box('ChildB', superclassName: 'Parent');
      final placed = _placement.of([parent, childA, childB]);

      final p = placed.firstWhere((b) => b.box.name == 'Parent');
      final ca = placed.firstWhere((b) => b.box.name == 'ChildA');
      final cb = placed.firstWhere((b) => b.box.name == 'ChildB');

      expect(p.columnIndex, 0);
      expect(ca.columnIndex, 0);
      expect(cb.columnIndex, 1);
      expect(ca.left, lessThan(cb.left));
    });

    test('invariant: corridor between adjacent columns is completely unobstructed across full height', () {
      final parent = _box('P', attributes: [
        _row('attrVeryLongNameForTestingWidth: Entero'),
      ]);
      final c1 = _box('C1', superclassName: 'P');
      final c2 = _box('C2', superclassName: 'P');
      final c3 = _box('C3', superclassName: 'P');
      final sub1 = _box('Sub1', superclassName: 'C2');

      final placed = _placement.of([parent, c1, c2, c3, sub1], boxGap: 64.0);

      final byColumn = <int, List<PlacedClassBox>>{};
      for (final box in placed) {
        byColumn.putIfAbsent(box.columnIndex, () => []).add(box);
      }

      final sortedColumns = byColumn.keys.toList()..sort();
      for (var index = 0; index < sortedColumns.length - 1; index++) {
        final colA = sortedColumns[index];
        final colB = sortedColumns[index + 1];

        final rightOfA = byColumn[colA]!
            .map((b) => b.right)
            .reduce((max, r) => r > max ? r : max);
        final leftOfB = byColumn[colB]!
            .map((b) => b.left)
            .reduce((min, l) => l < min ? l : min);

        final gap = leftOfB - rightOfA;
        expect(gap, greaterThanOrEqualTo(64.0));

        final corridorX = (rightOfA + leftOfB) / 2;
        for (final box in placed) {
          final overlapsCorridor = box.left < corridorX && corridorX < box.right;
          expect(overlapsCorridor, isFalse,
              reason: '${box.box.name} overlaps corridor X=$corridorX');
        }
      }
    });

    test('deterministic placement across multiple runs', () {
      final classes = [
        _box('A'),
        _box('B', superclassName: 'A'),
        _box('C', superclassName: 'A'),
      ];

      final run1 = _placement.of(classes);
      final run2 = _placement.of(classes);

      for (var index = 0; index < run1.length; index++) {
        expect(run1[index].left, run2[index].left);
        expect(run1[index].top, run2[index].top);
        expect(run1[index].columnIndex, run2[index].columnIndex);
        expect(run1[index].levelIndex, run2[index].levelIndex);
      }
    });
  });
}
