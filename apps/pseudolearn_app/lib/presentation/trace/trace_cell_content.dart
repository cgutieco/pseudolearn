import 'package:flutter/material.dart';
import '../../application/trace/trace_state.dart';
import '../components/typography/app_text.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/editor_metrics.dart';
import '../theme/tokens/spacing.dart';

final class TraceCellContent extends StatelessWidget {
  final TraceTableCell cell;

  const TraceCellContent({super.key, required this.cell});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: EditorMetricsTokens.traceVariableColumnWidth,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.space2),
        child: Align(alignment: Alignment.centerLeft, child: _CellValue(cell: cell)),
      ),
    );
  }
}

final class _CellValue extends StatelessWidget {
  final TraceTableCell cell;

  const _CellValue({required this.cell});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    if (cell.isOutOfScope) return const SizedBox.shrink();
    if (cell.identityBadge != null) {
      return _AliasedValue(badge: cell.identityBadge!, text: cell.formattedValue, isChanged: cell.hasJustChanged);
    }
    return AppText(
      cell.formattedValue,
      variant: AppTextVariant.codeCaption,
      color: cell.hasJustChanged ? theme.colors.text.link : theme.colors.text.tertiary,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

final class _AliasedValue extends StatelessWidget {
  final int badge;
  final String text;
  final bool isChanged;

  const _AliasedValue({required this.badge, required this.text, required this.isChanged});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.link, size: 14, color: theme.colors.text.link),
        const SizedBox(width: SpacingTokens.space1),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.space1, vertical: SpacingTokens.spaceHalf),
          decoration: BoxDecoration(
            color: theme.colors.surfaces.brandSubtle,
            borderRadius: BorderRadius.circular(4),
          ),
          child: AppText('#$badge', variant: AppTextVariant.caption, color: theme.colors.text.link),
        ),
        const SizedBox(width: SpacingTokens.space1),
        Flexible(
          child: AppText(
            text,
            variant: AppTextVariant.codeCaption,
            color: isChanged ? theme.colors.text.link : theme.colors.text.tertiary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
