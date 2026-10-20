import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/settings/app_theme_mode.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/settings/settings_overview_view.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

Future<void> _pumpSettingsOverviewView(
  WidgetTester tester, {
  required Size size,
  required ThemeData theme,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      locale: const Locale('es'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) =>
          DesignCanvas(child: child ?? const SizedBox.shrink()),
      home: Scaffold(
        body: SettingsOverviewView(
          currentLanguage: UiLanguageId.spanish,
          currentThemeMode: AppThemeMode.system,
          assistedDiagramZoom: true,
          editorAssistance: false,
          appVersion: '1.0.0',
          onNavigateAccount: () {},
          onNavigateLanguage: () {},
          onNavigateTheme: () {},
          onNavigateDiagram: () {},
          onNavigateEditor: () {},
          onRestartOnboarding: () {},
          onNavigateContact: () {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group(
    'SettingsOverviewPage render checks (PANT-05-F3) — three widths, two themes',
    () {
      final widths = <String, double>{
        'compact': 360,
        'medium': 600,
        'expanded': 960,
      };

      for (final widthEntry in widths.entries) {
        testWidgets('overview · ${widthEntry.key} · light', (tester) async {
          await _pumpSettingsOverviewView(
            tester,
            size: Size(widthEntry.value, 800),
            theme: AppTheme.light(),
          );
          expect(find.byType(MaterialApp), findsOneWidget);
          expect(tester.takeException(), isNull);
        });

        testWidgets('overview · ${widthEntry.key} · dark', (tester) async {
          await _pumpSettingsOverviewView(
            tester,
            size: Size(widthEntry.value, 800),
            theme: AppTheme.dark(),
          );
          expect(find.byType(MaterialApp), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    },
  );
}
