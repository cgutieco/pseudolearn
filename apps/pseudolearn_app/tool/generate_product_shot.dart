import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pseudolearn_app/application/execution/execution_cubit.dart';
import 'package:pseudolearn_app/application/route/route_index_cubit.dart';
import 'package:pseudolearn_app/application/route/route_index_state.dart';
import 'package:pseudolearn_app/domain/model/settings/app_theme_mode.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/rust/native_rust_transport.dart';
import 'package:pseudolearn_app/presentation/document/components/tab_selector.dart';

import '../test/fakes/load_bundled_fonts.dart';
import 'product/app_stage.dart';
import 'product/product_dependencies.dart';
import 'product/product_documents.dart';
import 'product/scene_actions.dart';
import 'product/scene_stage.dart';
import 'product/web_scene_actions.dart';

const String _outputDirectory = '../pseudolearn_web/src/assets/product';

const double _rasterScale = 2.0;

final GlobalKey _boundaryKey = GlobalKey();

enum _Device {
  mobile('mobile', Size(390, 844)),
  desktop('desktop', Size(1280, 800));

  final String slug;
  final Size canvasSize;

  const _Device(this.slug, this.canvasSize);
}

typedef _SceneCheck = void Function(SceneStage stage);

final class _WebScene {
  final String slug;
  final List<_Device> devices;
  final List<SceneAction> script;
  final _SceneCheck check;

  const _WebScene({
    required this.slug,
    required this.devices,
    required this.script,
    required this.check,
  });
}

List<_WebScene> _scenesFor(String localeTag) {
  final lesson = firstBundledLesson(localeTag);
  return <_WebScene>[
    _WebScene(
      slug: 'editor',
      devices: _Device.values,
      script: <SceneAction>[
        openDocument(guidedDemoId),
        runToEnd(),
        openTab(DocumentTabKind.flowchart),
        toggleCompanion(),
      ],
      check: _programProducedOutput,
    ),
    _WebScene(
      slug: 'tasks',
      devices: _Device.values,
      script: <SceneAction>[
        openDocument(tasksDemoId),
        runToEnd(),
        openTab(DocumentTabKind.tasks),
      ],
      check: _programProducedOutput,
    ),
    _WebScene(
      slug: 'lesson',
      devices: _Device.values,
      script: <SceneAction>[openBundledLesson(lesson)],
      check: (stage) => expect(lessonTitleFinder(lesson), findsWidgets),
    ),
    _WebScene(
      slug: 'route',
      devices: _Device.values,
      script: <SceneAction>[openRouteIndex()],
      check: _routeLoaded,
    ),
  ];
}

const Map<UiLanguageId, String> _localeTags = <UiLanguageId, String>{
  UiLanguageId.spanish: 'es',
  UiLanguageId.english: 'en',
};

const Map<AppThemeMode, String> _themeSlugs = <AppThemeMode, String>{
  AppThemeMode.light: 'light',
  AppThemeMode.dark: 'dark',
};

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeNativeBridge();
    await loadBundledFonts();
  });

  setUp(rootBundle.clear);

  test('the bundled families are the ones that will be rasterized', () {
    expect(
      _advanceWidthOf('iiii'),
      lessThan(_advanceWidthOf('MMMM')),
      reason:
          'Every glyph has the same advance, so the test placeholder font is '
          'still in place and the shots would be rows of blocks',
    );
  });

  for (final language in _localeTags.keys) {
    for (final scene in _scenesFor(_localeTags[language]!)) {
      for (final device in scene.devices) {
        for (final themeMode in _themeSlugs.keys) {
          final relativePath = _shotPath(language, scene, device, themeMode);
          testWidgets('$relativePath is written from the running app', (
            tester,
          ) async {
            await _pumpScene(tester, language, scene, device, themeMode);
            final file = await _writeShot(tester, relativePath);
            expect(file.lengthSync(), greaterThan(0));
          });
        }
      }
    }
  }
}

String _shotPath(
  UiLanguageId language,
  _WebScene scene,
  _Device device,
  AppThemeMode themeMode,
) {
  final name = '${scene.slug}-${device.slug}-${_themeSlugs[themeMode]}.png';
  return p.join(_localeTags[language]!, name);
}

Future<void> _pumpScene(
  WidgetTester tester,
  UiLanguageId language,
  _WebScene scene,
  _Device device,
  AppThemeMode themeMode,
) async {
  tester.view.physicalSize = device.canvasSize;
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
        logicalSize: device.canvasSize,
        dependencies: buildProductDependencies(
          language: language,
          themeMode: themeMode,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final stage = SceneStage(tester);
  for (final action in scene.script) {
    await action(stage);
  }
  scene.check(stage);
}

void _programProducedOutput(SceneStage stage) {
  final execution = BlocProvider.of<ExecutionCubit>(
    stage.tester.element(find.byType(TabSelector)),
  );
  expect(
    execution.state.outputLines,
    isNotEmpty,
    reason: 'The program did not run, so the shot would show an idle editor',
  );
}

void _routeLoaded(SceneStage stage) {
  final route = BlocProvider.of<RouteIndexCubit>(stage.appContext).state;
  expect(route.status, RouteIndexStatus.success);
  expect(route.toc.lessons, isNotEmpty);
}

Future<File> _writeShot(WidgetTester tester, String relativePath) async {
  final boundary =
      _boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final file = File(p.join(_outputDirectory, relativePath));
  file.parent.createSync(recursive: true);

  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: _rasterScale);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    file.writeAsBytesSync(bytes!.buffer.asUint8List());
    image.dispose();
  });

  return file;
}

double _advanceWidthOf(String text) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: const TextStyle(fontFamily: 'IBMPlexSans', fontSize: 32),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  return painter.width;
}
