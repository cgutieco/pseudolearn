import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_metrics.dart';
import 'package:pseudolearn_app/domain/model/diagram/structogram_metrics.dart';
import 'package:pseudolearn_app/engine/structogram/cell_measure.dart';
import 'package:pseudolearn_app/engine/structogram/structogram_cell.dart';

const CellMeasure _measure = CellMeasure();

StructogramLeaf _leaf(List<String> lines) =>
    StructogramLeaf(kind: StructogramLeafKind.process, lines: lines);

StructogramBranch _branch(List<StructogramCell> bodies) => StructogramBranch(
      headerLines: const ['a = b'],
      isBinary: bodies.length == 2,
      columns: [
        for (final body in bodies) StructogramColumn(label: 'SI', body: body),
      ],
    );

StructogramCell _nested(int depth) =>
    depth == 0 ? _leaf(const ['x']) : _branch([_nested(depth - 1), _nested(depth - 1)]);

void main() {
  group('a single leaf', () {
    test('never goes below the minimum width', () {
      expect(_measure.measure(_leaf(const ['i'])).minWidth,
          StructogramMetrics.cellMinWidth);
    });

    test('derives its height from the number of text lines', () {
      final one = _measure.measure(_leaf(const ['uno']));
      final three = _measure.measure(_leaf(const ['uno', 'dos', 'tres']));
      expect(three.minHeight - one.minHeight, DiagramMetrics.lineHeight * 2);
    });

    test('grows past the minimum width when the text is long', () {
      final wide = _measure.measure(_leaf(const ['contador <- contador + incremento']));
      expect(wide.minWidth, greaterThan(StructogramMetrics.cellMinWidth));
    });

    test('keeps the minimum height for empty text', () {
      expect(_measure.measure(_leaf(const [''])).minHeight,
          StructogramMetrics.cellMinHeight);
    });

    test('keeps the minimum width for a one-character text', () {
      expect(_measure.measure(_leaf(const ['x'])).minWidth,
          StructogramMetrics.cellMinWidth);
    });

    test('stays finite for a five-hundred-character text', () {
      final long = _measure.measure(_leaf([('a' * 500)]));
      expect(long.minWidth.isFinite, isTrue);
      expect(long.minWidth, greaterThan(StructogramMetrics.cellMinWidth));
    });
  });

  group('a vertical stack', () {
    final stack = _measure.measure(StructogramStack([
      _leaf(const ['uno']),
      _leaf(const ['dos']),
      _leaf(const ['tres']),
    ]));

    test('adds the heights of its children with no separation between them', () {
      var sum = 0.0;
      for (final child in stack.children) {
        sum += child.minHeight;
      }
      expect(stack.minHeight, sum);
    });

    test('takes the widest of its children as its own minimum width', () {
      var widest = 0.0;
      for (final child in stack.children) {
        if (child.minWidth > widest) widest = child.minWidth;
      }
      expect(stack.minWidth, widest);
    });

    test('an empty stack still measures at least one minimum cell', () {
      final empty = _measure.measure(const StructogramStack([]));
      expect(empty.minWidth, StructogramMetrics.cellMinWidth);
      expect(empty.minHeight, StructogramMetrics.cellMinHeight);
    });
  });

  group('a conditional', () {
    test('demands the sum of the minimum widths of its two columns', () {
      final branch = _measure.measure(_branch([
        _leaf(const ['f <- f * i']),
        _leaf(const ['x']),
      ]));
      expect(branch.minWidth, branch.children[0].minWidth + branch.children[1].minWidth);
    });

    test('reserves a label band on top of the header text', () {
      final branch = _measure.measure(_branch([_leaf(const ['x']), _leaf(const ['y'])]));
      expect(branch.headerHeight,
          _measure.textHeight(const ['a = b']) + StructogramMetrics.branchLabelBand);
    });

    test('is as tall as its header plus its tallest column', () {
      final branch = _measure.measure(_branch([
        _leaf(const ['una', 'de', 'tres']),
        _leaf(const ['x']),
      ]));
      expect(branch.minHeight, branch.headerHeight + branch.children[0].minHeight);
    });

    test('an empty branch column still demands a minimum cell', () {
      final branch = _measure.measure(_branch([
        _leaf(const ['x']),
        const StructogramStack([]),
      ]));
      expect(branch.children[1].minWidth, StructogramMetrics.cellMinWidth);
    });
  });

  group('a four-case selection', () {
    final selection = _measure.measure(_branch([
      _leaf(const ['uno']),
      _leaf(const ['dos']),
      _leaf(const ['tres']),
      _leaf(const ['otro']),
    ]));

    test('demands the sum of its four columns', () {
      var demanded = 0.0;
      for (final column in selection.children) {
        demanded += column.minWidth;
      }
      expect(selection.minWidth, demanded);
    });

    test('gives none of the four less than the minimum width', () {
      for (final column in selection.children) {
        expect(column.minWidth, greaterThanOrEqualTo(StructogramMetrics.cellMinWidth));
      }
    });
  });

  group('a loop', () {
    final loop = _measure.measure(StructogramLoop(
      headerLines: const ['k < 10'],
      position: StructogramLoopPosition.header,
      body: StructogramStack([
        _leaf(const ['uno']),
        _leaf(const ['dos']),
        _leaf(const ['tres']),
      ]),
    ));

    test('adds the indent of its frame exactly once', () {
      expect(loop.minWidth, loop.children.first.minWidth + StructogramMetrics.loopIndent);
    });

    test('is as tall as its header band plus its body', () {
      expect(loop.minHeight, loop.headerHeight + loop.children.first.minHeight);
    });

    test('an empty body still demands a minimum cell', () {
      final empty = _measure.measure(const StructogramLoop(
        headerLines: ['k < 10'],
        position: StructogramLoopPosition.header,
        body: StructogramStack([]),
      ));
      expect(empty.children.first.minHeight, StructogramMetrics.cellMinHeight);
    });
  });

  group('deep nesting', () {
    test('multiplies the demanded width by two at every conditional level', () {
      final six = _measure.measure(_nested(6));
      expect(six.minWidth, StructogramMetrics.cellMinWidth * 64);
    });

    test('is deterministic: measuring twice gives the same numbers', () {
      final tree = _nested(6);
      expect(_measure.measure(tree).minWidth, _measure.measure(tree).minWidth);
      expect(_measure.measure(tree).minHeight, _measure.measure(tree).minHeight);
    });
  });
}
