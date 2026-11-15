import '../../domain/model/profiles/syntax_profile_id.dart';
import 'rust_profile_name.dart';
import 'rust_transport.dart';

final class RustEditorVocabulary {
  final RustTransport _transport;

  const RustEditorVocabulary(this._transport);

  Map<String, Object?> forProfile(SyntaxProfileId profileId) =>
      _transport.call('editor_vocabulary', {
            'profile': rustProfileName(profileId),
          })
          as Map<String, Object?>;
  String receiverName(SyntaxProfileId profileId) {
    try {
      final words = forProfile(profileId)['keywords'] as List<Object?>;
      for (final raw in words) {
        final pair = raw as List<Object?>;
        if (pair.first == 'thisObject') return pair.last as String;
      }
    } on Object {
      return 'thisObject';
    }
    return 'thisObject';
  }
}
