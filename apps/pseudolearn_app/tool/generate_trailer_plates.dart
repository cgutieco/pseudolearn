import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';

import '../test/fakes/load_bundled_fonts.dart';
import 'package:pseudolearn_app/engine/rust/native_rust_transport.dart';
import 'product/bundled_font_probe.dart';
import 'product/scene_stage.dart';
import 'store_plates/plate_devices.dart';
import 'store_plates/plate_recorder.dart';
import 'store_plates/plate_stage.dart';
import 'store_plates/plate_timeline.dart';
import 'store_plates/preview_scenes.dart';
import 'store_plates/preview_take.dart';

const String _outputRoot = 'build/store-previews';
const int _fps = 30;
const String _deviceFilter = String.fromEnvironment('STORE_PREVIEW_DEVICES');
const String _sceneFilter = String.fromEnvironment('STORE_PREVIEW_SCENES');
const String _languageFilter =
    String.fromEnvironment('STORE_PREVIEW_LANGUAGES');

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

  final devices = readPlateDevices(storeMediaCatalogPath, previewSlotKind);
  final languages = selectedByName(
      plateLocaleTags.keys.toList(), _languageFilter, (l) => plateLocaleTags[l]!);
  for (final device in selectedByName(devices, _deviceFilter, (d) => d.id)) {
    for (final scene in selectedByName(previewScenes, _sceneFilter, (s) => s.plate)) {
      for (final language in languages) {
        testWidgets('${scene.plate} is recorded live on ${device.id} in '
            '${plateLocaleTags[language]}', (tester) async {
          final timeline = await _record(tester, (device, scene, language));
          expect(timeline.pixelSize, device.pixelSize);
          expect(timeline.frames.length, greaterThan(_fps * 4));
        });
      }
    }
  }
}

Future<PlateTimeline> _record(
  WidgetTester tester,
  (PlateDevice, PreviewScene, UiLanguageId) take,
) async {
  final (device, scene, language) = take;
  final directory = Directory(p.join(_outputRoot, scene.plate, device.id,
      scene.theme, plateLocaleTags[language]!));
  if (directory.existsSync()) directory.deleteSync(recursive: true);
  directory.createSync(recursive: true);
  await pumpPlateStage(
    tester,
    PlateStageSetup(
      language: language,
      themeMode: plateThemes[scene.theme]!,
      logicalSize: device.logicalSize,
      safeInsets: device.insets,
    ),
  );
  final stage = SceneStage(tester);
  for (final action in scene.setup) {
    await action(stage);
  }
  final recorder = PlateRecorder(
    tester: tester,
    boundaryKey: plateBoundaryKey,
    pixelRatio: device.plateScale,
    fps: _fps,
    directory: directory,
    focus: scene.focus(),
  );
  final previewTake = PreviewTake(stage: stage, recorder: recorder);
  await scene.perform(previewTake, language);
  scene.check(previewTake);
  return recorder.finish(scene: scene.plate, language: plateLocaleTags[language]!);
}
