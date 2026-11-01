import '../../domain/model/diagram/diagram_metrics.dart';
import '../../domain/model/diagram/structogram_metrics.dart';
import '../diagram/diagram_vocabulary.dart';
import '../diagram/text_metrics.dart';
import '../structogram/structogram_cell.dart';
import 'rust_caption_text.dart';
import 'rust_diagram_captions.dart';
import 'rust_program_view.dart';
import 'rust_statement_treatment.dart';
import 'rust_task_nodes.dart';

final class RustStructogramCellBuilder {
  final RustProgramView _view;
  final DiagramVocabulary _vocabulary;
  final TextMetrics _text;
  final RustDiagramCaptions _captions;

  const RustStructogramCellBuilder({
    required RustProgramView view,
    required DiagramVocabulary vocabulary,
    required RustDiagramCaptions captions,
    TextMetrics text = const TextMetrics(),
  }) : _view = view,
       _vocabulary = vocabulary,
       _captions = captions,
       _text = text;

  StructogramCell buildBody(RustViewNode body) {
    final statements = rustStatementsOf(_view, body);
    if (statements.isEmpty) return _emptyCell();
    return StructogramStack([
      for (final statement in statements) _statement(statement),
    ]);
  }

  StructogramCell _statement(RustViewNode wrapper) {
    final node = _semanticStatement(wrapper);
    return switch (rustStatementTreatment(_view, node)) {
      StatementTreatment.conditional => _conditional(wrapper, node),
      StatementTreatment.selection => _selection(wrapper, node),
      StatementTreatment.whileLoop ||
      StatementTreatment.countedLoop => _preTestLoop(wrapper, node),
      StatementTreatment.iteration => _iteration(wrapper, node),
      StatementTreatment.repeatLoop => _postTestLoop(wrapper, node),
      StatementTreatment.taskScope => _taskScope(wrapper, node),
      StatementTreatment.receiveSelection => _receiveSelection(wrapper, node),
      StatementTreatment.returnExit ||
      StatementTreatment.call ||
      StatementTreatment.inputOutput ||
      StatementTreatment.process => _leaf(wrapper, node),
      StatementTreatment.unsupported => throw UnsupportedSyntaxView(
        rustUnsupportedKind(_view, node),
      ),
    };
  }

  RustViewNode _semanticStatement(RustViewNode wrapper) {
    for (final child in rustChildrenOf(_view, wrapper)) {
      if (wrapper.childRoles[child.id.value] == 'statement') return child;
    }
    return wrapper;
  }

  StructogramCell _conditional(RustViewNode wrapper, RustViewNode node) =>
      StructogramBranch(
        headerLines: _wrap(_question(_view.childForRole(node, 'condition'))),
        isBinary: true,
        nodeId: wrapper.id,
        sourceLine: wrapper.range.startLine,
        columns: [
          StructogramColumn(
            label: _vocabulary.affirmative,
            body: _branch(_view.childForRole(node, 'then_body')),
          ),
          StructogramColumn(
            label: _vocabulary.negative,
            body: _branch(_view.childForRole(node, 'else_body')),
          ),
        ],
      );

  StructogramCell _selection(RustViewNode wrapper, RustViewNode node) {
    final columns = <StructogramColumn>[];
    for (final branch in rustChildrenForRole(_view, node, 'case')) {
      columns.add(
        StructogramColumn(
          label: rustCaptionOf(_view.childForRole(branch, 'labels')),
          body: _branch(_view.childForRole(branch, 'body')),
        ),
      );
    }
    final defaultCase = _view.childForRole(node, 'default_case');
    if (defaultCase != null) {
      columns.add(
        StructogramColumn(
          label: rustFirstLine(defaultCase.text).replaceAll(':', '').trim(),
          body: _branch(_view.childForRole(defaultCase, 'body')),
        ),
      );
    }
    return StructogramBranch(
      headerLines: _wrap(
        _captions.selector(rustCaptionOf(_view.childForRole(node, 'selector'))),
      ),
      isBinary: false,
      nodeId: wrapper.id,
      sourceLine: wrapper.range.startLine,
      columns: columns.isEmpty ? [_emptyColumn()] : columns,
    );
  }

