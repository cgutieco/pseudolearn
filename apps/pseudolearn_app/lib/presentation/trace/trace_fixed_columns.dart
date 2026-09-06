import 'package:flutter/material.dart';
import '../../application/trace/trace_state.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/editor_metrics.dart';
import '../theme/tokens/icon_metrics.dart';
import '../theme/tokens/spacing.dart';

final class TraceFixedColumns extends StatelessWidget {
  final List<TraceTableRow> rows;
  final int activeRowIndex;

  const TraceFixedColumns({
    super.key,
    required this.rows,
    required this.activeRowIndex,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: theme.colors.borders.subtle)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FixedHeader(
            step: l10n.traceStepHeader,
            line: l10n.traceLineHeader,
            scope: l10n.traceScopeHeader,
          ),
          for (var index = 0; index < rows.length; index++)
            _FixedRow(row: rows[index], isActive: index == activeRowIndex),
        ],
      ),
    );
  }
}

final class _FixedHeader extends StatelessWidget {
  final String step;
  final String line;
  final String scope;

  const _FixedHeader({required this.step, required this.line, required this.scope});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Container(
      height: EditorMetricsTokens.traceHeaderHeight,
      color: theme.colors.surfaces.subtle,
      child: Row(
        children: [
          _FixedCell(text: step, width: EditorMetricsTokens.traceStepColumnWidth, isHeading: true),
          _FixedCell(text: line, width: EditorMetricsTokens.traceLineColumnWidth, isHeading: true),
          _FixedCell(text: scope, width: EditorMetricsTokens.traceScopeColumnWidth, isHeading: true),
        ],
      ),
    );
  }
}

final class _FixedRow extends StatelessWidget {
  final TraceTableRow row;
  final bool isActive;

  const _FixedRow({required this.row, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Container(
      height: EditorMetricsTokens.traceRowHeightMedium,
      color: isActive ? theme.colors.surfaces.brandSubtle : null,
      child: Row(
        children: [
          _StepCell(stepNumber: row.stepNumber, isOpen: row.isOpen),
          _FixedCell(text: row.lineNumber?.toString() ?? '', width: EditorMetricsTokens.traceLineColumnWidth),
          _FixedCell(text: row.scopeName, width: EditorMetricsTokens.traceScopeColumnWidth),
        ],
      ),
    );
  }
}

final class _StepCell extends StatelessWidget {
  final int stepNumber;
  final bool isOpen;

  const _StepCell({required this.stepNumber, required this.isOpen});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);

    return SizedBox(
      width: EditorMetricsTokens.traceStepColumnWidth,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.space2),
        child: Row(
          children: [
            if (isOpen) const _OpenRowMarker(),
            Flexible(
              child: AppText(
                '$stepNumber',
                variant: AppTextVariant.codeCaption,
                color: isOpen ? theme.colors.text.link : null,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _OpenRowMarker extends StatelessWidget {
  const _OpenRowMarker();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: SpacingTokens.space1),
      child: Icon(
        Icons.more_horiz,
        size: IconMetricsTokens.iconXs,
        color: AppThemeExtension.of(context).colors.text.link,
        semanticLabel: AppLocalizations.of(context)!.traceRowOpen,
      ),
    );
  }
}

final class _FixedCell extends StatelessWidget {
  final String text;
  final double width;
  final bool isHeading;

  const _FixedCell({required this.text, required this.width, this.isHeading = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.space2),
        child: Align(
          alignment: Alignment.centerLeft,
          child: AppText(
            text,
            variant: isHeading ? AppTextVariant.label : AppTextVariant.codeCaption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
