import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/domain/model/diagram/class_diagram_metrics.dart';
import 'package:pseudolearn_app/domain/model/diagram/class_model.dart';
import 'package:pseudolearn_app/engine/classdiagram/class_box_sizing.dart';

ClassMemberRow _row(String text) => ClassMemberRow(
      text: text,
      visibility: ClassMemberVisibility.public,
      nodeId: const ProgramNodeId(1),
      sourceLine: 1,
    );

ClassBox _box({
  String name = 'C',
  List<ClassMemberRow> attributes = const [],
  List<ClassMemberRow> methods = const [],
}) =>
    ClassBox(
      name: name,
      attributes: attributes,
      methods: methods,
      nodeId: const ProgramNodeId(1),
      sourceLine: 1,
    );

void main() {
  const sizing = ClassBoxSizing();

  group('ClassBoxSizing', () {
    test('an empty class keeps the minimum width and both empty bands', () {
      final size = sizing.of(_box());

      expect(size.width, ClassDiagramMetrics.boxMinWidth);
      expect(size.headerHeight, ClassDiagramMetrics.headerHeight);
      expect(size.attributesHeight, ClassDiagramMetrics.emptyCompartmentHeight);
      expect(size.methodsHeight, ClassDiagramMetrics.emptyCompartmentHeight);
    });

    test('height grows one row at a time', () {
      final one = sizing.of(_box(attributes: [_row('a: Entero')]));
      final two = sizing.of(
        _box(attributes: [_row('a: Entero'), _row('b: Entero')]),
      );

      expect(
        two.attributesHeight - one.attributesHeight,
        ClassDiagramMetrics.rowHeight,
      );
    });

    test('width follows the longest row, not the number of rows', () {
      final short = sizing.of(_box(methods: [_row('M()')]));
      final long = sizing.of(
        _box(methods: [_row('MetodoConNombreMuyLargoDeVerdad(a: Entero)')]),
      );

      expect(short.width, ClassDiagramMetrics.boxMinWidth);
      expect(long.width, greaterThan(short.width));
    });

    test('width never exceeds the maximum, however long the row is', () {
      final size = sizing.of(_box(methods: [_row('M' * 400)]));

      expect(size.width, ClassDiagramMetrics.boxMaxWidth);
    });

    test('a long class name widens the box', () {
      final size = sizing.of(_box(name: 'NombreDeClaseMuyLargoDeVerdadSiSenor'));

      expect(size.width, greaterThan(ClassDiagramMetrics.boxMinWidth));
    });

    test('total height is the sum of the three compartments', () {
      final size = sizing.of(_box(attributes: [_row('a')], methods: [_row('m()')]));

      expect(
        size.height,
        size.headerHeight + size.attributesHeight + size.methodsHeight,
      );
    });

    test('two measures of the same box give the same size', () {
      final box = _box(attributes: [_row('a: Entero')], methods: [_row('m()')]);

      expect(sizing.of(box).width, sizing.of(box).width);
      expect(sizing.of(box).height, sizing.of(box).height);
    });
  });
}
