import 'dart:convert';
import 'dart:io';

import 'package:flutter/painting.dart';

const String storeMediaCatalogPath =
    '../../packages/pseudolearn_store_media/catalog/slots.json';

const String screenshotSlotKind = 'screenshot';
const String trailerSlotKind = 'trailer';

final class PlateDevice {
  final String id;
  final Size logicalSize;
  final double plateScale;

  const PlateDevice({
    required this.id,
    required this.logicalSize,
    required this.plateScale,
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
    );
