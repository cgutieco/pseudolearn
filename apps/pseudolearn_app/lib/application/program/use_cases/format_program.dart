import '../../../domain/model/profiles/syntax_profile_id.dart';
import '../../../domain/model/program/program_text_result.dart';
import '../../../domain/ports/program_formatter.dart';

final class FormatProgram {
  final ProgramFormatter _formatter;

  const FormatProgram({required this._formatter});

  ProgramTextResult call({
    required String sourceCode,
    required SyntaxProfileId profileId,
  }) {
    try {
      return _formatter.format(sourceCode: sourceCode, profileId: profileId);
    } catch (error) {
      return ProgramTextRefused(ProgramTextFailure.rejected, detail: '$error');
    }
  }
}
