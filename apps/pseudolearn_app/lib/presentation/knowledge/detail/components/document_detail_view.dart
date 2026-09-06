import 'package:flutter/material.dart';
import '../../../../domain/model/knowledge/knowledge_detail_content.dart';
import '../../../theme/tokens/motion.dart';
import '../../../theme/tokens/spacing.dart';
import 'content_block_view.dart';
import 'document_headings_nav.dart';

final class DocumentDetailView extends StatefulWidget {
  final DocumentDetailContent content;
  final ValueChanged<double>? onScrollChanged;

  const DocumentDetailView({
    super.key,
    required this.content,
    this.onScrollChanged,
  });

  @override
  State<DocumentDetailView> createState() => _DocumentDetailViewState();
}

final class _DocumentDetailViewState extends State<DocumentDetailView> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: widget.content.scrollOffset,
    );
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (widget.onScrollChanged != null && _scrollController.hasClients) {
      widget.onScrollChanged!(_scrollController.offset);
    }
  }

  void _scrollToBlock(int blockIndex) {
    if (!_scrollController.hasClients) return;
    final estimatedOffset = (blockIndex * 90.0).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      estimatedOffset,
      duration: MotionTokens.motionPanel,
      curve: MotionTokens.easeStandard,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DocumentHeadingsNav(
          headings: widget.content.headings,
          onSelectHeading: _scrollToBlock,
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: SpacingTokens.space6),
            itemCount: widget.content.blocks.length,
            itemBuilder: (context, index) {
              return ContentBlockView(
                block: widget.content.blocks[index],
              );
            },
          ),
        ),
      ],
    );
  }
}
