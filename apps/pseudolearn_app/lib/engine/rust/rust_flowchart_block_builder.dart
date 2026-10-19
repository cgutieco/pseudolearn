import '../../domain/model/diagram/diagram_scene.dart';
import '../diagram/branch_blocks.dart';
import '../diagram/diagram_vocabulary.dart';
import '../diagram/layout_block.dart';
import '../diagram/node_factory.dart';
import '../diagram/post_test_loop_block.dart';
import '../diagram/pre_test_loop_block.dart';
import 'rust_program_view.dart';

final class RustFlowchartBlockBuilder {
  final RustProgramView _view;
  final NodeFactory _nodes;
  final DiagramVocabulary _vocabulary;

  const RustFlowchartBlockBuilder({
    required RustProgramView view,
    required NodeFactory nodes,
    required DiagramVocabulary vocabulary,
  }) : _view = view,
       _nodes = nodes,
       _vocabulary = vocabulary;

  LayoutBlock sequence(RustViewNode body) {
    final statements = rustChildrenOf(
      _view,
      body,
    ).where((node) => node.syntaxKind == 'statement').toList();
    if (statements.isEmpty) return LayoutBlock.fromNode(_nodes.connector());
    return LayoutBlock.stack(statements.map(_statement).toList());
  }

  LayoutBlock _statement(RustViewNode wrapper) {
    final node = _semanticStatement(wrapper);
    return switch (node.syntaxKind) {
      'conditional' => _conditional(wrapper, node),
      'switch' => _selection(wrapper, node),
      'while_loop' => _while(wrapper, node),
      'repeat_loop' => _repeat(wrapper, node),
      'for_loop' => _for(wrapper, node),
      'return_statement' => LayoutBlock.fromNode(
        _simpleNode(wrapper, node),
        hasExit: false,
      ),
      _ => LayoutBlock.fromNode(_simpleNode(wrapper, node)),
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
      decision: _decision(wrapper, condition),
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

  LayoutBlock _selection(RustViewNode wrapper, RustViewNode node) {
    final columns = <BranchColumn>[];
    for (final branch in rustChildrenForRole(_view, node, 'case')) {
      final labels = _view.childForRole(branch, 'labels');
      columns.add(
        BranchColumn(
          block: _branch(_view.childForRole(branch, 'body')),
          label: _caption(labels),
          kind: DiagramEdgeKind.branchCase,
        ),
      );
    }
    final defaultCase = _view.childForRole(node, 'default_case');
    if (defaultCase != null) {
      columns.add(
        BranchColumn(
          block: _branch(_view.childForRole(defaultCase, 'body')),
          label: _firstLine(defaultCase.text).replaceAll(':', '').trim(),
          kind: DiagramEdgeKind.branchCase,
        ),
      );
    }
    return BranchBlocks.selection(
      selector: _decision(wrapper, _view.childForRole(node, 'selector')),
      junction: _nodes.connector(),
      columns: columns.isEmpty ? [_emptyCase()] : columns,
    );
  }

  LayoutBlock _while(RustViewNode wrapper, RustViewNode node) =>
      PreTestLoopBlock.compose(
        header: _decision(wrapper, _view.childForRole(node, 'condition')),
        body: _body(node),
        junction: _nodes.connector(),
        enterLabel: _vocabulary.affirmative,
        exitLabel: _vocabulary.negative,
      );

  LayoutBlock _repeat(RustViewNode wrapper, RustViewNode node) =>
      PostTestLoopBlock.compose(
        decision: _decision(wrapper, _view.childForRole(node, 'condition')),
        body: _body(node),
        entryConnector: _nodes.connector(),
        enterLabel: _vocabulary.negative,
        exitLabel: _vocabulary.affirmative,
      );

  LayoutBlock _for(RustViewNode wrapper, RustViewNode node) =>
      PreTestLoopBlock.compose(
        header: _nodes.create(
          shape: DiagramShape.preparation,
          text: _header(node),
          sourceLine: node.range.startLine,
          nodeId: wrapper.id,
        ),
        body: _body(node),
        junction: _nodes.connector(),
        enterLabel: null,
        exitLabel: null,
      );

  DiagramNode _decision(RustViewNode owner, RustViewNode? condition) =>
      _nodes.create(
        shape: DiagramShape.decision,
        text: _vocabulary.asQuestion(_caption(condition)),
        sourceLine: owner.range.startLine,
        nodeId: owner.id,
      );

  DiagramNode _simpleNode(RustViewNode wrapper, RustViewNode node) =>
      _nodes.create(
        shape: _shape(node),
        text: _caption(node),
        sourceLine: node.range.startLine,
        nodeId: wrapper.id,
      );

  DiagramShape _shape(RustViewNode node) => switch (node.syntaxKind) {
    'input' || 'output' => DiagramShape.inputOutput,
    'call_statement' => DiagramShape.subprogram,
    'return_statement' => DiagramShape.startEnd,
    _ => DiagramShape.process,
  };

  LayoutBlock _body(RustViewNode node) {
    final body = _view.childForRole(node, 'body');
    return body == null
        ? LayoutBlock.fromNode(_nodes.connector())
        : sequence(body);
  }

  LayoutBlock _branch(RustViewNode? body) {
    if (body == null ||
        !rustChildrenOf(
          _view,
          body,
        ).any((child) => child.syntaxKind == 'statement')) {
      return const LayoutBlock.lane(0.0);
    }
    return sequence(body);
  }

  BranchColumn _emptyCase() => BranchColumn(
    block: const LayoutBlock.lane(0.0),
    label: '',
    kind: DiagramEdgeKind.branchCase,
  );

  String _header(RustViewNode node) {
    final parts = rustChildrenForRole(_view, node, 'loop_header');
    if (parts.isEmpty) return _caption(node);
    return parts.map(_caption).join(' ');
  }

  String _caption(RustViewNode? node) {
    if (node == null) return '';
    final text = node.text.replaceAll('\n', ' ').trim();
    return text.endsWith(';')
        ? text.substring(0, text.length - 1).trimRight()
        : text;
  }

  String _firstLine(String text) => text.split('\n').first.trim();
}
