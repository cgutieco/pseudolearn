import 'package:flutter/material.dart';
import '../../../../domain/model/knowledge/content_block.dart';
import '../../../../domain/model/knowledge/knowledge_detail_content.dart';
import '../../../components/button/app_button.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/tokens/border_metrics.dart';
import '../../../theme/tokens/motion.dart';
import '../../../theme/tokens/radii.dart';
import '../../../theme/tokens/spacing.dart';
import 'content_block_view.dart';
import 'document_headings_nav.dart';

final class SpecificationDetailView extends StatefulWidget {
  final SpecificationDetailContent content;
  final ValueChanged<String>? onReturnToModule;
  final ValueChanged<double>? onScrollChanged;

  const SpecificationDetailView({
    super.key,
    required this.content,
    this.onReturnToModule,
    this.onScrollChanged,
  });

  @override
  State<SpecificationDetailView> createState() => _SpecificationDetailViewState();
}

final class _SpecificationDetailViewState extends State<SpecificationDetailView> {
  late final ScrollController _scrollController;
  final Map<int, GlobalKey> _blockKeys = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: widget.content.scrollOffset,
    );
    _scrollController.addListener(_onScroll);
    if (widget.content.selectedAnchor != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToAnchor());
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (widget.onScrollChanged != null && _scrollController.hasClients) {
      widget.onScrollChanged!(_scrollController.offset);
    }
  }

  void _scrollToBlock(int index) {
    final key = _blockKeys[index];
    final context = key?.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: MotionTokens.motionScreen,
        curve: MotionTokens.easeStandard,
      );
    }
  }

  void _scrollToAnchor() {
    if (widget.content.headings.isEmpty) return;
    _scrollToBlock(widget.content.headings.first.blockIndex);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fromTitle = widget.content.fromModuleTitle;
    final fromId = widget.content.fromModuleId;

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (fromId != null && fromTitle != null && widget.onReturnToModule != null)
            _ReturnBanner(
              moduleTitle: fromTitle,
              moduleId: fromId,
              l10n: l10n,
              onReturn: widget.onReturnToModule!,
            ),
          DocumentHeadingsNav(
            headings: widget.content.headings,
            onSelectHeading: _scrollToBlock,
          ),
          _BlockList(
            blocks: widget.content.blocks,
            blockKeys: _blockKeys,
          ),
        ],
      ),
    );
  }
}

final class _BlockList extends StatelessWidget {
  final List<ContentBlock> blocks;
  final Map<int, GlobalKey> blockKeys;

  const _BlockList({required this.blocks, required this.blockKeys});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < blocks.length; i++)
          Container(
            key: blockKeys.putIfAbsent(i, () => GlobalKey()),
            child: ContentBlockView(block: blocks[i]),
          ),
      ],
    );
  }
}

final class _ReturnBanner extends StatelessWidget {
  final String moduleTitle;
  final String moduleId;
  final AppLocalizations l10n;
  final ValueChanged<String> onReturn;

  const _ReturnBanner({
    required this.moduleTitle,
    required this.moduleId,
    required this.l10n,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final border = BorderSide(
      color: theme.colors.borders.subtle,
      width: BorderMetricsTokens.widthHairline,
    );
    return Container(
      margin: const EdgeInsets.only(bottom: SpacingTokens.space4),
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.space3,
        vertical: SpacingTokens.space2,
      ),
      decoration: BoxDecoration(
        color: theme.colors.surfaces.brandSubtle,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusSm),
        border: Border.fromBorderSide(border),
      ),
      child: AppButton(
        label: l10n.knowledgeSpecReturnToModule(moduleTitle),
        icon: Icons.arrow_back_rounded,
        variant: AppButtonVariant.tertiary,
        onPressed: () => onReturn(moduleId),
      ),
    );
  }
}
