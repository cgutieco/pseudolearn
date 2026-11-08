import '../model/program/program_run_report.dart';
import '../model/program/program_run_request.dart';

abstract interface class ProgramBatchRunner {
  ProgramRunReport run(ProgramRunRequest request);
}
