import 'package:material_ui/material_ui.dart';
import '../../../domain/model/agent/reply_block.dart';
import '../../../domain/model/agent/reply_run.dart';
import '../../components/typography/app_text.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/radii.dart';
import '../../theme/tokens/spacing.dart';
import 'reply_metrics.dart';
import 'reply_runs_text.dart';

const Map<ReplyCellAlignment, TextAlign> _textAlignments = {
  ReplyCellAlignment.start: TextAlign.start,
  ReplyCellAlignment.center: TextAlign.center,
  ReplyCellAlignment.end: TextAlign.end,
};

final class ReplyTableView extends StatelessWidget {
  final ReplyTable table;

  const ReplyTableView({super.key, required this.table});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    if (table.header.isEmpty) return const SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colors.borders.subtle),
          borderRadius: BorderRadius.circular(RadiusTokens.radiusMd),
        ),
        child: Table(
          defaultColumnWidth: const IntrinsicColumnWidth(),
          border: TableBorder.symmetric(inside: BorderSide(color: theme.colors.borders.subtle)),
          children: [
            _row(table.header, header: true, theme: theme),
            for (final row in table.rows) _row(row, header: false, theme: theme),
          ],
        ),
      ),
    );
  }

  TableRow _row(List<List<ReplyRun>> cells, {required bool header, required AppThemeExtension theme}) {
    final columns = table.header.length;
    return TableRow(
      decoration: header ? BoxDecoration(color: theme.colors.surfaces.raised) : null,
      children: [
        for (var column = 0; column < columns; column += 1)
          _ReplyTableCell(
            runs: column < cells.length ? cells[column] : const [],
            header: header,
            align: _textAlignments[column < table.alignments.length ? table.alignments[column] : null] ??
                TextAlign.start,
          ),
      ],
    );
  }
}

final class _ReplyTableCell extends StatelessWidget {
  final List<ReplyRun> runs;
  final bool header;
  final TextAlign align;

  const _ReplyTableCell({required this.runs, required this.header, required this.align});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: ReplyMetrics.tableCellMaxWidth),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.space3, vertical: SpacingTokens.space2),
        child: ReplyRunsText(
          runs: runs,
          variant: header ? AppTextVariant.label : AppTextVariant.bodySmall,
          textAlign: align,
        ),
      ),
    );
  }
}
