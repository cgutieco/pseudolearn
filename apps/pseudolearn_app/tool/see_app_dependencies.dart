import 'package:pseudolearn_app/composition/rust_engine_services.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_dependency.dart';
import 'package:pseudolearn_app/domain/model/export/export_result.dart';
import 'package:pseudolearn_app/domain/model/export/target_language_id.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_view_source.dart';
import 'package:pseudolearn_app/engine/rust/rust_transport.dart';

const Set<String> _staticOperations = {
  'create_analysis',
  'create_document',
  'analysis',
  'program_view',
  'release',
  'editor_vocabulary',
};

Future<Map<String, Object?>> runDependenciesScenario(
  RustTransport transport,
  Map<String, Object?> input,
) async {
  final program = input['program'] as String;
  final english = input['profile'] == 'en';
  final profile = english
      ? SyntaxProfileId.english
      : SyntaxProfileId.classicSpanish;
  final language = english ? UiLanguageId.english : UiLanguageId.spanish;
  final recorder = _OperationRecorder(transport);
  final services = buildRustEngineServices(recorder);
  final view = RustProgramViewSource(
    recorder,
  ).loadStructure(sourceCode: program, profileId: profile, languageId: language);
  final execution = buildRustEngineServices(
    transport,
  ).createProgramExecution().startExecution(
    sourceCode: program,
    profileId: profile,
    languageId: language,
  );
  final export = services.programExporter.export(
    sourceCode: program,
    targetLanguage: TargetLanguageId.python,
    profileId: profile,
  );
  return {
    'structure': view != null,
    'dependencies': [
      for (final dependency in view?.dependencies ?? <ProgramDependency>[])
        {
          'kind': dependency.kind.name,
          'path': dependency.path,
          'alias': dependency.alias,
          'status': dependency.status.name,
          'diagnostic': dependency.diagnosticCode,
          'text': program.substring(
            dependency.range.startOffset,
            dependency.range.endOffset,
          ),
        },
    ],
    'units': [for (final unit in view?.units ?? []) unit.name],
    'execution_started': !execution.isHalted,
    'export_available': export is ExportSuccess,
    'operations_beyond_static': recorder.operations
        .toSet()
        .difference(_staticOperations)
        .toList(),
  };
}

final class _OperationRecorder implements RustTransport {
  final RustTransport _inner;
  final List<String> operations = [];

  _OperationRecorder(this._inner);

  @override
  Object? call(String operation, Map<String, Object?> arguments) {
    operations.add(operation);
    return _inner.call(operation, arguments);
  }

  @override
  void close() {}
}
