import '../../domain/model/diagram/diagram_scene.dart';
import '../diagram/branch_blocks.dart';
import '../diagram/layout_block.dart';
import 'rust_caption_text.dart';
import 'rust_program_view.dart';
import 'rust_task_nodes.dart';

final class RustFlowchartColumns {
  final RustProgramView _view;
  final LayoutBlock Function(RustViewNode? body) _branch;

  const RustFlowchartColumns(this._view, this._branch);

  List<BranchColumn> cases(RustViewNode node) => _orEmpty([
    for (final branch in rustChildrenForRole(_view, node, 'case'))
      _column(
        _view.childForRole(branch, 'body'),
        rustCaptionOf(_view.childForRole(branch, 'labels')),
      ),
    if (_view.childForRole(node, 'default_case') case final RustViewNode other)
      _column(
        _view.childForRole(other, 'body'),
        rustFirstLine(other.text).replaceAll(':', '').trim(),
      ),
  ]);

  List<BranchColumn> receives(RustViewNode node) => _orEmpty([
    for (final branch in rustChildrenForRole(_view, node, 'branch'))
      _column(_view.childForRole(branch, 'body'), rustHeaderLine(branch)),
  ]);

  BranchColumn _column(RustViewNode? body, String label) => BranchColumn(
    block: _branch(body),
    label: label,
    kind: DiagramEdgeKind.branchCase,
  );

  List<BranchColumn> _orEmpty(List<BranchColumn> columns) => columns.isEmpty
      ? [
          BranchColumn(
            block: const LayoutBlock.lane(0.0),
            label: '',
            kind: DiagramEdgeKind.branchCase,
          ),
        ]
      : columns;
}
