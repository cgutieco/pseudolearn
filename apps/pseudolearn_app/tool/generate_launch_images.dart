import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pseudolearn_app/presentation/brand/brand_symbol.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/brand_metrics.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/color_semantic.dart';

const List<int> _scales = <int>[1, 2, 3];

const String _imagesetPath = 'ios/Runner/Assets.xcassets/LaunchImage.imageset';
const String _colorsetPath = 'ios/Runner/Assets.xcassets/LaunchBackground.colorset';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('launch screen assets are written from the brand geometry', () async {
    const light = AppSemanticColors.light();
    const dark = AppSemanticColors.dark();

    final imageset = Directory(_imagesetPath)..createSync(recursive: true);
    for (final scale in _scales) {
      await _writeSymbol(
        directory: imageset,
        fileName: _symbolFileName(scale: scale, isDark: false),
        color: light.brandInk.signature,
        scale: scale,
      );
      await _writeSymbol(
        directory: imageset,
        fileName: _symbolFileName(scale: scale, isDark: true),
        color: dark.brandInk.signature,
        scale: scale,
      );
    }
    File(p.join(imageset.path, 'Contents.json')).writeAsStringSync(_imagesetContents());

    final colorset = Directory(_colorsetPath)..createSync(recursive: true);
    File(p.join(colorset.path, 'Contents.json')).writeAsStringSync(
      _colorsetContents(light: light.surfaces.canvas, dark: dark.surfaces.canvas),
    );

    expect(File(p.join(imageset.path, 'LaunchImage@3x.png')).existsSync(), isTrue);
    expect(File(p.join(colorset.path, 'Contents.json')).existsSync(), isTrue);
  });
}

String _symbolFileName({required int scale, required bool isDark}) {
  final suffix = scale == 1 ? '' : '@${scale}x';
  return isDark ? 'LaunchImage-Dark$suffix.png' : 'LaunchImage$suffix.png';
}

Future<void> _writeSymbol({
  required Directory directory,
  required String fileName,
  required Color color,
  required int scale,
}) async {
  final side = (BrandMetricsTokens.symbolSizeLaunch * scale).round();
  final recorder = PictureRecorder();
  BrandSymbolPainter(color: color).paint(Canvas(recorder), Size.square(side.toDouble()));
  final image = await recorder.endRecording().toImage(side, side);
  final bytes = await image.toByteData(format: ImageByteFormat.png);
  File(p.join(directory.path, fileName)).writeAsBytesSync(bytes!.buffer.asUint8List());
  image.dispose();
}

String _imagesetContents() {
  final entries = <String>[];
  for (final scale in _scales) {
    entries.add(_imageEntry(fileName: _symbolFileName(scale: scale, isDark: false), scale: scale));
    entries.add(_imageEntry(
      fileName: _symbolFileName(scale: scale, isDark: true),
      scale: scale,
      isDark: true,
    ));
  }
  return '{\n  "images" : [\n${entries.join(',\n')}\n  ],\n${_infoBlock()}\n}\n';
}

String _imageEntry({required String fileName, required int scale, bool isDark = false}) {
  final appearances = isDark
      ? '      "appearances" : [\n        {\n          "appearance" : "luminosity",\n'
          '          "value" : "dark"\n        }\n      ],\n'
      : '';
  return '    {\n$appearances      "filename" : "$fileName",\n'
      '      "idiom" : "universal",\n      "scale" : "${scale}x"\n    }';
}

String _colorsetContents({required Color light, required Color dark}) {
  final entries = <String>[
    '    {\n      "color" : ${_colorBlock(light)},\n      "idiom" : "universal"\n    }',
    '    {\n      "appearances" : [\n        {\n          "appearance" : "luminosity",\n'
        '          "value" : "dark"\n        }\n      ],\n'
        '      "color" : ${_colorBlock(dark)},\n      "idiom" : "universal"\n    }',
  ];
  return '{\n  "colors" : [\n${entries.join(',\n')}\n  ],\n${_infoBlock()}\n}\n';
}

String _colorBlock(Color color) {
  return '{\n        "color-space" : "srgb",\n        "components" : {\n'
      '          "alpha" : "1.000",\n'
      '          "blue" : "${_channel(color.b)}",\n'
      '          "green" : "${_channel(color.g)}",\n'
      '          "red" : "${_channel(color.r)}"\n'
      '        }\n      }';
}

String _channel(double value) =>
    '0x${(value * 255).round().toRadixString(16).toUpperCase().padLeft(2, '0')}';

String _infoBlock() => '  "info" : {\n    "author" : "pseudolearn",\n    "version" : 1\n  }';
