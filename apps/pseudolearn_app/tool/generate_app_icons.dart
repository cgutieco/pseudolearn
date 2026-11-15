import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pseudolearn_app/presentation/brand/brand_symbol_geometry.dart';

const String _iosDirectory = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';
const String _macosDirectory =
    'macos/Runner/Assets.xcassets/AppIcon.appiconset';
const String _windowsIconPath = 'windows/runner/resources/app_icon.png';
const String _windowsIcoPath = 'windows/runner/resources/app_icon.ico';
const List<(String, int, int)> _macosIcons = <(String, int, int)>[
  ('16x16', 16, 1),
  ('16x16', 32, 2),
  ('32x32', 32, 1),
  ('32x32', 64, 2),
  ('128x128', 128, 1),
  ('128x128', 256, 2),
  ('256x256', 256, 1),
  ('256x256', 512, 2),
  ('512x512', 512, 1),
  ('512x512', 1024, 2),
];
const List<(String, String, int, int)> _iosIcons = <(String, String, int, int)>[
  ('20x20', 'iphone', 2, 40),
  ('20x20', 'iphone', 3, 60),
  ('29x29', 'iphone', 1, 29),
  ('29x29', 'iphone', 2, 58),
  ('29x29', 'iphone', 3, 87),
  ('40x40', 'iphone', 2, 80),
  ('40x40', 'iphone', 3, 120),
  ('60x60', 'iphone', 2, 120),
  ('60x60', 'iphone', 3, 180),
  ('20x20', 'ipad', 1, 20),
  ('20x20', 'ipad', 2, 40),
  ('29x29', 'ipad', 1, 29),
  ('29x29', 'ipad', 2, 58),
  ('40x40', 'ipad', 1, 40),
  ('40x40', 'ipad', 2, 80),
  ('76x76', 'ipad', 1, 76),
  ('76x76', 'ipad', 2, 152),
  ('83.5x83.5', 'ipad', 2, 167),
  ('1024x1024', 'ios-marketing', 1, 1024),
];
const List<int> _macosSizes = <int>[16, 32, 64, 128, 256, 512, 1024];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'application icons are generated from the brand symbol geometry',
    () async {
      final ios = Directory(_iosDirectory)..createSync(recursive: true);
      final macos = Directory(_macosDirectory)..createSync(recursive: true);
      final windowsIcon = File(_windowsIconPath);
      final windowsIco = File(_windowsIcoPath);
      windowsIcon.parent.createSync(recursive: true);
      final iosFiles = <String>{};
      final macosFiles = <String>{};

      for (final (size, idiom, scale, pixels) in _iosIcons) {
        final name = _iosFileName(size, idiom, scale);
        if (iosFiles.add(name)) {
          await _writeIcon(ios, name, pixels);
        }
      }
      for (final size in _macosSizes) {
        final name = 'app_icon_$size.png';
        macosFiles.add(name);
        await _writeIcon(macos, name, size);
      }
      windowsIcon.writeAsBytesSync(await _renderIcon(1024));
      windowsIco.writeAsBytesSync(await _renderIco());

      _writeContents(ios, _iosContents());
      _writeContents(macos, _macosContents());

      expect(
        iosFiles.every((name) => File(p.join(ios.path, name)).existsSync()),
        isTrue,
      );
      expect(
        macosFiles.every((name) => File(p.join(macos.path, name)).existsSync()),
        isTrue,
      );
      expect(windowsIcon.existsSync(), isTrue);
      expect(windowsIco.existsSync(), isTrue);
    },
  );
}

String _iosFileName(String size, String idiom, int scale) {
  if (idiom == 'ios-marketing') {
    return 'Icon-App-1024x1024@1x.png';
  }
  return 'Icon-App-$size@${scale}x.png';
}

Future<void> _writeIcon(Directory directory, String name, int pixels) async {
  File(
    p.join(directory.path, name),
  ).writeAsBytesSync(await _renderIcon(pixels));
}

Future<Uint8List> _renderIcon(int pixels) async {
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder)..scale(pixels / 1024);
  final bounds = const Rect.fromLTWH(0, 0, 1024, 1024);
  canvas.drawRect(
    bounds,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0xFF195C5F), Color(0xFF0F4346)],
      ).createShader(bounds),
  );
  canvas
    ..save()
    ..translate(230.4, 224.472)
    ..scale(5.928421)
    ..drawPath(buildBrandSymbolPath(), Paint()..color = const Color(0xFFFFFFFF))
    ..restore();
  final image = await recorder.endRecording().toImage(pixels, pixels);
  final bytes = await image.toByteData(format: ImageByteFormat.png);
  final png = bytes!.buffer.asUint8List();
  image.dispose();
  return png;
}

Future<Uint8List> _renderIco() async {
  const sizes = <int>[16, 32, 48, 64, 128, 256];
  final images = <Uint8List>[];
  for (final size in sizes) {
    images.add(await _renderIcon(size));
  }
  final directory = ByteData(6 + sizes.length * 16);
  directory.setUint16(0, 0, Endian.little);
  directory.setUint16(2, 1, Endian.little);
  directory.setUint16(4, sizes.length, Endian.little);
  var offset = directory.lengthInBytes;
  for (var index = 0; index < sizes.length; index++) {
    final size = sizes[index];
    final entry = 6 + index * 16;
    directory.setUint8(entry, size == 256 ? 0 : size);
    directory.setUint8(entry + 1, size == 256 ? 0 : size);
    directory.setUint8(entry + 2, 0);
    directory.setUint8(entry + 3, 0);
    directory.setUint16(entry + 4, 1, Endian.little);
    directory.setUint16(entry + 6, 32, Endian.little);
    directory.setUint32(entry + 8, images[index].length, Endian.little);
    directory.setUint32(entry + 12, offset, Endian.little);
    offset += images[index].length;
  }
  final bytes = BytesBuilder(copy: false)..add(directory.buffer.asUint8List());
  for (final image in images) {
    bytes.add(image);
  }
  return bytes.takeBytes();
}

void _writeContents(Directory directory, Map<String, Object> contents) {
  File(p.join(directory.path, 'Contents.json')).writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(contents)}\n',
  );
}

Map<String, Object> _iosContents() => <String, Object>{
  'images': _iosIcons
      .map(
        (icon) => <String, Object>{
          'size': icon.$1,
          'idiom': icon.$2,
          'filename': _iosFileName(icon.$1, icon.$2, icon.$3),
          'scale': '${icon.$3}x',
        },
      )
      .toList(),
  'info': <String, Object>{'version': 1, 'author': 'pseudolearn'},
};

Map<String, Object> _macosContents() => <String, Object>{
  'images': <Map<String, Object>>[
    for (final (size, pixels, scale) in _macosIcons)
      <String, Object>{
        'size': size,
        'idiom': 'mac',
        'filename': 'app_icon_$pixels.png',
        'scale': '${scale}x',
      },
  ],
  'info': <String, Object>{'version': 1, 'author': 'pseudolearn'},
};
