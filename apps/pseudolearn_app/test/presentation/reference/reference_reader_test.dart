import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/reference/bundled_reference_repository.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_load_result.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_edition.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_section.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/reference/reference_reader.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

const _edition = ReferenceEdition(
  language: UiLanguageId.spanish,
  profile: SyntaxProfileId.classicSpanish,
);

Future<ReferenceSection> _section(String id) async {
  final repository = BundledReferenceRepository(
    assetLoader: (path) async => File(path).readAsString(),
  );
  final loaded = await repository.loadSection(_edition, id);
  return (loaded as ContentLoaded<ReferenceSection>).value;
}

Widget _app(Widget child, {required bool dark}) => MaterialApp(
  theme: dark ? AppTheme.dark() : AppTheme.light(),
  locale: const Locale('es'),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, c) => DesignCanvas(child: c ?? const SizedBox.shrink()),
  home: Scaffold(body: child),
);

void main() {
  for (final dark in [false, true]) {
    testWidgets('renders a compiled section on a phone (dark: $dark)', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final section = await tester.runAsync(() => _section('control.si'));
      final opened = <String>[];
      await tester.pumpWidget(
        _app(
          ReferenceReader(section: section!, edition: _edition, anchor: null, onOpenSection: opened.add),
          dark: dark,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('6.1.1'), findsOneWidget);
      expect(find.byIcon(Icons.toc_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('renders the arrays section with its anatomy on a phone', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final section = await tester.runAsync(() => _section('tipos.arreglos'));
    await tester.pumpWidget(
      _app(
        ReferenceReader(section: section!, edition: _edition, anchor: null, onOpenSection: (_) {}),
        dark: false,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Pieza por pieza'), findsOneWidget);
    expect(find.textContaining('para todos los arreglos', findRichText: true), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('steps through a figure', (tester) async {
    tester.view.physicalSize = const Size(375, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final section = await tester.runAsync(() => _section('control.si'));
    await tester.pumpWidget(
      _app(ReferenceReader(section: section!, edition: _edition, anchor: 'funciona', onOpenSection: (_) {}), dark: false),
    );
    await tester.pumpAndSettle();
    final next = find.textContaining('Siguiente');
    await tester.ensureVisible(next.first);
    expect(find.text('Paso 1 de 5'), findsOneWidget);
    await tester.tap(next.first);
    await tester.pumpAndSettle();
    expect(find.text('Paso 2 de 5'), findsOneWidget);
  });

  testWidgets('shows the contents column on wide screens', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final section = await tester.runAsync(() => _section('control.si'));
    await tester.pumpWidget(
      _app(ReferenceReader(section: section!, edition: _edition, anchor: null, onOpenSection: (_) {}), dark: false),
    );
    await tester.pumpAndSettle();
    expect(find.text('En esta sección'), findsOneWidget);
    expect(find.byIcon(Icons.toc_rounded), findsNothing);
  });

  for (final dark in [false, true]) {
    testWidgets('meets the accessibility guidelines with doubled text (dark: $dark)', (tester) async {
      final semantics = tester.ensureSemantics();
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final section = await tester.runAsync(() => _section('expresiones.precedencia'));
      await tester.pumpWidget(
        _app(ReferenceReader(section: section!, edition: _edition, anchor: null, onOpenSection: (_) {}), dark: dark),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      semantics.dispose();
    });
  }
}
