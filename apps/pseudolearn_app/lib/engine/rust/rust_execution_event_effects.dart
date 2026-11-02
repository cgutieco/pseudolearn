import '../../domain/model/execution/output_line.dart';
import 'rust_execution_readers.dart';
import 'rust_output_assembler.dart';
import 'rust_program_view.dart';
import 'rust_wire_models.dart';
import 'source_offset_index.dart';

final class RustExecutionEventEffects {
  RustOutputAssembler _output = RustOutputAssembler();
  String? _inputPrompt;

  List<OutputLine> get outputLines => List.unmodifiable(_output.lines);

  String? get inputPrompt => _inputPrompt;

  void clear() {
    _output = RustOutputAssembler();
    _inputPrompt = null;
  }

  void clearInputPrompt() => _inputPrompt = null;

  void record(
    RustEvent event,
    RustProgramView view,
    SourceOffsetIndex offsets,
  ) {
    switch (event.eventClass) {
      case 'output':
        _output.append('${event.data['texto']}');
      case 'input_received':
        _output.echoInput('${event.data['texto']}');
      case 'input_requested':
        _inputPrompt = inputPromptOf(view, offsets, event);
    }
  }
}
