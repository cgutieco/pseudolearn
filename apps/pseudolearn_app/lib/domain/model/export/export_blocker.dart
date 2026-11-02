import 'package:equatable/equatable.dart';
import '../analysis/program_node_id.dart';
import '../analysis/source_range.dart';

final class ExportBlocker extends Equatable {
  final String construct;
  final ProgramNodeId origin;
  final SourceRange range;

  const ExportBlocker({
    required this.construct,
    required this.origin,
    required this.range,
  });

  @override
  List<Object?> get props => [
    construct,
    origin,
    range.startOffset,
    range.endOffset,
  ];
}