  StructogramCell _preTestLoop(RustViewNode wrapper, RustViewNode node) =>
      StructogramLoop(
        headerLines: _wrap(
          node.syntaxKind == 'for_loop'
              ? _header(node)
              : _question(_view.childForRole(node, 'condition')),
        ),
        position: StructogramLoopPosition.header,
        nodeId: wrapper.id,
        sourceLine: wrapper.range.startLine,
        body: _body(node),
      );

  StructogramCell _postTestLoop(RustViewNode wrapper, RustViewNode node) =>
      StructogramLoop(
        headerLines: _wrap(_question(_view.childForRole(node, 'condition'))),
        position: StructogramLoopPosition.footer,
        nodeId: wrapper.id,
        sourceLine: wrapper.range.endLine,
        body: _body(node),
      );

  StructogramCell _iteration(RustViewNode wrapper, RustViewNode node) =>
      StructogramLoop(
        headerLines: _wrap(rustHeaderLine(node)),
        position: StructogramLoopPosition.header,
        nodeId: wrapper.id,
        sourceLine: wrapper.range.startLine,
        body: _body(node),
      );

  StructogramCell _taskScope(RustViewNode wrapper, RustViewNode node) =>
      StructogramLoop(
        headerLines: _wrap(rustHeaderLine(node)),
        position: StructogramLoopPosition.header,
        nodeId: wrapper.id,
        sourceLine: wrapper.range.startLine,
        body: _body(node),
      );

  StructogramCell _receiveSelection(RustViewNode wrapper, RustViewNode node) {
    final columns = [
      for (final branch in rustChildrenForRole(_view, node, 'branch'))
        StructogramColumn(
          label: rustHeaderLine(branch),
          body: _branch(_view.childForRole(branch, 'body')),
        ),
    ];
    return StructogramBranch(
      headerLines: _wrap(rustHeaderLine(node)),
      isBinary: false,
      nodeId: wrapper.id,
      sourceLine: wrapper.range.startLine,
      columns: columns.isEmpty ? [_emptyColumn()] : columns,
    );
  }

  StructogramCell _leaf(RustViewNode wrapper, RustViewNode node) =>
      StructogramLeaf(
        kind: switch (node.syntaxKind) {
          'call_statement' => StructogramLeafKind.call,
          'return_statement' => StructogramLeafKind.exit,
          _ when rustNodeIsTaskOperation(_view, node) =>
            StructogramLeafKind.call,
          _ => StructogramLeafKind.process,
        },
        lines: _wrap(rustCaptionOf(node)),
        nodeId: wrapper.id,
        sourceLine: wrapper.range.startLine,
      );

  StructogramCell _body(RustViewNode node) {
    final body = _view.childForRole(node, 'body');
    return body == null ? _emptyCell() : buildBody(body);
  }

  StructogramCell _branch(RustViewNode? body) {
    if (body == null) return _emptyCell();
    final hasStatements = rustStatementsOf(_view, body).isNotEmpty;
    return hasStatements ? buildBody(body) : _emptyCell();
  }

  StructogramColumn _emptyColumn() =>
      StructogramColumn(label: '', body: _emptyCell());

  StructogramCell _emptyCell() => StructogramLeaf(
    kind: StructogramLeafKind.empty,
    lines: _wrap(_vocabulary.emptyCell),
  );

  String _header(RustViewNode node) {
    final parts = rustChildrenForRole(_view, node, 'loop_header');
    if (parts.isEmpty) return rustCaptionOf(node);
    return _captions.loopHeader(parts.map(rustCaptionOf).toList());
  }

  String _question(RustViewNode? condition) =>
      _vocabulary.asQuestion(rustCaptionOf(condition));


  List<String> _wrap(String text) => _text.wrapText(
    text,
    maxUnits:
        (StructogramMetrics.cellMaxTextWidth -
            StructogramMetrics.cellPadding * 2) /
        DiagramMetrics.fontSize,
    maxLines: DiagramMetrics.maxTextLines,
  );
}
