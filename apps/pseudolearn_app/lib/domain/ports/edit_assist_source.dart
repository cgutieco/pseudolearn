import '../model/completion/assist_result.dart';
import '../model/editor/caret_range.dart';
import '../model/profiles/syntax_profile_id.dart';

abstract interface class EditAssistSource {
  AssistResult? accept({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required CaretRange replacement,
    required String label,
  });

  AssistResult? insertTemplate({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required String construction,
    required CaretRange replacement,
  });

  AssistResult? afterTyping({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required int cursorUtf16,
    required String character,
  });

  AssistResult? navigate({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required StopDirection direction,
  });

  void close();
}
