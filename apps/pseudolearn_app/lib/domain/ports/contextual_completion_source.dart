import '../model/completion/completion_query_result.dart';
import '../model/profiles/syntax_profile_id.dart';

abstract interface class ContextualCompletionSource {
  CompletionQueryResult complete({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required int cursorUtf16,
    required int revision,
  });
}
