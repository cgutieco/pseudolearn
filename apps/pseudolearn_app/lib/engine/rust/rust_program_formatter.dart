import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/program/program_text_result.dart';
import '../../domain/ports/program_formatter.dart';
import 'rust_profile_name.dart';
import 'rust_transport.dart';

final class RustProgramFormatter implements ProgramFormatter {
  static const String _documentUri = 'file:///agent.pseudo';

  final RustTransport _transport;

  const RustProgramFormatter(this._transport);

  @override
  ProgramTextResult format({
    required String sourceCode,
    required SyntaxProfileId profileId,
  }) {
    try {
      final created = _transport.call('create_lsp', const <String, Object?>{}) as Map<String, Object?>;
      final resource = created['resource'] as int;
      try {
        return _formatWith(resource, sourceCode, rustProfileName(profileId));
      } finally {
        _transport.call('release', {'resource': resource});
      }
    } on RustBridgeFailure catch (failure) {
      return ProgramTextRefused(
        ProgramTextFailure.rejected,
        detail: failure.detail,
      );
    }
  }

  ProgramTextResult _formatWith(int resource, String source, String locale) {
    _message(resource, {
      'jsonrpc': '2.0',
      'id': 1,
      'method': 'initialize',
      'params': {'locale': locale},
    });
    _message(resource, {
      'jsonrpc': '2.0',
      'method': 'textDocument/didOpen',
      'params': {
        'textDocument': {
          'uri': _documentUri,
          'languageId': 'pseudolearn',
          'version': 1,
          'text': source,
        },
      },
    });
    final answers = _message(resource, {
      'jsonrpc': '2.0',
      'id': 2,
      'method': 'textDocument/formatting',
      'params': {
        'textDocument': {'uri': _documentUri},
        'options': <String, Object?>{},
      },
    });
    return _resultOf(answers, source);
  }

  List<Object?> _message(int resource, Map<String, Object?> message) {
    final reply = _transport.call('lsp_message', {
      'resource': resource,
      'message': message,
    });
    final messages = reply is Map<String, Object?> ? reply['messages'] : null;
    return messages is List<Object?> ? messages : const [];
  }

  ProgramTextResult _resultOf(List<Object?> answers, String source) {
    for (final answer in answers) {
      if (answer is! Map<String, Object?> || answer['id'] != 2) continue;
      final edits = answer['result'];
      if (edits is List<Object?> && edits.isNotEmpty) {
        final first = edits.first;
        final text = first is Map<String, Object?> ? first['newText'] : null;
        if (text is String) return ProgramTextProduced(text);
      }
      return const ProgramTextRefused(ProgramTextFailure.unchanged);
    }
    return const ProgramTextRefused(ProgramTextFailure.rejected);
  }
}
