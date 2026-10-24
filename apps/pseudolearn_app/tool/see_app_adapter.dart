import 'dart:convert';
import 'dart:io';

import 'package:pseudolearn_app/engine/rust/native_rust_transport.dart';
import 'package:pseudolearn_app/engine/rust/rust_transport.dart';

import 'see_app_protocol.dart';
import 'see_app_api.dart';
import 'see_app_execute.dart';
import 'see_app_scenarios.dart';

Future<void> main() async {
  await initializeNativeBridge();
  final transport = openNativeTransport();
  await for (final line
      in stdin.transform(utf8.decoder).transform(const LineSplitter())) {
    final request = _object(jsonDecode(line));
    final kind = request['kind'];
    final response = await _responseFor(transport, request, kind);
    stdout.writeln(jsonEncode(response));
    await stdout.flush();
    if (kind == 'shutdown') return;
  }
  transport.close();
}

Future<Map<String, Object?>> _responseFor(
  RustTransport transport,
  Map<String, Object?> request,
  Object? kind,
) async {
  try {
    return switch (kind) {
      'hello' => _hello(),
      'analyze' => _analyze(transport, request),
      'execute' => executeThroughTransport(transport, request),
      'app' => await handleAppScenario(transport, request),
      'api' => executeApiRequest(transport, request),
      'shutdown' => _shutdown(transport),
      _ => {'kind': 'error', 'message': 'Unsupported operation'},
    };
  } on RustBridgeFailure catch (failure) {
    if (kind == 'app') {
      return {
        'kind': 'app',
        'app': {'error': failure.family},
      };
    }
    return {
      'kind': 'error',
      'family': failure.family,
      'message': failure.detail,
    };
  } catch (failure) {
    if (kind == 'app') {
      return {
        'kind': 'app',
        'app': {'error': 'internal', 'detail': '$failure'},
      };
    }
    return {'kind': 'error', 'family': 'internal', 'message': '$failure'};
  }
}

Map<String, Object?> _hello() => {
  'kind': 'hello',
  'protocol': seeProtocolVersion,
  'subject': 'app',
  'subject_version': '0.1.0',
  'capabilities': [
    'api',
    'app',
    'analyze',
    'execute',
    'observe',
    'program_view',
  ],
  'profiles': ['es', 'en'],
  'strictness': ['strict', 'flexible'],
};

Map<String, Object?> _analyze(
  RustTransport transport,
  Map<String, Object?> request,
) {
  final created = _object(
    transport.call('create_analysis', {
      'program': request['program'],
      'profile': request['profile'],
      'strictness': request['strictness'],
    }),
  );
  final document = created['document'] as int;
  final analysis = created['resource'] as int;
  try {
    final report = _object(transport.call('analysis', {'resource': analysis}));
    if (request['include_program_view'] == true) {
      report['program_view'] = transport.call('program_view', {
        'resource': document,
      });
    }
    return report;
  } finally {
    transport.call('release', {'resource': document});
  }
}

Map<String, Object?> _shutdown(RustTransport transport) {
  transport.close();
  return {'kind': 'shutdown'};
}

Map<String, Object?> _object(Object? value) =>
    (value as Map).cast<String, Object?>();
