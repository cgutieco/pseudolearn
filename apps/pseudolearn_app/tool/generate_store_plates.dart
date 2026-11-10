import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pseudolearn_app/domain/model/settings/app_theme_mode.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/rust/native_rust_transport.dart';

import '../test/fakes/native_test_engine.dart';
import 'package:pseudolearn_app/presentation/document/components/tab_selector.dart';

import '../test/fakes/load_bundled_fonts.dart';
import 'product/app_stage.dart';
import 'product/bundled_font_probe.dart';
import 'product/product_dependencies.dart';
import 'product/product_documents.dart';
import 'product/scene_actions.dart';
import 'product/scene_stage.dart';
import 'store_plates/chapter_scenes.dart';
import 'store_plates/plate_agent.dart';
import 'store_plates/plate_devices.dart';
import 'store_plates/plate_recorder.dart';
import 'store_plates/plate_timeline.dart';
import 'store_plates/story_code.dart';

const String _outputRoot = 'build/store-plates';
const Size _logicalSize = Size(443, 960);
const double _pixelRatio = 2.0;
const int _fps = 30;
const int _holdFrames = 6;
const String _themeFilter =
    String.fromEnvironment('STORE_PLATE_THEMES', defaultValue: 'light,dark');
const String _deviceFilter = String.fromEnvironment('STORE_PLATE_DEVICES');
const String _chapterFilter = String.fromEnvironment('STORE_PLATE_CHAPTERS');

const Map<UiLanguageId, SyntaxProfileId> _storyProfiles =
    <UiLanguageId, SyntaxProfileId>{
  UiLanguageId.spanish: SyntaxProfileId.classicSpanish,
  UiLanguageId.english: SyntaxProfileId.english,
};

const Map<String, AppThemeMode> _themes = <String, AppThemeMode>{
  'light': AppThemeMode.light,
  'dark': AppThemeMode.dark,
};

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
    test('the code the store story shows passes the analyzer in '
        '${_localeTags[language]}', () {
      final programs = storyPrograms(language);
      expect(programs, isNotEmpty);
      for (final program in programs) {
        final report = nativeTestEngine.analyzer.analyze(
          sourceCode: program,
          profileId: _storyProfiles[language]!,
          languageId: language,
        );
        expect(report.isExecutable && !report.hasErrors, isTrue,
            reason: program);
      }
    });
  }

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

  for (final device in _selected(readPlateDevices(), _deviceFilter, (d) => d.id)) {
    for (final chapter in _selected(chapterScenes, _chapterFilter, (c) => c.plate)) {
      for (final theme in _selected(_themes.keys.toList(), _themeFilter, (t) => t)) {
        for (final language in _localeTags.keys) {
          testWidgets('${chapter.plate} is recorded on ${device.id} in $theme '
              '${_localeTags[language]}', (tester) async {
            final timeline = await _recordChapter(
              tester,
              _ChapterTake(device, chapter, theme, language),
            );
            expect(timeline.pixelSize, device.pixelSize);
          });
        }
      }
    }
  }
}

List<T> _selected<T>(List<T> all, String filter, String Function(T) name) {
  final wanted = filter.split(',').where((entry) => entry.isNotEmpty).toSet();
  return wanted.isEmpty
      ? all
      : all.where((entry) => wanted.contains(name(entry))).toList();
}

final class _ChapterTake {
  final PlateDevice device;
  final ChapterScene chapter;
  final String theme;
  final UiLanguageId language;

  const _ChapterTake(this.device, this.chapter, this.theme, this.language);

  Directory get directory => Directory(p.join(
        _outputRoot,
        chapter.plate,
        device.id,
        theme,
        _localeTags[language]!,
      ));
}

Future<PlateTimeline> _recordChapter(
  WidgetTester tester,
  _ChapterTake take,
) async {
  final directory = take.directory;
  if (directory.existsSync()) directory.deleteSync(recursive: true);
  directory.createSync(recursive: true);
  await _pumpStage(
    tester,
    _StageSetup(
      language: take.language,
      themeMode: _themes[take.theme]!,
      logicalSize: take.device.logicalSize,
    ),
  );
  final stage = SceneStage(tester);
  for (final action in take.chapter.script(take.language)) {
    await action(stage);
  }
  take.chapter.check(stage);
  final recorder = PlateRecorder(
    tester: tester,
    boundaryKey: _boundaryKey,
    pixelRatio: take.device.plateScale,
    fps: _fps,
    directory: directory,
    focus: take.chapter.focus(),
  );
  recorder.mark(PlateEventKind.completion);
  await recorder.hold(frames: 1);
  return recorder.finish(
    scene: take.chapter.plate,
    language: _localeTags[take.language]!,
  );
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
  await _pumpStage(tester, _StageSetup(language: language));
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

final class _StageSetup {
  final UiLanguageId language;
  final AppThemeMode themeMode;
  final Size logicalSize;

  const _StageSetup({
    required this.language,
    this.themeMode = AppThemeMode.light,
    this.logicalSize = _logicalSize,
  });
}

Future<void> _pumpStage(WidgetTester tester, _StageSetup setup) async {
  tester.view.physicalSize = setup.logicalSize;
  tester.view.devicePixelRatio = 1.0;
  tester.platformDispatcher.localesTestValue = <Locale>[
    Locale(_localeTags[setup.language]!),
  ];
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  await tester.pumpWidget(
    RepaintBoundary(
      key: _boundaryKey,
      child: AppStage(
        logicalSize: setup.logicalSize,
        dependencies: buildProductDependencies(
          language: setup.language,
          themeMode: setup.themeMode,
          agent: scriptedNodo(setup.language),
          authGateway: signedInGateway(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
