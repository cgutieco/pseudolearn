import 'rust_program_view.dart';

enum RustProgramViewReadFailureKind {
  bridgeFailure,
  analysisRejected,
  missingField,
  malformedField,
  duplicateNodeId,
  missingReference,
  foreignReference,
  invalidSpan,
}

sealed class RustProgramViewReadResult {
  const RustProgramViewReadResult();

  RustProgramView? get view;
}

final class RustProgramViewReadSuccess extends RustProgramViewReadResult {
  @override
  final RustProgramView view;

  const RustProgramViewReadSuccess(this.view);
}

final class RustProgramViewReadFailure extends RustProgramViewReadResult {
  final RustProgramViewReadFailureKind kind;
  final String path;

  const RustProgramViewReadFailure({required this.kind, required this.path});

  @override
  RustProgramView? get view => null;
}
