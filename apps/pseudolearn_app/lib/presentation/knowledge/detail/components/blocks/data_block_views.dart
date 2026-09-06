import 'package:flutter/material.dart';
import '../../../../../domain/model/knowledge/content_block.dart';
import '../../../../components/typography/app_text.dart';
import '../../../../knowledge/illustrations/illustration_catalog.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/tokens/border_metrics.dart';
import '../../../../theme/tokens/component_metrics.dart';
import '../../../../theme/tokens/radii.dart';
import '../../../../theme/tokens/spacing.dart';
import 'text_block_views.dart';

final class TableBlockView extends StatelessWidget {
  final TableBlock block;

  const TableBlockView({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: SpacingTokens.space4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(RadiusTokens.radiusSm),
        border: Border.all(
          color: theme.colors.borders.subtle,
          width: BorderMetricsTokens.widthHairline,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TableRowView(cells: block.headers, isHeader: true),
            for (final row in block.rows)
              _TableRowView(cells: row, isHeader: false),
          ],
        ),
      ),
    );
  }
}

final class _TableRowView extends StatelessWidget {
  final List<String> cells;
  final bool isHeader;

  const _TableRowView({required this.cells, required this.isHeader});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Container(
      color: isHeader ? theme.colors.surfaces.subtle : null,
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.space3,
        vertical: SpacingTokens.space2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final cell in cells)
            SizedBox(
              width: ComponentMetricsTokens.contentTableColumnWidth,
              child: AppText(
                cell,
                variant: isHeader
                    ? AppTextVariant.label
                    : AppTextVariant.bodyDefault,
                color: isHeader
                    ? theme.colors.text.primary
                    : theme.colors.text.secondary,
              ),
            ),
        ],
      ),
    );
  }
}

final class MarkerBlockView extends StatelessWidget {
  final MarkerBlock block;

  const MarkerBlockView({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    return ParagraphBlockView(
      block: ParagraphBlock(text: block.resolvedText),
    );
  }
}

final class FigureBlockView extends StatelessWidget {
  final FigureBlock block;

  const FigureBlockView({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    final illustration = illustrationCatalog[block.illustrationId];
    if (illustration == null) {
      return ParagraphBlockView(block: ParagraphBlock(text: block.caption));
    }
    final theme = AppThemeExtension.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          illustration(),
          const SizedBox(height: SpacingTokens.space2),
          AppText(
            block.caption,
            variant: AppTextVariant.caption,
            color: theme.colors.text.secondary,
          ),
        ],
      ),
    );
  }
}
