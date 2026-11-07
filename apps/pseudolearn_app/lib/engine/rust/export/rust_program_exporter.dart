import '../../../domain/model/analysis/program_node_id.dart';
import '../../../domain/model/export/export_blocker.dart';
import '../../../domain/model/export/export_result.dart';
import '../../../domain/model/export/exported_program.dart';
import '../../../domain/model/export/target_language_id.dart';
import '../../../domain/model/profiles/syntax_profile_id.dart';
import '../../../domain/ports/program_exporter.dart';
import '../../export/target_code_header.dart';
import '../rust_profile_name.dart';
import '../rust_program_view.dart';
import '../rust_program_view_source.dart';
import '../rust_transport.dart';

final class RustProgramExporter implements ProgramExporter {
  final RustTransport _transport;
  final RustProgramViewSource _views;

  RustProgramExporter(this._transport)
    : _views = RustProgramViewSource(_transport);

  @override
  ExportResult export({
    required String sourceCode,
    required TargetLanguageId targetLanguage,
    required SyntaxProfileId profileId,
  }) {
    final view = _views.load(sourceCode: sourceCode, profileId: profileId);
    if (view == null) return const ExportAnalysisError();
    final created =
        _transport.call('create_document', {
              'program': sourceCode,
              'profile': rustProfileName(profileId),
            })
            as Map<String, Object?>;
    final document = created['resource'] as int;
    try {
      final result =
          _transport.call('equivalent_code', {
                'resource': document,
                'target': targetLanguage.id,
              })
              as Map<String, Object?>;
      return _resultOf(result, view: view, targetLanguage: targetLanguage);
    } finally {
      _transport.call('release', {'resource': document});
    }
  }

  ExportResult _resultOf(
    Map<String, Object?> result, {
    required RustProgramView view,
    required TargetLanguageId targetLanguage,
  }) => switch (result['status']) {
    'ready' => ExportSuccess(_program(result, targetLanguage)),
    'unavailable' => ExportUnavailable('', blockers: _blockers(result, view)),
    _ => const ExportAnalysisError(),
  };

  ExportedProgram _program(
    Map<String, Object?> result,
    TargetLanguageId targetLanguage,
  ) {
    final code = (result['code'] as String).trimRight();
    final origins = (result['line_origins'] as List<Object?>)
        .map((origin) => origin is String ? _nodeOf(origin) : null)
        .toList();
    return ExportedProgram(
      targetLanguage: targetLanguage,
      sourceCode: '${targetCodeHeader(targetLanguage)}\n$code',
      lineOrigins: List.unmodifiable([null, ...origins]),
    );
  }

  List<ExportBlocker> _blockers(
    Map<String, Object?> result,
    RustProgramView view,
  ) {
    final blockers = <ExportBlocker>[];
    for (final entry in result['blockers'] as List<Object?>) {
      final blocker = entry as Map<String, Object?>;
      final identifier = blocker['node_id'];
      if (identifier is! String) continue;
      final origin = _nodeOf(identifier);
      final node = view.nodeById(origin);
      if (node == null) continue;
      blockers.add(
        ExportBlocker(
          construct: blocker['construct'] as String,
          origin: origin,
          range: node.range,
        ),
      );
    }
    return blockers;
  }

  ProgramNodeId _nodeOf(String identifier) => ProgramNodeId(
    int.parse(
      identifier.substring(identifier.lastIndexOf('.n') + 2),
      radix: 16,
    ),
  );
}
