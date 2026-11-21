import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pseudolearn_app/presentation/brand/brand_symbol.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/brand_metrics.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/color_semantic.dart';

import 'app_icon_canvas.dart';

const String _resourcesPath = 'android/app/src/main/res';
const Map<String, double> _densityScales = <String, double>{
  'mdpi': 1,
  'hdpi': 1.5,
  'xhdpi': 2,
  'xxhdpi': 3,
  'xxxhdpi': 4,
};
const double _legacyIconDp = 48;
const double _adaptiveLayerDp = 108;
const double _adaptiveVisibleDp = 72;
const double _splashIconCanvasDp = 288;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('android launcher and launch resources are generated from the brand geometry', () async {
    const light = AppSemanticColors.light();
    const dark = AppSemanticColors.dark();
    for (final MapEntry(key: density, value: scale) in _densityScales.entries) {
      await _writeLauncherIcons(density, scale);
      await _writeLaunchSymbols(density, scale, lightInk: light.brandInk.signature, darkInk: dark.brandInk.signature);
    }
    _writeAdaptiveIconDeclaration();
    _writeLaunchColors(light: light.surfaces.canvas, dark: dark.surfaces.canvas);
    _writeLaunchBackground();
    _writeThemes();

    expect(File(p.join(_resourcesPath, 'mipmap-xxxhdpi', 'ic_launcher_foreground.png')).existsSync(), isTrue);
    expect(File(p.join(_resourcesPath, 'mipmap-anydpi-v26', 'ic_launcher.xml')).existsSync(), isTrue);
    expect(File(p.join(_resourcesPath, 'values-night-v31', 'styles.xml')).existsSync(), isTrue);
  });
}

Future<void> _writeLauncherIcons(String density, double scale) async {
  final folder = 'mipmap-$density';
  _writeBytes(folder, 'ic_launcher.png', await renderAppIcon(_pixels(_legacyIconDp, scale)));
  final layerPixels = _pixels(_adaptiveLayerDp, scale);
  _writeBytes(
    folder,
    'ic_launcher_background.png',
    await renderDesignCanvas(layerPixels, (canvas) {
      paintAppIconBackground(canvas, const Rect.fromLTWH(0, 0, appIconDesignSide, appIconDesignSide));
    }),
  );
  _writeBytes(folder, 'ic_launcher_foreground.png', await renderDesignCanvas(layerPixels, _paintSymbolInVisibleArea));
}

void _paintSymbolInVisibleArea(Canvas canvas) {
  const visibleFraction = _adaptiveVisibleDp / _adaptiveLayerDp;
  const margin = appIconDesignSide * (1 - visibleFraction) / 2;
  canvas
    ..save()
    ..translate(margin, margin)
    ..scale(visibleFraction);
  paintAppIconSymbol(canvas);
  canvas.restore();
}

Future<void> _writeLaunchSymbols(
  String density,
  double scale, {
  required Color lightInk,
  required Color darkInk,
}) async {
  for (final (folder, ink) in [('drawable-$density', lightInk), ('drawable-night-$density', darkInk)]) {
    _writeBytes(folder, 'launch_symbol.png', await _renderCentredSymbol(ink, scale, BrandMetricsTokens.symbolSizeLaunch));
    _writeBytes(folder, 'splash_symbol.png', await _renderCentredSymbol(ink, scale, _splashIconCanvasDp));
  }
}

Future<Uint8List> _renderCentredSymbol(Color ink, double scale, double canvasDp) async {
  final side = _pixels(canvasDp, scale);
  final symbolSide = BrandMetricsTokens.symbolSizeLaunch * scale;
  final offset = (side - symbolSide) / 2;
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder)..translate(offset, offset);
  BrandSymbolPainter(color: ink).paint(canvas, Size.square(symbolSide));
  final image = await recorder.endRecording().toImage(side, side);
  final bytes = await image.toByteData(format: ImageByteFormat.png);
  image.dispose();
  return bytes!.buffer.asUint8List();
}

void _writeAdaptiveIconDeclaration() {
  _writeText('mipmap-anydpi-v26', 'ic_launcher.xml', '''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@mipmap/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
    <monochrome android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
''');
}

void _writeLaunchColors({required Color light, required Color dark}) {
  for (final (folder, color) in [('values', light), ('values-night', dark)]) {
    _writeText(folder, 'colors.xml', '''<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="launch_background">${_hex(color)}</color>
</resources>
''');
  }
}

void _writeLaunchBackground() {
  _writeText('drawable', 'launch_background.xml', '''<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@color/launch_background"/>
    <item>
        <bitmap android:gravity="center" android:src="@drawable/launch_symbol"/>
    </item>
</layer-list>
''');
}

void _writeThemes() {
  for (final (suffix, parent) in [('', 'Light'), ('-night', 'Black')]) {
    _writeText('values$suffix', 'styles.xml', _themes(parent, ''));
    _writeText('values$suffix-v31', 'styles.xml', _themes(parent, '''
        <item name="android:windowSplashScreenBackground">@color/launch_background</item>
        <item name="android:windowSplashScreenAnimatedIcon">@drawable/splash_symbol</item>
'''));
  }
}

String _themes(String parent, String splashItems) => '''<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="LaunchTheme" parent="@android:style/Theme.$parent.NoTitleBar">
        <item name="android:windowBackground">@drawable/launch_background</item>
$splashItems    </style>
    <style name="NormalTheme" parent="@android:style/Theme.$parent.NoTitleBar">
        <item name="android:windowBackground">@color/launch_background</item>
    </style>
</resources>
''';

String _hex(Color color) {
  String channel(double value) => (value * 255).round().toRadixString(16).toUpperCase().padLeft(2, '0');
  return '#${channel(color.a)}${channel(color.r)}${channel(color.g)}${channel(color.b)}';
}

int _pixels(double dp, double scale) => (dp * scale).round();

void _writeBytes(String folder, String name, Uint8List bytes) {
  final file = File(p.join(_resourcesPath, folder, name))..parent.createSync(recursive: true);
  file.writeAsBytesSync(bytes);
}

void _writeText(String folder, String name, String content) {
  final file = File(p.join(_resourcesPath, folder, name))..parent.createSync(recursive: true);
  file.writeAsStringSync(content);
}
