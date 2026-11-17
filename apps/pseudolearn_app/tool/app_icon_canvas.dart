import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:pseudolearn_app/presentation/brand/brand_symbol_geometry.dart';

const double appIconDesignSide = 1024;

void paintAppIconBackground(Canvas canvas, Rect bounds) {
  canvas.drawRect(
    bounds,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0xFF195C5F), Color(0xFF0F4346)],
      ).createShader(bounds),
  );
}

void paintAppIconSymbol(Canvas canvas) {
  canvas
    ..save()
    ..translate(230.4, 224.472)
    ..scale(5.928421)
    ..drawPath(buildBrandSymbolPath(), Paint()..color = const Color(0xFFFFFFFF))
    ..restore();
}

Future<Uint8List> renderAppIcon(int pixels) => renderDesignCanvas(pixels, (canvas) {
  paintAppIconBackground(canvas, const Rect.fromLTWH(0, 0, appIconDesignSide, appIconDesignSide));
  paintAppIconSymbol(canvas);
});

Future<Uint8List> renderDesignCanvas(int pixels, void Function(Canvas canvas) draw) async {
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder)..scale(pixels / appIconDesignSide);
  draw(canvas);
  final image = await recorder.endRecording().toImage(pixels, pixels);
  final bytes = await image.toByteData(format: ImageByteFormat.png);
  final png = bytes!.buffer.asUint8List();
  image.dispose();
  return png;
}
