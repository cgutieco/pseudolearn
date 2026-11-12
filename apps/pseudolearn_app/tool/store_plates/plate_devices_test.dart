import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import 'chapter_scenes.dart';
import 'plate_devices.dart';

void main() {
  test('reads every device the store media engine frames', () {
    final devices = readPlateDevices();
    expect(devices.map((device) => device.id), <String>[
      'iphone-large',
      'iphone-duo-inner-portrait',
      'iphone-duo-inner-landscape',
      'iphone-duo-outer-portrait',
      'iphone-duo-outer-landscape',
      'ipad-13',
      'mac',
      'windows-desktop',
    ]);
  });

  test('reads the trailer device at the native size of the trailer', () {
    final devices = readPlateDevices(storeMediaCatalogPath, trailerSlotKind);
    expect(devices.map((device) => device.id), <String>['windows-trailer']);
    expect(devices.single.pixelSize, const Size(1920, 1080));
  });

  test('reads no device for a kind no slot declares', () {
    expect(readPlateDevices(storeMediaCatalogPath, 'hologram'), isEmpty);
  });

  test('records each plate at the exact pixel size of its screenshot slot', () {
    final sizes = <String, Size>{
      for (final device in readPlateDevices()) device.id: device.pixelSize,
    };
    expect(sizes['iphone-large'], const Size(1320, 2868));
    expect(sizes['iphone-duo-inner-landscape'], const Size(2853, 2007));
    expect(sizes['iphone-duo-outer-portrait'], const Size(1398, 2034));
    expect(sizes['ipad-13'], const Size(2064, 2752));
    expect(sizes['mac'], const Size(2880, 1800));
    expect(sizes['windows-desktop'], const Size(3840, 2160));
  });

  test('names every chapter plate once', () {
    final plates = chapterScenes.map((scene) => scene.plate).toList();
    expect(plates.toSet(), hasLength(plates.length));
    expect(plates, everyElement(startsWith('chapter-')));
  });

  test('fails loudly when the catalog has no device list', () {
    final file = File('${Directory.systemTemp.createTempSync().path}/slots.json')
      ..writeAsStringSync('{"slots": []}');
    expect(() => readPlateDevices(file.path), throwsA(isA<TypeError>()));
  });

  test('fails loudly when the catalog is missing', () {
    expect(
      () => readPlateDevices('does/not/exist.json'),
      throwsA(isA<FileSystemException>()),
    );
  });
}
