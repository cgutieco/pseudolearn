import 'package:equatable/equatable.dart';
import 'export_blocker.dart';
import 'exported_program.dart';

sealed class ExportResult extends Equatable {
  const ExportResult();
}

final class ExportSuccess extends ExportResult {
  final ExportedProgram program;

  const ExportSuccess(this.program);

  @override
  List<Object?> get props => [program];
}

final class ExportUnavailable extends ExportResult {
  final String reason;
  final List<ExportBlocker> blockers;

  const ExportUnavailable(this.reason, {this.blockers = const []});

  @override
  List<Object?> get props => [reason, blockers];
}

final class ExportAnalysisError extends ExportResult {
  const ExportAnalysisError();

  @override
  List<Object?> get props => [];
}
