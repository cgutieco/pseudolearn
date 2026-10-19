import '../../domain/model/execution/watch_row.dart';
import 'rust_state_api.dart';

final class RustEnvironment {
  final List<WatchRow> rows;
  final String scopeName;
  final int depth;

  const RustEnvironment({
    required this.rows,
    required this.scopeName,
    required this.depth,
  });
}

final class RustWatchRows {
  static const String _absent = '-';

  final RustStateApi _state;

  const RustWatchRows(this._state);

  RustEnvironment at({
    required int execution,
    required int event,
    required int depth,
  }) {
    final frames = <Map<String, Object?>>[];
    for (var index = 0; index < depth; index++) {
      final frame = _state.frame(execution, event, index);
      if (frame == null) break;
      frames.add(frame);
    }
    return RustEnvironment(
      rows: [
        for (final frame in frames)
          ..._rowsOf(_QueryPoint(execution, event), frame, frames),
      ],
      scopeName: frames.isEmpty ? 'global' : frames.last['unidad'] as String,
      depth: frames.length,
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
      formattedValue: text ?? _absent,
      scopeName: label.$2,
      isAbsent: text == null,
    );
  }

  WatchRow _referenceRow(_QueryPoint point, _Label label, int reference) {
    final length = _state.arrayLength(point.execution, point.event, reference);
    final description = length != null
        ? '[$length]'
        : '${_state.objectOf(point.execution, point.event, reference)?['clase']}#$reference';
    return WatchRow(
      name: label.$1,
      formattedValue: description,
      identityBadge: reference,
      scopeName: label.$2,
    );
  }
}

typedef _Label = (String, String);

final class _QueryPoint {
  final int execution;
  final int event;

  const _QueryPoint(this.execution, this.event);
}
