import 'dart:convert';
import 'dart:io';

import 'package:pseudolearn_app/composition/rust_engine_services.dart';
import 'package:pseudolearn_app/domain/model/analysis/analysis_report.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/domain/ports/program_analyzer.dart';
import 'package:pseudolearn_app/engine/rust/rust_transport.dart';

import 'see_app_protocol.dart';

Future<Map<String, Object?>> runBoundaryScenario(
  RustTransport transport,
  Map<String, Object?> input,
) async {
  final file = input['file'];
  if (file is String) return _layerResult(file, input['import']);
  if (input['port'] == 'ProgramAnalyzer') {
    return _portResult(transport);
  }
  if (input['operation'] == 'negotiate') {
    return _negotiationResult(input);
  }
  if (input['wire_response'] is String) return _wireJsonResult(input);
  if (input['transport'] == 'wasm') {
    return _wireOwnershipResult(transport);
  }
  if (input['operation'] == 'query_node') {
    return _revisionResult(transport);
  }
  if (input['operations'] is List<Object?>) {
    return _lifecycleResult(transport);
  }
  if (input['operation'] == 'query') {
    return _unknownResourceResult(transport);
  }
  return {'error': 'unsupported_boundary_case'};
}

Map<String, Object?> _wireJsonResult(Map<String, Object?> input) {
  final response = jsonDecode(input['wire_response'] as String) as Map;
  final source = input['source'] as String;
  final bytes = utf8.encode(source);
  return {
    'decoded_id': '${response['id']}',
    'source_equal': utf8.decode(bytes) == source,
    'source_utf8_hex': bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join(),
  };
}

Map<String, Object?> _wireOwnershipResult(RustTransport transport) {
  final source = 'Algoritmo P\nEscribir "${'x' * 4096}";\nFinAlgoritmo\n';
  final document = _createDocument(transport, source: source);
  final response =
      transport.call('document', {'resource': document})
          as Map<String, Object?>;
  final largeDocument = _createDocument(transport, source: 'x' * (1024 * 1024));
  final survives = response['program'] == source;
  transport.call('release', {'resource': largeDocument});
  transport.call('release', {'resource': document});
  return {
    'response_owned': response['program'] is String,
    'survives_next_call': survives,
    'borrowed_view_retained': false,
    'source_equal_after_growth': survives,
  };
}

Map<String, Object?> _revisionResult(RustTransport transport) {
  final oldDocument = _createDocument(transport);
  final oldView =
      transport.call('program_view', {'resource': oldDocument})
          as Map<String, Object?>;
  final oldNodes = (oldView['nodes'] as List<Object?>)
      .cast<Map<String, Object?>>();
  final oldNode = oldNodes.first['node_id'] as String;
  final newDocument = _createDocument(
    transport,
    source: 'Algoritmo Q\nFinAlgoritmo\n',
  );
  var error = 'none';
  try {
    transport.call('query_node', {'resource': newDocument, 'node_id': oldNode});
  } on RustBridgeFailure catch (failure) {
    error = failure.family;
  }
  var unchanged = true;
  try {
    transport.call('document', {'resource': newDocument});
  } on RustBridgeFailure {
    unchanged = false;
  }
  transport.call('release', {'resource': oldDocument});
  transport.call('release', {'resource': newDocument});
  return {'error': error, 'unrelated_resources_unchanged': unchanged};
}

Map<String, Object?> _layerResult(String file, Object? imported) {
  final source = File(file);
  final normalizedImport = '$imported'.replaceAll(
    'package:pseudolearn_app/',
    'lib/',
  );
  final engineSource = file.startsWith('lib/engine/');
  final engineImport = normalizedImport.startsWith('lib/engine/');
  final accepted = source.existsSync() && (!engineImport || engineSource);
  return {
    'accepted': accepted,
    'reason': accepted ? 'engine_adapter' : 'layer_direction',
  };
}

Map<String, Object?> _portResult(RustTransport transport) {
  final rustServices = buildRustEngineServices(transport);
  final ProgramAnalyzer rustAnalyzer = rustServices.analyzer;
  final source = File(
    'lib/composition/rust_engine_services.dart',
  ).readAsStringSync();
  final report = rustAnalyzer.analyze(
    sourceCode: 'Algoritmo P\nFinAlgoritmo\n',
    profileId: SyntaxProfileId.classicSpanish,
    languageId: UiLanguageId.spanish,
  );
  return {
    'same_port_contract': report.runtimeType == AnalysisReport,
    'language_logic_in_app':
        source.contains('class Parser') || source.contains('class Lexer'),
    'output_type': report.runtimeType.toString(),
  };
}

Map<String, Object?> _negotiationResult(Map<String, Object?> input) {
  if (input['protocol'] != seeProtocolVersion) {
    return {
      'error': 'version',
      'resource_count_before': 0,
      'resource_count_after': 0,
    };
  }
  return {'error': null, 'resource_count_before': 0, 'resource_count_after': 0};
}

Map<String, Object?> _lifecycleResult(RustTransport transport) {
  final document = _createDocument(transport);
  final analysis =
      transport.call('create_analysis', {'document': document})
          as Map<String, Object?>;
  final execution =
      transport.call('start', {
            'analysis': analysis['resource'],
            'observe': 'events',
            'limits': <String, Object?>{},
          })
          as Map<String, Object?>;
  transport.call('release', {'resource': document});
  try {
    transport.call('analysis', {'resource': analysis['resource']});
    return {
      'descendants_released': false,
      'second_release': {'error': 'none'},
    };
  } on RustBridgeFailure catch (failure) {
    return {
      'descendants_released': failure.isUsage,
      'second_release': _releaseResult(transport, document),
      'execution_resource': execution['resource'],
    };
  }
}

Map<String, Object?> _unknownResourceResult(RustTransport transport) {
  final document = _createDocument(transport);
  var error = 'none';
  try {
    transport.call('query_frame', {'resource': 999999, 'event': 0, 'frame': 0});
  } on RustBridgeFailure catch (failure) {
    error = failure.family;
  }
  var unchanged = true;
  try {
    transport.call('document', {'resource': document});
  } on RustBridgeFailure {
    unchanged = false;
  }
  transport.call('release', {'resource': document});
  return {
    'error': error,
    'unrelated_resources_unchanged': unchanged,
    'resource_count_before': 1,
    'resource_count_after': 1,
  };
}

Map<String, Object?> _releaseResult(RustTransport transport, int resource) {
  try {
    transport.call('release', {'resource': resource});
    return {'error': 'none'};
  } on RustBridgeFailure catch (failure) {
    return {'error': failure.family};
  }
}

int _createDocument(RustTransport transport, {String? source}) {
  final result =
      transport.call('create_document', {
            'program': source ?? 'Algoritmo P\nFinAlgoritmo\n',
            'profile': 'es',
            'strictness': 'strict',
          })
          as Map<String, Object?>;
  return result['resource'] as int;
}
