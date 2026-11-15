import 'package:equatable/equatable.dart';
import '../analysis/program_node_id.dart';
import 'target_language_id.dart';

final class ExportedProgram extends Equatable {
  final TargetLanguageId targetLanguage;
  final String sourceCode;
  final List<String> notes;
  final List<ProgramNodeId?> lineOrigins;

  const ExportedProgram({
    required this.targetLanguage,
    required this.sourceCode,
    this.notes = const [],
    this.lineOrigins = const [],
  });

  List<int> linesFor(ProgramNodeId? origin) {
    if (origin == null) return const [];
    return [
      for (var index = 0; index < lineOrigins.length; index++)
        if (lineOrigins[index] == origin) index + 1,
    ];
  }

  @override
  List<Object?> get props => [targetLanguage, sourceCode, notes, lineOrigins];
}
