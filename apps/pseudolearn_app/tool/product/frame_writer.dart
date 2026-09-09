import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'opaque_png.dart';

Future<File> writeOpaquePngFile({
  required WidgetTester tester,
  required GlobalKey boundaryKey,
  required double rasterScale,
  required String path,
}) async {
  final boundary =
      boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final file = File(path);
  file.parent.createSync(recursive: true);

  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: rasterScale);
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    file.writeAsBytesSync(encodeOpaquePng(RasterizedFrame(
      widthInPixels: image.width,
      heightInPixels: image.height,
      rgbaBytes: data!.buffer.asUint8List(),
    )));
    image.dispose();
  });

  return file;
}
