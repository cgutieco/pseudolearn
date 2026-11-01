import '../../domain/model/diagram/diagram_scene.dart';
import '../diagram/branch_blocks.dart';
import '../diagram/diagram_vocabulary.dart';
import '../diagram/layout_block.dart';
import '../diagram/node_factory.dart';
import '../diagram/post_test_loop_block.dart';
import '../diagram/pre_test_loop_block.dart';
import 'rust_diagram_captions.dart';
import 'rust_flowchart_columns.dart';
import 'rust_flowchart_exit_blocks.dart';
import 'rust_flowchart_scope_blocks.dart';
import 'rust_flowchart_nodes.dart';
import 'rust_program_view.dart';
import 'rust_statement_treatment.dart';
import 'rust_task_nodes.dart';

final class RustFlowchartBlockBuilder {
  final RustProgramView _view;
  final NodeFactory _nodes;
  final DiagramVocabulary _vocabulary;
  final RustFlowchartNodes _shapes;
  final RustFlowchartExitBlocks _exits;
  final RustFlowchartScopeBlocks _scopes;

  RustFlowchartBlockBuilder({
    required RustProgramView view,
    required NodeFactory nodes,
    required DiagramVocabulary vocabulary,
    required RustDiagramCaptions captions,
  }) : _view = view,
       _nodes = nodes,
       _vocabulary = vocabulary,
       _shapes = RustFlowchartNodes(
         view: view,
         nodes: nodes,
         vocabulary: vocabulary,
         captions: captions,
       ),
       _exits = RustFlowchartExitBlocks(
         view: view,
         nodes: nodes,
         vocabulary: vocabulary,
       ),
       _scopes = RustFlowchartScopeBlocks(
         view: view,
         nodes: nodes,
         vocabulary: vocabulary,
       );

  LayoutBlock sequence(RustViewNode body) {
    final statements = rustStatementsOf(_view, body);
    if (statements.isEmpty) return LayoutBlock.fromNode(_nodes.connector());
    return _scopes.closeScope(
      body,
      LayoutBlock.stack(statements.map(_statement).toList()),
    );
  }

  LayoutBlock _statement(RustViewNode wrapper) {
    final node = _semanticStatement(wrapper);
    return switch (rustStatementTreatment(_view, node)) {
      StatementTreatment.conditional => _conditional(wrapper, node),
      StatementTreatment.selection => _selection(wrapper, node),
      StatementTreatment.whileLoop => _while(wrapper, node),
      StatementTreatment.repeatLoop => _repeat(wrapper, node),
      StatementTreatment.countedLoop => _for(wrapper, node),
      StatementTreatment.iteration => _iteration(wrapper, node),
      StatementTreatment.taskScope => _taskScope(wrapper, node),
      StatementTreatment.receiveSelection => _receiveSelection(wrapper, node),
      StatementTreatment.returnExit => _exits.returnBlock(
        node,
        _shapes.simple(wrapper, node),
      ),
      StatementTreatment.breakExit => _exits.breakBlock(wrapper, node),
      StatementTreatment.deferral => _exits.deferBlock(
        wrapper,
        node,
        _body(node, role: 'cleanup_body'),
      ),
      StatementTreatment.call ||
      StatementTreatment.inputOutput ||
      StatementTreatment.process => _exits.withPropagation(
        node,
        _shapes.simple(wrapper, node),
      ),
      StatementTreatment.unsupported =>
        throw UnsupportedSyntaxView(rustUnsupportedKind(_view, node)),
    };
  }

  RustViewNode _semanticStatement(RustViewNode wrapper) {
    for (final child in rustChildrenOf(_view, wrapper)) {
      if (wrapper.childRoles[child.id.value] == 'statement') return child;
    }
    return wrapper;
  }

