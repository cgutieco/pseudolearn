import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/rust/native_rust_transport.dart';

import '../test/fakes/load_bundled_fonts.dart';
import 'product/bundled_font_probe.dart';
import 'product/scene_stage.dart';
import 'store_plates/live_take.dart';
import 'store_plates/plate_devices.dart';
import 'store_plates/plate_recorder.dart';
import 'store_plates/plate_stage.dart';
import 'store_plates/plate_timeline.dart';
import 'store_plates/trailer_scene.dart';

const String _outputRoot = 'build/trailer-plates';
const int _fps = 30;

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeNativeBridge();
    await loadBundledFonts();
  });

  setUp(rootBundle.clear);

  test('the bundled families are the ones that will be rasterized', () {
    expectBundledFontsRasterized();
  });

  for (final device in readPlateDevices(storeMediaCatalogPath, trailerSlotKind)) {
    for (final language in plateLocaleTags.keys) {
      testWidgets('$trailerPlate is recorded live on ${device.id} in '
          '${plateLocaleTags[language]}', (tester) async {
        final timeline = await _record(tester, device, language);
        expect(timeline.pixelSize, device.pixelSize);
        expect(timeline.frames.length, greaterThan(_fps * 7));
      });
    }
  }
}

Future<PlateTimeline> _record(
  WidgetTester tester,
  PlateDevice device,
  UiLanguageId language,
) async {
  final directory = Directory(p.join(_outputRoot, trailerPlate, device.id,
      trailerTheme, plateLocaleTags[language]!));
  if (directory.existsSync()) directory.deleteSync(recursive: true);
  directory.createSync(recursive: true);
  await pumpPlateStage(
    tester,
    PlateStageSetup(
      language: language,
      themeMode: plateThemes[trailerTheme]!,
      logicalSize: device.logicalSize,
    ),
  );
  final stage = SceneStage(tester);
  for (final action in trailerSetup) {
    await action(stage);
  }
  final take = LiveTake(
    stage: stage,
    recorder: PlateRecorder(
      tester: tester,
      boundaryKey: plateBoundaryKey,
      pixelRatio: device.plateScale,
      fps: _fps,
      directory: directory,
      focus: trailerFocus(),
    ),
  );
  await performTrailerRun(take);
  expectTrailerRunPaused(take);
  return take.recorder.finish(scene: trailerPlate, language: plateLocaleTags[language]!);
}
