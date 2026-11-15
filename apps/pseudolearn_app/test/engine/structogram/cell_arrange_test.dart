import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/diagram/structogram_metrics.dart';
import 'package:pseudolearn_app/engine/structogram/cell_arrange.dart';
import 'package:pseudolearn_app/engine/structogram/cell_measure.dart';
import 'package:pseudolearn_app/engine/structogram/structogram_cell.dart';

const CellMeasure _measure = CellMeasure();
const CellArrange _arrange = CellArrange();

StructogramLeaf _leaf(List<String> lines) =>
    StructogramLeaf(kind: StructogramLeafKind.process, lines: lines);

StructogramBranch _branch(List<StructogramCell> bodies) => StructogramBranch(
      headerLines: const ['a = b'],
      isBinary: bodies.length == 2,
      columns: [
        for (final body in bodies) StructogramColumn(label: 'SI', body: body),
      ],
    );

StructogramLoop _loop(StructogramCell body, StructogramLoopPosition position) =>
    StructogramLoop(
      headerLines: const ['k < 10'],
      position: position,
      body: body,
    );

StructogramCell _nested(int depth) => depth == 0
    ? _leaf(const ['x'])
    : _branch([
        _nested(depth - 1),
        _loop(_nested(depth - 1), StructogramLoopPosition.header)
      ]);

PlacedCell _place(StructogramCell cell, {double? width}) =>
    _arrange.arrange(_measure.measure(cell), left: 0.0, top: 0.0, width: width);

bool _overlap(PlacedCell a, PlacedCell b) =>
    a.left < b.right &&
    b.left < a.right &&
    a.top < b.bottom &&
    b.top < a.bottom;

bool _contains(PlacedCell parent, PlacedCell child) =>
    child.left >= parent.left - 0.001 &&
    child.top >= parent.top - 0.001 &&
    child.right <= parent.right + 0.001 &&
    child.bottom <= parent.bottom + 0.001;

void _assertTiles(PlacedCell parent) {
  for (final child in parent.children) {
    expect(_contains(parent, child), isTrue,
        reason: 'a child escapes its parent at (${child.left}, ${child.top})');
  }
  for (var i = 0; i < parent.children.length; i++) {
    for (var j = i + 1; j < parent.children.length; j++) {
      expect(_overlap(parent.children[i], parent.children[j]), isFalse,
          reason: 'two siblings overlap at (${parent.children[i].left})');
    }
  }
  for (final child in parent.children) {
    _assertTiles(child);
  }
}

double _minWidthOf(PlacedCell placed) => _measure.measure(placed.cell).minWidth;

void _assertNeverBelowMinimum(PlacedCell placed) {
  expect(placed.width,
      greaterThanOrEqualTo(StructogramMetrics.cellMinWidth - 0.001));
  expect(placed.height,
      greaterThanOrEqualTo(StructogramMetrics.cellMinHeight - 0.001));
  for (final child in placed.children) {
    _assertNeverBelowMinimum(child);
  }
}

