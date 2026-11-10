import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pseudolearn_app/domain/model/settings/app_theme_mode.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/rust/native_rust_transport.dart';
import 'package:pseudolearn_app/presentation/document/components/tab_selector.dart';

import '../test/fakes/load_bundled_fonts.dart';
import 'product/app_stage.dart';
import 'product/bundled_font_probe.dart';
import 'product/product_dependencies.dart';
import 'product/product_documents.dart';
import 'product/scene_actions.dart';
import 'product/scene_stage.dart';
import 'store_plates/plate_recorder.dart';
import 'store_plates/plate_timeline.dart';

const String _outputRoot = 'build/store-plates';
const Size _logicalSize = Size(443, 960);
const double _pixelRatio = 2.0;
const int _fps = 30;
const int _holdFrames = 6;

const Map<UiLanguageId, String> _localeTags = <UiLanguageId, String>{
  UiLanguageId.spanish: 'es',
  UiLanguageId.english: 'en',
};

final GlobalKey _boundaryKey = GlobalKey();

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

  for (final language in _localeTags.keys) {
    testWidgets('the calibration plate is recorded from the running app in '
        '${_localeTags[language]}', (tester) async {
      final timeline = await _recordCalibration(tester, language);
      final decoded = jsonDecode(
        File(p.join(_directoryFor(language).path, 'timeline.json'))
            .readAsStringSync(),
      ) as Map<String, Object?>;
      expect(timeline.frames, hasLength(2 * _holdFrames));
      expect(decoded['pixelWidth'], 886);
      expect(decoded['pixelHeight'], 1920);
      expect(timeline.events.map((event) => event.kind), <PlateEventKind>[
        PlateEventKind.statement,
        PlateEventKind.completion,
      ]);
      expect(timeline.frames.first.focus.single.key, 'tabs');
    });
  }
}

Directory _directoryFor(UiLanguageId language) =>
    Directory(p.join(_outputRoot, 'calibration', _localeTags[language]!));

Future<PlateTimeline> _recordCalibration(
  WidgetTester tester,
  UiLanguageId language,
) async {
  final directory = _directoryFor(language);
  if (directory.existsSync()) directory.deleteSync(recursive: true);
  directory.createSync(recursive: true);
  await _pumpStage(tester, language);
  final stage = SceneStage(tester);
  await openDocument(guidedDemoId)(stage);
  final recorder = PlateRecorder(
    tester: tester,
    boundaryKey: _boundaryKey,
    pixelRatio: _pixelRatio,
    fps: _fps,
    directory: directory,
    focus: <String, Finder>{'tabs': find.byType(TabSelector)},
  );
  recorder.mark(PlateEventKind.statement);
  await recorder.hold(frames: _holdFrames);
  await runToEnd()(stage);
  recorder.mark(PlateEventKind.completion);
  await recorder.hold(frames: _holdFrames);
  return recorder.finish(
    scene: 'calibration',
    language: _localeTags[language]!,
  );
}

Future<void> _pumpStage(WidgetTester tester, UiLanguageId language) async {
  tester.view.physicalSize = _logicalSize;
  tester.view.devicePixelRatio = 1.0;
  tester.platformDispatcher.localesTestValue = <Locale>[
    Locale(_localeTags[language]!),
  ];
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  await tester.pumpWidget(
    RepaintBoundary(
      key: _boundaryKey,
      child: AppStage(
        logicalSize: _logicalSize,
        dependencies: buildProductDependencies(
          language: language,
          themeMode: AppThemeMode.light,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
