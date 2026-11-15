import 'flowchart.dart';
import 'reply_run.dart';

sealed class ReplyBlock {
  const ReplyBlock();
}

final class ReplyHeading extends ReplyBlock {
  final int level;
  final List<ReplyRun> runs;

  const ReplyHeading({required this.level, required this.runs});
}

final class ReplyParagraph extends ReplyBlock {
  final List<ReplyRun> runs;

  const ReplyParagraph(this.runs);
}

enum ReplyTask { none, open, done }

final class ReplyListItem {
  final ReplyTask task;
  final List<ReplyBlock> blocks;

  const ReplyListItem({required this.blocks, this.task = ReplyTask.none});
}

final class ReplyList extends ReplyBlock {
  final bool ordered;
  final int start;
  final List<ReplyListItem> items;

  const ReplyList({required this.ordered, required this.items, this.start = 1});
}

enum ReplyQuoteKind { plain, note, tip, important, warning, caution }

final class ReplyQuote extends ReplyBlock {
  final ReplyQuoteKind kind;
  final List<ReplyBlock> blocks;

  const ReplyQuote({required this.blocks, this.kind = ReplyQuoteKind.plain});
}

enum ReplyCellAlignment { start, center, end }

final class ReplyTable extends ReplyBlock {
  final List<ReplyCellAlignment> alignments;
  final List<List<ReplyRun>> header;
  final List<List<List<ReplyRun>>> rows;

  const ReplyTable({required this.alignments, required this.header, required this.rows});
}

final class ReplyRule extends ReplyBlock {
  const ReplyRule();
}

final class ReplyCode extends ReplyBlock {
  final int index;

  const ReplyCode(this.index);
}

final class ReplyDiagram extends ReplyBlock {
  final String source;
  final Flowchart? flowchart;

  const ReplyDiagram({required this.source, this.flowchart});
}
