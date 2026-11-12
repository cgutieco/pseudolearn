import 'dart:convert';

import '../../domain/model/execution/output_line.dart';
import 'rust_execution_readers.dart';
import 'rust_output_assembler.dart';
import 'rust_program_view.dart';
import 'rust_wire_models.dart';
import 'source_offset_index.dart';

final class RustExecutionEventEffects {
  RustOutputAssembler _output = RustOutputAssembler();
  String? _inputPrompt;
  int _outputBytes = 0;

  List<OutputLine> get outputLines => List.unmodifiable(_output.lines);

  String? get inputPrompt => _inputPrompt;

  void clear() {
    _output = RustOutputAssembler();
    _inputPrompt = null;
    _outputBytes = 0;
  }

  void clearInputPrompt() => _inputPrompt = null;

  void record(
    RustEvent event,
    RustProgramView view,
    SourceOffsetIndex offsets, {
    List<(int, int)> errorRanges = const [],
  }) {
    switch (event.eventClass) {
      case 'output':
        _recordOutput('${event.data['texto']}', errorRanges);
      case 'input_received':
        _output.echoInput('${event.data['texto']}');
      case 'input_requested':
        _inputPrompt = inputPromptOf(view, offsets, event);
    }
  }

  void _recordOutput(String text, List<(int, int)> errorRanges) {
    final start = _outputBytes;
    final end = start + utf8.encode(text).length;
    _outputBytes = end;
    final isError = errorRanges.any(
      (range) => start >= range.$1 && end <= range.$2,
    );
    _output.append(
      text,
      kind: isError ? OutputLineKind.programError : OutputLineKind.programOutput,
    );
  }
}
