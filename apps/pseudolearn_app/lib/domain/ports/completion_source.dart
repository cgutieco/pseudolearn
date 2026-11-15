import '../model/completion/completion_item.dart';
import '../model/profiles/syntax_profile_id.dart';

abstract interface class CompletionSource {
  List<CompletionItem> getCompletions(SyntaxProfileId profileId);
}
