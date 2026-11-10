import 'dart:convert';
import 'dart:io';
import 'dart:ui';

const String storeMediaCatalogPath =
    '../../packages/pseudolearn_store_media/catalog/slots.json';

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

List<PlateDevice> readPlateDevices([String path = storeMediaCatalogPath]) {
  final document =
      jsonDecode(File(path).readAsStringSync()) as Map<String, Object?>;
  final entries = document['devices']! as List<Object?>;
  return <PlateDevice>[
    for (final entry in entries.cast<Map<String, Object?>>())
      PlateDevice(
        id: entry['id']! as String,
        logicalSize: Size(
          (entry['logicalWidth']! as num).toDouble(),
          (entry['logicalHeight']! as num).toDouble(),
        ),
        plateScale: (entry['plateScale']! as num).toDouble(),
      ),
  ];
}
