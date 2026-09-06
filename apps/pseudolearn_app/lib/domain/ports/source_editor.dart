import '../model/editor/caret_range.dart';
import '../model/editor/editor_key.dart';
import '../model/editor/source_edit.dart';
import '../model/profiles/syntax_profile_id.dart';

abstract interface class SourceEditor {
  SourceEdit applyKey({
    required String sourceCode,
    required CaretRange caret,
    required EditorKey key,
    required SyntaxProfileId profileId,
    required int revision,
  });
}
