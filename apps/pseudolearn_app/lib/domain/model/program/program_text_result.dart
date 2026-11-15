enum ProgramTextFailure { rejected, unchanged }

sealed class ProgramTextResult {
  const ProgramTextResult();
}

final class ProgramTextProduced extends ProgramTextResult {
  final String text;

  const ProgramTextProduced(this.text);
}

final class ProgramTextRefused extends ProgramTextResult {
  final ProgramTextFailure failure;
  final String detail;

  const ProgramTextRefused(this.failure, {this.detail = ''});
}
