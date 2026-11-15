import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/domain/model/diagram/class_diagram_metrics.dart';
import 'package:pseudolearn_app/domain/model/diagram/class_model.dart';
import 'package:pseudolearn_app/engine/classdiagram/class_box_sizing.dart';
import 'package:pseudolearn_app/engine/classdiagram/class_column_grid.dart';

ClassBox _box(String name) => ClassBox(
      name: name,
      attributes: const [],
      methods: const [],
      nodeId: ProgramNodeId(name.hashCode),
      sourceLine: 1,
    );

ClassBoxSize _size(double width) => ClassBoxSize(
      width: width,
      headerHeight: 28.0,
      attributesHeight: 14.0,
      methodsHeight: 14.0,
    );

void main() {
  group('ClassColumnGrid', () {
    test('an empty levels list produces 0 columns and 0 width', () {
      final grid = ClassColumnGrid.of(
        levels: const [],
        sizes: const {},
        boxGap: 64.0,
      );

      expect(grid.columnCount, 0);
      expect(grid.totalWidth, 0.0);
    });

    test('a single box in one level produces 1 column with the box width', () {
      final boxA = _box('A');
      final grid = ClassColumnGrid.of(
        levels: [
          [boxA],
        ],
        sizes: {boxA: _size(180.0)},
        boxGap: 64.0,
      );

      expect(grid.columnCount, 1);
      expect(grid.columnOf(boxA), 0);
      expect(grid.columnWidthAt(0), 180.0);
      expect(grid.columnLeftAt(0), 0.0);
      expect(grid.totalWidth, 180.0);
    });

    test('matching levels assign identical column indices', () {
      final boxA = _box('A');
      final boxB = _box('B');
      final boxC = _box('C');
      final boxD = _box('D');
      final grid = ClassColumnGrid.of(
        levels: [
          [boxA, boxB],
          [boxC, boxD],
        ],
        sizes: {
          boxA: _size(150.0),
          boxB: _size(160.0),
          boxC: _size(170.0),
          boxD: _size(180.0),
        },
        boxGap: 64.0,
      );

      expect(grid.columnCount, 2);
      expect(grid.columnOf(boxA), 0);
      expect(grid.columnOf(boxB), 1);
      expect(grid.columnOf(boxC), 0);
      expect(grid.columnOf(boxD), 1);
      expect(grid.columnWidthAt(0), 170.0);
      expect(grid.columnWidthAt(1), 180.0);
      expect(grid.columnLeftAt(0), 0.0);
      expect(grid.columnLeftAt(1), 170.0 + 64.0);
      expect(grid.totalWidth, 170.0 + 64.0 + 180.0);
    });

    test('a single box over three boxes centers at column 1', () {
      final boxRoot = _box('Root');
      final boxA = _box('A');
      final boxB = _box('B');
      final boxC = _box('C');
      final grid = ClassColumnGrid.of(
        levels: [
          [boxRoot],
          [boxA, boxB, boxC],
        ],
        sizes: {
          boxRoot: _size(200.0),
          boxA: _size(150.0),
          boxB: _size(150.0),
          boxC: _size(150.0),
        },
        boxGap: 64.0,
      );

      expect(grid.columnCount, 3);
      expect(grid.columnOf(boxRoot), 1);
      expect(grid.columnOf(boxA), 0);
      expect(grid.columnOf(boxB), 1);
      expect(grid.columnOf(boxC), 2);
      expect(grid.columnWidthAt(1), 200.0);
    });

    test('two boxes over four boxes center at columns 1 and 2', () {
      final boxP = _box('P');
      final boxQ = _box('Q');
      final box1 = _box('1');
      final box2 = _box('2');
      final box3 = _box('3');
      final box4 = _box('4');
      final grid = ClassColumnGrid.of(
        levels: [
          [boxP, boxQ],
          [box1, box2, box3, box4],
        ],
        sizes: {
          boxP: _size(160.0),
          boxQ: _size(160.0),
          box1: _size(150.0),
          box2: _size(150.0),
          box3: _size(150.0),
          box4: _size(150.0),
        },
        boxGap: 64.0,
      );

      expect(grid.columnCount, 4);
      expect(grid.columnOf(boxP), 1);
      expect(grid.columnOf(boxQ), 2);
    });

    test('out of bounds column query returns safe defaults', () {
      final grid = ClassColumnGrid.of(
        levels: const [],
        sizes: const {},
        boxGap: 64.0,
      );

      expect(grid.columnLeftAt(-1), 0.0);
      expect(grid.columnLeftAt(5), 0.0);
      expect(grid.columnWidthAt(-1), ClassDiagramMetrics.boxMinWidth);
      expect(grid.columnWidthAt(5), ClassDiagramMetrics.boxMinWidth);
    });
  });
}
