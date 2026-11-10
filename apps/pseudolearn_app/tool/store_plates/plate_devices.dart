import 'dart:convert';
import 'dart:io';

import 'package:flutter/painting.dart';

const String storeMediaCatalogPath =
    '../../packages/pseudolearn_store_media/catalog/slots.json';

const String screenshotSlotKind = 'screenshot';
const String previewSlotKind = 'app-preview';

final class PlateDevice {
  final String id;
  final Size logicalSize;
  final double plateScale;
  final EdgeInsets insets;

  const PlateDevice({
    required this.id,
    required this.logicalSize,
    required this.plateScale,
    this.insets = EdgeInsets.zero,
  });

  Size get pixelSize => logicalSize * plateScale;
}

List<PlateDevice> readPlateDevices([
  String path = storeMediaCatalogPath,
  String slotKind = screenshotSlotKind,
]) {
  final document =
      jsonDecode(File(path).readAsStringSync()) as Map<String, Object?>;
  final entries = document['devices']! as List<Object?>;
  final wanted = <Object?>{
    for (final slot in (document['slots']! as List<Object?>)
        .cast<Map<String, Object?>>())
      if (slot['kind'] == slotKind) slot['device'],
  };
  return <PlateDevice>[
    for (final entry in entries.cast<Map<String, Object?>>())
      if (wanted.contains(entry['id'])) _deviceOf(entry),
  ];
}

PlateDevice _deviceOf(Map<String, Object?> entry) => PlateDevice(
      id: entry['id']! as String,
      logicalSize: Size(
        (entry['logicalWidth']! as num).toDouble(),
        (entry['logicalHeight']! as num).toDouble(),
      ),
      plateScale: (entry['plateScale']! as num).toDouble(),
      insets: _insetsOf(entry['insets'] as Map<String, Object?>?),
    );

EdgeInsets _insetsOf(Map<String, Object?>? insets) => insets == null
    ? EdgeInsets.zero
    : EdgeInsets.fromLTRB(
        (insets['left']! as num).toDouble(),
        (insets['top']! as num).toDouble(),
        (insets['right']! as num).toDouble(),
        (insets['bottom']! as num).toDouble(),
      );
