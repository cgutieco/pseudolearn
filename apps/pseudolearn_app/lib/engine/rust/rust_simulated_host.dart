import 'dart:convert';

import '../../domain/model/execution/simulated_capabilities.dart';

const int _readRight = 1;
const int _writeRight = 2;

final class _Request {
  final String operation;
  final List<Map<String, Object?>> arguments;
  final Map<String, Object?>? capability;
  final Map<String, Object?>? receiver;

  _Request(Map<String, Object?> json)
    : operation = json['operation'] as String,
      arguments = (json['arguments'] as List<Object?>? ?? const [])
          .cast<Map<String, Object?>>(),
      capability = json['result_capability'] as Map<String, Object?>?,
      receiver = json['receiver'] as Map<String, Object?>?;
}

final class _Resource {
  final String path;
  final int rights;

  const _Resource(this.path, this.rights);
}

final class RustSimulatedHost {
  final SimulatedCapabilities _capabilities;
  final Map<String, List<int>> _files;
  final Map<int, _Resource> _resources = {};
  int _clockNanos;

  RustSimulatedHost(this._capabilities)
    : _files = {
        for (final entry in _capabilities.files.entries)
          entry.key: List<int>.of(entry.value),
      },
      _clockNanos = _capabilities.clockStartNanos;

  Map<String, Object?> hostDocument() => {
    'permissions': _capabilities.permissions.toList()..sort(),
    'detached': true,
  };

  int get openResources => _resources.length;

  Map<String, Object?> reply(Map<String, Object?> json) {
    try {
      return _committed(_Request(json));
    } on _HostFailure catch (failure) {
      return failure.reply;
    }
  }

  Map<String, Object?> _committed(_Request request) {
    final arguments = request.arguments;
    if (request.operation == 'request_directory') {
      return _register(request.capability, '', _grantedRights(request.capability));
    }
    if (request.operation.startsWith('request_')) {
      return _register(request.capability, '', 0);
    }
    return switch (request.operation) {
      'console_write' => _value('integer', _text(arguments, 0).length),
      'arguments_values' => _value('text_list', _capabilities.arguments),
      'clock_now' => _value('integer', _clockNanos),
      'timer_wait' => _wait(arguments),
      _ => _fileOperation(request),
    };
  }

  Map<String, Object?> _fileOperation(_Request request) {
    final parent = _resourceOf(request.receiver);
    final arguments = request.arguments;
    switch (request.operation) {
      case 'file_open' || 'directory_derive':
        final path = _join(parent.path, _text(arguments, 0));
        final rights = _modeRights(_text(arguments, 1));
        if (rights & ~parent.rights != 0) throw _HostFailure.denied();
        if (request.operation == 'file_open' && !_files.containsKey(path)) {
          if (rights & _writeRight == 0) throw _HostFailure.notFound();
          _files[path] = [];
        }
        return _register(request.capability, path, rights);
      case 'file_read_bytes':
        return _value('bytes', _read(parent));
      case 'file_read_text':
        return _value('text', _decode(_read(parent)));
      case 'file_write_bytes' || 'file_write_text':
        return _write(parent, arguments);
      case 'file_close' || 'directory_close':
        _resources.remove((request.receiver!['slot'] as num).toInt());
        return _value('boolean', true);
    }
    throw _HostFailure.interrupted();
  }

  Map<String, Object?> _write(
    _Resource target,
    List<Map<String, Object?>> arguments,
  ) {
    if (target.rights & _writeRight == 0) throw _HostFailure.denied();
    final raw = arguments.first;
    final bytes = raw['kind'] == 'bytes'
        ? (raw['value'] as List<Object?>).cast<int>()
        : _text(arguments, 0).codeUnits;
    _files[target.path] = List<int>.of(bytes);
    return _value('integer', bytes.length);
  }

  List<int> _read(_Resource source) {
    if (source.rights & _readRight == 0) throw _HostFailure.denied();
    return _files[source.path] ?? (throw _HostFailure.notFound());
  }

  String _decode(List<int> bytes) {
    try {
      return utf8.decode(bytes);
    } on FormatException {
      throw _HostFailure('utf8_invalido');
    }
  }

  Map<String, Object?> _wait(List<Map<String, Object?>> arguments) {
    final duration = (arguments.first['value'] as num).toInt();
    _clockNanos += duration;
    return _value('integer', _clockNanos);
  }

  _Resource _resourceOf(Map<String, Object?>? receiver) {
    final slot = (receiver?['slot'] as num?)?.toInt();
    return _resources[slot] ?? (throw _HostFailure('capacidad_cerrada'));
  }

  Map<String, Object?> _register(
    Map<String, Object?>? capability,
    String path,
    int rights,
  ) {
    if (capability == null) throw _HostFailure.denied();
    _resources[(capability['slot'] as num).toInt()] = _Resource(path, rights);
    return _value('capability', capability);
  }

  static int _grantedRights(Map<String, Object?>? capability) =>
      ((capability?['rights'] as num?)?.toInt() ?? 0) & (_readRight | _writeRight);

  static int _modeRights(String mode) => switch (mode) {
    'read' || 'lectura' => _readRight,
    'write' || 'escritura' => _writeRight,
    'read_write' || 'lectura_escritura' => _readRight | _writeRight,
    _ => throw _HostFailure('ruta_invalida'),
  };

  static String _join(String parent, String child) {
    final invalid =
        child.isEmpty ||
        child.startsWith('/') ||
        child.contains('\\') ||
        child.contains(':') ||
        child.contains('\u0000') ||
        child.split('/').any((part) => part.isEmpty || part == '.' || part == '..');
    if (invalid) throw _HostFailure('ruta_invalida');
    return parent.isEmpty ? child : '$parent/$child';
  }

  static String _text(List<Map<String, Object?>> arguments, int index) {
    final argument = index < arguments.length ? arguments[index] : null;
    if (argument == null || argument['kind'] != 'text') {
      throw _HostFailure('ruta_invalida');
    }
    return argument['value'] as String;
  }

  static Map<String, Object?> _value(String kind, Object? value) => {
    'outcome': 'committed',
    'value': {'kind': kind, 'value': value},
  };
}

final class _HostFailure implements Exception {
  final String code;

  const _HostFailure(this.code);

  factory _HostFailure.denied() => const _HostFailure('permiso_denegado');
  factory _HostFailure.notFound() => const _HostFailure('no_encontrado');
  factory _HostFailure.interrupted() => const _HostFailure('interrumpido');

  Map<String, Object?> get reply => {
    'outcome': 'failed',
    'value': {'code': code, 'uncertain': false},
  };
}
