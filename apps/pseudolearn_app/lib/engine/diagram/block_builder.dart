import 'package:pseudolearn_core/pseudolearn_core.dart';

import '../../domain/model/analysis/program_node_id.dart';
import '../../domain/model/diagram/diagram_scene.dart';
import 'branch_blocks.dart';
import 'diagram_vocabulary.dart';
import 'layout_block.dart';
import 'post_test_loop_block.dart';
import 'pre_test_loop_block.dart';
import 'node_factory.dart';
import 'statement_caption.dart';

final class BlockBuilder {
  final NodeFactory _nodes;
  final StatementCaption _caption;
  final DiagramVocabulary _vocabulary;

  const BlockBuilder({
    required NodeFactory nodes,
    required StatementCaption caption,
    required DiagramVocabulary vocabulary,
  })  : _nodes = nodes,
        _caption = caption,
        _vocabulary = vocabulary;

  LayoutBlock buildSequence(List<StatementNode> statements) {
    if (statements.isEmpty) return LayoutBlock.fromNode(_nodes.connector());
    return LayoutBlock.stack(statements.map(buildStatement).toList());
  }

  LayoutBlock buildStatement(StatementNode statement) {
    return switch (statement) {
      IfStatementNode() => _buildConditional(statement),
      SwitchStatementNode() => _buildSelection(statement),
      WhileStatementNode() => _buildWhile(statement),
      RepeatUntilStatementNode() => _buildRepeatUntil(statement),
      ForStatementNode() => _buildFor(statement),
      ReturnStatementNode() => _buildTerminatingNode(statement),
      _ => LayoutBlock.fromNode(_simpleNode(statement)),
    };
  }

  DiagramNode _simpleNode(StatementNode statement) => _nodes.create(
        shape: _shapeOf(statement),
        text: _caption.forStatement(statement),
        sourceLine: statement.span.start.line,
        nodeId: ProgramNodeId(statement.id.value),
      );

  LayoutBlock _buildTerminatingNode(ReturnStatementNode statement) =>
      LayoutBlock.fromNode(_simpleNode(statement), hasExit: false);

  DiagramShape _shapeOf(StatementNode statement) {
    return switch (statement) {
      ReadStatementNode() || WriteStatementNode() => DiagramShape.inputOutput,
      CallStatementNode() || MethodCallStatementNode() => DiagramShape.subprogram,
      ReturnStatementNode() => DiagramShape.startEnd,
      _ => DiagramShape.process,
    };
  }

  LayoutBlock _buildConditional(IfStatementNode statement) {
    return BranchBlocks.conditional(
      decision: _decisionNode(statement, statement.condition, statement.span.start.line),
      junction: _nodes.connector(),
      columns: [
        BranchColumn(
          block: _branchColumn(statement.thenBody),
          label: _vocabulary.affirmative,
          kind: DiagramEdgeKind.branchTrue,
        ),
        BranchColumn(
          block: _branchColumn(statement.elseBody ?? const []),
          label: _vocabulary.negative,
          kind: DiagramEdgeKind.branchFalse,
        ),
      ],
    );
  }

  LayoutBlock _buildSelection(SwitchStatementNode statement) {
    final columns = [
      for (final branch in statement.cases)
        BranchColumn(
          block: _branchColumn(branch.body),
          label: _caption.forCaseLabels(branch.labels),
          kind: DiagramEdgeKind.branchCase,
        ),
      if (statement.defaultCase != null)
        BranchColumn(
          block: _branchColumn(statement.defaultCase!.body),
          label: _caption.forCaseLabels(null),
          kind: DiagramEdgeKind.branchCase,
        ),
    ];
    return BranchBlocks.selection(
      selector: _nodes.create(
        shape: DiagramShape.decision,
        text: _caption.forSelector(statement.selector),
        sourceLine: statement.span.start.line,
        nodeId: ProgramNodeId(statement.id.value),
      ),
      junction: _nodes.connector(),
      columns: columns.isEmpty ? [_emptyCaseColumn()] : columns,
    );
  }

  BranchColumn _emptyCaseColumn() => BranchColumn(
        block: const LayoutBlock.lane(0.0),
        label: _caption.forCaseLabels(null),
        kind: DiagramEdgeKind.branchCase,
      );

  LayoutBlock _buildWhile(WhileStatementNode statement) {
    return PreTestLoopBlock.compose(
      header: _decisionNode(statement, statement.condition, statement.span.start.line),
      body: buildSequence(statement.body),
      junction: _nodes.connector(),
      enterLabel: _vocabulary.affirmative,
      exitLabel: _vocabulary.negative,
    );
  }

  LayoutBlock _buildFor(ForStatementNode statement) {
    return PreTestLoopBlock.compose(
      header: _nodes.create(
        shape: DiagramShape.preparation,
        text: _caption.forLoopHeader(statement),
        sourceLine: statement.span.start.line,
        nodeId: ProgramNodeId(statement.id.value),
      ),
      body: buildSequence(statement.body),
      junction: _nodes.connector(),
      enterLabel: null,
      exitLabel: null,
    );
  }

  LayoutBlock _buildRepeatUntil(RepeatUntilStatementNode statement) {
    return PostTestLoopBlock.compose(
      decision: _decisionNode(statement, statement.condition, statement.untilKeywordSpan.start.line),
      body: buildSequence(statement.body),
      entryConnector: _nodes.connector(),
      enterLabel: _vocabulary.negative,
      exitLabel: _vocabulary.affirmative,
    );
  }

  LayoutBlock _branchColumn(List<StatementNode> statements) {
    if (statements.isEmpty) return const LayoutBlock.lane(0.0);
    return LayoutBlock.stack(statements.map(buildStatement).toList());
  }

  DiagramNode _decisionNode(StatementNode owner, ExpressionNode condition, int sourceLine) =>
      _nodes.create(
        shape: DiagramShape.decision,
        text: _caption.forCondition(condition),
        sourceLine: sourceLine,
        nodeId: ProgramNodeId(owner.id.value),
      );
}
