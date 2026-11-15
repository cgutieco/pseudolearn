import 'package:material_ui/material_ui.dart';
import '../../../domain/model/reference/reference_block.dart';
import '../../../domain/model/reference/reference_run.dart';
import '../../components/typography/app_text.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/radii.dart';
import '../../theme/tokens/spacing.dart';
import '../reference_runs_text.dart';

const double _cellMaxWidth = 280;

final class ReferenceTableView extends StatelessWidget {
  final ReferenceTable table;
  final ValueChanged<String> onOpenSection;

  const ReferenceTableView({
    super.key,
    required this.table,
    required this.onOpenSection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colors.borders.subtle),
          borderRadius: BorderRadius.circular(RadiusTokens.radiusMd),
        ),
        child: Table(
          defaultColumnWidth: const IntrinsicColumnWidth(),
          border: TableBorder.symmetric(
            inside: BorderSide(color: theme.colors.borders.subtle),
          ),
          children: [
            _row(context, table.header, header: true),
            for (final row in table.rows) _row(context, row, header: false),
          ],
        ),
      ),
    );
  }

  TableRow _row(
    BuildContext context,
    List<List<ReferenceRun>> cells, {
    required bool header,
  }) {
    final theme = AppThemeExtension.of(context);
    return TableRow(
      decoration: header
          ? BoxDecoration(color: theme.colors.surfaces.subtle)
          : null,
      children: [
        for (final cell in cells)
          ReferenceTableCell(
            runs: cell,
            header: header,
            onOpenSection: onOpenSection,
          ),
      ],
    );
  }
}

final class ReferenceTableCell extends StatelessWidget {
  final List<ReferenceRun> runs;
  final bool header;
  final ValueChanged<String> onOpenSection;

  const ReferenceTableCell({
    super.key,
    required this.runs,
    required this.header,
    required this.onOpenSection,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _cellMaxWidth),
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.space2),
        child: ReferenceRunsText(
          runs: runs,
          variant: header ? AppTextVariant.label : AppTextVariant.bodySmall,
          onOpenSection: onOpenSection,
        ),
      ),
    );
  }
}
