import 'package:pseudolearn_core/pseudolearn_core.dart';
import '../../domain/model/execution/watch_row.dart';

final class WatchRowProjection {
  const WatchRowProjection._();

  static WatchRow toWatchRow(
    VariableSnapshotEntry variable,
    String scopeName,
  ) {
    final value = variable.value;
    return WatchRow(
      name: variable.name,
      formattedValue: _formatValue(value, variable.hasValue),
      identityBadge: value is ObjectValue ? value.instance.id : null,
      scopeName: scopeName,
    );
  }

  static List<WatchRow> toReceiverRows(
    ObjectValue receiver,
    String scopeName,
  ) {
    final rows = <WatchRow>[];
    for (final entry in receiver.instance.fieldEntries) {
      final cell = entry.value;
      final val = cell.hasValue ? cell.value : null;
      rows.add(
        WatchRow(
          name: 'Este.${entry.key}',
          formattedValue: _formatValue(val, cell.hasValue),
          identityBadge: receiver.instance.id,
          scopeName: scopeName,
        ),
      );
    }
    return rows;
  }

  static String _formatValue(RuntimeValue? value, bool hasValue) {
    if (!hasValue || value == null) return '-';
    return switch (value) {
      IntegerValue(:final value) => value.toString(),
      RealValue(:final value) => value.toString(),
      BooleanValue(:final value) => value.toString(),
      CharacterValue(:final value) => "'$value'",
      StringValue(:final value) => '"$value"',
      ObjectValue(:final instance) =>
        '${instance.classSymbol.name}#${instance.id}',
    };
  }
}
