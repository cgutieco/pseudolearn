import '../../domain/model/execution/simulated_capabilities.dart';
import 'rust_simulated_files.dart';

final class RustSimulatedHttp {
  final SimulatedCapabilities _capabilities;
  final RustSimulatedFiles _resources;

  const RustSimulatedHttp(this._capabilities, this._resources);

  Map<String, Object?> get hostFields {
    final fields = <String, Object?>{};
    if (_capabilities.networkOrigins.isNotEmpty) {
      fields['network_origins'] = _capabilities.networkOrigins.toList()..sort();
    }
    if (_capabilities.httpResponses.isNotEmpty || _networkFailures.isNotEmpty) {
      fields['http'] = _scripts;
    }
    return fields;
  }

  Map<String, Object?> reply(SimulatedHostRequest request) {
    if (!_capabilities.permissions.contains('red')) {
      throw RustSimulatedHostFailure.denied();
    }
    _resources.requireResource(request.receiver);
    final value = request.arguments.isEmpty
        ? null
        : request.arguments.first['value'];
    if (value is! Map<String, Object?>) {
      throw RustSimulatedHostFailure.interrupted();
    }
    final method = value['method'];
    final url = value['url'];
    if (method is! String || url is! String) {
      throw RustSimulatedHostFailure.interrupted();
    }
    final uri = Uri.tryParse(url);
    if (uri == null ||
        !uri.hasAuthority ||
        uri.userInfo.isNotEmpty ||
        !_capabilities.networkOrigins.contains(uri.origin)) {
      throw const RustSimulatedHostFailure('destino_denegado');
    }
    _failIfConfigured('$method $url');
    final response = _capabilities.httpResponses['$method $url'];
    if (response == null) {
      throw const RustSimulatedHostFailure('conexion_fallida');
    }
    return _value('http_response', {
      'status': response.status,
      'headers': [
        for (final entry in response.headers.entries) [entry.key, entry.value],
      ],
      'body': method == 'HEAD' ? const <int>[] : response.body,
      'final_url': url.split('#').first,
    });
  }

  void _failIfConfigured(String key) {
    final failure = _capabilities.failures[key];
    if (failure != null) {
      throw RustSimulatedHostFailure(failure.code, failure.uncertain);
    }
  }

  Map<String, Object?> get _scripts => {
    for (final entry in _capabilities.httpResponses.entries)
      entry.key: {
        'estado': entry.value.status,
        'cabeceras': [
          for (final header in entry.value.headers.entries)
            [header.key, header.value],
        ],
        'cuerpo_bytes': entry.value.body,
      },
    for (final entry in _networkFailures.entries)
      entry.key: {'fallo': entry.value.code, 'incierto': entry.value.uncertain},
  };

  Map<String, SimulatedEffectFailure> get _networkFailures => {
    for (final entry in _capabilities.failures.entries)
      if (entry.key.contains(' ')) entry.key: entry.value,
  };

  static Map<String, Object?> _value(String kind, Object? value) => {
    'outcome': 'committed',
    'value': {'kind': kind, 'value': value},
  };
}
