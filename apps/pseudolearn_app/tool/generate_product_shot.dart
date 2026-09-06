import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:pseudolearn_app/application/execution/execution_cubit.dart';
import 'package:pseudolearn_app/composition/app_dependencies.dart';
import 'package:pseudolearn_app/composition/cubit_scope.dart';
import 'package:pseudolearn_app/domain/model/documents/document.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/app_preferences.dart';
import 'package:pseudolearn_app/domain/model/settings/app_theme_mode.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/presentation/document/components/tab_selector.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';

import '../test/fakes/in_memory_document_repository.dart';
import '../test/fakes/in_memory_preferences_store.dart';
import '../test/fakes/load_bundled_fonts.dart';
import '../test/fakes/test_dependencies.dart';

const String _outputDirectory = '../fe-pseudolearn/src/assets/product';

const double _rasterScale = 2.0;

final GlobalKey _boundaryKey = GlobalKey();

final class _ProductShot {
  final String relativePath;
  final Size canvasSize;
  final AppThemeMode themeMode;
  final UiLanguageId language;
  final String documentId;
  final String documentTitle;
  final String sourcePath;
  final SyntaxProfileId profileId;

  const _ProductShot({
    required this.relativePath,
    required this.canvasSize,
    required this.themeMode,
    required this.language,
    required this.documentId,
    required this.documentTitle,
    required this.sourcePath,
    required this.profileId,
  });
}

const List<_ProductShot> _shots = <_ProductShot>[
  _ProductShot(
    relativePath: 'es/editor-mobile-light.png',
    canvasSize: Size(390, 844),
    themeMode: AppThemeMode.light,
    language: UiLanguageId.spanish,
    documentId: 'demostracion-guiada',
    documentTitle: 'Demostración Guiada',
    sourcePath: 'assets/knowledge/examples/guided_demo_es.pseudo',
    profileId: SyntaxProfileId.classicSpanish,
  ),
  _ProductShot(
    relativePath: 'es/editor-mobile-dark.png',
    canvasSize: Size(390, 844),
    themeMode: AppThemeMode.dark,
    language: UiLanguageId.spanish,
    documentId: 'demostracion-guiada',
    documentTitle: 'Demostración Guiada',
    sourcePath: 'assets/knowledge/examples/guided_demo_es.pseudo',
    profileId: SyntaxProfileId.classicSpanish,
  ),
  _ProductShot(
    relativePath: 'es/editor-desktop-light.png',
    canvasSize: Size(1280, 800),
    themeMode: AppThemeMode.light,
    language: UiLanguageId.spanish,
    documentId: 'demostracion-guiada',
    documentTitle: 'Demostración Guiada',
    sourcePath: 'assets/knowledge/examples/guided_demo_es.pseudo',
    profileId: SyntaxProfileId.classicSpanish,
  ),
  _ProductShot(
    relativePath: 'es/editor-desktop-dark.png',
    canvasSize: Size(1280, 800),
    themeMode: AppThemeMode.dark,
    language: UiLanguageId.spanish,
    documentId: 'demostracion-guiada',
    documentTitle: 'Demostración Guiada',
    sourcePath: 'assets/knowledge/examples/guided_demo_es.pseudo',
    profileId: SyntaxProfileId.classicSpanish,
  ),
  _ProductShot(
    relativePath: 'en/editor-mobile-light.png',
    canvasSize: Size(390, 844),
    themeMode: AppThemeMode.light,
    language: UiLanguageId.english,
    documentId: 'guided-demo',
    documentTitle: 'Guided Demo',
    sourcePath: 'assets/knowledge/examples/guided_demo_en.pseudo',
    profileId: SyntaxProfileId.english,
  ),
  _ProductShot(
    relativePath: 'en/editor-mobile-dark.png',
    canvasSize: Size(390, 844),
    themeMode: AppThemeMode.dark,
    language: UiLanguageId.english,
    documentId: 'guided-demo',
    documentTitle: 'Guided Demo',
    sourcePath: 'assets/knowledge/examples/guided_demo_en.pseudo',
    profileId: SyntaxProfileId.english,
  ),
  _ProductShot(
    relativePath: 'en/editor-desktop-light.png',
    canvasSize: Size(1280, 800),
    themeMode: AppThemeMode.light,
    language: UiLanguageId.english,
    documentId: 'guided-demo',
    documentTitle: 'Guided Demo',
    sourcePath: 'assets/knowledge/examples/guided_demo_en.pseudo',
    profileId: SyntaxProfileId.english,
  ),
  _ProductShot(
    relativePath: 'en/editor-desktop-dark.png',
    canvasSize: Size(1280, 800),
    themeMode: AppThemeMode.dark,
    language: UiLanguageId.english,
    documentId: 'guided-demo',
    documentTitle: 'Guided Demo',
    sourcePath: 'assets/knowledge/examples/guided_demo_en.pseudo',
    profileId: SyntaxProfileId.english,
  ),
];

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadBundledFonts();
  });

  test('the bundled families are the ones that will be rasterized', () {
    expect(
      _advanceWidthOf('iiii'),
      lessThan(_advanceWidthOf('MMMM')),
      reason:
          'Every glyph has the same advance, so the test placeholder font is '
          'still in place and the shots would be rows of blocks',
    );
  });

  for (final shot in _shots) {
    testWidgets(
        '${shot.relativePath} is written from the running document screen',
        (tester) async {
      await _pumpExecutedDocument(tester, shot);

      final execution = BlocProvider.of<ExecutionCubit>(
        tester.element(find.byType(TabSelector)),
      );
      expect(
        execution.state.outputLines,
        isNotEmpty,
        reason:
            'The program did not run, so the shot would show an idle editor',
      );

      final file = await _writeShot(tester, shot.relativePath);
      expect(file.lengthSync(), greaterThan(0));
    });
  }
}