void main() {
  group('a stack of three leaves', () {
    final stack = _place(StructogramStack([
      _leaf(const ['uno']),
      _leaf(const ['dos']),
      _leaf(const ['tres']),
    ]));

    test('gives the three the same width', () {
      for (final child in stack.children) {
        expect(child.width, stack.width);
      }
    });

    test('leaves no gap between one cell and the next', () {
      expect(stack.children[1].top, stack.children[0].bottom);
      expect(stack.children[2].top, stack.children[1].bottom);
    });

    test('ends exactly at the bottom of its last child', () {
      expect(stack.children.last.bottom, stack.bottom);
    });

    test('gives spare height to the last child when the parent is stretched',
        () {
      final stretched = _arrange.arrange(
        _measure.measure(StructogramStack([
          _leaf(const ['uno']),
          _leaf(const ['dos'])
        ])),
        height: 400.0,
      );
      expect(stretched.children.last.bottom, stretched.bottom);
      expect(stretched.height, 400.0);
    });
  });

  group('a conditional with columns of different content', () {
    final branch = _place(_branch([
      _leaf(const [
        'contador <- contador + incremento',
        'y una segunda linea larga'
      ]),
      _leaf(const ['x']),
    ]));

    test('makes its two columns add up to the width of the parent exactly', () {
      expect(branch.children[0].width + branch.children[1].width, branch.width);
      expect(branch.children.last.right, branch.right);
    });

    test('gives both columns the same height', () {
      expect(branch.children[0].height, branch.children[1].height);
    });

    test('starts both columns under the header band', () {
      for (final column in branch.children) {
        expect(column.top, branch.top + branch.headerHeight);
      }
    });

    test('gives the busier column more width than the emptier one', () {
      expect(branch.children[0].width, greaterThan(branch.children[1].width));
    });
  });

  group('a four-case selection', () {
    final selection = _place(_branch([
      _leaf(const ['uno']),
      _leaf(const ['dos']),
      _leaf(const ['tres']),
      _leaf(const ['de otro modo']),
    ]));

    test('shares the whole width among the four', () {
      var sum = 0.0;
      for (final column in selection.children) {
        sum += column.width;
      }
      expect(sum, closeTo(selection.width, 0.0001));
    });

    test('gives none of the four less than the minimum width', () {
      for (final column in selection.children) {
        expect(column.width,
            greaterThanOrEqualTo(StructogramMetrics.cellMinWidth));
      }
    });
  });

  group('a test-first loop with a body of three cells', () {
    final loop = _place(_loop(
      StructogramStack([
        _leaf(const ['uno']),
        _leaf(const ['dos']),
        _leaf(const ['tres']),
      ]),
      StructogramLoopPosition.header,
    ));

    test('applies its indent once, on the left of the body', () {
      expect(
          loop.children.first.left, loop.left + StructogramMetrics.loopIndent);
      expect(loop.children.first.width,
          loop.width - StructogramMetrics.loopIndent);
    });

    test('starts the body under the header band', () {
      expect(loop.children.first.top, loop.top + loop.headerHeight);
    });

    test('keeps the body inside the frame', () {
      expect(_contains(loop, loop.children.first), isTrue);
      _assertTiles(loop);
    });
  });

  group('a test-last loop', () {
    final loop = _place(
        _loop(_leaf(const ['k <- k - 1']), StructogramLoopPosition.footer));

    test('puts the body above and leaves the header band at the bottom', () {
      expect(loop.children.first.top, loop.top);
      expect(loop.children.first.bottom, loop.bottom - loop.headerHeight);
    });
  });

  group('six levels of nesting mixing conditionals and loops', () {
    final deep = _place(_nested(6));

    test('leaves no cell below the minimum width or height', () {
      _assertNeverBelowMinimum(deep);
    });

    test('never lets a cell escape its parent nor overlap a sibling', () {
      _assertTiles(deep);
    });

    test('honours the demanded minimum width of every cell', () {
      expect(deep.width, greaterThanOrEqualTo(_minWidthOf(deep)));
    });
  });

  group('edge cases', () {
    test('an empty loop body still places one cell inside the frame', () {
      final loop = _place(
          _loop(const StructogramStack([]), StructogramLoopPosition.header));
      expect(loop.children.first.width,
          loop.width - StructogramMetrics.loopIndent);
      _assertTiles(loop);
    });

    test('an empty branch column keeps the tiling exact', () {
      final branch = _place(_branch([
        _leaf(const ['x']),
        const StructogramStack([])
      ]));
      expect(branch.children.last.right, branch.right);
      _assertTiles(branch);
    });

    test('a five-hundred-character text still tiles', () {
      final wide = _place(_branch([
        _leaf([('a' * 500)]),
        _leaf(const ['x'])
      ]));
      expect(wide.children.last.right, wide.right);
      _assertTiles(wide);
    });

    test('an extra width offered to a leaf is taken in full', () {
      final wide = _place(_leaf(const ['x']), width: 500.0);
      expect(wide.width, 500.0);
    });

    test('a width narrower than the minimum is refused', () {
      final narrow = _place(_leaf(const ['x']), width: 4.0);
      expect(narrow.width, StructogramMetrics.cellMinWidth);
    });
  });

  test('arranging the same tree twice gives the same coordinates', () {
    final tree = _nested(4);
    final first = _place(tree);
    final second = _place(tree);
    expect(first.width, second.width);
    expect(first.height, second.height);
    expect(first.children.first.left, second.children.first.left);
    expect(first.children.last.right, second.children.last.right);
  });
}
