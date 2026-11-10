import 'package:flutter_test/flutter_test.dart';

import '../product/scene_stage.dart';
import 'plate_recorder.dart';
import 'plate_timeline.dart';

final class PreviewTake {
  final SceneStage stage;
  final PlateRecorder recorder;

  const PreviewTake({required this.stage, required this.recorder});

  WidgetTester get tester => stage.tester;

  Future<void> hold(double seconds) =>
      recorder.hold(frames: (seconds * recorder.fps).round());

  Future<void> tap(Finder target, {PlateEventKind? mark}) async {
    recorder.markTap(target);
    if (mark != null) recorder.mark(mark);
    await tester.tap(target.first);
  }

  Future<void> type(Finder field, String text) =>
      tester.enterText(field.first, text);

  Future<void> fling(Finder target, Offset offset, double speed) =>
      tester.fling(target.first, offset, speed);

  void mark(PlateEventKind kind) => recorder.mark(kind);
}
