import '../domain/ports/program_batch_runner.dart';
import '../domain/ports/program_formatter.dart';
import '../domain/ports/program_translator.dart';

final class ProgramTools {
  final ProgramBatchRunner runner;
  final ProgramTranslator translator;
  final ProgramFormatter formatter;

  const ProgramTools({
    required this.runner,
    required this.translator,
    required this.formatter,
  });
}
