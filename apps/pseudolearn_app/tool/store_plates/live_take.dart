import 'package:flutter_test/flutter_test.dart';

import '../product/scene_stage.dart';
import 'plate_recorder.dart';
import 'plate_timeline.dart';

final class LiveTake {
  final SceneStage stage;
  final PlateRecorder recorder;

  const LiveTake({required this.stage, required this.recorder});

  Future<void> hold(double seconds) =>
      recorder.hold(frames: (seconds * recorder.fps).round());

  Future<void> tap(Finder target, {PlateEventKind? mark}) async {
    recorder.markTap(target);
    if (mark != null) recorder.mark(mark);
    await stage.tester.tap(target.first);
  }
}
