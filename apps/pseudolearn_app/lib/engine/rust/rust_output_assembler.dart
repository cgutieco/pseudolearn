import '../../domain/model/execution/output_line.dart';

final class RustOutputAssembler {
  final List<OutputLine> lines = [];
  bool _hasOpenLine = false;

  void append(String text) {
    if (text.isEmpty) return;
    final parts = text.split('\n');
    for (var index = 0; index < parts.length; index++) {
      _appendPart(parts[index], index == parts.length - 1, index > 0);
    }
  }

  void echoInput(String rawText) {
    _hasOpenLine = false;
    lines.add(OutputLine(text: rawText, kind: OutputLineKind.userInputEcho));
  }

  void _appendPart(String part, bool isLastPart, bool isAfterNewline) {
    if (isAfterNewline) _hasOpenLine = false;
    if (part.isEmpty && isLastPart) return;
    final canJoin =
        _hasOpenLine &&
        lines.isNotEmpty &&
        lines.last.kind == OutputLineKind.programOutput;
    if (canJoin) {
      lines[lines.length - 1] = OutputLine(
        text: lines.last.text + part,
        kind: OutputLineKind.programOutput,
      );
    } else {
      lines.add(OutputLine(text: part, kind: OutputLineKind.programOutput));
    }
    _hasOpenLine = isLastPart;
  }
}
