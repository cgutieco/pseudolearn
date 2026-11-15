import '../../domain/model/profiles/syntax_profile_id.dart';
import 'rust_editor_vocabulary.dart';
import 'rust_transport.dart';

final class RustDiagramCaptions {
  final Map<String, String> _keywords;

  const RustDiagramCaptions(this._keywords);

  factory RustDiagramCaptions.load(
    RustEditorVocabulary vocabulary,
    SyntaxProfileId profileId,
  ) {
    try {
      final words =
          vocabulary.forProfile(profileId)['keywords'] as List<Object?>;
      return RustDiagramCaptions({
        for (final pair in words)
          (pair as List<Object?>)[0] as String: pair[1] as String,
      });
    } on RustBridgeFailure {
      return const RustDiagramCaptions({});
    }
  }

  String selector(String text) => '${_word('switchKeyword')} $text';

  String loopHeader(List<String> parts) {
    if (parts.length < 3) return parts.join(' ');
    final step = parts.length > 3 ? ' ${_word('step')} ${parts[3]}' : '';
    return '${parts[0]} ${_word('assignment')} ${parts[1]} '
        '${_word('to')} ${parts[2]}$step';
  }

  String _word(String identity) => _keywords[identity] ?? identity;
}
