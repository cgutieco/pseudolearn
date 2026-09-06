import '../../domain/model/analysis/program_node_id.dart';

enum StructogramLeafKind { process, call, exit, empty }

enum StructogramLoopPosition { header, footer }

sealed class StructogramCell {
  const StructogramCell();
}

final class StructogramLeaf extends StructogramCell {
  final StructogramLeafKind kind;
  final List<String> lines;
  final ProgramNodeId? nodeId;
  final int? sourceLine;

  const StructogramLeaf({
    required this.kind,
    required this.lines,
    this.nodeId,
    this.sourceLine,
  });
}

final class StructogramStack extends StructogramCell {
  final List<StructogramCell> children;

  const StructogramStack(this.children);
}

final class StructogramColumn {
  final String label;
  final StructogramCell body;

  const StructogramColumn({required this.label, required this.body});
}

final class StructogramBranch extends StructogramCell {
  final List<String> headerLines;
  final List<StructogramColumn> columns;
  final bool isBinary;
  final ProgramNodeId? nodeId;
  final int? sourceLine;

  const StructogramBranch({
    required this.headerLines,
    required this.columns,
    required this.isBinary,
    this.nodeId,
    this.sourceLine,
  });
}

final class StructogramLoop extends StructogramCell {
  final List<String> headerLines;
  final StructogramLoopPosition position;
  final StructogramCell body;
  final ProgramNodeId? nodeId;
  final int? sourceLine;

  const StructogramLoop({
    required this.headerLines,
    required this.position,
    required this.body,
    this.nodeId,
    this.sourceLine,
  });
}
