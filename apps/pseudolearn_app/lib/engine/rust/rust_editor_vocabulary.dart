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
}
