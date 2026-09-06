import '../../domain/model/analysis/program_node_id.dart';
import '../../domain/model/export/exported_program.dart';
import '../../domain/model/export/target_language_id.dart';

final class TargetCodeBuilder {
  final List<String> _lines = [];
  final List<ProgramNodeId?> _origins = [];
  ProgramNodeId? _origin;

  void writeln([String text = '']) {
    _lines.add(text);
    _origins.add(_origin);
  }

  void attributedTo(ProgramNodeId origin, void Function() emit) {
    final previous = _origin;
    _origin = origin;
    emit();
    _origin = previous;
  }

  ExportedProgram build(TargetLanguageId targetLanguage) {
    var end = _lines.length;
    while (end > 0 && _lines[end - 1].trim().isEmpty) {
      end--;
    }
    return ExportedProgram(
      targetLanguage: targetLanguage,
      sourceCode: _lines.take(end).join('\n'),
      lineOrigins: List.unmodifiable(_origins.take(end)),
    );
  }
}
