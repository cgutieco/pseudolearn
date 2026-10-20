import '../../domain/model/completion/completion_item.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/ports/completion_source.dart';
import 'rust_profile_name.dart';
import 'rust_transport.dart';

final class RustTemplateSource implements CompletionSource {
  final RustTransport _transport;

  const RustTemplateSource(this._transport);

  @override
  List<CompletionItem> getCompletions(SyntaxProfileId profileId) {
    try {
      final response =
          _transport.call('completion_templates', {
                'profile': rustProfileName(profileId),
              })
              as Map<String, Object?>;
      final rows = response['templates'] as List<Object?>;
      return [for (final row in rows) _templateOf(row as Map<String, Object?>)];
    } catch (_) {
      return const [];
    }
  }

  CompletionItem _templateOf(Map<String, Object?> row) {
    final family = switch (row['family']) {
      'procedural' => CompletionFamily.procedural,
      'oop' => CompletionFamily.oop,
      _ => CompletionFamily.structured,
    };
    return CompletionItem(
      label: row['label'] as String,
      template: row['template'] as String,
      caretOffset: row['caret_offset'] as int,
      family: family,
      construction: row['construction'] as String?,
    );
  }
}
