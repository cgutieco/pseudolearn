import 'package:equatable/equatable.dart';

final class TraceTableCell extends Equatable {
  final String formattedValue;
  final int? identityBadge;
  final bool isOutOfScope;
  final bool hasJustChanged;

  const TraceTableCell({
    required this.formattedValue,
    this.identityBadge,
    this.isOutOfScope = false,
    this.hasJustChanged = false,
  });

  const TraceTableCell.outOfScope()
      : formattedValue = '',
        identityBadge = null,
        isOutOfScope = true,
        hasJustChanged = false;

  TraceTableCell markedAsChanged() => TraceTableCell(
        formattedValue: formattedValue,
        identityBadge: identityBadge,
        isOutOfScope: isOutOfScope,
        hasJustChanged: true,
      );

  bool holdsSameValueAs(TraceTableCell? other) =>
      other != null &&
      other.formattedValue == formattedValue &&
      other.identityBadge == identityBadge &&
      other.isOutOfScope == isOutOfScope;

  @override
  List<Object?> get props => [formattedValue, identityBadge, isOutOfScope, hasJustChanged];
}

final class TraceTableRow extends Equatable {
  final int stepNumber;
  final int? lineNumber;
  final String scopeName;
  final Map<String, TraceTableCell> cells;
  final bool isOpen;

  const TraceTableRow({
    required this.stepNumber,
    required this.lineNumber,
    required this.scopeName,
    required this.cells,
    this.isOpen = false,
  });

  TraceTableRow closedWith(Map<String, TraceTableCell> settledCells) => TraceTableRow(
        stepNumber: stepNumber,
        lineNumber: lineNumber,
        scopeName: scopeName,
        cells: settledCells,
      );

  @override
  List<Object?> get props => [stepNumber, lineNumber, scopeName, cells, isOpen];
}

final class TraceState extends Equatable {
  final List<TraceTableRow> rows;
  final List<String> variableNames;
  final int currentRowIndex;
  final bool hasExecution;
  final List<String> changedNames;
  final List<String> changedValues;

  const TraceState({
    required this.rows,
    required this.variableNames,
    required this.currentRowIndex,
    required this.hasExecution,
    this.changedNames = const [],
    this.changedValues = const [],
  });

  const TraceState.initial()
      : rows = const [],
        variableNames = const [],
        currentRowIndex = 0,
        hasExecution = false,
        changedNames = const [],
        changedValues = const [];

  TraceTableRow? get currentRow =>
      currentRowIndex >= 0 && currentRowIndex < rows.length ? rows[currentRowIndex] : null;

  TraceTableRow? get openRow {
    if (rows.isEmpty) return null;
    final last = rows.last;
    return last.isOpen ? last : null;
  }

  @override
  List<Object?> get props =>
      [rows, variableNames, currentRowIndex, hasExecution, changedNames, changedValues];
}
