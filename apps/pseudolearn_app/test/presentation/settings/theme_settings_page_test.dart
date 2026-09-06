import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/settings/app_theme_mode.dart';
import 'package:pseudolearn_app/presentation/components/layout/app_page.dart';
import 'package:pseudolearn_app/presentation/components/list/app_list_item.dart';
import 'package:pseudolearn_app/presentation/settings/widgets/settings_note.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/settings/theme/theme_settings_view.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

Widget _buildThemeSettingsTestApp({
  AppThemeMode selectedThemeMode = AppThemeMode.system,
  ValueChanged<AppThemeMode>? onThemeSelected,
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
      body: ThemeSettingsView(
        selectedThemeMode: selectedThemeMode,
        onThemeSelected: onThemeSelected ?? (_) {},
        onBack: onBack ?? () {},
      ),
    ),
  );
}

void main() {
  group('ThemeSettingsView Interaction Tests (PANT-05-F3)', () {
    testWidgets('Renders theme options', (tester) async {
      await tester.pumpWidget(_buildThemeSettingsTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Tema visual'), findsOneWidget);
      expect(find.text('Tema del sistema'), findsOneWidget);
      expect(find.text('Tema claro'), findsOneWidget);
      expect(find.text('Tema oscuro'), findsOneWidget);
    });

    testWidgets('Selecting an option invokes onThemeSelected callback', (tester) async {
      AppThemeMode? selected;
      await tester.pumpWidget(_buildThemeSettingsTestApp(
        onThemeSelected: (mode) => selected = mode,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(AppListItem, 'Tema oscuro'));
      await tester.pumpAndSettle();

      expect(selected, equals(AppThemeMode.dark));
    });

    testWidgets('Renders the explanatory note as its own labelled group', (tester) async {
      await tester.pumpWidget(_buildThemeSettingsTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Temas disponibles'), findsOneWidget);
      expect(find.text('Sobre este ajuste'), findsOneWidget);
      expect(find.byType(SettingsNote), findsOneWidget);
    });

    testWidgets('Back affordance invokes onBack', (tester) async {
      var returned = false;
      await tester.pumpWidget(_buildThemeSettingsTestApp(onBack: () => returned = true));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      expect(returned, isTrue);
    });

    testWidgets('Shares the page frame with the settings index', (tester) async {
      await tester.pumpWidget(_buildThemeSettingsTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(AppPage), findsOneWidget);
    });

    testWidgets('Wraps content in SafeArea to respect device notches and insets', (tester) async {
      await tester.pumpWidget(_buildThemeSettingsTestApp());
      await tester.pumpAndSettle();

      expect(find.descendant(of: find.byType(ThemeSettingsView), matching: find.byType(SafeArea)), findsOneWidget);
    });
  });
}
