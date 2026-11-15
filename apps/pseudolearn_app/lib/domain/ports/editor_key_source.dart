import '../model/editor/editor_key.dart';
import '../model/profiles/syntax_profile_id.dart';

abstract interface class EditorKeySource {
  List<EditorKey> keysFor(SyntaxProfileId profileId);
}
