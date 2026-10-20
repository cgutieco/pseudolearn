import 'package:pseudolearn_app/engine/rust/rust_transport.dart';

import 'see_app_assist.dart';
import 'see_app_boundary.dart';
import 'see_app_completion.dart';
import 'see_app_pace.dart';
import 'see_app_snapshot.dart';

Future<Map<String, Object?>> handleAppScenario(
  RustTransport transport,
  Map<String, Object?> request,
) async {
  final input = _object(request['input']);
  final result = switch (request['scenario']) {
    'boundary' => await runBoundaryScenario(transport, input),
    'pace' => await runPaceScenario(transport, input),
    'snapshot' => await runSnapshotScenario(transport, input),
    'completion' => await runCompletionScenario(transport, input),
    'edit_assistance' => await runEditAssistanceScenario(transport, input),
    'accept_candidate' => await runAcceptCandidateScenario(transport, input),
    'template_navigation' => await runTemplateNavigationScenario(
      transport,
      input,
    ),
    _ => {'error': 'unsupported_scenario'},
  };
  return {'kind': 'app', 'app': result};
}

Map<String, Object?> _object(Object? value) =>
    (value as Map).cast<String, Object?>();
