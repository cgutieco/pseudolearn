import 'dart:convert';

final class SimulatedHostRequest {
  final String operation;
  final List<Map<String, Object?>> arguments;
  final Map<String, Object?>? capability;
  final Map<String, Object?>? receiver;

  SimulatedHostRequest(Map<String, Object?> json)
    : operation = json['operation'] as String,
      arguments = (json['arguments'] as List<Object?>? ?? const [])
          .cast<Map<String, Object?>>(),
      capability = json['result_capability'] as Map<String, Object?>?,
      receiver = json['receiver'] as Map<String, Object?>?;
}

final class RustSimulatedHostFailure implements Exception {
  final String code;
  final bool uncertain;

  const RustSimulatedHostFailure(this.code, [this.uncertain = false]);

  factory RustSimulatedHostFailure.denied() =>
      const RustSimulatedHostFailure('permiso_denegado');
  factory RustSimulatedHostFailure.notFound() =>
      const RustSimulatedHostFailure('no_encontrado');
  factory RustSimulatedHostFailure.interrupted() =>
      const RustSimulatedHostFailure('interrumpido');

  Map<String, Object?> get reply => {
    'outcome': uncertain ? 'uncertain' : 'failed',
    'value': {'code': code, 'uncertain': uncertain},
  };
}

final class _Resource {
  final String path;
  final int rights;
  final int generation;
  final int kind;
  final int declaredRights;

  const _Resource({
    required this.path,
    required this.rights,
    required this.generation,
    required this.kind,
    required this.declaredRights,
  });
}

final class RustSimulatedFiles {
  static const int _readRight = 1;
  static const int _writeRight = 2;

  final Map<String, List<int>> _files;
  final Map<int, _Resource> _resources = {};

  RustSimulatedFiles(Map<String, List<int>> files)
    : _files = {
        for (final entry in files.entries) entry.key: List<int>.of(entry.value),
      };

  int get openResources => _resources.length;

  void closeAll() => _resources.clear();

  Map<String, Object?> register(
    Map<String, Object?>? capability,
    String path,
    int rights,
  ) => _register(capability, path, rights);

  void requireResource(Map<String, Object?>? receiver) {
    _resourceOf(receiver);
  }

  Map<String, Object?> reply(SimulatedHostRequest request) =>
      _fileOperation(request);

  Map<String, Object?> _fileOperation(SimulatedHostRequest request) {
    final parent = _resourceOf(request.receiver);
    final arguments = request.arguments;
    switch (request.operation) {
      case 'file_open' || 'directory_derive':
        final path = _join(parent.path, _text(arguments, 0));
        final rights = _modeRights(_text(arguments, 1));
        if (rights & ~parent.rights != 0) {
          throw RustSimulatedHostFailure.denied();
        }
        if (request.operation == 'file_open' && !_files.containsKey(path)) {
          if (rights & _writeRight == 0) {
            throw RustSimulatedHostFailure.notFound();
          }
          _files[path] = [];
        }
        return _register(request.capability, path, rights);
      case 'file_read_bytes':
        return _value('bytes', _read(parent));
      case 'file_read_text':
        return _value('text', _decode(_read(parent)));
      case 'file_write_bytes' || 'file_write_text':
        return _write(parent, arguments);
      case 'file_close' || 'directory_close' || 'network_close':
        _resources.remove((request.receiver!['slot'] as num).toInt());
        return _value('boolean', true);
    }
    throw RustSimulatedHostFailure.interrupted();
  }

  Map<String, Object?> _write(
    _Resource target,
    List<Map<String, Object?>> arguments,
  ) {
    if (target.rights & _writeRight == 0) {
      throw RustSimulatedHostFailure.denied();
    }
    final raw = arguments.first;
    final bytes = raw['kind'] == 'bytes'
        ? (raw['value'] as List<Object?>).cast<int>()
        : _text(arguments, 0).codeUnits;
    _files[target.path] = List<int>.of(bytes);
    return _value('integer', bytes.length);
  }

  List<int> _read(_Resource source) {
    if (source.rights & _readRight == 0) {
      throw RustSimulatedHostFailure.denied();
    }
    return _files[source.path] ?? (throw RustSimulatedHostFailure.notFound());
  }

  String _decode(List<int> bytes) {
    try {
      return utf8.decode(bytes);
    } on FormatException {
      throw const RustSimulatedHostFailure('utf8_invalido');
    }
  }

  _Resource _resourceOf(Map<String, Object?>? receiver) {
    final slot = receiver?['slot'];
    if (slot is! num) throw const RustSimulatedHostFailure('capacidad_cerrada');
    final resource = _resources[slot.toInt()];
    if (resource == null ||
        receiver?['generation'] != resource.generation ||
        receiver?['kind'] != resource.kind ||
        receiver?['rights'] != resource.declaredRights) {
      throw const RustSimulatedHostFailure('capacidad_cerrada');
    }
    return resource;
  }

  Map<String, Object?> _register(
    Map<String, Object?>? capability,
    String path,
    int rights,
  ) {
    if (capability == null) throw RustSimulatedHostFailure.denied();
    final slot = capability['slot'];
    final generation = capability['generation'];
    final kind = capability['kind'];
    final declaredRights = capability['rights'];
    if (slot is! num ||
        generation is! num ||
        kind is! num ||
        declaredRights is! num) {
      throw RustSimulatedHostFailure.denied();
    }
    _resources[slot.toInt()] = _Resource(
      path: path,
      rights: rights & declaredRights.toInt(),
      generation: generation.toInt(),
      kind: kind.toInt(),
      declaredRights: declaredRights.toInt(),
    );
    return _value('capability', capability);
  }

  static int _modeRights(String mode) => switch (mode) {
    'read' || 'lectura' => _readRight,
    'write' || 'escritura' => _writeRight,
    'read_write' || 'lectura_escritura' => _readRight | _writeRight,
    _ => throw const RustSimulatedHostFailure('ruta_invalida'),
  };

  static String _join(String parent, String child) {
    final invalid =
        child.isEmpty ||
        child.startsWith('/') ||
        child.contains('\\') ||
        child.contains(':') ||
        child.contains('\u0000') ||
        child
            .split('/')
            .any((part) => part.isEmpty || part == '.' || part == '..');
    if (invalid) throw const RustSimulatedHostFailure('ruta_invalida');
    return parent.isEmpty ? child : '$parent/$child';
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
