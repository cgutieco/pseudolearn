import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../product/opaque_png.dart';
import 'plate_timeline.dart';

typedef FocusProbe = Map<String, Finder>;

final class PlateRecorder {
  final WidgetTester tester;
  final GlobalKey boundaryKey;
  final double pixelRatio;
  final int fps;
  final Directory directory;
  final FocusProbe focus;
  final List<PlateFrame> _frames = <PlateFrame>[];
  final List<PlateEvent> _events = <PlateEvent>[];
  Uint8List? _previousPixels;
  String? _previousFile;

  PlateRecorder({
    required this.tester,
    required this.boundaryKey,
    required this.pixelRatio,
    required this.fps,
    required this.directory,
    required this.focus,
  });

  Duration get frameDuration =>
      Duration(microseconds: Duration.microsecondsPerSecond ~/ fps);

  Future<void> hold({required int frames}) async {
    for (var frame = 0; frame < frames; frame++) {
      await tester.pump(frameDuration);
      await _capture();
    }
  }

  void mark(PlateEventKind kind) {
    _events.add(PlateEvent(frame: _frames.length, kind: kind));
  }

  void markTap(Finder target) {
    final origin = tester.getTopLeft(find.byKey(boundaryKey));
    final center = tester.getCenter(target.first) - origin;
    _events.add(PlateEvent(
      frame: _frames.length,
      kind: PlateEventKind.tap,
      point: center * pixelRatio,
    ));
  }

  Future<PlateTimeline> finish({
    required String scene,
    required String language,
  }) async {
    final boundary = _boundary();
    final timeline = PlateTimeline(
      scene: scene,
      language: language,
      fps: fps,
      pixelSize: boundary.size * pixelRatio,
      frames: List<PlateFrame>.unmodifiable(_frames),
      events: _events
          .where((event) => event.frame < _frames.length)
          .toList(growable: false),
    );
    File(p.join(directory.path, 'timeline.json'))
        .writeAsStringSync(timeline.encode());
    return timeline;
  }

  Future<void> _capture() async {
    final index = _frames.length;
    final name = 'frame_${(index + 1).toString().padLeft(6, '0')}.png';
    final boundary = _boundary();
    final file = await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      final pixels = data!.buffer.asUint8List();
      final repeated = _previousFile != null && listEquals(pixels, _previousPixels);
      if (!repeated) {
        File(p.join(directory.path, name)).writeAsBytesSync(
          encodeOpaquePng(RasterizedFrame(
            widthInPixels: image.width,
            heightInPixels: image.height,
            rgbaBytes: pixels,
          )),
        );
        _previousPixels = pixels;
        _previousFile = name;
      }
      image.dispose();
      return _previousFile!;
    });
    _frames.add(PlateFrame(index: index, file: file!, focus: _focusRects()));
  }

  List<PlateFocus> _focusRects() {
    final origin = tester.getTopLeft(find.byKey(boundaryKey));
    final plate = Offset.zero & (_boundary().size * pixelRatio);
    return <PlateFocus>[
      for (final entry in focus.entries)
        if (_present(entry.value))
          if (_pixelRect(entry.value, origin).intersect(plate) case final rect
              when rect.width > 0 && rect.height > 0)
            PlateFocus(key: entry.key, pixelRect: rect),
    ];
  }

  Rect _pixelRect(Finder finder, Offset origin) {
    final logical = tester.getRect(finder.first).shift(-origin);
    return Rect.fromLTWH(
      logical.left * pixelRatio,
      logical.top * pixelRatio,
      logical.width * pixelRatio,
      logical.height * pixelRatio,
    );
  }

  bool _present(Finder finder) {
    try {
      return finder.evaluate().isNotEmpty;
    } on StateError {
      return false;
    }
  }

  RenderRepaintBoundary _boundary() =>
      boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
}
