import 'source_range.dart';

enum ProgramDependencyKind { importation, exportation }

enum ProgramDependencyStatus { unlinked }

final class ProgramDependency {
  final String id;
  final ProgramDependencyKind kind;
  final List<String> path;
  final String? alias;
  final ProgramDependencyStatus status;
  final String diagnosticCode;
  final SourceRange range;

  ProgramDependency({
    required this.id,
    required this.kind,
    required List<String> path,
    required this.alias,
    required this.status,
    required this.diagnosticCode,
    required this.range,
  }) : path = List.unmodifiable(path);

  String get qualifiedPath => path.join('.');
}
