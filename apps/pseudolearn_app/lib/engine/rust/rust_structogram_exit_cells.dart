import '../diagram/diagram_vocabulary.dart';
import '../structogram/structogram_cell.dart';
import 'rust_caption_text.dart';
import 'rust_control_exits.dart';
import 'rust_program_view.dart';
import 'rust_statement_treatment.dart';

final class RustStructogramExitCells {
  final RustProgramView _view;
  final ExitVocabulary _words;
  final RustControlExits _exits;
  final List<String> Function(String text) _wrap;

  RustStructogramExitCells({
    required RustProgramView view,
    required DiagramVocabulary vocabulary,
    required List<String> Function(String text) wrap,
  }) : _view = view,
       _words = vocabulary.exits,
       _exits = RustControlExits(view),
       _wrap = wrap;

  String caption(RustViewNode node) {
    final propagation = rustFirstPropagation(_view, node);
    final exitNode = propagation ?? node;
    final text = propagation == null
        ? rustCaptionOf(node)
        : '${rustCaptionOf(node)} — ${_words.propagationNote}';
    return _words.withCleanups(text, _exits.exitCleanupLines(exitNode));
  }

  StructogramCell closeScope(RustViewNode body, StructogramStack sequence) {
    final lines = _exits.normalCleanupLines(body);
    if (lines.isEmpty || !reachesEnd(sequence)) return sequence;
    return StructogramStack([
      ...sequence.children,
      StructogramLeaf(
        kind: StructogramLeafKind.call,
        lines: _wrap(_words.cleanupsAtEndOf(lines)),
        nodeId: body.id,
        sourceLine: lines.first,
      ),
    ]);
  }

  static bool reachesEnd(StructogramCell cell) => switch (cell) {
    StructogramLeaf(:final kind) => kind != StructogramLeafKind.exit,
    StructogramStack(:final children) =>
      children.isEmpty || reachesEnd(children.last),
    StructogramBranch(:final columns) => columns.any(
      (column) => reachesEnd(column.body),
    ),
    StructogramLoop() => true,
  };
}
