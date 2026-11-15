import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/program/program_text_result.dart';
import '../../domain/ports/program_translator.dart';
import 'rust_profile_name.dart';
import 'rust_transport.dart';

final class RustProgramTranslator implements ProgramTranslator {
  final RustTransport _transport;

  const RustProgramTranslator(this._transport);

  @override
  ProgramTextResult translate({
    required String sourceCode,
    required SyntaxProfileId targetProfile,
  }) {
    try {
      final reply = _transport.call('translate', {
        'program': sourceCode,
        'target_profile': rustProfileName(targetProfile),
      });
      final text = reply is Map<String, Object?> ? reply['text'] : null;
      return text is String
          ? ProgramTextProduced(text)
          : const ProgramTextRefused(ProgramTextFailure.rejected);
    } on RustBridgeFailure catch (failure) {
      return ProgramTextRefused(
        ProgramTextFailure.rejected,
        detail: failure.detail,
      );
    }
  }
}
