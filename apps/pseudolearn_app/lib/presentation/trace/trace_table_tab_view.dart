import 'package:flutter/material.dart';
import '../../application/trace/trace_state.dart';
import '../components/empty/app_empty_state.dart';
import '../l10n/generated/app_localizations.dart';
import 'trace_table.dart';

final class TraceTableTabView extends StatelessWidget {
  final TraceState state;

  const TraceTableTabView({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (!state.hasExecution || state.rows.isEmpty) {
      return AppEmptyState(
        icon: Icons.table_rows_outlined,
        title: l10n.tabTrace,
        description: l10n.traceEmpty,
      );
    }

    return TraceTable(
      rows: state.rows,
      variableNames: state.variableNames,
      activeRowIndex: state.currentRowIndex,
    );
  }
}
