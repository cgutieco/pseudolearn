import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pseudolearn_app/composition/cubit_scope.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/presentation/components/layout/app_page.dart';
import 'package:pseudolearn_app/presentation/components/list/app_list_item.dart';
import 'package:pseudolearn_app/presentation/components/list/app_radio_list.dart';
import 'package:pseudolearn_app/presentation/settings/widgets/settings_note.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/settings/language/language_settings_page.dart';
import 'package:pseudolearn_app/presentation/settings/language/language_settings_view.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';
import '../../fakes/test_dependencies.dart';

Widget _buildLanguageSettingsTestApp({
  UiLanguageId selectedLanguage = UiLanguageId.system,
  ValueChanged<UiLanguageId>? onLanguageSelected,
  VoidCallback? onBack,
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
      body: LanguageSettingsView(
        selectedLanguage: selectedLanguage,
        onLanguageSelected: onLanguageSelected ?? (_) {},
        onBack: onBack ?? () {},
      ),
    ),
  );
}

void main() {
  group('LanguageSettingsView Interaction Tests (PANT-05-F3)', () {
    testWidgets('Renders language options and notice', (tester) async {
      await tester.pumpWidget(_buildLanguageSettingsTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Idioma de la interfaz'), findsOneWidget);
      expect(find.text('No cambia el vocabulario de tus documentos'), findsOneWidget);
      expect(find.text('Idioma del sistema'), findsOneWidget);
      expect(find.text('Español'), findsOneWidget);
      expect(find.text('Inglés'), findsOneWidget);
    });

    testWidgets('Selecting an option invokes onLanguageSelected callback', (tester) async {
      UiLanguageId? selected;
      await tester.pumpWidget(_buildLanguageSettingsTestApp(
        onLanguageSelected: (lang) => selected = lang,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(AppListItem, 'Español'));
      await tester.pumpAndSettle();

      expect(selected, equals(UiLanguageId.spanish));
    });

    testWidgets('Renders the explanatory note as its own labelled group', (tester) async {
      await tester.pumpWidget(_buildLanguageSettingsTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Idiomas disponibles'), findsOneWidget);
      expect(find.text('Sobre este ajuste'), findsOneWidget);
      expect(find.byType(SettingsNote), findsOneWidget);
    });

    testWidgets('Back affordance invokes onBack', (tester) async {
      var returned = false;
      await tester.pumpWidget(_buildLanguageSettingsTestApp(onBack: () => returned = true));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      expect(returned, isTrue);
    });

    testWidgets('Shares the page frame with the settings index', (tester) async {
      await tester.pumpWidget(_buildLanguageSettingsTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(AppPage), findsOneWidget);
      expect(find.byType(AppRadioList<UiLanguageId>), findsOneWidget);
    });

    testWidgets('Wraps content in SafeArea to respect device notches and insets', (tester) async {
      await tester.pumpWidget(_buildLanguageSettingsTestApp());
      await tester.pumpAndSettle();

      expect(find.descendant(of: find.byType(LanguageSettingsView), matching: find.byType(SafeArea)), findsOneWidget);
    });
  });

  group('LanguageSettingsPage Dynamic Locale Switching', () {
    testWidgets('Selecting English updates full UI texts to English immediately', (tester) async {
      tester.platformDispatcher.localesTestValue = const [Locale('es')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      final router = GoRouter(
        initialLocation: '/ajustes/idioma',
        routes: [
          GoRoute(
            path: '/ajustes/idioma',
            builder: (context, state) => const LanguageSettingsPage(),
          ),
        ],
      );

      final dependencies = buildTestDependencies();
      await tester.pumpWidget(CubitScope(
        dependencies: dependencies,
        router: router,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Idioma de la interfaz'), findsOneWidget);
      expect(find.text('Inglés'), findsOneWidget);

      await tester.tap(find.widgetWithText(AppListItem, 'Inglés'));
      await tester.pumpAndSettle();

      expect(find.text('Interface language'), findsOneWidget);
      expect(find.text('Does not change the vocabulary of your documents'), findsOneWidget);
      expect(find.text('System language'), findsOneWidget);
      expect(find.text('Spanish'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Idioma de la interfaz'), findsNothing);
    });

    testWidgets('Selecting Spanish after English reverts UI texts to Spanish', (tester) async {
      tester.platformDispatcher.localesTestValue = const [Locale('es')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      final router = GoRouter(
        initialLocation: '/ajustes/idioma',
        routes: [
          GoRoute(
            path: '/ajustes/idioma',
            builder: (context, state) => const LanguageSettingsPage(),
          ),
        ],
      );

      final dependencies = buildTestDependencies();
      await tester.pumpWidget(CubitScope(
        dependencies: dependencies,
        router: router,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(AppListItem, 'Inglés'));
      await tester.pumpAndSettle();
      expect(find.text('Interface language'), findsOneWidget);

      await tester.tap(find.widgetWithText(AppListItem, 'Spanish'));
      await tester.pumpAndSettle();

      expect(find.text('Idioma de la interfaz'), findsOneWidget);
      expect(find.text('Español'), findsOneWidget);
    });
  });
}
