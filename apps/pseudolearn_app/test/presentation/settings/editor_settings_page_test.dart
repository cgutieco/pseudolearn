import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/components/list/app_list_item.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/settings/editor/editor_settings_view.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

Widget _app({
  required bool isAssisted,
  required ValueChanged<bool> onAssistSelected,
  Locale locale = const Locale('es'),
}) {
  return MaterialApp(
    theme: AppTheme.light(),
    locale: locale,
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
      body: EditorSettingsView(
        isAssisted: isAssisted,
        onAssistSelected: onAssistSelected,
        onBack: () {},
      ),
    ),
  );
}

void main() {
  group('EditorSettingsView', () {
    testWidgets('renders both options in Spanish with the shortcut notice', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(isAssisted: false, onAssistSelected: (_) {}),
      );
      await tester.pumpAndSettle();

      expect(find.text('Asistencia de edición'), findsOneWidget);
      expect(find.text('Sugerir y completar al escribir'), findsOneWidget);
      expect(find.text('Solo cuando la pida'), findsOneWidget);
      expect(find.textContaining('Ctrl+Espacio'), findsOneWidget);
      final marked = tester.widget<AppListItem>(
        find.widgetWithText(AppListItem, 'Solo cuando la pida'),
      );
      expect(marked.selected, isTrue);
    });

    testWidgets('renders in English and reports the chosen option', (
      tester,
    ) async {
      bool? chosen;
      await tester.pumpWidget(
        _app(
          isAssisted: false,
          onAssistSelected: (value) => chosen = value,
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Suggest and complete while typing'));
      await tester.pumpAndSettle();

      expect(chosen, isTrue);
    });
  });
}
