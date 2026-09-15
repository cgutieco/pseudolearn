import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/settings/app_theme_mode.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/presentation/components/layout/app_page.dart';
import 'package:pseudolearn_app/presentation/components/list/app_list_item.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/settings/settings_overview_view.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/spacing.dart';

Widget _buildSettingsOverviewTestApp({
  UiLanguageId currentLanguage = UiLanguageId.spanish,
  AppThemeMode currentThemeMode = AppThemeMode.system,
  bool assistedDiagramZoom = true,
  VoidCallback? onNavigateAccount,
  VoidCallback? onNavigateLanguage,
  VoidCallback? onNavigateTheme,
  VoidCallback? onNavigateDiagram,
  VoidCallback? onRestartOnboarding,
  VoidCallback? onNavigateContact,
}) {
  return MaterialApp(
    theme: AppTheme.light(),
    locale: const Locale('es'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => DesignCanvas(child: child ?? const SizedBox.shrink()),
    home: Scaffold(
      body: SettingsOverviewView(
        currentLanguage: currentLanguage,
        currentThemeMode: currentThemeMode,
        assistedDiagramZoom: assistedDiagramZoom,
        onNavigateAccount: onNavigateAccount ?? () {},
        onNavigateLanguage: onNavigateLanguage ?? () {},
        onNavigateTheme: onNavigateTheme ?? () {},
        onNavigateDiagram: onNavigateDiagram ?? () {},
        onRestartOnboarding: onRestartOnboarding ?? () {},
        onNavigateContact: onNavigateContact ?? () {},
      ),
    ),
  );
}

void main() {
  group('SettingsOverviewView Interaction Tests', () {
    testWidgets('Shows the diagram assistance turned off when it is off', (tester) async {
      await tester.pumpWidget(
        _buildSettingsOverviewTestApp(assistedDiagramZoom: false),
      );
      await tester.pumpAndSettle();

      expect(find.text('No mover el diagrama'), findsOneWidget);
      expect(find.text('Seguir el paso activo'), findsNothing);
    });

    testWidgets('Tapping diagram assistance navigates to its screen', (tester) async {
      var called = false;
      await tester.pumpWidget(
        _buildSettingsOverviewTestApp(onNavigateDiagram: () => called = true),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(AppListItem, 'Zoom asistido en diagramas'));
      await tester.pumpAndSettle();

      expect(called, isTrue);
    });

    testWidgets('Renders all sections, list items, and version footer', (tester) async {
      await tester.pumpWidget(_buildSettingsOverviewTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Ajustes'), findsOneWidget);
      expect(find.text('General'), findsOneWidget);
      expect(find.text('Información'), findsOneWidget);

      expect(find.text('Idioma de la interfaz'), findsOneWidget);
      expect(find.text('Tema visual'), findsOneWidget);
      expect(find.text('Zoom asistido en diagramas'), findsOneWidget);
      expect(find.text('Seguir el paso activo'), findsOneWidget);
      expect(find.text('Ver la introducción de nuevo'), findsOneWidget);
      expect(find.text('Contacto y soporte'), findsOneWidget);
      expect(find.text('v1.0.0'), findsOneWidget);
      expect(find.bySemanticsLabel('PseudoLearn'), findsOneWidget);

      expect(find.text('Cuenta'), findsOneWidget);
      expect(find.text('Perfil y sincronización'), findsNothing);
      expect(find.text('Planes y suscripción'), findsNothing);
      expect(find.text('Sin sincronizar aún'), findsNothing);
    });

    testWidgets('Tapping Language triggers onNavigateLanguage callback', (tester) async {
      var called = false;
      await tester.pumpWidget(_buildSettingsOverviewTestApp(
        onNavigateLanguage: () => called = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(AppListItem, 'Idioma de la interfaz'));
      await tester.pumpAndSettle();
      expect(called, isTrue);
    });

    testWidgets('Tapping Theme triggers onNavigateTheme callback', (tester) async {
      var called = false;
      await tester.pumpWidget(_buildSettingsOverviewTestApp(
        onNavigateTheme: () => called = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(AppListItem, 'Tema visual'));
      await tester.pumpAndSettle();
      expect(called, isTrue);
    });

    testWidgets('Tapping Restart Onboarding triggers onRestartOnboarding callback', (tester) async {
      var called = false;
      await tester.pumpWidget(_buildSettingsOverviewTestApp(
        onRestartOnboarding: () => called = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(AppListItem, 'Ver la introducción de nuevo'));
      await tester.pumpAndSettle();
      expect(called, isTrue);
    });

    testWidgets('Tapping Contact triggers onNavigateContact callback', (tester) async {
      var called = false;
      await tester.pumpWidget(_buildSettingsOverviewTestApp(
        onNavigateContact: () => called = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(AppListItem, 'Contacto y soporte'));
      await tester.pumpAndSettle();
      expect(called, isTrue);
    });

    testWidgets('Tapping Account calls onNavigateAccount callback', (tester) async {
      var called = false;
      await tester.pumpWidget(_buildSettingsOverviewTestApp(
        onNavigateAccount: () => called = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(AppListItem, 'Cuenta'));
      await tester.pumpAndSettle();
      expect(called, isTrue);
    });

    testWidgets('Wraps content in SafeArea to respect device notches and insets', (tester) async {
      await tester.pumpWidget(_buildSettingsOverviewTestApp());
      await tester.pumpAndSettle();

      expect(find.descendant(of: find.byType(SettingsOverviewView), matching: find.byType(SafeArea)), findsOneWidget);
    });

    testWidgets('Builds on the shared page frame, like the other destinations', (tester) async {
      await tester.pumpWidget(_buildSettingsOverviewTestApp());
      await tester.pumpAndSettle();

      expect(find.descendant(of: find.byType(SettingsOverviewView), matching: find.byType(AppPage)), findsOneWidget);
    });

    testWidgets('Leaves its heading on the left margin instead of centring it', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildSettingsOverviewTestApp());
      await tester.pumpAndSettle();

      const metrics = LayoutMetrics.expanded();
      final expectedLeft = metrics.screenMargin * metrics.densityScale;
      final heading = tester.getRect(find.text('Ajustes'));

      expect(heading.left, moreOrLessEquals(expectedLeft, epsilon: 0.5));
    });
  });
}
