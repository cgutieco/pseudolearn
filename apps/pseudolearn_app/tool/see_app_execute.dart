import 'package:pseudolearn_app/engine/rust/rust_transport.dart';

Map<String, Object?> executeThroughTransport(
  RustTransport transport,
  Map<String, Object?> request,
) {
  final created =
      transport.call('create_analysis', request) as Map<String, Object?>;
  final document = created['document'];
  try {
    final report =
        transport.call('analysis', {'resource': created['resource']})
            as Map<String, Object?>;
    final diagnostics = (report['diagnostics'] as List<Object?>)
        .cast<Map<String, Object?>>();
    if (report['tree'] != true ||
        diagnostics.any((diagnostic) => diagnostic['severity'] == 'error')) {
      return {
        'kind': 'execute',
        'output': '',
        'termination': {'kind': 'failed', 'code': 'analysisFailed'},
        'diagnostics': diagnostics,
        'events': <Object?>[],
        'inputs_consumed': 0,
      };
    }
    final started =
        transport.call('start', {...request, 'analysis': created['resource']})
            as Map<String, Object?>;
    final result = _drain(transport, started['resource']);
    if (request['include_program_view'] == true) {
      result['program_view'] = transport.call('program_view', {
        'resource': document,
      });
    }
    return result;
  } finally {
    transport.call('release', {'resource': document});
  }
}

Map<String, Object?> _drain(RustTransport transport, Object? execution) {
  final events = <Object?>[];
  while (true) {
    final batch =
        transport.call('advance', {'resource': execution, 'batch_size': 256})
            as Map<String, Object?>;
    events.addAll(batch['events'] as List<Object?>);
    if ((batch['termination'] as Map<String, Object?>)['kind'] != 'running') {
      return {...batch, 'kind': 'execute', 'events': events};
    }
  }
}
