import 'package:flutter/material.dart';
import '../../../domain/model/agent/code_block.dart';
import '../../../domain/model/agent/reply_block.dart';
import '../verified_code_block.dart';
import 'reply_diagram_view.dart';
import 'reply_heading_view.dart';
import 'reply_list_view.dart';
import 'reply_metrics.dart';
import 'reply_quote_view.dart';
import 'reply_runs_text.dart';
import 'reply_table_view.dart';

final class ReplyBlocksView extends StatelessWidget {
  final List<ReplyBlock> blocks;
  final List<CheckedCodeBlock> codeBlocks;
  final int depth;

  const ReplyBlocksView({super.key, required this.blocks, required this.codeBlocks, this.depth = 0});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, block) in blocks.indexed)
          Padding(
            padding: EdgeInsets.only(top: index == 0 ? 0 : ReplyMetrics.blockGap),
            child: ReplyBlockView(block: block, codeBlocks: codeBlocks, depth: depth),
          ),
      ],
    );
  }
}

final class ReplyBlockView extends StatelessWidget {
  final ReplyBlock block;
  final List<CheckedCodeBlock> codeBlocks;
  final int depth;

  const ReplyBlockView({super.key, required this.block, required this.codeBlocks, required this.depth});

  @override
  Widget build(BuildContext context) {
    return switch (block) {
      final ReplyHeading heading => ReplyHeadingView(heading: heading),
      ReplyParagraph(:final runs) => ReplyRunsText(runs: runs),
      final ReplyList list => ReplyListView(list: list, codeBlocks: codeBlocks, depth: depth),
      final ReplyQuote quote => ReplyQuoteView(quote: quote, codeBlocks: codeBlocks, depth: depth),
      final ReplyTable table => ReplyTableView(table: table),
      ReplyRule() => const Divider(height: ReplyMetrics.blockGap),
      ReplyCode(:final index) => index < codeBlocks.length
          ? VerifiedCodeBlock(code: codeBlocks[index])
          : const SizedBox.shrink(),
      final ReplyDiagram diagram => ReplyDiagramView(diagram: diagram),
    };
  }
}
