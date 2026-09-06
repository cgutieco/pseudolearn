import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/components/layout/app_page.dart';
import 'package:pseudolearn_app/presentation/components/list/app_list_item.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/settings/diagram/diagram_settings_view.dart';
import 'package:pseudolearn_app/presentation/settings/widgets/settings_note.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

Widget _buildDiagramSettingsTestApp({
  bool isAssisted = true,
  ValueChanged<bool>? onAssistSelected,
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
      body: DiagramSettingsView(
        isAssisted: isAssisted,
        onAssistSelected: onAssistSelected ?? (_) {},
        onBack: onBack ?? () {},
      ),
    ),
  );
}

void main() {
  group('DiagramSettingsView', () {
    testWidgets('renders both behaviours and its explanatory note',
        (tester) async {
      await tester.pumpWidget(_buildDiagramSettingsTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Zoom asistido en diagramas'), findsOneWidget);
      expect(find.text('Seguir el paso activo'), findsOneWidget);
      expect(find.text('No mover el diagrama'), findsOneWidget);
      expect(find.text('Comportamiento al ejecutar paso a paso'), findsOneWidget);
      expect(find.text('Sobre este ajuste'), findsOneWidget);
      expect(find.byType(SettingsNote), findsOneWidget);
    });

    testWidgets('marks the behaviour in force', (tester) async {
      await tester.pumpWidget(_buildDiagramSettingsTestApp(isAssisted: false));
      await tester.pumpAndSettle();

      final marked = tester.widget<AppListItem>(
        find.widgetWithText(AppListItem, 'No mover el diagrama'),
      );
      final unmarked = tester.widget<AppListItem>(
        find.widgetWithText(AppListItem, 'Seguir el paso activo'),
      );

      expect(marked.selected, isTrue);
      expect(unmarked.selected, isFalse);
    });

    testWidgets('turning the assistance off reports the choice',
        (tester) async {
      bool? chosen;
      await tester.pumpWidget(_buildDiagramSettingsTestApp(
        onAssistSelected: (isAssisted) => chosen = isAssisted,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(AppListItem, 'No mover el diagrama'));
      await tester.pumpAndSettle();

      expect(chosen, isFalse);
    });

    testWidgets('turning the assistance back on reports the choice',
        (tester) async {
      bool? chosen;
      await tester.pumpWidget(_buildDiagramSettingsTestApp(
        isAssisted: false,
        onAssistSelected: (isAssisted) => chosen = isAssisted,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(AppListItem, 'Seguir el paso activo'));
      await tester.pumpAndSettle();

      expect(chosen, isTrue);
    });

    testWidgets('back affordance invokes onBack', (tester) async {
      var returned = false;
      await tester.pumpWidget(
        _buildDiagramSettingsTestApp(onBack: () => returned = true),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      expect(returned, isTrue);
    });

    testWidgets('shares the page frame with the settings index', (tester) async {
      await tester.pumpWidget(_buildDiagramSettingsTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(AppPage), findsOneWidget);
    });
  });
}
