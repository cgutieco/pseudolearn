import 'package:flutter/material.dart';
import '../../../../domain/model/knowledge/content_block.dart';
import 'blocks/code_block_views.dart';
import 'blocks/data_block_views.dart';
import 'blocks/diagnostic_block_view.dart';
import 'blocks/text_block_views.dart';

final class ContentBlockView extends StatelessWidget {
  final ContentBlock block;

  const ContentBlockView({
    super.key,
    required this.block,
  });

  @override
  Widget build(BuildContext context) {
    return switch (block) {
      final HeadingBlock b => HeadingBlockView(block: b),
      final ParagraphBlock b => ParagraphBlockView(block: b),
      final ListBlock b => ListBlockView(block: b),
      final CodeBlock b => CodeBlockView(block: b),
      final QuoteBlock b => QuoteBlockView(block: b),
      final DiagramBlock b => DiagramBlockView(block: b),
      final FigureBlock b => FigureBlockView(block: b),
      final MarkerBlock b => MarkerBlockView(block: b),
      final TableBlock b => TableBlockView(block: b),
      final DiagnosticBlock b => DiagnosticBlockView(block: b),
    };
  }
}