Future<void> _pumpExecutedDocument(
    WidgetTester tester, _ProductShot shot) async {
  tester.view.physicalSize = shot.canvasSize;
  tester.view.devicePixelRatio = 1.0;
  final localeString = shot.language == UiLanguageId.english ? 'en' : 'es';
  tester.platformDispatcher.localesTestValue = <Locale>[Locale(localeString)];
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);

  await tester.pumpWidget(
    RepaintBoundary(
      key: _boundaryKey,
      child: CubitScope(dependencies: _dependenciesFor(shot)),
    ),
  );
  await tester.pumpAndSettle();

  GoRouter.of(tester.element(find.byType(Navigator).first))
      .go('/biblioteca/documento/${shot.documentId}');
  await tester.pumpAndSettle();

  await tester.tap(find.byIcon(Icons.play_arrow).first);
  await tester.pumpAndSettle();

  final l10n = AppLocalizations.of(tester.element(find.byType(TabSelector)))!;
  await tester.tap(find.text(l10n.tabDiagrams));
  await tester.pumpAndSettle();

  await tester.tap(find.byIcon(Icons.crop_square));
  await tester.pumpAndSettle();

  await tester.tap(find.byIcon(Icons.center_focus_strong).first);
  await tester.pumpAndSettle();
}

AppDependencies _dependenciesFor(_ProductShot shot) {
  final repository = InMemoryDocumentRepository();
  final createdAt = DateTime(2026, 8, 15, 12, 0);
  repository.documents[shot.documentId] = Document(
    id: shot.documentId,
    title: shot.documentTitle,
    content: File(shot.sourcePath).readAsStringSync(),
    profileId: shot.profileId,
    revision: 1,
    createdAt: createdAt,
    updatedAt: createdAt,
  );

  return buildTestDependencies(
    repository: repository,
    preferences: InMemoryPreferencesStore(
      const AppPreferences.defaults().copyWith(
        themeMode: shot.themeMode,
        language: shot.language,
      ),
    ),
  );
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
        style: const TextStyle(fontFamily: 'IBMPlexSans', fontSize: 32)),
    textDirection: TextDirection.ltr,
  )..layout();
  return painter.width;
}
