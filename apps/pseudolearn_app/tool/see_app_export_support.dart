import 'dart:async';

import 'package:pseudolearn_app/application/execution/execution_state.dart';
import 'package:pseudolearn_app/application/export/export_cubit.dart';
import 'package:pseudolearn_app/application/export/export_state.dart';
import 'package:pseudolearn_app/composition/rust_engine_services.dart';
import 'package:pseudolearn_app/domain/model/export/target_language_id.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/engine/rust/rust_transport.dart';

Future<Map<String, Object?>> runExportSupportScenario(
  RustTransport transport,
  Map<String, Object?> input,
) async {
  final english = input['profile'] == 'en';
  final profile = english
      ? SyntaxProfileId.english
      : SyntaxProfileId.classicSpanish;
  final cubit = ExportCubit(
    exporter: buildRustEngineServices(transport).programExporter,
    executionStates: const Stream<ExecutionState>.empty(),
  );
  cubit.selectLanguage(
    TargetLanguageId.fromId(input['target'] as String),
    sourceCode: input['previous'] as String? ?? '',
    profileId: profile,
  );
  cubit.updateSource(sourceCode: input['program'] as String, profileId: profile);
  final state = cubit.state;
  await cubit.close();
  return {
    'status': state.status.name,
    'constructs': ({
      for (final blocker in state.blockers) blocker.construct,
    }.toList()..sort()),
    'first_line': state.blockers.isEmpty
        ? null
        : state.blockers.first.range.startLine,
    'code_visible': state.exportedCode.isNotEmpty,
    'focused_lines': state.focusedLines.length,
    'ready': state.status == ExportStatus.ready,
  };
}
