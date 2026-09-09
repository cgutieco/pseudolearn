import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';

import '../test/fakes/load_bundled_fonts.dart';
import 'product/bundled_font_probe.dart';
import 'product/app_stage.dart';
import 'product/feature_graphic.dart';
import 'product/frame_writer.dart';
import 'product/marketing_copy.dart';
import 'product/marketing_lexicon.dart';
import 'product/png_header.dart';
import 'product/product_dependencies.dart';
import 'product/product_theme.dart';
import 'product/promo_frame.dart';
import 'product/promo_layout.dart';
import 'product/scene_scripts.dart';
import 'product/scene_stage.dart';
import 'product/store_catalogue.dart';
import 'product/store_scene.dart';
import 'product/store_target.dart';

const String _outputRoot = 'build/store';
const int _truecolourWithoutAlpha = 2;

final GlobalKey _boundaryKey = GlobalKey();

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadBundledFonts();
  });

  setUp(rootBundle.clear);

  test('the bundled families are the ones that will be rasterized', () {
    expectBundledFontsRasterized();
  });

  test('no headline carries vocabulary the stores reject', () {
    final violations = <MarketingViolation>[];
    for (final target in screenshotTargets) {
      for (final language in productLanguages) {
        for (final scene in storyOrder) {
          violations.addAll(
            auditHeadline(storeHeadlines[language]![scene]!, target.audience),
          );
        }
      }
    }
    for (final language in productLanguages) {
      violations.addAll(auditHeadline(
        featureGraphicTagline[language]!,
        googlePlayFeatureGraphic.audience,
      ));
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('every headline fits the band its frame reserves for it', () {
    final overflowing = <String>[];
    for (final target in screenshotTargets) {
      final layout = _layoutOf(target);
      for (final language in productLanguages) {
        for (final scene in storyOrder) {
          final headline = storeHeadlines[language]![scene]!;
          if (_overflows(headline, layout, target)) {
            overflowing.add('${target.destination.name} / $headline');
          }
        }
      }
    }
    expect(overflowing, isEmpty, reason: overflowing.join('\n'));
  });

  for (final target in screenshotTargets) {
    for (final language in productLanguages) {
      for (final scene in storyOrder) {
        testWidgets(
          '${target.destination.directoryName} ${localeTags[language]} '
          '${scene.fileSlug} is composed over the running app',
          (tester) async {
            await _writeScreenshot(
              tester: tester,
              target: target,
              language: language,
              scene: scene,
            );
          },
        );
      }
    }
  }

  for (final language in productLanguages) {
    testWidgets(
      'the google play feature graphic is composed for '
      '${localeTags[language]}',
      (tester) async {
        await _writeFeatureGraphic(tester: tester, language: language);
      },
    );
  }
}

PromoLayout _layoutOf(ScreenshotTarget target) => PromoLayout(
      frameSize: target.frameLogicalSize,
      appLogicalSize: target.appLogicalSize,
    );

bool _overflows(String headline, PromoLayout layout, ScreenshotTarget target) {
  final painter = TextPainter(
    text: TextSpan(
      text: headline,
      style: headlineStyleOf(layout, productColors[target.themeMode]!),
    ),
    textDirection: TextDirection.ltr,
    maxLines: layout.headlineMaxLines,
  )..layout(maxWidth: layout.headlineWidth);
  return painter.didExceedMaxLines;
}

Future<void> _writeScreenshot({
  required WidgetTester tester,
  required ScreenshotTarget target,
  required UiLanguageId language,
  required StoreScene scene,
}) async {
  _prepareView(tester, target.pixelSize, target.rasterScale, language);
  final layout = _layoutOf(target);

  await tester.pumpWidget(
    RepaintBoundary(
      key: _boundaryKey,
      child: PromoFrame(
        layout: layout,
        colors: productColors[target.themeMode]!,
        elevation: productElevation[target.themeMode]!,
        headline: storeHeadlines[language]![scene]!,
        appRender: AppStage(
          logicalSize: target.appLogicalSize,
          dependencies: buildProductDependencies(
            language: language,
            themeMode: target.themeMode,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final stage = SceneStage(tester);
  final spec = storeSceneSpecs[scene]!;
  for (final action in spec.script) {
    await action(stage);
  }
  spec.check(stage);

  await _rasterizeAndVerify(
    tester: tester,
    rasterScale: target.rasterScale,
    pixelSize: target.pixelSize,
    path: p.join(
      _outputRoot,
      target.destination.directoryName,
      localeTags[language]!,
      '${scene.fileSlug}.png',
    ),
  );
}

Future<void> _writeFeatureGraphic({
  required WidgetTester tester,
  required UiLanguageId language,
}) async {
  final target = googlePlayFeatureGraphic;
  _prepareView(tester, target.pixelSize, target.rasterScale, language);

  await tester.pumpWidget(
    RepaintBoundary(
      key: _boundaryKey,
      child: FeatureGraphic(
        frameSize: target.frameLogicalSize,
        colors: productColors[target.themeMode]!,
        theme: productThemes[target.themeMode]!,
        locale: Locale(localeTags[language]!),
        tagline: featureGraphicTagline[language]!,
      ),
    ),
  );
  await tester.pumpAndSettle();

  await _rasterizeAndVerify(
    tester: tester,
    rasterScale: target.rasterScale,
    pixelSize: target.pixelSize,
    path: p.join(
      _outputRoot,
      target.destination.directoryName,
      '${localeTags[language]}.png',
    ),
  );
}

void _prepareView(
  WidgetTester tester,
  Size pixelSize,
  double rasterScale,
  UiLanguageId language,
) {
  tester.view.physicalSize = pixelSize;
  tester.view.devicePixelRatio = rasterScale;
  tester.platformDispatcher.localesTestValue = <Locale>[
    Locale(localeTags[language]!),
  ];
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
}

Future<void> _rasterizeAndVerify({
  required WidgetTester tester,
  required double rasterScale,
  required Size pixelSize,
  required String path,
}) async {
  final file = await writeOpaquePngFile(
    tester: tester,
    boundaryKey: _boundaryKey,
    rasterScale: rasterScale,
    path: path,
  );

  final header = readPngHeader(file.readAsBytesSync());
  expect(
    header.colourType,
    _truecolourWithoutAlpha,
    reason: 'Both stores reject artwork that carries an alpha channel',
  );
  expect(header.carriesAlphaChannel, isFalse);
  expect(header.widthInPixels, pixelSize.width.round());
  expect(header.heightInPixels, pixelSize.height.round());
}
