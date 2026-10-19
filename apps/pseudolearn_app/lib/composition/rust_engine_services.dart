import '../domain/ports/program_analyzer.dart';
import '../domain/ports/program_execution.dart';
import '../engine/rust/rust_analysis_api.dart';
import '../engine/rust/rust_program_analyzer.dart';
import '../engine/rust/rust_program_execution.dart';
import '../engine/rust/rust_transport.dart';

final class RustEngineServices {
  final ProgramAnalyzer analyzer;
  final ProgramExecution Function() createProgramExecution;

  const RustEngineServices({
    required this.analyzer,
    required this.createProgramExecution,
  });
}

RustEngineServices buildRustEngineServices(RustTransport transport) {
  return RustEngineServices(
    analyzer: RustProgramAnalyzer(RustAnalysisApi(transport)),
    createProgramExecution: () => RustProgramExecution(transport),
  );
}
