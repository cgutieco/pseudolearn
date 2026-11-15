import '../../domain/model/execution/execution_focus.dart';
import '../../domain/model/execution/execution_step.dart';
import 'trace_state.dart';

final class TraceRowsProjection {
  const TraceRowsProjection();

  TraceState opened(
    TraceState current,
    ExecutionStep step,
    ExecutionFocus focus,
  ) {
    final names = <String>{...current.variableNames};
    final cells = _cellsOf(step, names);
    final closedRows = _rowsWithLastClosed(current, cells);
    final opened = TraceTableRow(
      stepNumber: closedRows.length + 1,
      lineNumber: focus.startLine,
      scopeName: step.scopeName,
      cells: cells,
      isOpen: true,
    );
    return _stateOf([...closedRows, opened], names, closedRows);
  }

  TraceState closed(TraceState current, ExecutionStep step) {
    if (current.openRow == null) return current;
    final names = <String>{...current.variableNames};
    final closedRows = _rowsWithLastClosed(current, _cellsOf(step, names));
    return _stateOf(closedRows, names, closedRows);
  }

  TraceState _stateOf(
    List<TraceTableRow> rows,
    Set<String> names,
    List<TraceTableRow> closedRows,
  ) {
    final justClosed = closedRows.isEmpty ? null : closedRows.last;
    final changedNames = <String>[];
    final changedValues = <String>[];
    final cells = justClosed?.cells ?? const <String, TraceTableCell>{};
    for (final entry in cells.entries) {
      if (!entry.value.hasJustChanged) continue;
      changedNames.add(entry.key);
      changedValues.add(entry.value.formattedValue);
    }
    return TraceState(
      rows: rows,
      variableNames: names.toList(),
      currentRowIndex: rows.length - 1,
      hasExecution: true,
      changedNames: changedNames,
      changedValues: changedValues,
    );
  }

  List<TraceTableRow> _rowsWithLastClosed(
    TraceState current,
    Map<String, TraceTableCell> cells,
  ) {
    final open = current.openRow;
    if (open == null) return current.rows;
    final rows = current.rows;
    final settled = rows.length >= 2 ? rows[rows.length - 2] : null;
    return [
      ...rows.sublist(0, rows.length - 1),
      open.closedWith(_markedAgainst(cells, settled)),
    ];
  }

  Map<String, TraceTableCell> _markedAgainst(
    Map<String, TraceTableCell> cells,
    TraceTableRow? previous,
  ) {
    final marked = <String, TraceTableCell>{};
    for (final entry in cells.entries) {
      final keepsValue = entry.value.isOutOfScope ||
          entry.value.holdsSameValueAs(previous?.cells[entry.key]);
      marked[entry.key] = keepsValue ? entry.value : entry.value.markedAsChanged();
    }
    return marked;
  }

  Map<String, TraceTableCell> _cellsOf(ExecutionStep step, Set<String> names) {
    final cells = <String, TraceTableCell>{};
    for (final variable in step.variables) {
      names.add(variable.name);
      cells[variable.name] = TraceTableCell(
        formattedValue: variable.formattedValue,
        identityBadge: variable.identityBadge,
      );
    }
    for (final name in names) {
      cells.putIfAbsent(name, () => const TraceTableCell.outOfScope());
    }
    return cells;
  }
}
