import 'dart:convert';

import '../l10n/generated/app_localizations.dart';

String executionValueText(AppLocalizations l10n, Map<String, Object?> value) {
  if (value['valor'] is String) return value['valor'] as String;
  if (value['sin_valor'] == true) return l10n.executionValueUndefined;
  if (value['nulo'] == true) return l10n.executionValueNull;
  if (value['ref'] is int) {
    return l10n.executionValueReference(value['ref'] as int);
  }
  final channel = value['canal'];
  if (channel is Map<String, Object?>) return _channelText(l10n, channel);
  return jsonEncode(value);
}

String _channelText(AppLocalizations l10n, Map<String, Object?> channel) {
  final identity = channel['identidad'];
  final capacity = channel['capacidad'];
  final open = channel['abierto'];
  final queued = channel['en_cola'];
  if (identity is! int || capacity is! int || open is! bool || queued is! int) {
    return jsonEncode({'canal': channel});
  }
  return l10n.executionValueChannel(
    identity,
    capacity,
    open ? l10n.executionChannelOpen : l10n.executionChannelClosed,
    queued,
  );
}