  LayoutBlock _conditional(RustViewNode wrapper, RustViewNode node) {
    final condition = _view.childForRole(node, 'condition');
    final thenBody = _view.childForRole(node, 'then_body');
    final elseBody = _view.childForRole(node, 'else_body');
    return BranchBlocks.conditional(
      decision: _shapes.decision(wrapper, condition),
      junction: _nodes.connector(),
      columns: [
        BranchColumn(
          block: _branch(thenBody),
          label: _vocabulary.affirmative,
          kind: DiagramEdgeKind.branchTrue,
        ),
        BranchColumn(
          block: _branch(elseBody),
          label: _vocabulary.negative,
          kind: DiagramEdgeKind.branchFalse,
        ),
      ],
    );
  }

  LayoutBlock _selection(RustViewNode wrapper, RustViewNode node) =>
      BranchBlocks.selection(
        selector: _shapes.selector(wrapper, _view.childForRole(node, 'selector')),
        junction: _nodes.connector(),
        columns: RustFlowchartColumns(_view, _branch).cases(node),
      );

  LayoutBlock _while(RustViewNode wrapper, RustViewNode node) =>
      _scopes.closeLoop(
        node,
        PreTestLoopBlock.compose(
          header: _shapes.decision(
            wrapper,
            _view.childForRole(node, 'condition'),
          ),
          body: _body(node),
          junction: _nodes.connector(),
          enterLabel: _vocabulary.affirmative,
          exitLabel: _vocabulary.negative,
        ),
      );

  LayoutBlock _repeat(RustViewNode wrapper, RustViewNode node) =>
      _scopes.closeLoop(
        node,
        PostTestLoopBlock.compose(
          decision: _shapes.decision(
            wrapper,
            _view.childForRole(node, 'condition'),
          ),
          body: _body(node),
          entryConnector: _nodes.connector(),
          enterLabel: _vocabulary.negative,
          exitLabel: _vocabulary.affirmative,
        ),
      );

  LayoutBlock _for(RustViewNode wrapper, RustViewNode node) =>
      _headedLoop(wrapper, node, _shapes.header(node));

  LayoutBlock _iteration(RustViewNode wrapper, RustViewNode node) =>
      _headedLoop(wrapper, node, rustHeaderLine(node));

  LayoutBlock _headedLoop(
    RustViewNode wrapper,
    RustViewNode node,
    String header,
  ) => _scopes.closeLoop(
    node,
    PreTestLoopBlock.compose(
      header: _nodes.create(
        shape: DiagramShape.preparation,
        text: header,
        sourceLine: node.range.startLine,
        nodeId: wrapper.id,
      ),
      body: _body(node),
      junction: _nodes.connector(),
      enterLabel: null,
      exitLabel: null,
    ),
  );

  LayoutBlock _taskScope(RustViewNode wrapper, RustViewNode node) =>
      LayoutBlock.stack([
        LayoutBlock.fromNode(
          _nodes.create(
            shape: DiagramShape.preparation,
            text: rustHeaderLine(node),
            sourceLine: node.range.startLine,
            nodeId: wrapper.id,
          ),
        ),
        _body(node),
      ]);

  LayoutBlock _receiveSelection(RustViewNode wrapper, RustViewNode node) =>
      BranchBlocks.selection(
        selector: _nodes.create(
          shape: DiagramShape.decision,
          text: rustHeaderLine(node),
          sourceLine: node.range.startLine,
          nodeId: wrapper.id,
        ),
        junction: _nodes.connector(),
        columns: RustFlowchartColumns(_view, _branch).receives(node),
      );

  LayoutBlock _body(RustViewNode node, {String role = 'body'}) {
    final body = _view.childForRole(node, role);
    return body == null
        ? LayoutBlock.fromNode(_nodes.connector())
        : sequence(body);
  }

  LayoutBlock _branch(RustViewNode? body) {
    if (body == null || rustStatementsOf(_view, body).isEmpty) {
      return const LayoutBlock.lane(0.0);
    }
    return sequence(body);
  }
}
