import 'dart:convert';

import '../../domain/model/execution/output_line.dart';
import '../../domain/model/execution/read_request.dart';
import 'rust_execution_readers.dart';
import 'rust_output_assembler.dart';
import 'rust_program_view.dart';
import 'rust_read_request_tracker.dart';
import 'rust_wire_models.dart';
import 'source_offset_index.dart';

final class RustExecutionEventEffects {
  RustOutputAssembler _output = RustOutputAssembler();
  final RustReadRequestTracker _reads = RustReadRequestTracker();
  int _outputBytes = 0;

  List<OutputLine> get outputLines => List.unmodifiable(_output.lines);

  ReadRequest? get readRequest => _reads.request;

  void clear() {
    _output = RustOutputAssembler();
    _reads.clear();
    _outputBytes = 0;
  }

  void submitInput(String text) => _reads.submit(text);

  void record(
    RustEvent event,
    RustProgramView view,
    SourceOffsetIndex offsets, {
    List<(int, int)> errorRanges = const [],
    String? rejectionMessage,
  }) {
    switch (event.eventClass) {
      case 'output':
        _recordOutput('${event.data['texto']}', errorRanges);
      case 'statement_entered':
        _reads.enter(event);
      case 'input_received':
        _recordReceived('${event.data['texto']}');
      case 'input_requested':
        _recordRequested(
          _reads.open(
            event,
            readStatementSourceOf(view, offsets, event),
            rejectionMessage,
          ),
        );
    }
  }

  void _recordReceived(String text) {
    final answered = _reads.receive();
    _output.echoInput(
      text,
      target: answered?.designator,
      sourceLine: answered?.line,
    );
  }

  void _recordRequested(ReadRequest request) {
    final rejected = request.rejection?.rejectedText;
    if (rejected == null) return;
    _output.rejectInput(
      rejected,
      target: request.designator,
      sourceLine: request.line,
    );
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
