import 'package:pseudolearn_core/pseudolearn_core.dart';

import '../../domain/model/analysis/program_node_id.dart';
import '../../domain/model/diagram/diagram_metrics.dart';
import '../../domain/model/diagram/structogram_metrics.dart';
import '../diagram/diagram_vocabulary.dart';
import '../diagram/statement_caption.dart';
import '../diagram/text_metrics.dart';
import 'structogram_cell.dart';

final class StructogramCellBuilder {
  final StatementCaption _caption;
  final DiagramVocabulary _vocabulary;
  final TextMetrics _text;

  const StructogramCellBuilder({
    required StatementCaption caption,
    required DiagramVocabulary vocabulary,
    TextMetrics text = const TextMetrics(),
  })  : _caption = caption,
        _vocabulary = vocabulary,
        _text = text;

  StructogramCell buildBody(List<StatementNode> statements) {
    if (statements.isEmpty) return _emptyCell();
    return StructogramStack([
      for (final statement in statements) buildStatement(statement),
    ]);
  }

  StructogramCell buildStatement(StatementNode statement) {
    return switch (statement) {
      IfStatementNode() => _buildConditional(statement),
      SwitchStatementNode() => _buildSelection(statement),
      WhileStatementNode() => _buildPreTestLoop(
          statement,
          _caption.forCondition(statement.condition),
        ),
      ForStatementNode() => _buildPreTestLoop(
          statement,
          _caption.forLoopHeader(statement),
        ),
      RepeatUntilStatementNode() => _buildPostTestLoop(statement),
      _ => _buildLeaf(statement),
    };
  }

  StructogramCell _buildLeaf(StatementNode statement) => StructogramLeaf(
        kind: _leafKindOf(statement),
        lines: _wrap(_caption.forStatement(statement)),
        nodeId: ProgramNodeId(statement.id.value),
        sourceLine: statement.span.start.line,
      );

  StructogramLeafKind _leafKindOf(StatementNode statement) {
    return switch (statement) {
      CallStatementNode() || MethodCallStatementNode() => StructogramLeafKind.call,
      ReturnStatementNode() => StructogramLeafKind.exit,
      _ => StructogramLeafKind.process,
    };
  }

  StructogramCell _buildConditional(IfStatementNode statement) => StructogramBranch(
        headerLines: _wrap(_caption.forCondition(statement.condition)),
        isBinary: true,
        nodeId: ProgramNodeId(statement.id.value),
        sourceLine: statement.span.start.line,
        columns: [
          StructogramColumn(
            label: _vocabulary.affirmative,
            body: buildBody(statement.thenBody),
          ),
          StructogramColumn(
            label: _vocabulary.negative,
            body: buildBody(statement.elseBody ?? const []),
          ),
        ],
      );

  StructogramCell _buildSelection(SwitchStatementNode statement) {
    final columns = [
      for (final branch in statement.cases)
        StructogramColumn(
          label: _caption.forCaseLabels(branch.labels),
          body: buildBody(branch.body),
        ),
      if (statement.defaultCase != null)
        StructogramColumn(
          label: _caption.forCaseLabels(null),
          body: buildBody(statement.defaultCase!.body),
        ),
    ];
    return StructogramBranch(
      headerLines: _wrap(_caption.forSelector(statement.selector)),
      isBinary: false,
      nodeId: ProgramNodeId(statement.id.value),
      sourceLine: statement.span.start.line,
      columns: columns.isEmpty ? [_emptyColumn()] : columns,
    );
  }

  StructogramCell _buildPreTestLoop(StatementNode statement, String header) {
    return StructogramLoop(
      headerLines: _wrap(header),
      position: StructogramLoopPosition.header,
      nodeId: ProgramNodeId(statement.id.value),
      sourceLine: statement.span.start.line,
      body: buildBody(_bodyOf(statement)),
    );
  }

  StructogramCell _buildPostTestLoop(RepeatUntilStatementNode statement) {
    return StructogramLoop(
      headerLines: _wrap(_caption.forCondition(statement.condition)),
      position: StructogramLoopPosition.footer,
      nodeId: ProgramNodeId(statement.id.value),
      sourceLine: statement.untilKeywordSpan.start.line,
      body: buildBody(statement.body),
    );
  }

  List<StatementNode> _bodyOf(StatementNode statement) {
    return switch (statement) {
      WhileStatementNode(:final body) => body,
      ForStatementNode(:final body) => body,
      _ => const [],
    };
  }

  StructogramColumn _emptyColumn() => StructogramColumn(
        label: _caption.forCaseLabels(null),
        body: _emptyCell(),
      );

  StructogramCell _emptyCell() => StructogramLeaf(
        kind: StructogramLeafKind.empty,
        lines: _wrap(_vocabulary.emptyCell),
      );

  List<String> _wrap(String text) => _text.wrapText(
        text,
        maxUnits: (StructogramMetrics.cellMaxTextWidth -
                StructogramMetrics.cellPadding * 2) /
            DiagramMetrics.fontSize,
        maxLines: DiagramMetrics.maxTextLines,
      );
}
