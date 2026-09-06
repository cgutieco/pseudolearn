import 'package:flutter/material.dart';
import '../../application/trace/trace_state.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/editor_metrics.dart';
import '../theme/tokens/spacing.dart';
import 'trace_cell_content.dart';
import 'trace_fixed_columns.dart';

final class TraceTable extends StatefulWidget {
  final List<TraceTableRow> rows;
  final List<String> variableNames;
  final int activeRowIndex;

  const TraceTable({
    super.key,
    required this.rows,
    required this.variableNames,
    required this.activeRowIndex,
  });

  @override
  State<TraceTable> createState() => _TraceTableState();
}

final class _TraceTableState extends State<TraceTable> {
  late final ScrollController _verticalController;

  @override
  void initState() {
    super.initState();
    _verticalController = ScrollController();
  }

  @override
  void didUpdateWidget(TraceTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeRowIndex != widget.activeRowIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _revealActiveRow());
    }
  }

  @override
  void dispose() {
    _verticalController.dispose();
    super.dispose();
  }

  void _revealActiveRow() {
    if (!_verticalController.hasClients) return;
    final target = widget.activeRowIndex * EditorMetricsTokens.traceRowHeightMedium;
    final maximum = _verticalController.position.maxScrollExtent;
    _verticalController.jumpTo(target.clamp(0.0, maximum));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _verticalController,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TraceFixedColumns(rows: widget.rows, activeRowIndex: widget.activeRowIndex),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _VariableColumns(
                rows: widget.rows,
                variableNames: widget.variableNames,
                activeRowIndex: widget.activeRowIndex,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final class _VariableColumns extends StatelessWidget {
  final List<TraceTableRow> rows;
  final List<String> variableNames;
  final int activeRowIndex;

  const _VariableColumns({
    required this.rows,
    required this.variableNames,
    required this.activeRowIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _VariableHeader(variableNames: variableNames),
        for (var index = 0; index < rows.length; index++)
          _VariableRow(
            row: rows[index],
            variableNames: variableNames,
            isActive: index == activeRowIndex,
          ),
      ],
    );
  }
}

final class _VariableHeader extends StatelessWidget {
  final List<String> variableNames;

  const _VariableHeader({required this.variableNames});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Container(
      height: EditorMetricsTokens.traceHeaderHeight,
      color: theme.colors.surfaces.subtle,
      child: Row(
        children: variableNames
            .map((name) => _HeaderCell(label: name))
            .toList(),
      ),
    );
  }
}

final class _HeaderCell extends StatelessWidget {
  final String label;

  const _HeaderCell({required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: EditorMetricsTokens.traceVariableColumnWidth,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.space2),
        child: Align(
          alignment: Alignment.centerLeft,
          child: AppText(label, variant: AppTextVariant.codeInline, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }
}

final class _VariableRow extends StatelessWidget {
  final TraceTableRow row;
  final List<String> variableNames;
  final bool isActive;

  const _VariableRow({
    required this.row,
    required this.variableNames,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Container(
      height: EditorMetricsTokens.traceRowHeightMedium,
      color: isActive ? theme.colors.surfaces.brandSubtle : null,
      child: Row(
        children: variableNames
            .map((name) => TraceCellContent(cell: row.cells[name] ?? const TraceTableCell.outOfScope()))
            .toList(),
      ),
    );
  }
}

final class TraceTableHeaderLabels {
  const TraceTableHeaderLabels._();

  static List<String> of(AppLocalizations l10n) => [
        l10n.traceStepHeader,
        l10n.traceLineHeader,
        l10n.traceScopeHeader,
      ];
}
