import '../../domain/model/execution/watch_row.dart';
import 'rust_state_api.dart';

final class RustEnvironment {
  final List<WatchRow> rows;
  final String scopeName;
  final int depth;

  RustEnvironment({
    required List<WatchRow> rows,
    required this.scopeName,
    required this.depth,
  }) : rows = List.unmodifiable(rows);
}

sealed class RustEnvironmentResult {
  const RustEnvironmentResult();
}

final class RustEnvironmentValue extends RustEnvironmentResult {
  final RustEnvironment environment;

  const RustEnvironmentValue(this.environment);
}

final class RustEnvironmentFailure extends RustEnvironmentResult {
  final String reason;

  const RustEnvironmentFailure(this.reason);
}

final class RustWatchRows {
  static const String _absent = '-';

  final RustStateApi _state;

  const RustWatchRows(this._state);

  RustEnvironmentResult at({
    required int execution,
    required int event,
    required int taskId,
    required int depth,
  }) {
    try {
      return _readEnvironment(
        execution: execution,
        event: event,
        taskId: taskId,
        depth: depth,
      );
    } on _WatchReadFailure catch (failure) {
      return RustEnvironmentFailure(failure.reason);
    } on Object {
      return const RustEnvironmentFailure('invalid_state_response');
    }
  }

  RustEnvironmentResult _readEnvironment({
    required int execution,
    required int event,
    required int taskId,
    required int depth,
  }) {
    final frames = <Map<String, Object?>>[];
    for (var index = 0; index < depth; index++) {
      final result = _state.frame(execution, event, index, taskId: taskId);
      if (result is RustStateValue<Map<String, Object?>>) {
        frames.add(result.value);
        continue;
      }
      if (result is RustStateUsage<Map<String, Object?>> && index > 0) break;
      throw _WatchReadFailure(_reasonOf(result));
    }
    return RustEnvironmentValue(
      RustEnvironment(
        rows: [
          for (final frame in frames)
            ..._rowsOf(_QueryPoint(execution, event, taskId), frame, frames),
        ],
        scopeName: frames.isEmpty ? 'global' : frames.last['unidad'] as String,
        depth: frames.length,
      ),
    );
  }

  List<WatchRow> _rowsOf(
    _QueryPoint point,
    Map<String, Object?> frame,
    List<Map<String, Object?>> frames,
  ) {
    final scope = frame['unidad'] as String;
    final variables = (frame['variables'] as Map<String, Object?>).entries;
    return [
      for (final entry in variables)
        _rowOf(point, (entry.key, scope), _resolve(entry.value, frames)),
    ];
  }

  Object? _resolve(Object? value, List<Map<String, Object?>> frames) {
    if (value is! Map<String, Object?> || !value.containsKey('alias')) {
      return value;
    }
    final alias = value['alias'] as Map<String, Object?>;
    final frameIndex = alias['marco'] as int;
    if (frameIndex >= frames.length) return value;
    final target = frames[frameIndex]['variables'] as Map<String, Object?>;
    return target[alias['variable']] ?? value;
  }

  WatchRow _rowOf(_QueryPoint point, _Label label, Object? value) {
    final fields = value is Map<String, Object?>
        ? value
        : const <String, Object?>{};
    final reference = fields['ref'] as int?;
    if (reference != null) return _referenceRow(point, label, reference);
    final text = fields['valor'] as String?;
    return WatchRow(
      name: label.$1,
      formattedValue: text == null ? _absent : _typed(text, fields['tipo']),
      scopeName: label.$2,
      isAbsent: text == null,
    );
  }

  String _objectDescription(_QueryPoint point, int reference) {
    final result = _state.objectOf(
      point.execution,
      point.event,
      reference,
      taskId: point.taskId,
    );
    if (result is! RustStateValue<Map<String, Object?>>) {
      throw _WatchReadFailure(_reasonOf(result));
    }
    final object = result.value;
    final vector = object['vector'];
    if (vector is Map<String, Object?>) {
      return '[${vector['longitud']}]#$reference';
    }
    final dictionary = object['diccionario'];
    if (dictionary is Map<String, Object?>) {
      return '{${dictionary['longitud']}}#$reference';
    }
    return '${object['clase']}#$reference';
  }

  WatchRow _referenceRow(_QueryPoint point, _Label label, int reference) {
    final result = _state.arrayShape(
      point.execution,
      point.event,
      reference,
      taskId: point.taskId,
    );
    if (result is RustStateFailure<List<int>>) {
      throw _WatchReadFailure(result.reason);
    }
    final shape = result is RustStateValue<List<int>> ? result.value : null;
    final description = shape != null
        ? '[${shape.join('x')}]'
        : _objectDescription(point, reference);
    return WatchRow(
      name: label.$1,
      formattedValue: description,
      identityBadge: reference,
      scopeName: label.$2,
    );
  }

  String _typed(String text, Object? kind) => switch (kind) {
    'caracter' => "'$text'",
    'texto' => '"$text"',
    _ => text,
  };
}

String _reasonOf<T>(RustStateResult<T> result) => switch (result) {
  RustStateUsage<T>() => 'task_state_unavailable',
  RustStateFailure<T>(:final reason) => reason,
  RustStateValue<T>() => 'invalid_state_response',
};

final class _WatchReadFailure implements Exception {
  final String reason;

  const _WatchReadFailure(this.reason);
}

typedef _Label = (String, String);

final class _QueryPoint {
  final int execution;
  final int event;
  final int taskId;

  const _QueryPoint(this.execution, this.event, this.taskId);
}
