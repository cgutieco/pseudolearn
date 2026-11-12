import 'package:pseudolearn_app/application/editor/editor_state.dart';
import 'package:pseudolearn_app/composition/rust_engine_services.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/engine/rust/rust_transport.dart';

Map<String, Object?> runAssistancePresentation(
  RustTransport transport,
  Map<String, Object?> input,
) {
  final services = buildRustEngineServices(transport);
  final profile = input['profile'] == 'en'
      ? SyntaxProfileId.english
      : SyntaxProfileId.classicSpanish;
  final document = input['document'] as String;
  final listing = services.contextualCompletionSource.complete(
    sourceCode: document,
    profileId: profile,
    cursorUtf16: input['cursor_utf16'] as int,
    revision: 1,
  );
  final state =
      EditorState.initial(
        showsKeyBar: input['onscreen_capable'] == true,
      ).copyWith(
        sourceCode: document,
        keys: services.editorKeySource.keysFor(profile),
        contextualCompletions: listing.candidates,
      );
  final usesBar = state.usesSuggestionBar(
    keyboardVisible: input['keyboard_visible'] == true,
    keepsKeyBar: true,
    isExecuting: false,
  );
  return {
    'uses_suggestion_bar': usesBar,
    'allows_anchored_assistance': !usesBar,
    'insertion_preview': state.inlineCandidate?.insertionPreview,
  };
}
