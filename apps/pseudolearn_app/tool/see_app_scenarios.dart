import 'package:pseudolearn_app/engine/rust/rust_transport.dart';

import 'see_app_assist.dart';
import 'see_app_boundary.dart';
import 'see_app_class_diagram.dart';
import 'see_app_completion.dart';
import 'see_app_control_flow.dart';
import 'see_app_dependencies.dart';
import 'see_app_export_support.dart';
import 'see_app_help.dart';
import 'see_app_pace.dart';
import 'see_app_snapshot.dart';
import 'see_app_syntax_coverage.dart';

Future<Map<String, Object?>> handleAppScenario(
  RustTransport transport,
  Map<String, Object?> request,
) async {
  final input = _object(request['input']);
  final result = switch (request['scenario']) {
    'boundary' => await runBoundaryScenario(transport, input),
    'pace' => await runPaceScenario(transport, input),
    'snapshot' => await runSnapshotScenario(transport, input),
    'class_diagram' => await runClassDiagramScenario(transport, input),
    'control_flow' => await runControlFlowScenario(transport, input),
    'export_support' => await runExportSupportScenario(transport, input),
    'dependencies' => await runDependenciesScenario(transport, input),
    'syntax_coverage' => await runSyntaxCoverageScenario(input),
    'completion' => await runCompletionScenario(transport, input),
    'edit_assistance' => await runEditAssistanceScenario(transport, input),
    'accept_candidate' => await runAcceptCandidateScenario(transport, input),
    'template_navigation' => await runTemplateNavigationScenario(
      transport,
      input,
    ),
    'help' => await runHelpScenario(transport, input),
    'help_revision' => await runHelpRevisionScenario(transport, input),
    _ => {'error': 'unsupported_scenario'},
  };
  return {'kind': 'app', 'app': result};
}

Map<String, Object?> _object(Object? value) =>
    (value as Map).cast<String, Object?>();
