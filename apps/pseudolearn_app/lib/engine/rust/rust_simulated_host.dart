import '../../domain/model/execution/simulated_capabilities.dart';
import 'rust_simulated_files.dart';
import 'rust_simulated_http.dart';
import 'rust_wire_models.dart';

const int _readRight = 1;
const int _writeRight = 2;

final class RustSimulatedHost {
  final SimulatedCapabilities _capabilities;
  final RustSimulatedFiles _files;
  late final RustSimulatedHttp _http;
  int _clockNanos;

  RustSimulatedHost(SimulatedCapabilities capabilities)
    : _capabilities = _copyCapabilities(capabilities),
      _files = RustSimulatedFiles(capabilities.files),
      _clockNanos = capabilities.clockStartNanos {
    _http = RustSimulatedHttp(_capabilities, _files);
  }

  Map<String, Object?> hostDocument() {
    final document = <String, Object?>{
      'permissions': _capabilities.permissions.toList()..sort(),
      'detached': true,
    };
    if (_capabilities.files.isNotEmpty) {
      document['files'] = _capabilities.files;
    }
    if (_capabilities.arguments.isNotEmpty) {
      document['args'] = _capabilities.arguments;
    }
    if (_capabilities.clockStartNanos != 0) {
      document['clock'] = [_capabilities.clockStartNanos];
    }
    document.addAll(_http.hostFields);
    final failures = _operationFailures;
    if (failures.isNotEmpty) document['faults'] = failures;
    return document;
  }

  int get openResources => _files.openResources;

  void closeAll() => _files.closeAll();

  static List<PendingEffectRequest> deliveryOrder(
    List<PendingEffectRequest> pendings,
  ) =>
      List.of(pendings)
        ..sort((left, right) => left.effectSeq.compareTo(right.effectSeq));

  Map<String, Object?> reply(Map<String, Object?> json) {
    try {
      return _committed(SimulatedHostRequest(json));
    } on RustSimulatedHostFailure catch (failure) {
      return failure.reply;
    }
  }

  Map<String, Object?> _committed(SimulatedHostRequest request) {
    if (request.operation == 'request_directory') {
      if (!_hasPermission(request.operation)) {
        throw RustSimulatedHostFailure.denied();
      }
      _failIfConfigured(request);
      return _files.register(
        request.capability,
        '',
        _grantedRights(request.capability),
      );
    }
    if (request.operation.startsWith('request_')) {
      if (!_hasPermission(request.operation)) {
        throw RustSimulatedHostFailure.denied();
      }
      _failIfConfigured(request);
      return _files.register(request.capability, '', 0);
    }
    if (request.operation != 'network_send') _failIfConfigured(request);
    return switch (request.operation) {
      'console_write' => _value('integer', _text(request.arguments, 0).length),
      'arguments_values' => _value('text_list', _capabilities.arguments),
      'clock_now' => _value('integer', _clockNanos),
      'timer_wait' => _wait(request.arguments),
      'network_send' => _http.reply(request),
      _ => _files.reply(request),
    };
  }

  SimulatedEffectFailure? _failureFor(SimulatedHostRequest request) {
    return _capabilities.failures[request.operation];
  }

  void _failIfConfigured(SimulatedHostRequest request) {
    final failure = _failureFor(request);
    if (failure != null) {
      throw RustSimulatedHostFailure(failure.code, failure.uncertain);
    }
  }

  bool _hasPermission(String operation) {
    final permission = switch (operation) {
      'request_console' => 'consola',
      'request_arguments' => 'argumentos',
      'request_directory' => 'archivos',
      'request_clock' => 'reloj',
      'request_timer' => 'temporizador',
      'request_network' => 'red',
      _ => '',
    };
    if (permission == 'archivos') {
      return _capabilities.permissions.contains('archivos_lectura') ||
          _capabilities.permissions.contains('archivos_escritura');
    }
    return _capabilities.permissions.contains(permission);
  }

  List<Map<String, Object?>> get _operationFailures => [
    for (final entry in _capabilities.failures.entries)
      if (!entry.key.contains(' '))
        {
          'operation': entry.key,
          'code': entry.value.code,
          'uncertain': entry.value.uncertain,
        },
  ];

  Map<String, Object?> _wait(List<Map<String, Object?>> arguments) {
    final duration = (arguments.first['value'] as num).toInt();
    _clockNanos += duration;
    return _value('integer', _clockNanos);
  }

  int _grantedRights(Map<String, Object?>? capability) {
    final declared = (capability?['rights'] as num?)?.toInt() ?? 0;
    final permissions = _capabilities.permissions;
    final configured =
        (permissions.contains('archivos_lectura') ? _readRight : 0) |
        (permissions.contains('archivos_escritura') ? _writeRight : 0);
    return declared & configured;
  }

  static String _text(List<Map<String, Object?>> arguments, int index) {
    final argument = index < arguments.length ? arguments[index] : null;
    if (argument == null || argument['kind'] != 'text') {
      throw const RustSimulatedHostFailure('ruta_invalida');
    }
    return argument['value'] as String;
  }

  static Map<String, Object?> _value(String kind, Object? value) => {
    'outcome': 'committed',
    'value': {'kind': kind, 'value': value},
  };
}

SimulatedCapabilities _copyCapabilities(SimulatedCapabilities source) =>
    SimulatedCapabilities(
      permissions: Set.unmodifiable(source.permissions),
      files: Map.unmodifiable({
        for (final entry in source.files.entries)
          entry.key: List<int>.unmodifiable(entry.value),
      }),
      arguments: List.unmodifiable(source.arguments),
      clockStartNanos: source.clockStartNanos,
      networkOrigins: Set.unmodifiable(source.networkOrigins),
      httpResponses: Map.unmodifiable({
        for (final entry in source.httpResponses.entries)
          entry.key: SimulatedHttpResponse(
            status: entry.value.status,
            headers: Map.unmodifiable(Map.of(entry.value.headers)),
            body: List<int>.unmodifiable(entry.value.body),
          ),
      }),
      failures: Map.unmodifiable(Map.of(source.failures)),
      hostEnabled: source.hostEnabled,
    );
